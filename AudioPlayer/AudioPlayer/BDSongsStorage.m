//
//  BDSongsStorage.m
//  AudioPlayer
//
//  Created by admin on 19.01.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "BDSongsStorage.h"
#import "BDSongAtributs.h"
@interface BDSongsStorage ()

{
    //массив для файлов песен
    NSMutableArray *fileArray; //TODO правильно ли так их объявлять может надо было сдлеать property?
    NSMutableArray *atributsArray;
}

@end


@implementation BDSongsStorage

#pragma mark metod for Singleton
+(BDSongsStorage *)sharedInstance
{
    //статическая переменная для хранения указателя на экземпляр класса
    static BDSongsStorage * _sharedInstance = nil;
    //Статическая переменная обеспечивающая, что код инициализации выполнится единожды
    static dispatch_once_t oncePredicate;
    //При использовании GCD выполняем инициализацию экземпляра (блок инициализации никогда не выполнится повторно)
    dispatch_once(&oncePredicate, ^{_sharedInstance = [[BDSongsStorage alloc] init];
    });
    return _sharedInstance;
}

#pragma mark Other metods
//инициализирую массив fileArray объектами из главной директории проекта
-(id)init
{
    self = [super init];
    if (self) {
        fileArray = [[NSMutableArray alloc] initWithObjects:[[NSBundle mainBundle] pathForResource:@"01" ofType:@"mp3"], [[NSBundle mainBundle] pathForResource:@"02" ofType:@"mp3"], [[NSBundle mainBundle] pathForResource:@"03" ofType:@"mp3"], nil];
        atributsArray = [[NSMutableArray alloc] init];
        for (NSString *fileURL  in fileArray) {
            BDSongAtributs *atribubsForFile = [[BDSongAtributs alloc] initWithPath:[NSURL fileURLWithPath:fileURL]];
            [atributsArray addObject:atribubsForFile];
        }
    }
    return self;
}

-(NSArray *)getFileSongs
{
    return fileArray;
}

#pragma mark methods for grouping attributes

-(NSArray *) getArrayAtributsTitle //TODO несовместимость типов, можно ли как-то решить это и вообзе есть ли смысл в возвращать неизменяемый массив (я думал что это желательно для безопасности, но так ли это на самом деле?)
{
    NSMutableArray *ArrayAtributsTitle = [[NSArray alloc] init];
     for (BDSongAtributs *fileTitle  in atributsArray) {
         [ArrayAtributsTitle addObject:[fileTitle getTitle]];
     }
    return ArrayAtributsTitle;
    
}
-(NSArray *) getArrayAtributsArtist
{

}
-(NSArray *) getArrayAtributsAlbum
{

}
-(NSArray *) getArrayAtributsGenre
{

}


@end
