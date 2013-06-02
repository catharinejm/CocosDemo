//
//  LevelManager.h
//  CocosDemo
//
//  Created by Jon Distad on 6/2/13.
//  Copyright (c) 2013 Jon Distad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Level.h"

@interface LevelManager : NSObject

+(LevelManager *)sharedInstance;
-(Level *)curLevel;
-(void)nextLevel;
-(void)reset;

@end
