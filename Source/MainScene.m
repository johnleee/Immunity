//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "ObstacleW.h"

static const CGFloat firstHeartwormPosition = 180.f;
static const CGFloat distanceBetweenHeartworms = 160.f;
static const NSInteger countdownTime = 5;

@implementation MainScene {
    CCSprite *_whiteblood;
    CCPhysicsNode *_physicsNode;
    CCNode *_ground1;
    CCNode *_ground2;
    CCNode *_sky1;
    CCNode *_sky2;
    NSArray *_grounds;
    NSArray *_skys;
    NSMutableArray *_obstaclesW;
    NSInteger _points;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_timerLabel;
    NSInteger _countTime;
    CCButton *_restartButton;
    BOOL _gameOver;
    CGFloat _scrollSpeed;
}

- (void)didLoadFromCCB {
    _grounds = @[_ground1, _ground2];
    self.userInteractionEnabled = TRUE;
    
    // set this class as delegate
    _physicsNode.collisionDelegate = self;
    // set collision txpe
    _whiteblood.physicsBody.collisionType = @"whiteblood";
    
    _obstaclesW = [NSMutableArray array];
    [self spawnNewObstacleW];
    [self spawnNewObstacleW];
    [self spawnNewObstacleW];
    
    _scrollSpeed = 100.f;
    _countTime = countdownTime;
    [self schedule:@selector(countDown:) interval:1.0f];// 0.5second intervals
}

- (void)update:(CCTime)delta {
    
    _whiteblood.position = ccp(_whiteblood.position.x + delta * _scrollSpeed, _whiteblood.position.y);
    _physicsNode.position = ccp(_physicsNode.position.x - (_scrollSpeed *delta), _physicsNode.position.y);
    // loop the ground
    for (CCNode *ground in _grounds) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
    }
    // loop the sky
    for (CCNode *sky in _skys) {
        // get the world position of the sky
        CGPoint skyWorldPosition = [_physicsNode convertToWorldSpace:sky.position];
        // get the screen position of the sky
        CGPoint skyScreenPosition = [self convertToNodeSpace:skyWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (skyScreenPosition.x <= (-1 * sky.contentSize.width)) {
            sky.position = ccp(sky.position.x + 2 * sky.contentSize.width, sky.position.y);
        }
    }
    
    // clamp velocity
    float yVelocity = clampf(_whiteblood.physicsBody.velocity.y, -1 * MAXFLOAT, 75.f);
    _whiteblood.physicsBody.velocity = ccp(0, yVelocity);
    
    NSMutableArray *offScreenObstacles = nil;
    for (CCNode *obstacle in _obstaclesW) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_obstaclesW removeObject:obstacleToRemove];
        // for each removed obstacle, add a new one
        [self spawnNewObstacleW];
    }
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!_gameOver) {
        [_whiteblood.physicsBody applyImpulse:ccp(0, 150.f)];
        [_whiteblood.physicsBody applyAngularImpulse:10000.f];
    }
    
    _points++;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points * 100];
    
    self.position = ccp(0, 0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:_whiteblood worldBoundary:self.boundingBox];
    [self runAction:follow];
    
}

- (void)spawnNewObstacleW {
    CCNode *previousObstacleW = [_obstaclesW lastObject];
    CGFloat previousObstacleWXPosition = previousObstacleW.position.x;
    if (!previousObstacleW) {
        // this is the first heartworm
        previousObstacleWXPosition = firstHeartwormPosition;
    }
    ObstacleW *obstacleW = (ObstacleW *)[CCBReader load:@"ObstacleW"];
    obstacleW.position = ccp(previousObstacleWXPosition + distanceBetweenHeartworms, 50);
    [obstacleW setupRandomPosition];
    
    [_physicsNode addChild:obstacleW];
    [_obstaclesW addObject:obstacleW];
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair whiteblood:(CCNode *)whiteblood worm:(CCNode *)worm {
    NSLog(@"Something collided with a worm");
    // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"WormExplosion"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the seals position
    explosion.position = worm.position;
    // add the particle effect to the same node the seal is on
    [worm.parent addChild:explosion];
    
    // finally, remove the destroyed worm
    [worm removeFromParent];
    _points++;
    
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points * 100];
    
    //reset timer
    _countTime = countdownTime;
    [_timerLabel setString:[NSString stringWithFormat:@"%i", _countTime]];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair whiteblood:(CCNode *)whiteblood goal:(CCNode *)goal {
    [goal removeFromParent];
    return TRUE;
}


-(void)countDown:(CCTime)delta {
     _countTime--;
    [_timerLabel setString:[NSString stringWithFormat:@"%i", _countTime]];
    if (_countTime <= 0) {
        [self unschedule:@selector(countDown:)];
        [self gameOver];
    }
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)gameOver {
    if (!_gameOver) {
        _scrollSpeed = 0.f;
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        _whiteblood.rotation = 90.f;
        _whiteblood.physicsBody.allowsRotation = FALSE;
        [_whiteblood stopAllActions];
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        [self runAction:bounce];
        [self stopAllActions];
    }
}

@end