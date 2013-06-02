//
//  GameOverLayer.h
//  CocosDemo
//
//  Created by Jon Distad on 6/2/13.
//  Copyright 2013 Jon Distad. All rights reserved.
//

#import "cocos2d.h"

@interface GameOverLayer : CCLayerColor {
}

+(CCScene *) sceneWithWon:(BOOL)won;
-(id)initWithWon:(BOOL)won;

@end
