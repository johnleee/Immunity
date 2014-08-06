//
//  ObstacleZ.m
//  Immunity
//
//  Created by John Lee on 8/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "ObstacleZ.h"

@implementation ObstacleZ
{
    CCNode *_chickenpox;
}
#define ARC4RANDOM_MAX      0x100000000
#define ARC4RANDOM_MAX_M    0x100000000
// visibility on a 3,5-inch iPhone ends a 88 points and we want some meat
static const CGFloat minimumYPositionTopPipe = 28.f;
// visibility ends at 480 and we want some meat
static const CGFloat maximumYPositionBottomPipe = 300.f;
// distance between top and bottom pipe
static const CGFloat pipeDistance = 142.f;
// calculate the end of the range of top pipe
static const CGFloat maximumYPositionTopPipe = maximumYPositionBottomPipe - pipeDistance;


- (void)didLoadFromCCB {
    _chickenpox.physicsBody.collisionType = @"chicken";
    _chickenpox.physicsBody.sensor = TRUE;
}

- (void)setupRandomPosition {
    // value between 0.f and 1.f
    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX);
    CGFloat range = maximumYPositionTopPipe - minimumYPositionTopPipe;
    self.position = ccp(self.position.x, minimumYPositionTopPipe + random * range);
    
    CGFloat randomu = ((double)arc4random() / ARC4RANDOM_MAX_M);
    CGFloat randomd = ((double)arc4random() / ARC4RANDOM_MAX_M);
    
    CCActionMoveBy* moveUp = [CCActionMoveBy actionWithDuration:1.0f position:ccp(0.0f, minimumYPositionTopPipe + randomu * range)];
    CCActionMoveBy* moveDown = [CCActionMoveBy actionWithDuration:1.0f position:ccp(0.0f, -(minimumYPositionTopPipe + randomd * range))];
    
    CCActionSequence* upAndDown = [CCActionSequence actions:moveUp, moveDown, nil];
    
    [self runAction:[CCActionRepeatForever actionWithAction:upAndDown]];
}
@end
