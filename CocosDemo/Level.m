//
//  Level.m
//  CocosDemo
//
//  Created by Jon Distad on 6/2/13.
//  Copyright (c) 2013 Jon Distad. All rights reserved.
//

#import "Level.h"

@implementation Level

-(id)initWithLevelNum:(int)levelNum secsPerSpawn:(float)secsPerSpawn backgroundColor:(ccColor4B)backgroundColor {
    if ((self = [super init])) {
        self.levelNum = levelNum;
        self.secsPerSpawn = secsPerSpawn;
        self.backgroundColor = backgroundColor;
    }
    return self;
}

@end
