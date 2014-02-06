//
//  ORBCreatePlanet.m
//  Orbitz
//
//  Created by Donald Little on 1/21/14.
//  Copyright (c) 2014 Donald Little. All rights reserved.
//

#import "ORBCreatePlanet.h"

@interface ORBCreatePlanet()

@property (nonatomic) int maxPlanetCount;
@property (nonatomic) int planetCount;
@property (nonatomic) BOOL allowedToCreate;
@property (nonatomic, strong) NSArray *planetTexture;

@end

@implementation ORBCreatePlanet

+(id)spriteNode {
    ORBCreatePlanet *createPlanet = [super spriteNodeWithImageNamed:@"planet_number_0"];
    createPlanet.planetCount = 0;
    createPlanet.allowedToCreate = YES;
    SKTexture *texture0 = [SKTexture textureWithImageNamed:@"planet_number_0"];
    SKTexture *texture1 = [SKTexture textureWithImageNamed:@"planet_number_1"];
    SKTexture *texture2 = [SKTexture textureWithImageNamed:@"planet_number_2"];
    SKTexture *texture3 = [SKTexture textureWithImageNamed:@"planet_number_3"];
    SKTexture *texture4 = [SKTexture textureWithImageNamed:@"planet_number_4"];
    SKTexture *texture5 = [SKTexture textureWithImageNamed:@"planet_number_5"];
    SKTexture *texture6 = [SKTexture textureWithImageNamed:@"planet_number_6"];
    SKTexture *texture7 = [SKTexture textureWithImageNamed:@"planet_number_7"];
    createPlanet.planetTexture = @[texture0, texture1, texture2, texture3,
                                   texture4, texture5, texture6, texture7];
    
    return createPlanet;
}


-(void)setStartPlanetCount:(int)planetCount {
    _planetCount = planetCount;
    _maxPlanetCount = planetCount;
    self.texture = _planetTexture[_planetCount];
}

-(BOOL)decreasePlanetCount {
    if (_planetCount > 0) {
        _planetCount--;
        self.texture = _planetTexture[_planetCount];
        return TRUE;
    }
    return FALSE;
}

-(BOOL)increasePlanetCount {
    if (_planetCount+1 <= _maxPlanetCount) {
        _planetCount++;
        self.texture = _planetTexture[_planetCount];
        return TRUE;
    }
    return FALSE;
}

-(void)stopPlanetCreation {
    _allowedToCreate = NO;
}

-(void)allowPlanetCreation {
    _allowedToCreate = YES;
}


-(BOOL)canCreatePlanet {
    return _planetCount > 0 && _allowedToCreate;
}

@end
