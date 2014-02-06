//
//  ORBTestingScene.m
//  Orbitz
//
//  Created by Donald Little on 1/25/14.
//  Copyright (c) 2014 Donald Little. All rights reserved.
//

#import "ORBGameScene.h"
#import "ORBMainScene.h"
#import "ORBCreatePlanet.h"
#import "ORBStarCount.h"
#import "CGMath.h"

@interface ORBGameScene()

@property (nonatomic, strong) NSString *levelName;
@property (nonatomic, strong) NSString *fileName;

@property (nonatomic, strong) SKSpriteNode *map;

@property (nonatomic, strong) SKLabelNode *pausedLabel;
@property (nonatomic, strong) SKLabelNode *mainMenuLabel;

@property (nonatomic, strong) SKLabelNode *levelFailed;
@property (nonatomic, strong) SKLabelNode *levelSuccess;


@property (nonatomic, strong) SKSpriteNode *spaceship;
@property (nonatomic, strong) SKSpriteNode *spaceshipCopy;
@property (nonatomic, strong) NSMutableArray *planets;
@property (nonatomic, strong) NSMutableArray *draggable;
@property (nonatomic, strong) NSMutableArray *eraseable;
@property (nonatomic, strong) NSMutableArray *stars;

@property (nonatomic, strong) ORBCreatePlanet *planetCount;
@property (nonatomic, strong) ORBStarCount *starCount;

@property (nonatomic, strong) SKNode *selected;

@property (nonatomic) BOOL hasStarted;
@property (nonatomic) BOOL shot;
@property (nonatomic) SKSpriteNode *startBtn;

@property (nonatomic, strong) SKEmitterNode *goal;

@property (nonatomic, strong) SKSpriteNode *background;
@property (nonatomic) SKSpriteNode *redoBtn;
@property (nonatomic) SKSpriteNode *pauseBtn;

@property  (nonatomic, strong) UIPinchGestureRecognizer *pinchRecognizer;
@property  (nonatomic) CGPoint mapPoint;
@property  (nonatomic) CGFloat mapScale;

@end

@implementation ORBGameScene

// Collision-mask categories
static const uint32_t spaceshipCategory     =  0x1 << 0;
static const uint32_t goalCategory          =  0x1 << 1;
static const uint32_t starCategory          =  0x1 << 2;


-(id)initWithSize:(CGSize)size andLevel:(NSString *) level andFile:(NSString *) file {
    
    if (self = [super initWithSize:size]) {
        
        self.scaleMode = SKSceneScaleModeAspectFill;
        
        // Store level and file to read from
        self.levelName = level;
        self.fileName = file;

        //Initialize Helper Arrays and Variables
        /*
         * _planets to track the planets / objects that will apply forces on the _spaceship
         * _draggable to track draggable objetcs
         * _eraseable to track what will be deleted once the scene starts
         * _stars to manage the stars
         *
         */
        self.planets = [[NSMutableArray alloc] init];
        self.draggable = [[NSMutableArray alloc] init];
        self.eraseable = [[NSMutableArray alloc] init];
        self.stars = [[NSMutableArray alloc] init];
        _selected = nil;
        _hasStarted = NO;
        _shot = NO;
        _mapScale = 1;
        _mapPoint = CGPointZero;
        
        // Set-up physics world
        [[self physicsWorld] setGravity:CGVectorMake(0, 0)];
        self.physicsWorld.contactDelegate = (id)self;

        
        // Create space envirnoment
        [self addBackground];
        
        // Create PAUSED Label
        _pausedLabel = [[SKLabelNode alloc] init];
        [_pausedLabel setText:@"PAUSED"];
        [_pausedLabel setFontName:@"Futura-CondensedExtraBold"];
        [_pausedLabel setFontSize:50];
        [_pausedLabel setZPosition:100];
        [_pausedLabel setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+20)];

        SKTexture *pausedMenuTexture = [SKTexture textureWithImageNamed:@"game_menu"];
        SKSpriteNode *menuBg = [SKSpriteNode spriteNodeWithTexture:pausedMenuTexture ];
        [menuBg setPosition:CGPointMake(0, -20)];
        [_pausedLabel addChild:menuBg];
        
        _mainMenuLabel = [[SKLabelNode alloc] init];
        [_mainMenuLabel setText:@"Main Menu"];
        [_mainMenuLabel setFontName:@"Futura-CondensedExtraBold"];
        [_mainMenuLabel setFontSize:25];
        [_mainMenuLabel setZPosition:100];
        [_mainMenuLabel setName:@"mainmenu"];
        [_mainMenuLabel setPosition:CGPointMake(0, -75)];
        [_pausedLabel addChild:_mainMenuLabel];
        
        
        // Create level failed menu
        _levelFailed = [[SKLabelNode alloc] init];
        [_levelFailed setText:@"Level Failed"];
        [_levelFailed setFontName:@"Futura-CondensedExtraBold"];
        [_levelFailed setFontSize:40];
        [_levelFailed setZPosition:100];
        [_levelFailed setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+60)];
        
        
        SKTexture *failedMenuTexture = [SKTexture textureWithImageNamed:@"game_menu"];
        SKSpriteNode *failedBg = [SKSpriteNode spriteNodeWithTexture:failedMenuTexture ];
        [failedBg setPosition:CGPointMake(0, -60)];
        [_levelFailed addChild:failedBg];

        // Create map node where everything will be added
        SKTexture *retryTexture = [SKTexture textureWithImageNamed:@"retry_button"];
        SKSpriteNode *retryButton = [SKSpriteNode spriteNodeWithTexture:retryTexture ];
        [retryButton setPosition:CGPointMake(-0, -120)];
        [retryButton setName:@"redo"];
        [_levelFailed addChild:retryButton];
        
        SKTexture *mainmenuTexture = [SKTexture textureWithImageNamed:@"main_menu_button"];
        SKSpriteNode *mainMenuButton = [SKSpriteNode spriteNodeWithTexture:mainmenuTexture ];
        [mainMenuButton setPosition:CGPointMake(-0, -160)];
        [mainMenuButton setName:@"mainmenu2"];
        [_levelFailed addChild:mainMenuButton];
        
        
        // Create level success menu
        _levelSuccess = [[SKLabelNode alloc] init];
        [_levelSuccess setText:@"Level Complete!"];
        [_levelSuccess setFontName:@"Futura-CondensedExtraBold"];
        [_levelSuccess setFontSize:40];
        [_levelSuccess setZPosition:100];
        [_levelSuccess setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+60)];
        
        
        SKTexture *successMenuTexture = [SKTexture textureWithImageNamed:@"game_menu"];
        SKSpriteNode *successBg = [SKSpriteNode spriteNodeWithTexture:successMenuTexture ];
        [successBg setPosition:CGPointMake(0, -60)];
        [_levelSuccess addChild:successBg];
        
        // Create map node where everything will be added
        SKTexture *retryTexture2 = [SKTexture textureWithImageNamed:@"retry_button"];
        SKSpriteNode *retryButton2 = [SKSpriteNode spriteNodeWithTexture:retryTexture2 ];
        [retryButton2 setPosition:CGPointMake(-0, -100)];
        [retryButton2 setName:@"redo"];
        [_levelSuccess addChild:retryButton2];
        
        SKTexture *nextTexture = [SKTexture textureWithImageNamed:@"next_button"];
        SKSpriteNode *nextButton = [SKSpriteNode spriteNodeWithTexture:nextTexture ];
        [nextButton setPosition:CGPointMake(-0, -140)];
        [nextButton setName:@"next"];
        [_levelSuccess addChild:nextButton];

        SKTexture *mainmenuTexture2 = [SKTexture textureWithImageNamed:@"main_menu_button"];
        SKSpriteNode *mainMenuButton2 = [SKSpriteNode spriteNodeWithTexture:mainmenuTexture2 ];
        [mainMenuButton2 setPosition:CGPointMake(-0, -180)];
        [mainMenuButton2 setName:@"mainmenu2"];
        [_levelSuccess addChild:mainMenuButton2];

        
        // Create map node where everything will be added
        SKTexture *mapTexture = [SKTexture textureWithImageNamed:@"map"];
        _map = [SKSpriteNode spriteNodeWithTexture:mapTexture ];
        [_map setAnchorPoint:CGPointZero];
        [_map setPosition:CGPointMake(-_map.size.width/4, -_map.size.height/4)];
        [_map setName:@"map"];
        [self addChild:_map];
        
        
        // Set up window interaction buttons
        // Options Button
        SKTexture *redoBtnTexture = [SKTexture textureWithImageNamed:@"redo_button"];
        _redoBtn = [SKSpriteNode spriteNodeWithTexture:redoBtnTexture ];
        [_redoBtn setPosition:CGPointMake(CGRectGetMaxX(self.frame)-20, CGRectGetMaxY(self.frame)-20)];
        [_redoBtn setName:@"redo"];
        [_redoBtn setZPosition:99];
        [self addChild:_redoBtn];
        
        SKTexture *pauseBtnTexture = [SKTexture textureWithImageNamed:@"pause_button"];
        _pauseBtn = [SKSpriteNode spriteNodeWithTexture:pauseBtnTexture ];
        [_pauseBtn setPosition:CGPointMake(CGRectGetMaxX(self.frame)-55, CGRectGetMaxY(self.frame)-20)];
        [_pauseBtn setName:@"pause"];
        [_pauseBtn setZPosition:99];
        [self addChild:_pauseBtn];

        
        SKTexture *startBtnTexture = [SKTexture textureWithImageNamed:@"start_button"];
        _startBtn = [SKSpriteNode spriteNodeWithTexture:startBtnTexture ];
        [_startBtn setName:@"startButton"];
        [_startBtn setZPosition:99];
        [_startBtn setPosition:CGPointMake(50, 25)];
        [self addChild:_startBtn];
        
        _planetCount  = [ORBCreatePlanet spriteNode];
        [_planetCount setName:@"planetcount"];
        [_planetCount setPosition:CGPointMake(24, CGRectGetMaxY(self.frame)-24)];
        [_planetCount setZPosition:99];
        [self addChild:_planetCount];
        
        _starCount  = [ORBStarCount spriteNode];
        [_starCount setName:@"starCount"];
        [_starCount setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)-15)];
        [_starCount setZPosition:99];
        [self addChild:_starCount];

        // Load level from file
        [self loadLevel:level fromFile:file];

        
        
    }
    
    return self;
}

-(void)didMoveToView:(SKView *)view {
    [super didMoveToView:view];
    
    // Add Pinch Gesture Recognizer
    _pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.scene.view addGestureRecognizer:_pinchRecognizer];
    _pinchRecognizer.delegate = (id)self;
    
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)handlePinch:(UIPinchGestureRecognizer *) recognizer {
    
    if (_mapScale*recognizer.scale < 2.0 && _mapScale*recognizer.scale >= 0.5){
        
        /* 
         * Hack to scale based on the center of the pinch. Store the location
         * find it's position relative to the origin of the screen, after
         * scaling recalculate the position again, take the differential and
         * drag the screen to reposition that point in the same locaiton. 
         * We still need to make sure that the new sized map is still within 
         * the screen viewable section.
         */
        
        if (CGPointEqualToPoint(_mapPoint, CGPointZero)) {
            _mapPoint = [recognizer locationInView:self.view];
        }
            
        CGPoint relativePinchLocation = CGPointMake(_mapPoint.x / _mapScale,
                                                    _mapPoint.y / _mapScale);
        
        [_map runAction:[SKAction scaleBy:recognizer.scale duration:0]];
        _mapScale = _mapScale * recognizer.scale;
        

        CGPoint newRelativePinchLocation = CGPointMake(_mapPoint.x / _mapScale,
                                                       _mapPoint.y / _mapScale);

        CGFloat dX = newRelativePinchLocation.x - relativePinchLocation .x;
        CGFloat dY = newRelativePinchLocation.y - relativePinchLocation .y;
        
        CGPoint newPos = CGPointMake(_map.position.x + dX, _map.position.y + dY);

        // Move map to a location that it should be or in the screen if it's too small
        [_map runAction:[SKAction moveTo:[self boundLayerPos:newPos] duration:0.15]];
        
        recognizer.scale = 1;
    }
}

-(void)addBackground {
    
    // Create and position background
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
    [_background setZPosition:-5];;
    [_background setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))];
    
    //Create space shimmering
    NSString *spaceEffectPath = [[NSBundle mainBundle] pathForResource:@"space" ofType:@"sks"];
    SKEmitterNode *spaceEffect = [NSKeyedUnarchiver unarchiveObjectWithFile:spaceEffectPath];
    [spaceEffect setPosition:CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))];
    [spaceEffect setName:@"space"];
    [spaceEffect setZPosition:-4];
    
    // Add background and effects
    [self addChild:_background];
    [self addChild:spaceEffect];
}

-(void)loadLevel:(NSString *)level fromFile:(NSString *) file {
    
    // Load level data
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"plist"];
    NSDictionary *levels = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary *levelInfo = [levels objectForKey:level];
    
    /*
     * All levels contain the following structure in a dictionary:
     *      start { x, y }
     *      goal { goalEmmiter, width, height, x, y }
     *      obstacles [{}, {}, ... , {} ]
     */
    
    
    // Add Goal
    CGPoint goalPos = CGPointMake([[[levelInfo objectForKey:@"goal"] objectForKey:@"x"] floatValue],
                                  [[[levelInfo objectForKey:@"goal"] objectForKey:@"y"] floatValue]);
    
    CGSize goalSize = CGSizeMake([[[levelInfo objectForKey:@"goal"] objectForKey:@"width"] floatValue],
                                 [[[levelInfo objectForKey:@"goal"] objectForKey:@"height"] floatValue]);
    
    NSString *goalEffectPath = [[NSBundle mainBundle] pathForResource:@"goal" ofType:@"sks"];
    _goal = [NSKeyedUnarchiver unarchiveObjectWithFile:goalEffectPath];
    [_goal setParticlePositionRange:CGVectorMake(goalSize.width, goalSize.height)];
    [_goal setPosition:goalPos];
    [_goal setName:@"goal"];
    [_goal setZPosition:99];
    [_goal setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:goalSize]];
    [[_goal physicsBody] setDynamic:NO];
    [[_goal physicsBody] setCategoryBitMask:goalCategory];
    [_map addChild:_goal];
    
    // Add Start Spaceship
    CGPoint startPos = CGPointMake([[[levelInfo objectForKey:@"start"] objectForKey:@"x"] floatValue],
                                   [[[levelInfo objectForKey:@"start"] objectForKey:@"y"] floatValue]);
    
    _spaceship = [SKSpriteNode spriteNodeWithImageNamed:@"spaceship"];
    [_spaceship setName:@"spaceship"];
    [_spaceship setZPosition:5];
    [_spaceship setPosition:startPos];
    [_map addChild:_spaceship];
    
    _spaceshipCopy = [_spaceship copy];
    
    // Add Obstacles
    
    NSArray *obstacles = [levelInfo objectForKey:@"obstacles"];
    
    for ( NSDictionary *object in obstacles ) {
        
        if ([[object objectForKey:@"name"] isEqualToString:@"steel_beam"]) {
            CGPoint pos= CGPointMake([[object objectForKey:@"x"] floatValue],
                                     [[object objectForKey:@"y"] floatValue]);
            
            SKSpriteNode *item = [SKSpriteNode spriteNodeWithImageNamed:[object objectForKey:@"name"]];
            [item setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(15, 168)]];
            [[item physicsBody] setDynamic:NO];
        
            [item setPosition:pos];
            [_map addChild:item];
            
        } else if ([[object objectForKey:@"name"] isEqualToString:@"star"]) {
            CGPoint pos= CGPointMake([[object objectForKey:@"x"] floatValue],
                                     [[object objectForKey:@"y"] floatValue]);
            
            SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"star"];
            [star setName:@"star"];
            [star setZPosition:99];
            [star setPosition:pos];
            [_map addChild:star];
            [_stars addObject:star];
            
            
        } else if ([[object objectForKey:@"name"] isEqualToString:@"speed_direction"]) {
            CGPoint pos= CGPointMake([[object objectForKey:@"x"] floatValue],
                                     [[object objectForKey:@"y"] floatValue]);
            
            SKSpriteNode *info = [SKSpriteNode spriteNodeWithImageNamed:@"speed_direction"];
            [info setPosition:pos];
            [_map addChild:info];
            [_eraseable addObject:info];
            
            
        } else if ([[object objectForKey:@"name"] isEqualToString:@"planet_hint"]) {
            CGPoint pos= CGPointMake([[object objectForKey:@"x"] floatValue],
                                     [[object objectForKey:@"y"] floatValue]);
            
            SKTexture *circleTexture = [SKTexture textureWithImageNamed:@"planet_circle_location"];
            SKSpriteNode *circle = [SKSpriteNode spriteNodeWithTexture:circleTexture];
            [circle setZPosition:-1];
            [circle setPosition:pos];
            [_map addChild:circle];

        } else if ([[object objectForKey:@"name"] rangeOfString:@"info_arrow"].location  != NSNotFound) {
            CGPoint pos= CGPointMake([[object objectForKey:@"x"] floatValue],
                                     [[object objectForKey:@"y"] floatValue]);
            
            SKSpriteNode *arrow = [SKSpriteNode spriteNodeWithImageNamed:[object objectForKey:@"name"]];
            
            [arrow setZPosition:99];
            [arrow setPosition:pos];
            [self addChild:arrow];
            [_eraseable addObject:arrow];
            
        } else {
        
            CGPoint planetPos = CGPointMake([[object objectForKey:@"x"] floatValue],
                                            [[object objectForKey:@"y"] floatValue]);

            SKSpriteNode *planet = [SKSpriteNode spriteNodeWithImageNamed:@"planet_earth"];
            [planet setName:@"fixedPlanet"];
            [planet setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:40]];
            [[planet physicsBody] setDynamic:NO];
            [planet setPosition:planetPos];
            
            SKSpriteNode *gravityRing = [SKSpriteNode spriteNodeWithImageNamed:@"atmosphere_green"];
            [gravityRing setName:@"fixedGravityRing"];
            [gravityRing setAlpha:0.65];
            [planet addChild:gravityRing];
            
            [_map addChild:planet];
            [_planets addObject:planet];
        }
    }
    
    
    // Add Instructions
    
    NSArray *instruction = [levelInfo objectForKey:@"instructions"];
    
    for ( NSDictionary *info in instruction ) {
        
        CGPoint textPos = CGPointMake([[info objectForKey:@"x"] floatValue],
                                      [[info objectForKey:@"y"] floatValue]);
        
        SKLabelNode *text = [[SKLabelNode alloc] init];
        [text setText:[info objectForKey:@"text"]];
        [text setFontName:@"Damascus"];
        [text setZPosition:99];
        [text setFontSize:15];
        [text setAlpha:0.75];
        [text setPosition:textPos];
        [self addChild:text];
        [_eraseable addObject:text];

        
    }
    
    // Set Planet count
    NSNumber *newLevelPlanetCount = [levelInfo objectForKey:@"planets"];
    [_planetCount setStartPlanetCount:[newLevelPlanetCount intValue]];
    
    
}

-(BOOL) insideMap:(CGPoint)pos {
    if (pos.x <= _map.size.width && pos.x >= 0 && pos.y <= _map.size.height && pos.y >= 0) {
        return YES;
    } else {
        return NO;
    }
}

// Ensure the newPosition of the  is always withing a bound that allows it to be seen on screen
-(CGPoint)boundLayerPos:(CGPoint)newPos {
    
    CGSize windowSize = self.size;
    CGPoint boundPos = newPos;
    
    // Ensure the position allows the map to be seen on screen
    boundPos.x = MAX( MIN(boundPos.x, 50), -[_map size].width + windowSize.width-50);
    boundPos.y = MAX( MIN(boundPos.y, 50), -[_map size].height + windowSize.height-50);
    
    return boundPos;
}

-(void)panForTranslation:(CGPoint)translation {
    
    CGPoint position = [_selected position];
    
    // Decide whether we want to move the map or the node
    if([_draggable containsObject:[_selected children][0]] && _hasStarted == NO) {
        
        [_selected setPosition:CGPointMake(position.x + translation.x/_mapScale, position.y + translation.y/_mapScale)];
        
    } else if ([[_selected name] isEqualToString:@"map"] && _hasStarted == NO) {
        
        CGPoint newPos = CGPointMake(position.x + translation.x, position.y + translation.y);
        [_map setPosition:[self boundLayerPos:newPos]];
        
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    // Single touch events ONLY
    if ([touches count] == 1 && self.view.paused == NO) {
        
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:location];

        // Check what node was selected and perform the particular action
        if ([_draggable containsObject:node] && [node.parent containsPoint:[touch locationInNode:_map]]) {
            
            _selected = node.parent;

        } else if ([node.name isEqualToString:@"map"] || [node.name isEqualToString:@"fixedGravityRing"]) {
        
            _selected = _map;

        } else if ([node.name isEqualToString:@"redo"] && self.view.paused == NO) {

            // Reset variables used to check map state
            _shot = NO;
            _hasStarted = NO;
            [_planetCount allowPlanetCreation];
            
            // Reset Start Button Alpha and initial map position
            [_startBtn setAlpha:1.0];
            [_map setPosition:CGPointMake(-_map.size.width/4, -_map.size.height/4)];
            
            NSString *path = [[NSBundle mainBundle] pathForResource:_fileName ofType:@"plist"];
            NSDictionary *levels = [NSDictionary dictionaryWithContentsOfFile:path];
            NSDictionary *levelInfo = [levels objectForKey:_levelName];

            
            // Overwrite Spaceship with a new instace in the initial location
            CGPoint startPos = CGPointMake([[[levelInfo objectForKey:@"start"] objectForKey:@"x"] floatValue],
                                           [[[levelInfo objectForKey:@"start"] objectForKey:@"y"] floatValue]);

            [_spaceship removeFromParent];
            _spaceship = [SKSpriteNode spriteNodeWithImageNamed:@"spaceship"];
            [_spaceship setName:@"spaceship"];
            [_spaceship setZPosition:5];
            [_spaceship setPosition:startPos];
            [_map addChild:_spaceship];
            
            // If we pressed redo from the levelfailed screen, remove it.
            if ([_levelFailed parent]){
                [_levelFailed removeFromParent];
            }
            
            // Remove all stars from map, replace them and reset the count
            [_starCount resetCount];

            for (SKSpriteNode *star in _stars) {
                [star removeFromParent];
            }
            
            self.stars = [[NSMutableArray alloc] init];
            
            NSArray *obstacles = [levelInfo objectForKey:@"obstacles"];
            
            for ( NSDictionary *object in obstacles ) {
                
                if ([[object objectForKey:@"name"] isEqualToString:@"star"]) {
                    CGPoint pos= CGPointMake([[object objectForKey:@"x"] floatValue],
                                             [[object objectForKey:@"y"] floatValue]);
                    
                    SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"star"];
                    [star setName:@"star"];
                    [star setZPosition:99];
                    [star setPosition:pos];
                    [_map addChild:star];
                    [_stars addObject:star];
                }
            }
            
        } else if ([node.name isEqualToString:@"next"]) {
            
            NSString *level;
            
            // Store 'next level'... Currently all unlocked for tutorial/demo purposes
            if ([_levelName isEqualToString:@"tutorial_1"]) {
                level = @"level_1";
            } else if ([_levelName isEqualToString:@"level_1"]) {
                level = @"level_2";
            } else if ([_levelName isEqualToString:@"level_2"]) {
                level = @"level_3";
            } else if ([_levelName isEqualToString:@"level_3"]) {
                level = @"level_4";
            } else {
                level = @"level_5";
            }
            
            [self.view removeGestureRecognizer:_pinchRecognizer];
            
            SKTransition *reveal = [SKTransition fadeWithDuration:0.375f];
            SKScene * myScene = [[ORBGameScene alloc] initWithSize:self.size andLevel:level andFile:_fileName];
            [self.view presentScene:myScene transition: reveal];
            
        } else if ([node.name isEqualToString:@"planetcount"]) {
            
            if ([_planetCount canCreatePlanet] && !_hasStarted) {
                
                // Decrease Count and Change Texture
                [_planetCount decreasePlanetCount];
                
                SKSpriteNode *planet = [SKSpriteNode spriteNodeWithImageNamed:@"planet_earth"];
                [planet setName:@"movablePlanet"];
                [planet setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:40]];
                [[planet physicsBody] setDynamic:NO];
                [planet setPosition:[touch locationInNode:_map]];
                
                SKSpriteNode *gravityRing = [SKSpriteNode spriteNodeWithImageNamed:@"atmosphere_blue"];
                [gravityRing setName:@"gravityRing"];
                [gravityRing setAlpha:0.65];
                [planet addChild:gravityRing];
                
                [_map addChild:planet];
                [_planets addObject:planet];
                [_draggable addObject:gravityRing];
                _selected = planet;
            }
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
	UITouch *touch = [touches anyObject];
    
	CGPoint positionInScene = [touch locationInNode:self];
	CGPoint previousPosition = [touch previousLocationInNode:self];
    
	[self panForTranslation:CGPointMinusPoint(positionInScene, previousPosition)];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch ends */
    
    // Reset the pinch-reference point
    _mapPoint = CGPointZero;
    
    for (UITouch *touch in touches) {
        
        CGPoint touchLocation = [touch locationInNode:self];
        SKNode *node = [self nodeAtPoint:touchLocation];
        
        if ([node.name isEqualToString:@"mainmenu"] || [node.name isEqualToString:@"mainmenu2"]) {
            
            self.view.paused = NO;
            if (![_pausedLabel parent] && self.view.paused == NO) {
                [self addChild:_pausedLabel];
            } else {
                [_pausedLabel removeFromParent];
                self.view.paused = NO;
            }

            [self.view removeGestureRecognizer:_pinchRecognizer];

            SKTransition *reveal = [SKTransition fadeWithDuration:1.0f];
            SKScene * myScene = [[ORBMainScene alloc] initWithSize:self.size];
            
            [self.view presentScene:myScene transition: reveal];
            
            
        } else if ([node.name isEqualToString:@"startButton"] && self.view.paused == NO) {
           
            for (SKNode *node in _eraseable) {
                [node runAction:[SKAction fadeOutWithDuration:1.0]];
            }
            [_eraseable removeAllObjects];
            
            for (SKSpriteNode *star in _stars) {
                [star setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:star.size]];
                [[star physicsBody] setCategoryBitMask:starCategory];
            }

            [_startBtn setAlpha:0];
            
            [_spaceship setPhysicsBody:[SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(24, 8)]];
            [[_spaceship physicsBody] setDynamic:YES];
            [[_spaceship physicsBody] setCategoryBitMask:spaceshipCategory];
            [[_spaceship physicsBody] setCollisionBitMask:goalCategory];
            [[_spaceship physicsBody] setContactTestBitMask:starCategory | goalCategory];
            [[_spaceship physicsBody] setAllowsRotation:NO];

            // Stop allowing creating planet
            [_planetCount stopPlanetCreation];
            
            // Center map on spaceship
            _mapScale = 1.0;
            CGPoint newMapPos = CGPointMake(-_spaceship.position.x + self.frame.size.width/2, -_spaceship.position.y + self.frame.size.height/2);
            SKAction *zoomOut = [SKAction scaleTo:1.0 duration:0.5];
            SKAction *move = [SKAction moveTo:newMapPos duration:0.5];
            SKAction *wait = [SKAction waitForDuration:1.0];
            SKAction *sequence = [SKAction group:@[zoomOut, move, wait]];
            
            [_map runAction: sequence completion:^{
                _hasStarted = YES;
            }];
            
        } else if ([node.name isEqualToString:@"pause"]) {
         
            if (![_pausedLabel parent] && self.view.paused == NO) {
                [self addChild:_pausedLabel];
            } else {
                [_pausedLabel removeFromParent];
                self.view.paused = NO;
            }
            
        }  else if ([node.name isEqualToString:@"planetcount"]) {
            
            [_planets removeObject:_selected];
            [_selected removeFromParent];
            [_planetCount increasePlanetCount];
        
        
        }
    }
    // Reset selected node once touch ends
    _selected = nil;
}

-(void)didBeginContact:(SKPhysicsContact *)contact {

    if (_hasStarted) {
    
        SKSpriteNode *nodeA, *nodeB;
        
        nodeA = (SKSpriteNode *)contact.bodyA.node;
        nodeB = (SKSpriteNode *) contact.bodyB.node;
        
        if ((contact.bodyA.categoryBitMask == goalCategory)
            && (contact.bodyB.categoryBitMask == spaceshipCategory)) {
        
            // We win, save state...
            [[_spaceship physicsBody] setResting:YES];
            
            NSUInteger *index;
            
            if ([_levelName isEqualToString:@"tutorial_1"]) {
                index = (NSUInteger *) 1;
            } else if ([_levelName isEqualToString:@"level_1"]) {
                index = (NSUInteger *) 2;
            } else if ([_levelName isEqualToString:@"level_2"]) {
                index = (NSUInteger *) 3;
            } else if ([_levelName isEqualToString:@"level_3"]) {
                index = (NSUInteger *) 4;
            } else {
                index = (NSUInteger *) 5;
            }

            NSArray *levelInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"levels"];
            NSMutableArray *levelInfoMutable = [levelInfo mutableCopy];
            NSDictionary *levelDictionary = [levelInfo objectAtIndex:index];
            NSMutableDictionary *levelDictionaryMutable = [levelDictionary mutableCopy];
            
            [levelDictionaryMutable setObject:@"NO" forKey:@"locked"];
            [levelInfoMutable replaceObjectAtIndex:index withObject:levelDictionaryMutable];
            [[NSUserDefaults standardUserDefaults] setObject:levelInfoMutable forKey:@"levels"];
            
            
            if ([_levelName isEqualToString:@"tutorial_1"]) {

                NSArray *levelInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"levels"];
                NSMutableArray *levelInfoMutable = [levelInfo mutableCopy];
                NSDictionary *levelDictionary = [levelInfo objectAtIndex:0];
                NSMutableDictionary *levelDictionaryMutable = [levelDictionary mutableCopy];
                
                [levelDictionaryMutable setObject:@"NO" forKey:@"display"];
                [levelInfoMutable replaceObjectAtIndex:0 withObject:levelDictionaryMutable];
                [[NSUserDefaults standardUserDefaults] setObject:levelInfoMutable forKey:@"levels"];

            } else if ([_levelName isEqualToString:@"level_1"]) {
                
                NSArray *levelInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"levels"];
                NSMutableArray *levelInfoMutable = [levelInfo mutableCopy];
                NSDictionary *levelDictionary = [levelInfo objectAtIndex:1];
                NSMutableDictionary *levelDictionaryMutable = [levelDictionary mutableCopy];
                
                if ([_starCount getStarCount] > [levelDictionaryMutable objectForKey:@"stars"]) {
                    [levelDictionaryMutable setObject:[_starCount getStarCount] forKey:@"stars"];
                    [levelInfoMutable replaceObjectAtIndex:1 withObject:levelDictionaryMutable];
                    [[NSUserDefaults standardUserDefaults] setObject:levelInfoMutable forKey:@"levels"];
                }
                
            } else if ([_levelName isEqualToString:@"level_2"]) {
                
                NSArray *levelInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"levels"];
                NSMutableArray *levelInfoMutable = [levelInfo mutableCopy];
                NSDictionary *levelDictionary = [levelInfo objectAtIndex:2];
                NSMutableDictionary *levelDictionaryMutable = [levelDictionary mutableCopy];
                
                
                if ([_starCount getStarCount] > [levelDictionaryMutable objectForKey:@"stars"]) {
                    [levelDictionaryMutable setObject:[_starCount getStarCount] forKey:@"stars"];
                    [levelInfoMutable replaceObjectAtIndex:2 withObject:levelDictionaryMutable];
                    [[NSUserDefaults standardUserDefaults] setObject:levelInfoMutable forKey:@"levels"];
                }
                
            } else if ([_levelName isEqualToString:@"level_3"]) {
                
                NSArray *levelInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"levels"];
                NSMutableArray *levelInfoMutable = [levelInfo mutableCopy];
                NSDictionary *levelDictionary = [levelInfo objectAtIndex:3];
                NSMutableDictionary *levelDictionaryMutable = [levelDictionary mutableCopy];
                
                if ([_starCount getStarCount] > [levelDictionaryMutable objectForKey:@"stars"]) {
                    [levelDictionaryMutable setObject:[_starCount getStarCount] forKey:@"stars"];
                    [levelInfoMutable replaceObjectAtIndex:3 withObject:levelDictionaryMutable];
                    [[NSUserDefaults standardUserDefaults] setObject:levelInfoMutable forKey:@"levels"];
                }
                
            } else if ([_levelName isEqualToString:@"level_4"]) {
                
                NSArray *levelInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"levels"];
                NSMutableArray *levelInfoMutable = [levelInfo mutableCopy];
                NSDictionary *levelDictionary = [levelInfo objectAtIndex:4];
                NSMutableDictionary *levelDictionaryMutable = [levelDictionary mutableCopy];
                
                if ([_starCount getStarCount] > [levelDictionaryMutable objectForKey:@"stars"]) {
                    [levelDictionaryMutable setObject:[_starCount getStarCount] forKey:@"stars"];
                    [levelInfoMutable replaceObjectAtIndex:4 withObject:levelDictionaryMutable];
                    [[NSUserDefaults standardUserDefaults] setObject:levelInfoMutable forKey:@"levels"];
                }
                
            } else if ([_levelName isEqualToString:@"level_5"]) {
                
                NSArray *levelInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"levels"];
                NSMutableArray *levelInfoMutable = [levelInfo mutableCopy];
                NSDictionary *levelDictionary = [levelInfo objectAtIndex:5];
                NSMutableDictionary *levelDictionaryMutable = [levelDictionary mutableCopy];
                
                if ([_starCount getStarCount] > [levelDictionaryMutable objectForKey:@"stars"]) {
                    
                    [levelDictionaryMutable setObject:[_starCount getStarCount] forKey:@"stars"];
                    [levelInfoMutable replaceObjectAtIndex:5 withObject:levelDictionaryMutable];
                    [[NSUserDefaults standardUserDefaults] setObject:levelInfoMutable forKey:@"levels"];
                }
                    
            }

            [self addChild:_levelSuccess];
            _hasStarted = NO;
            
        }
        
        
        if (((contact.bodyA.categoryBitMask == starCategory)&& (contact.bodyB.categoryBitMask == spaceshipCategory)) ||
            ((contact.bodyA.categoryBitMask == spaceshipCategory) && (contact.bodyB.categoryBitMask == starCategory))) {
            
            [_starCount addStar];
            if ([[nodeA name] isEqualToString:@"star"]) {
                [nodeA removeFromParent];
            } else {
                [nodeB removeFromParent];
            }
            
        }
        
    }
    
}

-(void)update:(CFTimeInterval)currentTime {

    // Pause the game if it needs to be paused - cleaver hack in order to render the paused node
    if ([_pausedLabel parent] && self.view.paused == NO) { self.view.paused = YES; }
    
    if (_hasStarted) {
        
        if (!_shot) {
            [[_spaceship physicsBody] setVelocity:CGVectorMake(-225, 0)];
            _shot = !_shot;
        }

        // Update position to center spaceship on screen
        CGPoint newMapPos = CGPointMake(-_spaceship.position.x + self.frame.size.width/2, -_spaceship.position.y + self.frame.size.height/2);
        [_map setPosition:newMapPos];
        
        // Check for conditions indicated level is failed
        if (CGVectorMagnitude([[_spaceship physicsBody] velocity]) < 5 || ![self insideMap:[_spaceship position]]) {
            
            if(![self insideMap:[_spaceship position]]) { [_spaceship removeFromParent]; }
            
            [self addChild:_levelFailed];
            _hasStarted = NO;
        }
        
        for (SKShapeNode *planet in _planets) {
            
            CGPoint planetPostion = [planet position];
            CGPoint debrisPosition = [_spaceship position];
            
            CGFloat distance = CGDistanceBetweenPoints(planetPostion, debrisPosition);
            
            // Only apply a Force if it's inside the gravity circle (size 96)
            if (distance <= 96) {
                
                CGVector vector = CGVectorFromPointToPoint(planetPostion, debrisPosition);
                
                CGFloat distanceSquared = sqrtf((vector.dx * vector.dx) + (vector.dy * vector.dy)) * sqrtf((vector.dx * vector.dx) + (vector.dy * vector.dy));
                
                CGVector normalized = CGVectorMake(vector.dx / distanceSquared, vector.dy / distanceSquared);
                
                CGFloat force = 15000 / distance;
                
                [[_spaceship physicsBody] applyForce:CGVectorMake(normalized.dx * force, normalized.dy * force)];
                // Ideas: Rotate the spaceship as it moves along the planet,
                //        we can calculate the angle and rotate it by the angle
                //        it is turning
            }
        }
    }
}

@end
