//
//  Monster.h
//  CocosDemo
//
//  Created by Jon Distad on 6/2/13.
//  Copyright 2013 Jon Distad. All rights reserved.
//

#import "cocos2d.h"

@interface Monster : CCSprite {
}

@property (nonatomic, assign) int hp;
@property (nonatomic, assign) int minMoveDuration;
@property (nonatomic, assign) int maxMoveDuration;

-(id)initWithFile:(NSString *)file hp:(int)hp minMoveDuration:(int)minMoveDuration maxMoveDuration:(int)maxMoveDuration;

@end

@interface WeakAndFastMonster : Monster
@end

@interface StrongAndSlowMonster : Monster
@end
