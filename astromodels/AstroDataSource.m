/* Copyright(C): Leaf Johnson <leafjohn@gmail.com> 2012

    This file is part of iosswe

    leaf-app is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    leaf-app is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with leaf-app.  If not, see <http://www.gnu.org/licenses/>.


 * 
 * 
 */


//
//  AstroDataSource.m
//  starvision
//
//  Created by leaf johnson on 11-10-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "AstroDataSource.h"
#import "PersonInformation.h"
#import "Planet.h"
#import "House.h"
#import "Aspect.h"
#import <Foundation/NSBundle.h>
#import "swephexp.h"
#import "starmath.h"

static char s_sweErrStrMem[AS_MAXCH];
char *s_sweErrStr = s_sweErrStrMem;
NSString *AstroDataChangedNotify = @"AstroDataChangedNotification";

@interface AstroDataSource (private)
/*Calculate all planet and houses information*/
- (void) calc;
- (void) calcAspects; //must call in calc, after planets generated

@end

static NSInteger houseIdAdd (NSInteger houseId, NSInteger inc)
{
    NSInteger res = houseId + inc;
    while (res > 12) res -= 12;
    while (res < 1) res += 12;
    return res;
}

@implementation AstroDataSource

@synthesize houses = _houses;
@synthesize planets = _planets;
@synthesize aspects = _aspects;
@synthesize timeLocation = _timeLocation;
@synthesize autoRecalc = _autoRecalc;
@synthesize planetsIdOrdered = _planetsIdOrdered;
@synthesize interestedPlanetIds = _interestedPlanetIds;

- (id) initWithTimeLocation:(id<TimeLocation>)timeLocation
{   
    _autoRecalc = NO;
    /*Init swe library*/
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundlePath = [bundle resourcePath];
       
    swe_set_ephe_path((char *)[bundlePath UTF8String]);
    
    self.timeLocation = timeLocation;
    return self;
}


#define ELEM_SIZE(ary) (sizeof(ary) / sizeof(ary[0]))

- (void) setTimeLocation:(id<TimeLocation>)timeLocation
{
    if (timeLocation != nil) {
        _timeLocation = [timeLocation retain];
        if (self.autoRecalc) {
            [self calc];
        }
    }
}

- (void) recacl
{
    [self calc];
}

- (void) dealloc
{
    self.houses = nil;
    self.planets = nil;
    self.timeLocation = nil;

    [super dealloc];
}

#pragma mark - fancy methods

- (House *) locateInHouse: (double) angleOnHoroscope
{
    for (House *house in self.houses) {
        double diff = angle_regulate(angleOnHoroscope - house.cusp);
        if (diff >= 0 && diff < house.range) {
            return  house;
        }
    }
    
    NSAssert(0, @"No house suite for angle %.2f", angleOnHoroscope);
    return nil;    
}

- (NSArray *) aspectsFor: (Planet *) planet
{
    NSMutableArray *ma = [[[NSMutableArray alloc] initWithCapacity:3] autorelease];
    for (Aspect * aspect in self.aspects) {
        if (aspect.planetA == planet || aspect.planetB == planet) {
            [ma addObject:aspect];
        }
    }
    return [NSArray arrayWithArray:ma];
}

//NOTE the range is a half-close area, i.e. [start, start + span), exclues the start+span item
- (NSArray *) planetsInRangeFrom:(double) start span:(double) span
{
    NSMutableArray * ma = [NSMutableArray array];
    BOOL isInRange = NO;
    for (Planet *pl in self.planets) {
        double cspan = angle_regulate([pl angleOnHoroscope] - start);
        if (! isInRange) {
            if (cspan >= 0) {
                if (cspan < span) {
                    isInRange = YES;
                } else if ([pl angleOnHoroscope] > start) {
                    break;
                }
            }
        }
        if (isInRange) {
            if (cspan >= span) break;
            [ma addObject:pl];
        }
    }
    return [NSArray arrayWithArray:ma];
}

- (NSArray *) planetsInHouse: (House *) house
{
    return [self planetsInRangeFrom:[house cusp] span:[house range]];
}

- (NSArray *) planetsInZodiac: (NSInteger) zi
{
    return [self planetsInRangeFrom:zi * 30.0 span:30.0];
}

- (NSArray *) housesInZodiac: (NSInteger) zi
{
    NSMutableArray *ma = [NSMutableArray arrayWithCapacity:2];
    for (House *house in self.houses) {
        NSInteger czi = ((NSInteger)[house cusp]) / 30;
        if (czi == zi) {
            [ma addObject:house];
        }
    }
    return [NSArray arrayWithArray:ma];
}

@end

@implementation AstroDataSource(private)

- (Planet *) calcPlanet: (NSInteger) planetId withJulTime: (double) jultime andFlang:(NSUInteger) flag
{
    double result[6];
    int ret = swe_calc_ut(jultime, planetId, flag, result, s_sweErrStr);
    if (ret < 0) {
        NSLog(@"Swe Error :%s", s_sweErrStr);
        return nil;
    } else {
        //            swe_cotrans(result, transed, eps);
        Planet *planet = [Planet planetWithId:planetId andAngle:result[0]];
        return planet;
    }
}

- (Planet *) calcNorthNodesWithTime: (double) jultime andFlang:(NSUInteger) flag
{
    Planet *northNode = [self calcPlanet:SE_TRUE_NODE withJulTime:jultime andFlang:flag];
    northNode.planetId = PLID_NORTH_NODE;
    return northNode;
}

/*calc planets zodiac angle, and sort them by this angle in ascend order*/
- (void) calc
{
    double jultime = [self.timeLocation tjd_ut];
    static const NSUInteger IFLAG = SEFLG_SPEED | SEFLG_SWIEPH;
       
    NSMutableArray *activePlanetArray = [NSMutableArray arrayWithCapacity:[self.interestedPlanetIds count]]; /*+2 is for the asc and mc*/
    
    double result[6], eps;//, transed[3];
    swe_calc_ut (jultime, SE_ECL_NUT, 0, result, s_sweErrStr);
    eps = result[0];
    Planet *northNode = nil;
    
    for (NSNumber *plidNum in self.interestedPlanetIds) {
        NSInteger plid = [plidNum integerValue];
        if (plid < SP_ID_START) {
            Planet *planet = [self calcPlanet: plid withJulTime:jultime andFlang:IFLAG];
            if (planet != nil) [activePlanetArray addObject:planet];
        } else {
            if (plid == PLID_NORTH_NODE) {
                if (northNode == nil) {
                    northNode = [self calcNorthNodesWithTime:jultime andFlang:IFLAG];
                }
                [activePlanetArray addObject:northNode];
            } else if (plid == PLID_SOUTH_NODE) {
                if (northNode == nil) {
                    northNode = [self calcNorthNodesWithTime:jultime andFlang:IFLAG];
                }
                Planet *southNode = [Planet planetWithId:PLID_SOUTH_NODE andAngle: angle_regulate(northNode.angleOnHoroscope + 180.0)];
                [activePlanetArray addObject:southNode];
            } else {
                
            }
        }
    }
       
    /* calculate houses ans asc, mc */
    CLLocationCoordinate2D pos = [self.timeLocation coordinate];
    double cusps[13];
    double ascmc[10];
    swe_houses(jultime, pos.latitude, pos.longitude, 'P', cusps, ascmc);

    NSArray * ascMcPlanets = [NSArray arrayWithObjects: [Planet planetWithId:PLID_ASC andAngle:ascmc[0]],
        [Planet planetWithId:PLID_MC andAngle:ascmc[1]],
        [Planet planetWithId:PLID_DES andAngle:angle_regulate(ascmc[0] + 180.0)],
        [Planet planetWithId:PLID_IC andAngle:angle_regulate(ascmc[1] + 180.0)], nil];
    
    for (Planet *ascmcPl in ascMcPlanets) {
        if ([self.interestedPlanetIds containsObject:[NSNumber numberWithInteger:ascmcPl.planetId]]) {
            [activePlanetArray addObject:ascmcPl];
        }
    }
    
    self.planetsIdOrdered = [NSArray arrayWithArray:activePlanetArray];
    
    self.planets = [activePlanetArray sortedArrayUsingComparator:^(id a, id b) {
        Planet *p1 = a;
        Planet *p2 = b;
        if (p1.angleOnHoroscope < p2.angleOnHoroscope) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
    
    NSMutableArray *activeHouses = [NSMutableArray arrayWithCapacity:12];
    for (NSUInteger i = 1; i < ELEM_SIZE(cusps); ++i) {
        [activeHouses addObject: [House houseWithId:i cusp:cusps[i] range:(cusps[houseIdAdd(i, 1)] - cusps[i])]];
    }
    
    self.houses = [NSArray arrayWithArray:activeHouses];
    [self calcAspects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AstroDataChangedNotify object:self];
}

struct aspect_judge_entry 
{
    enum aspect_id aspectId;
    double minAngleDiff;
    double maxAngleDiff;
};

/*This list must be sorted by the center value, so we could optimize the find operation*/
static const struct aspect_judge_entry aspectJudgeTable[] = {
    {AspectConjunction, 0, 3.0},
    {AspectSexitile, 57.0, 63.0},
    {AspectSquare, 87.0, 93.0},
    {AspectTrine, 117.0, 123.0},
    {AspectOpposition, 177.0, 183.0},
    {AspectTrine, 237.0, 243.0},
    {AspectSquare, 267.0, 273.0},
    {AspectSexitile, 297.0, 303.0},
    {AspectConjunction, 357.0, 360.0},
};

- (BOOL) isAcceptableAspectWithPlanetId: (NSInteger) plid0 and: (NSInteger) plid1
{
    static const NSInteger skipPairs[][2] = {
        {PLID_IC, PLID_MC},
        {PLID_ASC, PLID_DES},
        {PLID_NORTH_NODE, PLID_SOUTH_NODE},
    };

    for (NSUInteger i = 0; i < sizeof(skipPairs) / sizeof(skipPairs[0]); ++i) {
        if ( (plid0 == skipPairs[i][0] && plid1 == skipPairs[i][1])
        || (plid1 == skipPairs[i][0] && plid0 == skipPairs[i][1]) ) {
            return NO;
        }
    }
    return YES;
}

/*calc aspects*/
- (void) calcAspects
{
    //since the self.planets is sorted list, we could use this feature
    NSInteger nJudgeEntry = ELEM_SIZE(aspectJudgeTable);
    NSMutableArray *aspects = [NSMutableArray array];
    
    for (NSInteger aIdx = 0; aIdx < [self.planets count]; ++aIdx) {
        double aAngle = [[self.planets objectAtIndex:aIdx] angleOnHoroscope];
        NSInteger judgeIdx = 0;
        for (NSInteger bIdx = aIdx + 1; bIdx < [self.planets count]; ++bIdx) {
            Planet *planetB = [self.planets objectAtIndex:bIdx];
            double diff = planetB.angleOnHoroscope - aAngle;
            for (;judgeIdx < nJudgeEntry; ++judgeIdx) {
                if (diff < aspectJudgeTable[judgeIdx].minAngleDiff) break;
                if (diff > aspectJudgeTable[judgeIdx].maxAngleDiff) continue;

                Planet * planetA = [self.planets objectAtIndex:aIdx];
                if ([self isAcceptableAspectWithPlanetId:planetA.planetId and:planetB.planetId]) {
                    [aspects addObject:[Aspect aspectWithId:aspectJudgeTable[judgeIdx].aspectId
                                                planetA:planetA
                                                planetB:planetB]];
                }
                break;
            }
            if (judgeIdx >= nJudgeEntry) break;            
        }
    }
    self.aspects = [NSArray arrayWithArray:aspects];
}



@end