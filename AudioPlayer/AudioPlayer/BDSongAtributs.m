//
//  BDSongAtributs.m
//  AudioPlayer
//
//  Created by admin on 17.01.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "BDSongAtributs.h"

@interface BDSongAtributs ()

@property (nonatomic, retain) NSDictionary *fileInfoDict;

@end


@implementation BDSongAtributs

@synthesize filePath;
@synthesize fileInfoDict;

-(BDSongAtributs *)initWithPath:(NSURL *)path
{
    self = [super init];
    if (self) {
        //в filepath заношу путь к аудиофайлу
        filePath = path;
        //в fileInfoDict заношу словарь я атрибутами
        fileInfoDict = [self songID3Tegs];
        
    }
    return self;
}


-(NSDictionary *)songID3Tegs
{

    AudioFileID fileId = nil; // структура для хранения айдиофайла
    OSStatus error = noErr; // ошибка для проверки
    error = AudioFileOpenURL((__bridge CFURLRef) self.filePath, kAudioFileReadPermission, 0, &fileId);
    if (error != noErr) {
        NSLog(@"Audio Url failed");
    }
    UInt32 ID3DataSize = 0; //переменная для хранения размера памяти ID3
    //Получаю информацию о размере занимаемой памяти ID3 данных и заношу в ID3DataSize
    error = AudioFileGetPropertyInfo(fileId, kAudioFilePropertyID3Tag, &ID3DataSize, NULL); //TODO почему fileId с * (логично что fileId содержит адрес экземпляра класса и операция * здесь нужна) но прога по которой я делал работала без * В чем может быть причина?
    if (error != noErr) {
        NSLog(@"AudioFileGetPropertyInfo failed for ID3 tag");
    }
    char *rawID3raw = NULL; //массив для хранения сырых данных
    rawID3raw = (char *)malloc(ID3DataSize); //TODO не понял какой конкретно объем динамической памяти выделяется
    if (rawID3raw == NULL) {
        NSLog(@"could not allocate %d bytes of memory for ID3 tag", (unsigned int)ID3DataSize);
    }
    //Заносим ID3 свойства размером (Datasize) в rawID3raw
    error = AudioFileGetProperty(fileId, kAudioFilePropertyID3Tag, &ID3DataSize, rawID3raw);
    if (error != noErr) {
        NSLog(@"ID3 is failed");
    }
    //Определяем переменные под размер тегов метаданных
    UInt32 id3TagSize = 0;
    UInt32 id3TagSizeLength = 0;
    //После нее надо будет освободить память(дублирует объект) ЗАДАТЬ вопрос ментору на счет освобождения памяти (при ARC это не надо делать?) Получаем размер тегов для сырых данных аудио  первая в каком формате представить второе размер данных третье что используем в качестве входных данных четвертое количество байт записанных в буфер пятое куда пишем даные
    //TODO уточнить что конкретно получаем не совсем понял перевод
    error = AudioFormatGetProperty(kAudioFormatProperty_ID3TagSize,
                                   ID3DataSize,
                                   rawID3raw,
                                   &id3TagSizeLength,
                                   &id3TagSize);
    if (error != noErr)
    {
        NSLog(@"AudioFormatGetProperty_ID3TagSize failed");
        switch (error) {
            case kAudioFormatUnspecifiedError:
                NSLog(@"Error: audio format unspecified error");
                break;
            case kAudioFormatUnsupportedPropertyError:
                NSLog(@"Error: audio format unsupported property error");
                break;
            case kAudioFormatBadPropertySizeError:
                NSLog( @"Error: audio format bad property size error" );
                break;
            case kAudioFormatBadSpecifierSizeError:
                NSLog( @"Error: audio format bad specifier size error" );
                break;
            case kAudioFormatUnsupportedDataFormatError:
                NSLog( @"Error: audio format unsupported data format error" );
                break;
            case kAudioFormatUnknownFormatError:
                NSLog( @"Error: audio format unknown format error" );
                break;
            default:
                NSLog( @"Error: unknown audio format error" );
                break;

        }
    }
    //создаю
    CFDictionaryRef piDict = nil;
    UInt32 piDataSize = sizeof(piDict);
    
    error = AudioFileGetProperty(fileId, kAudioFilePropertyInfoDictionary, &piDataSize, &piDict);
    if (error != noErr) {
        NSLog(@"AudioFileGetProperty failed for property info dictionary");
    }
    free(rawID3raw);
    return (__bridge NSDictionary *)piDict;
}



#pragma mark metods for get other ID3
-(NSString *) getTitle
{
    //проверяем есть ли у песни атрибут Title
    if ([fileInfoDict objectForKey:[NSString stringWithUTF8String:kAFInfoDictionary_Title]]) {
        return [fileInfoDict objectForKey:[ NSString stringWithUTF8String:kAFInfoDictionary_Title]];
    }
    //если нет то возвращаем полный путь к файлу (url)
    else
    {
        NSString *url = [filePath absoluteString];
        NSArray *parts = [url componentsSeparatedByString:@"/"];
        return [parts objectAtIndex:[parts count]-1];
    }
   // return nil; //TODO данный return нужен??
}

-(NSString *) getArtist
{
    if ([fileInfoDict objectForKey:[NSString stringWithUTF8String:kAFInfoDictionary_Artist]]) {
        return [fileInfoDict objectForKey:[NSString stringWithUTF8String:kAFInfoDictionary_Artist]];
    }
    else
    {
        return @"";
    }
}
-(NSString *) getGenre
{
    if ([fileInfoDict objectForKey:[NSString stringWithUTF8String:kAFInfoDictionary_Genre]]) {
        return [fileInfoDict objectForKey:[NSString stringWithUTF8String:kAFInfoDictionary_Genre]];
    }
    else
    {
        return @"";
    }
}

-(NSString *) getAlbum
{
    if ([fileInfoDict objectForKey:[NSString stringWithUTF8String:kAFInfoDictionary_Album]]) {
        return [fileInfoDict objectForKey:[NSString stringWithUTF8String:kAFInfoDictionary_Album]];
    }
    else
    {
        return @"";
    }
}
-(float) getDuration
{
    if ([fileInfoDict objectForKey:[NSString stringWithUTF8String:kAFInfoDictionary_ApproximateDurationInSeconds]]) {
        return [[fileInfoDict objectForKey:[NSString stringWithUTF8String:kAFInfoDictionary_ApproximateDurationInSeconds]] floatValue];
    }
    else
    {
        return 0;
    }
}
-(NSString *)getDurationInMinutes
{
    return [NSString stringWithFormat: @"%d:%02d", (int)[self getDuration] / 60, (int) [self getDuration] % 60, nil];
}

//TODO как получить обложку песни?
-(UIImage *)getCoverImage
{
    return nil;
}
    
-(NSURL *) getPath
{
    return filePath;
}


@end
