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
//  House.m
//  starvision
//
//  Created by leaf johnson on 11-11-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "House.h"
#import "starmath.h"

@implementation House

@synthesize houseId = _houseId;
@synthesize cusp = _cusp;
@synthesize range = _range;
@synthesize name = _name;

+ (id) houseWithId: (NSInteger) hid cusp: (double) cusp range: (double) range
{
    return [[House alloc] initWithId:hid cusp:cusp range:range];
}

- (id) initWithId: (NSInteger) hid cusp: (double) cusp range:(double) range
{
    self = [super init];
    self.cusp = angle_regulate(cusp);
    self.range = angle_regulate(range);
    self.houseId = hid;
    self.name = [House houseName:hid];
    
    return self;
}

- (void) dealloc
{
    self.name = nil;
    [super dealloc];
}

- (bool) contains: (double) angleOnPlate
{
    for (NSInteger i = 0; i < 2; ++i) {
        if (angleOnPlate >= self.cusp && angleOnPlate < (self.cusp + self.range)) {
            return true;
        }
        angleOnPlate += 360.0;
    }
    
    return false;
}

@end

House * locateInHouse (NSArray *houses, double angleOnPlate)
{
    double achk = angle_regulate(angleOnPlate);
    for (House *house in houses) {
        if ( [house contains:achk] ){
            return house;
        }
    }
    return nil;
}

@implementation House(text)

+ (NSString *) houseName:(NSInteger)houseId
{
    return [NSString stringWithFormat:@"House %d", houseId];
}

@end
