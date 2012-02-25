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
//  House.h
//  starvision
//
//  Created by leaf johnson on 11-11-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface House : NSObject

@property NSUInteger houseId; /*value range 1~12, stands for house 1 ~ 12*/
@property double cusp; /*The house start*/
@property double range; /*The span of a house*/
@property (nonatomic, retain) NSString *name;

+ (id) houseWithId: (NSInteger) hid cusp: (double) cusp range: (double) range;
- (id) initWithId: (NSInteger) hid cusp: (double) cusp range:(double) range;
- (bool) contains: (double) angleOnPlate;

@end

House * locateInHouse (NSArray *houses, double angleOnPlate);

@interface House (text)

+ (NSString *) houseName: (NSInteger) houseId;

@end
