//
//  HelloWorldLayer.m
//  CocosDemo
//
//  Created by Jon Distad on 6/2/13.
//  Copyright Jon Distad 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "GameOverLayer.h"
#import "Monster.h"
#import "LevelManager.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "SimpleAudioEngine.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
    [layer setTouchEnabled:YES];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) addMonster {
    Monster * monster = nil;
    if (arc4random() % 2 == 0)
        monster = [[[WeakAndFastMonster alloc] init] autorelease];
    else
        monster = [[[StrongAndSlowMonster alloc] init] autorelease];
    
    monster.tag = 1;
    [_monsters addObject:monster];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int minY = monster.contentSize.height/2;
    int maxY = winSize.height - monster.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    monster.position = ccp(winSize.width + monster.contentSize.width/2, actualY);
    [self addChild:monster];
    
    int minDuration = monster.minMoveDuration;
    int maxDuration = monster.maxMoveDuration;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    CCMoveTo *actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(-monster.contentSize.width/2, actualY)];
    CCCallBlockN *actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        [node removeFromParentAndCleanup:YES];
        [_monsters removeObject:node];
        CCScene *gameOverScene = [GameOverLayer sceneWithWon:NO];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];
    }];
    [monster runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
    // Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super initWithColor:[LevelManager sharedInstance].curLevel.backgroundColor])) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        _player = [CCSprite spriteWithFile:@"player2.png"];
        _player.position = ccp(_player.contentSize.width/2, winSize.height/2);
        [self addChild:_player];
        [self schedule:@selector(gameLogic:) interval:[LevelManager sharedInstance].curLevel.secsPerSpawn];
        [self schedule:@selector(update:)];
        _monsters = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    
    [_monsters release];
    _monsters = nil;
    [_projectiles release];
    _projectiles = nil;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void) gameLogic: (ccTime)dt {
    [self addMonster];
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_nextProjectile != nil) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];

    _nextProjectile = [[CCSprite spriteWithFile:@"projectile2.png"] retain];
    _nextProjectile.position = ccp(20, winSize.height/2);
    
    CGPoint offset = ccpSub(location, _nextProjectile.position);
    
    if (offset.x <= 0) {
        [_nextProjectile release];
        _nextProjectile = nil;
        return;
    }
    
    int realX = winSize.width + (_nextProjectile.contentSize.width/2);
    float ratio = (float) offset.y / (float) offset.x;
    int realY = (realX * ratio) + _nextProjectile.position.y;
    CGPoint realDest = ccp(realX, realY);
    
    int offRealX = realX - _nextProjectile.position.x;
    int offRealY = realY - _nextProjectile.position.y;
    float length = sqrtf((offRealX * offRealX) + (offRealY * offRealY));
    float velocity = 480/1; // 480px / 1sec
    float realMoveDuration = length/velocity;
    
    float angleRadians = atanf((float)offRealY / (float)offRealX);
    float angleDegrees = CC_RADIANS_TO_DEGREES(angleRadians);
    float cocosAngle = -1 * angleDegrees;
    float rotateDegreesPerSecond = 360;
    float degreesDiff = _player.rotation - cocosAngle;
    float rotateDuration = fabs(degreesDiff / rotateDegreesPerSecond);
    
    [_player runAction:
     [CCSequence actions:
      [CCRotateTo actionWithDuration:rotateDuration angle:cocosAngle],
      [CCCallBlock actionWithBlock:^{
         [self addChild:_nextProjectile];
         [_projectiles addObject:_nextProjectile];
         
         [_nextProjectile release];
         _nextProjectile = nil;
     }],
      nil]];
    
    [_nextProjectile runAction:
     [CCSequence actions:
      [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
      [CCCallBlockN actionWithBlock:^(CCNode *node) {
         [node removeFromParentAndCleanup:YES];
         [_projectiles removeObject:node];
     }],
      nil]];
    
    _nextProjectile.tag = 2;
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
}

-(void)update:(ccTime)dt {
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    for (CCSprite *projectile in _projectiles) {
        
        BOOL monsterHit = FALSE;
        NSMutableArray *monstersToDelete = [[NSMutableArray alloc] init];
        for (Monster *monster in _monsters) {

            if (CGRectIntersectsRect(projectile.boundingBox, monster.boundingBox)) {
                monsterHit = TRUE;
                monster.hp--;
                if (monster.hp <= 0)
                    [monstersToDelete addObject:monster];
                break;
            }
            
        }
        
        for (Monster *monster in monstersToDelete) {
            [_monsters removeObject:monster];
            [self removeChild:monster cleanup:YES];
            _monstersDestroyed++;
            if (_monstersDestroyed > 30) {
                CCScene *gameOverScene = [GameOverLayer sceneWithWon:YES];
                [[CCDirector sharedDirector] replaceScene:gameOverScene];
            }
        }
        if (monsterHit) {
            [projectilesToDelete addObject:projectile];
            [[SimpleAudioEngine sharedEngine] playEffect:@"explosion.caf"];
        }

        [monstersToDelete release];
    }
    
    for (CCSprite *projectile in projectilesToDelete) {
        [_projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
    }
    [projectilesToDelete release];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissViewControllerAnimated:YES completion:nil];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissViewControllerAnimated:YES completion:nil];
}
@end
