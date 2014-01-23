//
//  BDSongsStorage.m
//  AudioPlayer
//
//  Created by admin on 19.01.14.
//  Copyright (c) 2014 admin. All rights reserved.
//
//TODO правильно ли делать этот класс синглтоном ведь в течении всего времени жизни приложения в памяти будут висеть два массива и достаточно крупных? или я не правильно понял паттерн синглтон?

#import "BDSongsStorage.h"
#import "BDMediaPlayerController.h"
@interface BDSongsStorage ()

{
    //массив для файлов песен
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
        NSArray* fileArray = [[NSMutableArray alloc] initWithObjects:[[NSBundle mainBundle] pathForResource:@"01" ofType:@"mp3"], [[NSBundle mainBundle] pathForResource:@"02" ofType:@"mp3"], [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp3"], [[NSBundle mainBundle] pathForResource:@"2" ofType:@"mp3"], [[NSBundle mainBundle] pathForResource:@"3" ofType:@"mp3"], nil];
       
        //Создаю массив атрибутов для каждой песни из fileArray
        atributsArray = [[NSMutableArray alloc] init];
        for (NSString *fileURL  in fileArray) {
            BDSongAtributs *atribubsForFile = [[BDSongAtributs alloc] initWithPath:[NSURL fileURLWithPath:fileURL]];
            [atributsArray addObject:atribubsForFile];
        }
    }
    return self;
}

//TODO (доделать) методы для получения массивов с BDSongAtributs (также здесь надо добавить методы для получения сгруппированных массивов нпаример по алфавиту или выборка по определенному исполнителю и так далее эти методы будут использоваться в методе - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath) класса BDViewController (точнее строчке  masForSendBDMediaPlayerController = [[BDSongsStorage sharedInstance] getSongsList];)

- (NSArray *)getSongsList
{
    return [atributsArray copy];
}

@end
