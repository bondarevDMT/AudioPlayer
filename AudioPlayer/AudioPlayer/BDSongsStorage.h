//
//  BDSongsStorage.h
//  AudioPlayer
//
//  Created by admin on 19.01.14.
//  Copyright (c) 2014 admin. All rights reserved.
//
//Данный класс хранит массив из объектов песен и соответствует паттерну синглтон

#import <Foundation/Foundation.h>

@interface BDSongsStorage : NSObject <UITableViewDataSource, UITableViewDelegate>

+(BDSongsStorage *)sharedInstance;

-(NSArray *)getFileSongs;

@end
