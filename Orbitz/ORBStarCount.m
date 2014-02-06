//
//  ORBStarCount.m
//  Orbitz
//
//  Created by Donald Little on 1/28/14.
//  Copyright (c) 2014 Donald Little. All rights reserved.
//

#import "ORBStarCount.h"

@interface ORBStarCount()

@property (nonatomic) int maxStarCount;
@property (nonatomic) int starCount;
@property (nonatomic, strong) NSArray *starTexture;

@end


@implementation ORBStarCount

+(id)spriteNode {
    
    ORBStarCount *star = [super spriteNodeWithImageNamed:@"star_count_0"];
    star.starCount = 0;
    SKTexture *texture0 = [SKTexture textureWithImageNamed:@"star_count_0"];
    SKTexture *texture1 = [SKTexture textureWithImageNamed:@"star_count_1"];
    SKTexture *texture2 = [SKTexture textureWithImageNamed:@"star_count_2"];
    SKTexture *texture3 = [SKTexture textureWithImageNamed:@"star_count_3"];
    star.starTexture = @[texture0, texture1, texture2, texture3];
    
    return star;
}


-(NSNumber *)getStarCount {
    return  [NSNumber numberWithInt:_starCount];
}

-(void)addStar {
    if (_starCount < 3) {
        _starCount++;
        self.texture = _starTexture[_starCount];
    }
}
-(void)resetCount {
    _starCount = 0;
    self.texture = _starTexture[0];

}



@end
