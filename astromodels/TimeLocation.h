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
//  TimeLocation.h
//  starvision
//
//  Created by leaf johnson on 11-10-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSValue.h>
#import <CoreLocation/CoreLocation.h>

@protocol TimeLocation <NSObject>

- (CLLocationCoordinate2D) coordinate;
- (double) tjd_ut; //use a 64-bit float to present a time value;
- (NSDate *) date;

@end
