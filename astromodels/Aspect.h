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
//  Aspect.h
//  starvision
//
//  Created by leaf johnson on 11-12-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum aspect_id
{
    NoAspect,
    AspectConjunction, //0
    AspectOpposition, //180
    AspectTrine,  //120
    AspectSexitile, //90
    AspectSquare, //60
};

@class Planet;
@interface Aspect : NSObject

@property (assign) enum aspect_id aspectId;
@property (nonatomic, retain) Planet *planetA;
@property (nonatomic, retain) Planet *planetB;

+ (Aspect *) aspectWithId: (enum aspect_id) id planetA:(Planet *) planetA planetB:(Planet *) planetB;

@end

@interface Aspect(text)
- (NSString *) aspectName;
@end