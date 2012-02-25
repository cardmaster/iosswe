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
//  Aspect.m
//  starvision
//
//  Created by leaf johnson on 11-12-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "Aspect.h"

@implementation Aspect

@synthesize aspectId = _aspectId;
@synthesize planetA = _planetA;
@synthesize planetB = _planetB;

+ (Aspect *) aspectWithId: (enum aspect_id) id planetA:(Planet *) planetA planetB:(Planet *) planetB
{
    Aspect *aspect = [[[Aspect alloc] init] autorelease];
    aspect.aspectId = id;
    aspect.planetA = planetA;
    aspect.planetB = planetB;
    
    return aspect;
}

- (void) dealloc
{
    self.planetA = nil;
    self.planetB = nil;
    [super dealloc];
}

@end

@implementation Aspect(text)

static NSString * s_AspectNameMap [] = {
    @"",
    @"Conjunction",
    @"Opposition",
    @"Trine",
    @"Sexitile",
    @"Square",
};

- (NSString *) aspectName
{
    return s_AspectNameMap[self.aspectId];
}

@end