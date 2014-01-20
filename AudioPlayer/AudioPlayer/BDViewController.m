//
//  BDViewController.m
//  AudioPlayer
//
//  Created by admin on 20.01.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "BDViewController.h"
#import "BDSongsStorage.h"

@interface BDViewController ()
{
    UITableView * dataTable;
    
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
	self.view.backgroundColor = [UIColor colorWithRed:0.76f green:0.81f blue:0.87f alpha:1.f];
    //Создаю синглтон
    BDSongsStorage *songsStorage = [BDSongsStorage sharedInstance];
    //создаю фрейм для отображения таблицы со списком песен
    CGRect frame = CGRectMake(0.f, 20.f, self.view.frame.size.width, self.view.frame.size.height - 20.f);
    dataTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    [dataTable setBackgroundView:Nil];
    //Указываю что делегатом таблицы является BDSongsStorage
    [dataTable setDelegate: songsStorage];
    [dataTable setDataSource: songsStorage];
    //Доьавляю таблицу как субвью
    [self.view addSubview:dataTable];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
