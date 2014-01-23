//
//  BDMediaPlayerController.m
//  AudioPlayer
//
//  Created by admin on 21.01.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import "BDMediaPlayerController.h"
#import "BDSongsStorage.h"
#import <AVFoundation/AVFoundation.h>

@interface BDMediaPlayerController ()<AVAudioPlayerDelegate>

{
    NSMutableArray *soundFiles;
    NSURL *soundFilePath;
    NSInteger selectedIndex;
    
    AVAudioPlayer *player;
    
}

@end

@implementation BDMediaPlayerController


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    updateTimer = nil;
    //создаю bar по стандарту из плеера ios
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    navigationBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    navigationBar.barStyle = UIBarStyleBlackOpaque;
    [self.view addSubview:navigationBar];
    //создаю  UINavigationItem чтобы он содержал информацию в стеке для navigationBar (чтобы была точка возврата для NavigationController)
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    [navigationBar pushNavigationItem:navItem animated:NO];
    //создаю кнопку возврата и инициализирую ее
    //TODO как называется клавиша со стрелкой
    //TODO и какой смысл делать
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissAudioPlayer)];
    //добавляю клавишу на бар
    navItem.leftBarButtonItem = doneButton;
    //TODO где логичнее создать данный экземпляр (будет использоваться для получения данных о треке и отображении их в баре) здесь или в методе инициализации? И я не использую принцип синглтона все так и надо?
    BDSongAtributs *selectedSong = [[[BDSongsStorage sharedInstance] getSongsList] objectAtIndex:0];
    //Настройка отображения наименования
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 14, 195, 12)];
    titleLabel.text = [selectedSong getTitle];
    titleLabel.font = [UIFont boldSystemFontOfSize:12];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(0, -1);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.view addSubview:titleLabel];
    
    //Настройка отображения наименования артиста
    artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 2, 195, 12)];
    artistLabel.text = [selectedSong getArtist];
    artistLabel.font = [UIFont boldSystemFontOfSize:12];
    artistLabel.backgroundColor = [UIColor clearColor];
    artistLabel.textColor = [UIColor lightGrayColor];
    artistLabel.shadowColor = [UIColor blackColor];
    artistLabel.shadowOffset = CGSizeMake(0, -1);
    artistLabel.textAlignment = NSTextAlignmentCenter;
    artistLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.view addSubview:artistLabel];
    
    //Настройка отображения наименования альбома
    albumLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 27, 195, 12) ];
    albumLabel.text = [selectedSong getAlbum];
    albumLabel.font = [UIFont boldSystemFontOfSize:12];
    albumLabel.backgroundColor = [UIColor clearColor];
    albumLabel.textColor = [UIColor lightGrayColor];
    albumLabel.shadowColor = [UIColor blackColor];
    albumLabel.shadowOffset = CGSizeMake(0, -1);
    albumLabel.textAlignment = NSTextAlignmentCenter;
    albumLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.view addSubview:albumLabel];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark metod for init AVAudioPlayer
//метод используется для принятия данных после выбора пользователем песни
-(BDMediaPlayerController *)initWithSoundFiles:(NSMutableArray *)songsAtributs atPath:(NSURL *)pathSong selectedIndex:(int)indexInMassive
{
    if (self = [super init]) {
        soundFiles = songsAtributs;
        soundFilePath = pathSong;
        selectedIndex = indexInMassive;
        
        NSError *error = nil;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[(BDSongAtributs *)[songsAtributs objectAtIndex:selectedIndex]filePath] error:&error];
        [player setNumberOfLoops:0];
         player.delegate = self;
        
        
        if (error) {
            NSLog(@"%@",error);
        }
    }
     return self;
}

//метод для возврата к списку песен
-(void)dismissAudioPlayer
{
  //
}
@end
