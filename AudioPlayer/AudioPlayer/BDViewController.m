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
    //TODO данный массив будет использоваться для отправки BDMediaPlayerController (почему написано в методе -(BDMediaPlayerController *)initWithMasSong:(NSArray *)masSong IndexSong:(int)index;)
    NSArray *masForSendBDMediaPlayerController;
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
    //создаю фрейм для отображения таблицы со списком песен
    CGRect frame = CGRectMake(0.f, 20.f, self.view.frame.size.width, self.view.frame.size.height - 20.f);
    dataTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    [dataTable setBackgroundView:Nil];
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
    masForSendBDMediaPlayerController = [[BDSongsStorage sharedInstance] getSongsList];
    BDSongAtributs *currentSong = [masForSendBDMediaPlayerController objectAtIndex:indexPath.row];
    cell.textLabel.text = [currentSong getTitle];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    BDMediaPlayerController *audioPlayer = [[BDMediaPlayerController alloc]initWithMasSong:masForSendBDMediaPlayerController IndexSong:indexPath.row];
    
    [self.navigationController pushViewController:audioPlayer animated:NO];
    
    //может пригодиться
    
    //  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:audioPlayer];
    
	//[self.navigationController presentViewController:audioPlayer animated:YES completion:nil];
}

@end
