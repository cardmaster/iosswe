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
//  Planet.m
//  starvision
//
//  Created by leaf johnson on 11-11-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "Planet.h"
#import "swephexp.h"

@implementation Planet (text) 

+ (NSString *) planetName:(NSInteger)planetId
{
    return [Planet planetNameLatin:planetId];
}

+ (NSString *) planetNameLatin:(NSInteger)planetId
{
    switch (planetId) {
        /*Just return the ascii name strings*/
        case PLID_ASC: return @"Asc";
        case PLID_MC: return @"Mc";
        case PLID_DES: return @"Des";
        case PLID_IC: return @"Ic";
        case PLID_NORTH_NODE: return @"NorthNode";
        case PLID_SOUTH_NODE: return @"SouthNode";
        default: {
            char swename[40];
            swe_get_planet_name(planetId, swename);
            return [NSString stringWithCString:swename encoding:NSASCIIStringEncoding];
        }
    }
}

@end

@implementation Planet

@synthesize angleOnHoroscope = _angleOnHoroscope;
@synthesize planetId = _planetId;
@synthesize name = _name;

+ (id) planetWithId:(NSInteger)planetId andAngle:(double)angleOnPlate
{
    return [[Planet alloc] initWithId: planetId andAngle: angleOnPlate];
}

- (id) initWithId:(NSInteger)planetId andAngle:(double)angleOnPlate
{
    self = [super init];
    self.planetId = planetId;
    self.angleOnHoroscope = angleOnPlate;
    self.name = [Planet planetName:planetId];
    return self;
}

- (void) dealloc
{
    self.name = nil;
    [super dealloc];
}

@end
