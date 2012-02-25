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
//  Planet.h
//  starvision
//
//  Created by leaf johnson on 11-11-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SP_ID_START 0xFF00
enum PlanetId {
    PLID_SUN = 0,
    PLID_MOON = 1,
    PLID_MERCURY = 2,
    PLID_VENUS =  3,
    PLID_MARS =   4,
    PLID_JUPITER = 5,
    PLID_SATURN = 6,
    PLID_URANUS = 7,
    PLID_NEPTUNE = 8,
    PLID_PLUTO =  9,
    PLID_EARTH =  14,
    PLID_CHIRON = 15, 
    PLID_PHOLUS = 16,
    PLID_CERES =  17, 
    PLID_PALLAS = 18,   
    PLID_JUNO = 19,    
    PLID_VESTA = 20,
//*=======================================    
    PLID_ASC = SP_ID_START,
    PLID_MC,
    PLID_DES,
    PLID_IC,
    PLID_NORTH_NODE,
    PLID_SOUTH_NODE
};

@interface Planet : NSObject

@property double angleOnHoroscope;
@property NSInteger planetId;
@property (nonatomic, retain) NSString * name;

+ (id) planetWithId: (NSInteger) planetId andAngle: (double) angleOnPlate;
- (id) initWithId: (NSInteger) planetId andAngle: (double) angleOnPlate;

@end

@interface Planet (text)

+ (NSString *) planetName: (NSInteger) planetId;
+ (NSString *) planetNameLatin: (NSInteger) planetId;

@end