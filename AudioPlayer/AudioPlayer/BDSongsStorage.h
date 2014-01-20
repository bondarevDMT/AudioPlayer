//
//  BDSongsStorage.h
//  AudioPlayer
//
//  Created by admin on 19.01.14.
//  Copyright (c) 2014 admin. All rights reserved.
//
//Данный класс хранит массив из объектов песен и соответствует паттерну синглтон

#import <Foundation/Foundation.h>

@interface BDSongsStorage : NSObject

+(BDSongsStorage *)sharedInstance;

-(NSArray *)getFileSongs;

//методы для получения массива со списком конкретного атрибута по всем файлам (планируется, что они будут применятся для отображения в таблице списка треков группированных по какому-либо атрибуту mp3 файла)
-(NSArray *) getArrayAtributsTitle;
-(NSArray *) getArrayAtributsArtist;
-(NSArray *) getArrayAtributsAlbum;
-(NSArray *) getArrayAtributsGenre;


@end
