//
//  BDSongsStorage.m
//  AudioPlayer
//
//  Created by admin on 19.01.14.
//  Copyright (c) 2014 admin. All rights reserved.
//
//TODO правильно ли делать этот класс синглтоном ведь в течении всего времени жизни приложения в памяти будут висеть два массива и достаточно крупных? или я не правильно понял паттерн синглтон?

#import "BDSongsStorage.h"
#import "BDSongAtributs.h"
@interface BDSongsStorage ()

{
    //массив для файлов песен
    NSMutableArray *fileArray; //TODO правильно ли так их объявлять может надо было сдлеать property?
    NSMutableArray *atributsArray;
    NSMutableArray *allTitleAtributs;
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
//TODO проблема: Создаю массив с файлами в init и массив с атрибутами этих файлов и привязка идет по индексам массивов (например в таблице отображаются атрибуты например имена песен нажимаешь на ячейку и открывается плеер, но если перемешать элементы например по алфавиту то при нажатии на название не факт что откроется тот самый трек) Решение вижу в BDSongAtributs в словаре для ID3 сохранять также полный путь к файлу тогда при нажатии на ячайку переход будет по полному пути (но не знаю как это сделать с NSDictionaryRef который по идее полностью забит стандартными атрибутами) конец метода songID3Tegs songID3Tegs в BDSongAtributs. Поэтому в приложение будет ориентироваться на хлипкой связи что элементы массивов fileArray и  atributsArray расположены по одним индексам

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
            //инициализирую массив состоящий из названий песен
            allTitleAtributs = [self getArrayAtributsTitle];
        }
    }
    return self;
}

-(NSArray *)getFileSongs
{
    return fileArray;
}



//методы для получения массива со списком конкретного атрибута по всем файлам (планируется, что они будут применятся для отображения в таблице списка треков группированных по какому-либо атрибуту mp3 файла)

#pragma mark methods for grouping attributes


-(NSMutableArray *) getArrayAtributsTitle //TODO несовместимость типов, можно ли как-то решить это и вообзе есть ли смысл возвращать неизменяемый массив (я думал что это желательно для безопасности, но так ли это на самом деле?)
{
    NSMutableArray *ArrayAtributsTitle = [[NSMutableArray alloc] init];
     for (BDSongAtributs *fileTitle  in atributsArray) {
         [ArrayAtributsTitle addObject:[fileTitle getTitle]];
     }
    return ArrayAtributsTitle;
}

/*-(NSArray *) getArrayAtributsArtist
{

}

-(NSArray *) getArrayAtributsAlbum
{

}

-(NSArray *) getArrayAtributsGenre
{

}*/


#pragma mark metods for table delegate

//В таблице будет только один столбец

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//количество ячеек равно числу элементов массива из названий всех песен

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [allTitleAtributs count];
}

//в таблице будут отображаться все значения из массива allTitleAtributs


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [[NSString stringWithFormat:@"%@",[allTitleAtributs objectAtIndex:indexPath.row]] stringByDeletingPathExtension];//TODO не совсем понял где указываю что выводить все элементы из массива
    return cell;
}

@end
