//
//  BDViewController.m
//  AudioPlayer
//
//  Created by admin on 20.01.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "BDViewController.h"
#import "BDSongsStorage.h"
#import "BDMediaPlayerController.h"


@interface BDViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView * dataTable;
    BDSongsStorage *songStorage;
}
@end

@implementation BDViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Инициалищирую цвет фона
	self.view.backgroundColor = [UIColor whiteColor];
    //Создаю синглтон
    songStorage = [BDSongsStorage sharedInstance];
    //создаю фрейм для отображения таблицы со списком песен
    CGRect frame = CGRectMake(0.f, 20.f, self.view.frame.size.width, self.view.frame.size.height - 20.f);
    dataTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    [dataTable setBackgroundView:Nil];
    //Указываю что делегатом таблицы является BDSongsStorage
    [dataTable setDelegate:self];
    [dataTable setDelegate:self];
    [dataTable setDataSource:self];
    //Добавляю таблицу как субвью
    [self.view addSubview:dataTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[[BDSongsStorage sharedInstance] getSongsList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const kTableViewCellIdentifier = @"cell";
    

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kTableViewCellIdentifier];
    NSArray *songList = [[BDSongsStorage sharedInstance] getSongsList];
    BDSongAtributs *currentSong = [songList objectAtIndex:indexPath.row];
    cell.textLabel.text = [currentSong getTitle];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BDMediaPlayerController *audioPlayer = [[BDMediaPlayerController alloc] initWithSoundFiles:<#(NSMutableArray *)#> atPath:<#(NSURL *)#> selectedIndex:<#(int)#>]
}

@end
