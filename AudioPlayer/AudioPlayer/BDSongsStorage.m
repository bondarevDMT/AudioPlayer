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
#import "BDMediaPlayerController.h"
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
//TODO проблему решил так: сделал в BDSongAtributs свойство NSURL *filePath открытым (оно как раз и содержит полный путь к файлу). Правильно ли я сделал?

//инициализирую массив fileArray объектами из главной директории проекта
-(id)init
{
    self = [super init];
    if (self) {
        fileArray = [[NSMutableArray alloc] initWithObjects:[[NSBundle mainBundle] pathForResource:@"01" ofType:@"mp3"], [[NSBundle mainBundle] pathForResource:@"02" ofType:@"mp3"], [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp3"], [[NSBundle mainBundle] pathForResource:@"2" ofType:@"mp3"], [[NSBundle mainBundle] pathForResource:@"3" ofType:@"mp3"], nil];
       
        //Создаю массив атрибутов для каждой песни из fileArray
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



#pragma mark metods for table delegate
//TODO проблема в том что у меня класс модель занимается задачами контроллера - например метод -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath (где правильнее было бы выполнять методы делегата таблицы если в контроллере то там бы пришлось создавать копии всех таблиц с данными хотя они и так существуют в синглтоне) вопрос как мне из вне достучаться до массивов синглтона? Видимо я не понимаю принцип синглтона я бы делал так: создал в контроллере синглтон и создал массив с названиями песен NSArray *title = [singlton getArrayAtributsTitle]; но это же не правильно.

//В таблице будет только один столбец

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//количество ячеек равно числу элементов массива из названий всех песен

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [atributsArray count];
}

//в таблице будут отображаться все значения из массива allTitleAtributs


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    //в таблицу заношу из массива атрибутов (состоящих из экземпляров BDSongAtributs)для всех песен поля Title
    cell.textLabel.text = [[NSString stringWithFormat:@"%@", [[atributsArray objectAtIndex:indexPath.row]getTitle]]stringByDeletingPathExtension];
    return cell;
}


//метод для действий если пользователь нажал на элемент таблицы
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    BDMediaPlayerController *audioPlayer = [[BDMediaPlayerController alloc] initWithSoundFiles:atributsArray atPath:[[atributsArray objectAtIndex:indexPath.row]getPath] selectedIndex:indexPath.row];

    //TODO как сделать UINavigationController между BDViewController и BDMediaViewPlayerController? по идее надо в этом методе (создал навигэйтконтроллер в делегате приложения и инициализировал его BDViewController теперь надо чтобы в этом методе был переход к  BDMediaPlayerController *audioPlayer) наверное мне надо создать протокол с методом (который передает нужные для инициализации audioPlayer данные расположить его здесь) а поддержку этого метода сделать в BDViewController Так и надо? с виду это как-то неадекватно (но по другому не знаю) и в поддерживаемом протоколе сделать создать BDMediaPlayerController и написать строчку ниже (либо не протокол а приемник/действие)
    
    //[self.navigationController pushViewController:scv animated:NO];
    
    //может пригодиться
    
  //  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:audioPlayer];

	//[self.navigationController presentViewController:audioPlayer animated:YES completion:nil];
}

@end
