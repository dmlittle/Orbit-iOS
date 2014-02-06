//
//  ORBCreatePlanet.h
//  Orbitz
//
//  Created by Donald Little on 1/21/14.
//  Copyright (c) 2014 Donald Little. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ORBCreatePlanet : SKSpriteNode

+ (id) spriteNode;
-(void)setStartPlanetCount:(int)planetCount;
-(BOOL)decreasePlanetCount;
-(BOOL)increasePlanetCount;
-(void)stopPlanetCreation;
-(BOOL)canCreatePlanet;
-(void)allowPlanetCreation;

@end
