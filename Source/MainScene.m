//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
static const CGFloat scrollSpeed = 80.f;
@implementation MainScene {
    CCSprite *_whiteblood;
    CCPhysicsNode *_physicsNode;
    CCNode *_ground1;
    CCNode *_ground2;
    CCNode *_sky1;
    CCNode *_sky2;
    NSArray *_grounds;
    NSArray *_skys;

}
- (void)didLoadFromCCB {
    _grounds = @[_ground1, _ground2];
    self.userInteractionEnabled = TRUE;
}

- (void)update:(CCTime)delta {
    
    _whiteblood.position = ccp(_whiteblood.position.x + delta * scrollSpeed, _whiteblood.position.y);
    _physicsNode.position = ccp(_physicsNode.position.x - (scrollSpeed *delta), _physicsNode.position.y);
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
    float yVelocity = clampf(_whiteblood.physicsBody.velocity.y, -1 * MAXFLOAT, 50.f);
    _whiteblood.physicsBody.velocity = ccp(0, yVelocity);
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [_whiteblood.physicsBody applyImpulse:ccp(0, 100.f)];
    
    self.position = ccp(0, 0);
    CCActionFollow *follow = [CCActionFollow actionWithTarget:_whiteblood worldBoundary:self.boundingBox];
    [self runAction:follow];
    
}
@end