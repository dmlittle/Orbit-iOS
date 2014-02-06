//
//  ORBLevel.m
//  Orbitz
//
//  Created by Donald Little on 1/16/14.
//  Copyright (c) 2014 Donald Little. All rights reserved.
//

#import "ORBLevelNode.h"

@interface ORBLevelNode()

@property (nonatomic) BOOL locked;

@end

@implementation ORBLevelNode

- (void) setLocked:(BOOL)locked {
    _locked = locked;
}

- (BOOL) isLocked {
    return _locked;
}
@end
