//
//  ObstacleHIV.m
//  Immunity
//
//  Created by John Lee on 7/20/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "ObstacleHIV.h"

@implementation ObstacleHIV{
    CCNode *_hiv;
}
#define ARC4RANDOM_MAX      0x100000000
// visibility on a 3,5-inch iPhone ends a 88 points and we want some meat
static const CGFloat minimumYPositionTopPipe = 28.f;
// visibility ends at 480 and we want some meat
static const CGFloat maximumYPositionBottomPipe = 300.f;
// distance between top and bottom pipe
static const CGFloat pipeDistance = 142.f;
// calculate the end of the range of top pipe
static const CGFloat maximumYPositionTopPipe = maximumYPositionBottomPipe - pipeDistance;


- (void)didLoadFromCCB {
    _hiv.physicsBody.collisionType = @"hiv";
    _hiv.physicsBody.sensor = TRUE;
}

- (void)setupRandomPosition {
    // value between 0.f and 1.f
    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX);
    CGFloat range = maximumYPositionTopPipe - minimumYPositionTopPipe;
    self.position = ccp(self.position.x, minimumYPositionTopPipe + random * range);
    
    CCActionMoveBy* moveUp = [CCActionMoveBy actionWithDuration:1.0f position:ccp(0.0f, 100.0f)];
    CCActionMoveBy* moveDown = [CCActionMoveBy actionWithDuration:1.0f position:ccp(0.0f, -100.0f)];
    CCActionSequence* upAndDown = [CCActionSequence actions:moveUp, moveDown, nil];
    
    [self runAction:[CCActionRepeatForever actionWithAction:upAndDown]];
}

@end
