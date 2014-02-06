//
//  ORBViewController.m
//  Orbitz
//
//  Created by Donald Little on 1/11/14.
//  Copyright (c) 2014 Donald Little. All rights reserved.
//

#import "ORBViewController.h"
#import "ORBMainScene.h"
#import "ORBGameScene.h"

#define DEBUGINFO FALSE

@interface ORBViewController ()

@property (nonatomic, strong) SKScene *mainScene;

@end


@implementation ORBViewController

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    
    if ( !skView.scene ) {
        
        if (DEBUGINFO) {
            skView.showsFPS = YES;
            skView.showsNodeCount = YES;
        }
        
        // Create and configure the scene.
        SKScene *scene = [[ORBMainScene alloc] initWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        
        
        // Present the scene.
        [skView presentScene:scene];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


@end
