//
//  HelloWorldLayer.h
//  CocosDemo
//
//  Created by Jon Distad on 6/2/13.
//  Copyright Jon Distad 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor
{
    int _monstersDestroyed;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
