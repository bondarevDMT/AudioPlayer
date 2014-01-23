//
//  BDSongAtributs.h
//  AudioPlayer
//
//  Created by admin on 17.01.14.
//  Copyright (c) 2014 admin. All rights reserved.
//
//TODO Спросить на счет сайтов(адекватных) где есть решенные задачи
//TODO полезные ссылки что может пригодиться

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface BDSongAtributs : NSObject

@property (nonatomic, retain) NSURL *filePath;



-(BDSongAtributs *)initWithPath:(NSURL *)path;
-(NSDictionary *)songID3Tegs;
-(NSString *) getTitle;
-(NSString *) getArtist;
-(NSString *) getAlbum;
-(NSString *) getGenre;
-(float) getDuration;
-(NSString *)getDurationInMinutes;
-(UIImage *)getCoverImage;
-(NSURL *) getPath;
@end
