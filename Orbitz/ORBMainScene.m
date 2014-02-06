//
//  ORBMainScene.m
//  Orbitz
//
//  Created by Donald Little on 1/11/14.
//  Copyright (c) 2014 Donald Little. All rights reserved.
//

#import "ORBMainScene.h"
#import "ORBGameScene.h"
#import "ORBLevelNode.h"
@import AVFoundation;

@interface ORBMainScene()

@property (nonatomic, strong) SKSpriteNode *background;
@property (nonatomic) SKSpriteNode *gameLogo;
@property (nonatomic) SKSpriteNode *playBtn;
@property (nonatomic) SKSpriteNode *optionsBtn;
@property (nonatomic) SKSpriteNode *muteBtn;
@property (nonatomic) NSMutableArray *levels;
@property (nonatomic) NSMutableArray *options;
@property (nonatomic) AVAudioPlayer * backgroundMusicPlayer;

@property (nonatomic) enum screenState screenState;
@property (strong, nonatomic) UISwipeGestureRecognizer* swipeRightGesture;
@property (strong, nonatomic) UISwipeGestureRecognizer* swipeLeftGesture;



@end


@implementation ORBMainScene

enum screenState {MAIN_SCREEN = 0, LEVEL_SCREEN, OPTION_SCREEN};

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.view.paused = NO;
        
        // Space Background and SKEmitters
        [self addBackground];
        [self addSpaceEffect];
        [self addSmokeEffect];
        
        // Music
        [self addSoundEffect];
        [[self backgroundMusicPlayer] play];

        
        // Logo
        SKTexture *gameTitleTexture = [SKTexture textureWithImageNamed:@"orbit-logo"];
        _gameLogo = [SKSpriteNode spriteNodeWithTexture:gameTitleTexture ];
        [_gameLogo setName:@"gameLogo"];
        [_gameLogo setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.75)];
        [self addChild:_gameLogo];
        
        // Play Button
        SKTexture *playBtnTexture = [SKTexture textureWithImageNamed:@"play_button"];
        _playBtn = [SKSpriteNode spriteNodeWithTexture:playBtnTexture ];
        [_playBtn setPosition:CGPointMake(CGRectGetMidX(self.frame)-100, 120)];
        [_playBtn setName:@"playButton"];
        [self addChild:_playBtn];

        // Options Button
        SKTexture *optionsBtnTexture = [SKTexture textureWithImageNamed:@"options_button"];
        _optionsBtn = [SKSpriteNode spriteNodeWithTexture:optionsBtnTexture ];
        [_optionsBtn setPosition:CGPointMake(CGRectGetMidX(self.frame)+100, 120)];
        [_optionsBtn setName:@"optionsButton"];
        [self addChild:_optionsBtn];
        
        // Options Button
        SKTexture *muteBtnTexture = [SKTexture textureWithImageNamed:@"not_mute_button"];
        _muteBtn = [SKSpriteNode spriteNodeWithTexture:muteBtnTexture ];
        [_muteBtn setPosition:CGPointMake(CGRectGetMaxX(self.frame)-25, CGRectGetMaxY(self.frame)-25)];
        [_muteBtn setName:@"muteButton"];
        [self addChild:_muteBtn];

        // Levels
        [self addLevels];
        [self addOptionMenu];

        // Set screen state
        _screenState = MAIN_SCREEN;

    }
    
    return self;
}

- (void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    
    // Add GestureRecognizer to allow swap to select menu arrangement
    _swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                   action:@selector( moveToRight)];
    [_swipeRightGesture setDirection: UISwipeGestureRecognizerDirectionRight];
    _swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                   action:@selector( moveToLeft)];
    
    [_swipeLeftGesture setDirection: UISwipeGestureRecognizerDirectionLeft];

    [self.view addGestureRecognizer: _swipeRightGesture];
    [self.view addGestureRecognizer: _swipeLeftGesture];
}

-(void)addBackground {
    
    // Create and position background
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    [_background setPosition:CGPointZero];
    [_background setAnchorPoint:CGPointZero];
        
    // Add background
    [self addChild:_background];

}

-(void)addSpaceEffect {
    
    //Create space shimmering
    NSString *spaceEffectPath = [[NSBundle mainBundle] pathForResource:@"space" ofType:@"sks"];
    SKEmitterNode *spaceEffect = [NSKeyedUnarchiver unarchiveObjectWithFile:spaceEffectPath];
    [spaceEffect setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))];
    
    // Add effects
    [self addChild:spaceEffect];

}

-(void)addSmokeEffect {
    
    // Create smoke effect
    NSString *smokeEffectPath = [[NSBundle mainBundle] pathForResource:@"smoke" ofType:@"sks"];
    SKEmitterNode *smokeEffectTop = [NSKeyedUnarchiver unarchiveObjectWithFile:smokeEffectPath];
    SKEmitterNode *smokeEffectBottom = [NSKeyedUnarchiver unarchiveObjectWithFile:smokeEffectPath];
    [smokeEffectBottom setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMinY(self.frame)-25)];
    [smokeEffectTop setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)+15)];
    [smokeEffectTop setYAcceleration:-5.0f];
    [smokeEffectTop setParticleSpeed:-10.0f];
    [smokeEffectTop setParticleSpeedRange:-2.0f];
    [smokeEffectTop setParticleAlpha:0.125f];
    
    // Add effects
    [self addChild:smokeEffectBottom];
    [self addChild:smokeEffectTop];

}

-(void)addSoundEffect {
    
    // Create background audio player
    NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"main-soundtrack" withExtension:@"mp3"];
    NSError *error;
    [self setBackgroundMusicPlayer:[[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL
                                                                          error:&error]];
    [[self backgroundMusicPlayer] setNumberOfLoops:-1];
    [[self backgroundMusicPlayer] prepareToPlay];


}

-(void)addLevels {

    // Levels Screen Array Init
    _levels = [[NSMutableArray alloc] init];
    
    // Load level data
    NSArray *levelInfoArray =  [[NSUserDefaults standardUserDefaults] objectForKey:@"levels"];

    // Level Display Settings
    static int imgOffset = 5;
    static int imgWidth = 125;
    int imgCount = 0;
    
    for (NSDictionary *level in levelInfoArray) {
        NSNumber *isDisplayed = (NSNumber *)[level objectForKey: @"display"];
        if (isDisplayed && [isDisplayed boolValue] == YES) {
            imgCount++;
        }
    }
    
    float coordX;
    if (imgCount % 2 == 0) {
        // count is Even
        coordX = -CGRectGetMidX(self.frame) - ((imgCount/2)-.5) * imgWidth/2 - ((imgCount/2)-.5) * imgOffset;

    } else {
        // count is Odd
        coordX = -CGRectGetMidX(self.frame) - (imgCount/2) * (imgWidth/2 + imgOffset);
  }
    
    
    for (NSDictionary *level in levelInfoArray) {
        
        NSNumber *isDisplayed = (NSNumber *)[level objectForKey: @"display"];
        
        // Only display the levels who's settings allow them to be displayed
        if (isDisplayed && [isDisplayed boolValue] == YES) {
            
            NSString *imgname = (NSString *)[level objectForKey:@"image"];
            
            // Change Image name with respect to the number of stars that have been unlocked
            if (![[level objectForKey:@"name"] isEqualToString:@"tutorial"] && [[level objectForKey:@"locked"] isEqualToString:@"NO"]) {
                imgname = [[imgname stringByAppendingString:@"_"] stringByAppendingString:[[level objectForKey:@"stars"] description]];
            }
            
            ORBLevelNode *levelSprite = [ORBLevelNode spriteNodeWithImageNamed:imgname];
            [levelSprite setPosition:CGPointMake(coordX, 115)];
            [levelSprite setName:(NSString *)[level objectForKey:@"name"]];
            
            // Lock level if necessary
            if ([[level objectForKey:@"locked"] isEqualToString:@"YES"]) {
                [levelSprite setAlpha:0.25];
                [levelSprite setLocked:YES];
            } else {
                [levelSprite setLocked:NO];
            }
            
            [_levels addObject:levelSprite];
            [self addChild:levelSprite];
            
            // Set next level coordinates
            coordX += imgWidth/2 + imgOffset;
        }
    }

    
    // Information Label
    SKLabelNode *levelLabel = [[SKLabelNode alloc] init];
    [levelLabel setText:@"Select Level:"];
    [levelLabel setFontSize:20.0f];
    [levelLabel setFontName:@"Copperplate-Light"];
    [levelLabel setAlpha:0.55f];
    [levelLabel setPosition:CGPointMake(CGRectGetMidX(self.frame)-CGRectGetMaxX(self.frame), 150)];
    

    // Menu Navegation
    SKSpriteNode *moveRight = [SKSpriteNode spriteNodeWithImageNamed:@"move_right"];
    [moveRight setName:@"moveRight"];
    [moveRight setPosition:CGPointMake(-25, 115)];
    
    [_levels addObject:levelLabel];
    [_levels addObject:moveRight];
    
    [self addChild:levelLabel];
    [self addChild:moveRight];
    
}

-(void)addOptionMenu {
    
    _options = [[NSMutableArray alloc] init];
    
    
    // Options Label Button
    SKLabelNode *label = [[SKLabelNode alloc] init];
    [label setPosition:CGPointMake(CGRectGetMidX(self.frame)+CGRectGetMaxX(self.frame), 130)];
    [label setText:@"Reset Tutorial"];
    [label setName:@"resetTutorial"];
    [label setAlpha:0.55f];
    [label setFontName:@"Copperplate-Light"];
    [label setFontSize:25.0f];
    
    // Create Recangle Path
    UIBezierPath* labelOutlineBezierPath = [[UIBezierPath alloc] init];
    [labelOutlineBezierPath moveToPoint:CGPointMake(0.0, 0.0)];
    [labelOutlineBezierPath addLineToPoint:CGPointMake(240, 0.0)];
    [labelOutlineBezierPath addLineToPoint:CGPointMake(240, 30.0)];
    [labelOutlineBezierPath addLineToPoint:CGPointMake(0, 30.0)];
    [labelOutlineBezierPath addLineToPoint:CGPointMake(0, 0)];

    // Create Outline foor Button
    SKShapeNode* labelOutline = [SKShapeNode node];
    [labelOutline setPath:[labelOutlineBezierPath CGPath]];
    [labelOutline setName:@"resetTutorial"];
    [labelOutline setLineWidth:1.0f];
    [labelOutline setAlpha:0.35f];
    [labelOutline setAntialiased:NO];
    [labelOutline setPosition:CGPointMake(CGRectGetMidX(self.frame)-120+CGRectGetMaxX(self.frame), 122)];
   
    // Menu Navegation
    SKSpriteNode *moveLeft = [SKSpriteNode spriteNodeWithImageNamed:@"move_left"];
    [moveLeft setName:@"moveLeft"];
    [moveLeft setPosition:CGPointMake(CGRectGetMaxX(self.frame)+35, 115)];

    [_options addObject:label];
    [_options addObject:labelOutline];
    [_options addObject:moveLeft];
    
    [self addChild:label];
    [self addChild:labelOutline];
    [self addChild:moveLeft];
}


-(void)toggleBackgroundMusic {
    if(self.backgroundMusicPlayer.isPlaying) {
        SKTexture *muteBtnTexture = [SKTexture textureWithImageNamed:@"mute_button"];
        [_muteBtn setTexture:muteBtnTexture];
        [self.backgroundMusicPlayer stop];
    } else {
        [self.backgroundMusicPlayer play];
        SKTexture *notMuteBtnTexture = [SKTexture textureWithImageNamed:@"not_mute_button"];
        [_muteBtn setTexture:notMuteBtnTexture];

    }
}

-(void)moveToRight {
    // Move the scene to the right to reveal new screen contents if possible
    if (_screenState != LEVEL_SCREEN) {
        SKAction *moveRight = [SKAction moveByX:CGRectGetMaxX(self.frame) y:0 duration:0.25];
    
        [_playBtn runAction: moveRight];
        [_optionsBtn runAction: moveRight];
        
        
        for (SKSpriteNode *level in _levels) {
            [level runAction:moveRight];
        }
        
        for (SKNode *optionNode in _options) {
            [optionNode runAction:moveRight];
        }

        
        if (_screenState == MAIN_SCREEN) {
            _screenState = LEVEL_SCREEN;
        } else if (_screenState == OPTION_SCREEN) {
            _screenState = MAIN_SCREEN;
        }
        
    }
}

-(void)moveToLeft {
    // Move the scene to the left to reveal new screen contents if possible
    if (_screenState != OPTION_SCREEN) {
        SKAction *moveLeft = [SKAction moveByX:-CGRectGetMaxX(self.frame) y:0 duration:0.25];
        
        [_playBtn runAction: moveLeft];
        [_optionsBtn runAction: moveLeft];
        
        
        for (SKSpriteNode *level in _levels) {
            [level runAction:moveLeft];
        }
        
        for (SKNode *optionNode in _options) {
            [optionNode runAction:moveLeft];
        }

        
        if (_screenState == MAIN_SCREEN) {
            _screenState = OPTION_SCREEN;
        } else if (_screenState == LEVEL_SCREEN) {
            _screenState = MAIN_SCREEN;
        }
        
    }
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */

    for (UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInNode:self];
        
        SKNode *node = [self nodeAtPoint:touchLocation];
        
        if ([node.name isEqualToString:@"playButton"]) {
            SKAction *zoomIn = [SKAction scaleTo:1.0625 duration:0.0625];
            SKAction *zoomOut = [SKAction scaleTo:1.0 duration:0.0625];
       
            SKAction *sequence = [SKAction sequence:@[zoomIn, zoomOut]];
            [_playBtn runAction: sequence completion:^{
                [self moveToRight];
            }];

        } else if ([node.name isEqualToString:@"optionsButton"]){
            SKAction *zoomIn = [SKAction scaleTo:1.0625 duration:0.0625];
            SKAction *zoomOut = [SKAction scaleTo:1.0 duration:0.0625];
            
            SKAction *sequence = [SKAction sequence:@[zoomIn, zoomOut]];
            [node runAction: sequence completion:^{
                [self moveToLeft];
            }];
        } else if ([node.name isEqualToString:@"muteButton"]) {
            [self toggleBackgroundMusic];
        } else if ([node.name isEqualToString:@"moveRight"]) {
            [self moveToLeft];
        } else if ([node.name isEqualToString:@"moveLeft"]) {
            [self moveToRight];
        } else if ([node.name isEqualToString:@"resetTutorial"]) {
            
            NSArray *levelInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"levels"];
            NSMutableArray *levelInfoMutable = [levelInfo mutableCopy];
            NSDictionary *levelDictionary = [levelInfo objectAtIndex:0];
            NSMutableDictionary *levelDictionaryMutable = [levelDictionary mutableCopy];
            
            [levelDictionaryMutable setObject:@"YES" forKey:@"display"];
            [levelInfoMutable replaceObjectAtIndex:0 withObject:levelDictionaryMutable];
            [[NSUserDefaults standardUserDefaults] setObject:levelInfoMutable forKey:@"levels"];
        
            SKTransition *reveal = [SKTransition fadeWithDuration:1.0];
            SKScene *scene = [[ORBMainScene alloc] initWithSize:self.size];
            [self.view removeGestureRecognizer:_swipeLeftGesture];
            [self.view removeGestureRecognizer:_swipeRightGesture];
            [self.view presentScene:scene transition: reveal];

            
        
        } else if ([node.name isEqualToString:@"tutorial"]) {
            SKAction *zoomIn = [SKAction scaleTo:1.125 duration:0.125];
            SKAction *zoomOut = [SKAction scaleTo:1.0 duration:0.125];
            
            SKAction *sequence = [SKAction sequence:@[zoomIn, zoomOut]];
            [node runAction:sequence completion:^{
                SKTransition *reveal = [SKTransition fadeWithDuration:1.0];
                SKScene *tutorialScene = [[ORBGameScene alloc] initWithSize:self.size andLevel:@"tutorial_1" andFile:@"levels"];
                [self.view removeGestureRecognizer:_swipeLeftGesture];
                [self.view removeGestureRecognizer:_swipeRightGesture];
                [self.view presentScene:tutorialScene transition: reveal];
                
            }];

        } else if ([node.name rangeOfString:@"level"].length != 0) {
            ORBLevelNode *levelNode = (ORBLevelNode *) node;
            SKAction *zoomIn = [SKAction scaleTo:1.125 duration:0.125];
            SKAction *zoomOut = [SKAction scaleTo:1.0 duration:0.125];
            SKAction *moveLeft = [SKAction moveByX:-2.0f y:0 duration:0.03125];
            SKAction *moveRight = [SKAction moveByX:2.0f y:0 duration:0.03125];

            SKAction *availableSequence = [SKAction sequence:@[zoomIn, zoomOut]];
            SKAction *lockedSound = [SKAction playSoundFileNamed:@"beep_no_access.mp3" waitForCompletion:NO];
            SKAction *lockedSequence = [SKAction sequence:@[moveLeft, moveRight, moveRight, moveLeft, moveLeft, moveRight]];
            SKAction *lockedGroup = [SKAction group:@[lockedSound, lockedSequence]];
            
            if ([levelNode isLocked]) {
                [levelNode runAction: lockedGroup];
            } else {

                [node runAction: availableSequence];
                
                SKAction *fadeLocked = [SKAction fadeAlphaTo:0.25 duration:0.5];
                SKTransition *reveal = [SKTransition fadeWithDuration:1.0];
                
                [self.view removeGestureRecognizer:_swipeLeftGesture];
                [self.view removeGestureRecognizer:_swipeRightGesture];


                if ([node.name isEqualToString:@"level1"]) {
                    [node runAction: fadeLocked completion:^{

                        SKScene *level1 = [[ORBGameScene alloc] initWithSize:self.size andLevel:@"level_1" andFile:@"levels"];
                        [self.view presentScene:level1 transition: reveal];
                    
                    }];
                } else  if ([node.name isEqualToString:@"level2"]) {
                    [node runAction: fadeLocked completion:^{
                        
                        SKScene *level2 = [[ORBGameScene alloc] initWithSize:self.size andLevel:@"level_2" andFile:@"levels"];
                        [self.view presentScene:level2 transition: reveal];
                        
                    }];
                } else  if ([node.name isEqualToString:@"level3"]) {
                    [node runAction: fadeLocked completion:^{
                        
                        SKScene *level3 = [[ORBGameScene alloc] initWithSize:self.size andLevel:@"level_3" andFile:@"levels"];
                        [self.view presentScene:level3 transition: reveal];
                        
                    }];
                } else  if ([node.name isEqualToString:@"level4"]) {
                    [node runAction: fadeLocked completion:^{
                        
                        SKScene *level4 = [[ORBGameScene alloc] initWithSize:self.size andLevel:@"level_4" andFile:@"levels"];
                        [self.view presentScene:level4 transition: reveal];
                        
                    }];
                } else  if ([node.name isEqualToString:@"level5"]) {
                    [node runAction: fadeLocked completion:^{
                        
                        SKScene *level5 = [[ORBGameScene alloc] initWithSize:self.size andLevel:@"level_5" andFile:@"levels"];
                        [self.view presentScene:level5 transition: reveal];
                        
                    }];
                }
                
            }
            
            
        }
        
    }
}

@end
