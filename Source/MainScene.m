//
//  MainScene.m
//  Immunity
//
//  Created by John Lee on 7/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene


- (void)play {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}



@end
