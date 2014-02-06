//
//  ORBStarCount.h
//  Orbitz
//
//  Created by Donald Little on 1/28/14.
//  Copyright (c) 2014 Donald Little. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ORBStarCount : SKSpriteNode

+ (id) spriteNode;
-(NSNumber *)getStarCount;
-(void)addStar;
-(void)resetCount;

@end
