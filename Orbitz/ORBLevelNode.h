//
//  ORBLevel.h
//  Orbitz
//
//  Created by Donald Little on 1/16/14.
//  Copyright (c) 2014 Donald Little. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface ORBLevelNode : SKSpriteNode

- (void) setLocked:(BOOL)locked;
- (BOOL) isLocked;

@end
