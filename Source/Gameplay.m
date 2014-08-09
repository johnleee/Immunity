//
//  MainScene.m
//  PROJECTNAME
//
//  Created by John Lee on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "ObstacleW.h"
#import "ObstacleZ.h"
#import "ObstacleHIV.h"

static const CGFloat firstHeartwormPosition = 380.f;
static const CGFloat distanceBetweenHeartworms = 160.f;
static const CGFloat firstHIVPosition = 800.f;
static const CGFloat distanceBetweenHIVs = 900.f;
static const CGFloat firstChickenpoxPosition = 680.f;
static const CGFloat distanceBetweenChickenpoxs = 420.f;
static const NSInteger countdownTime = 7;
static const NSInteger countdownTimeDouble = 9;
static const NSInteger displayCount = 10;

@implementation Gameplay {
    CCSprite *_whiteblood;
    CCPhysicsNode *_physicsNode;
    CCNode *_ground1;
    CCNode *_ground2;
    CCNode *_sky1;
    CCNode *_sky2;
    NSArray *_grounds;
    NSArray *_skys;
    NSMutableArray *_obstaclesW;
    NSMutableArray *_obstaclesZ;
    NSMutableArray *_obstaclesHIV;
    NSInteger _points;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_timerLabel;
    CCLabelTTF *_instructions;
    NSInteger _countTime;
    NSInteger _displayCounter;
    CCButton *_restartMenu;
    BOOL _gameOver;
    CGFloat _scrollSpeed;
}

- (void)didLoadFromCCB {
    _displayCounter = displayCount;
    
    
    
    _instructions = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"TAP-TAP to play. You have 7 seconds to consume the\nBLUE and YELLOW viruses and regain your lifespan.\n\AVOID the RED viruses! Fight for Immunity!"] fontName:@"Chalkduster" fontSize:16.0f];
    _instructions.positionType = CCPositionTypeNormalized;
    _instructions.position = ccp(0.50f, 0.70f);
    [self addChild:_instructions];

    
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
    
    _obstaclesZ = [NSMutableArray array];
    [self spawnNewObstacleZ];
    [self spawnNewObstacleZ];
    [self spawnNewObstacleZ];
    
    _obstaclesHIV = [NSMutableArray array];
    [self spawnNewObstacleHIV];
    [self spawnNewObstacleHIV];
    [self spawnNewObstacleHIV];
    
    _scrollSpeed = 100.f;
    _countTime = countdownTime;
    
    [self schedule:@selector(countDown:) interval:1.0f];// 0.5second intervals
    
    [self schedule:@selector(instructionsTimer:) interval:7.0f];
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
    
    NSMutableArray *offScreenObstaclesH = nil;
    for (CCNode *obstacle in _obstaclesHIV) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstaclesH) {
                offScreenObstaclesH = [NSMutableArray array];
            }
            [offScreenObstaclesH addObject:obstacle];
        }
    }
    for (CCNode *obstacleToRemove in offScreenObstaclesH) {
        [obstacleToRemove removeFromParent];
        [_obstaclesHIV removeObject:obstacleToRemove];
        // for each removed obstacle, add a new one
        [self spawnNewObstacleHIV];
    }
    
    NSMutableArray *offScreenObstaclesZ = nil;
    for (CCNode *obstacle in _obstaclesZ) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstaclesZ) {
                offScreenObstaclesZ = [NSMutableArray array];
            }
            [offScreenObstaclesZ addObject:obstacle];
        }
    }
    for (CCNode *obstacleToRemove in offScreenObstaclesZ) {
        [obstacleToRemove removeFromParent];
        [_obstaclesZ removeObject:obstacleToRemove];
        // for each removed obstacle, add a new one
        [self spawnNewObstacleZ];
    }
    
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!_gameOver) {
        [_whiteblood.physicsBody applyImpulse:ccp(0, 150.f)];
        [_whiteblood.physicsBody applyAngularImpulse:10000.f];
    }
    
    _points = _points + 1;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
    
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
    
    CCLabelTTF *hitlabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"HIT ME"] fontName:@"Chalkduster" fontSize:11.0f];
    //scorelabel.positionType = CCPositionTypeNormalized;
    //scorelabel.position = ccp(-10.00f, 11.00f);
    
    ObstacleW *obstacleW = (ObstacleW *)[CCBReader load:@"ObstacleW"];
    obstacleW.position = ccp(previousObstacleWXPosition + distanceBetweenHeartworms, 50);
    if (_displayCounter > 0) {
         [obstacleW addChild:hitlabel];
        _displayCounter--;
    }
   
    [obstacleW setupRandomPosition];

    //[_physicsNode addChild:scorelabel];
    [_physicsNode addChild:obstacleW];
    [_obstaclesW addObject:obstacleW];
}

- (void)spawnNewObstacleZ {
    CCNode *previousObstacleZ = [_obstaclesZ lastObject];
    CGFloat previousObstacleZXPosition = previousObstacleZ.position.x;
    if (!previousObstacleZ) {
        // this is the first heartworm
        previousObstacleZXPosition = firstChickenpoxPosition;
    }
    
       CCLabelTTF *hitlabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"HIT ME"] fontName:@"Chalkduster" fontSize:11.0f];
    
    ObstacleZ *obstacleZ = (ObstacleZ *)[CCBReader load:@"ObstacleZ"];
    obstacleZ.position = ccp(previousObstacleZXPosition + distanceBetweenChickenpoxs, 50);
    [obstacleZ setupRandomPosition];
    
    if (_displayCounter > 0) {
        [obstacleZ addChild:hitlabel];
        _displayCounter--;
    }
    
    [_physicsNode addChild:obstacleZ];
    [_obstaclesZ addObject:obstacleZ];
}

- (void)spawnNewObstacleHIV {
    CCNode *previousObstacleHIV = [_obstaclesHIV lastObject];
    CGFloat previousObstacleHIVXPosition = previousObstacleHIV.position.x;
    if (!previousObstacleHIV) {
        // this is the first heartworm
        previousObstacleHIVXPosition = firstHIVPosition;
    }
    
    CCLabelTTF *hitlabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"DANGER!"] fontName:@"ChalkboardSE-Bold" fontSize:12.0f];
    
    ObstacleHIV *obstacleHIV = (ObstacleHIV *)[CCBReader load:@"ObstacleHIV"];
    obstacleHIV.position = ccp(previousObstacleHIVXPosition + distanceBetweenHIVs, 50);
    [obstacleHIV setupRandomPosition];
    
    if (_displayCounter > 0) {
        [obstacleHIV addChild:hitlabel];
        _displayCounter--;
    }
    
    [_physicsNode addChild:obstacleHIV];
    [_obstaclesHIV addObject:obstacleHIV];
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair whiteblood:(CCNode *)whiteblood worm:(CCNode *)worm {
    //NSLog(@"Something collided with a worm");
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
    _points = _points + 100;
    
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
    
    //reset timer
    _countTime = countdownTime;
    [_timerLabel setString:[NSString stringWithFormat:@"%i", _countTime]];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair whiteblood:(CCNode *)whiteblood chicken:(CCNode *)chicken {
    //NSLog(@"Something collided with a worm");
    // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"WormExplosion"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the seals position
    explosion.position = chicken.position;
    // add the particle effect to the same node the seal is on
    [chicken.parent addChild:explosion];
    
    // finally, remove the destroyed worm
    [chicken removeFromParent];
    _points = _points + 100;
    
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
    
    //reset timer
    _countTime = countdownTimeDouble;
    [_timerLabel setString:[NSString stringWithFormat:@"%i", _countTime]];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair whiteblood:(CCNode *)whiteblood goal:(CCNode *)goal {
    [goal removeFromParent];
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair whiteblood:(CCNode *)whiteblood hiv:(CCNode *)hiv {
    //NSLog(@"Something collided with a hiv");
    [self unschedule:@selector(countDown:)];
    [self gameOver];
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

-(void)instructionsTimer:(CCTime)delta {
    _instructions.visible = false;
    
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"Gameplay"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)home {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)gameOver {
    if (!_gameOver) {
        _scrollSpeed = 0.f;
        _gameOver = TRUE;
        _restartMenu.visible = TRUE;
        _instructions.visible = FALSE;
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