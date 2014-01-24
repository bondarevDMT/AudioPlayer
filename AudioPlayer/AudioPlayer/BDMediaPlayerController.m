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
    //содержит массив BDSongAtributs для всех файлов (в дальнейшем можно будет сделать группировку не по всем файлам, а конкретного исполнителя и так далее) инициализация массива в методе -(BDMediaPlayerController *)initWithMasSong:(NSArray *)masSong IndexSong:(int)index

    NSArray *soundFiles;
    //содержит путь к треку
    NSURL *soundFilePath;
    //содержит индекс в массиве для переданной песни
    NSInteger selectedIndex;
    AVAudioPlayer *player;
    
}

@end

@implementation BDMediaPlayerController

static const CGFloat kDefaultReflectionFraction = 0.65;
static const CGFloat kDefaultReflectionOpacity = 0.40;

@synthesize updateTimer, titleLabel, artistLabel, albumLabel, indexLabel, duration, currentTime;
@synthesize progressSlider;
@synthesize containerView;
@synthesize artWorkView;
@synthesize reflectionView;
@synthesize gradientLayer;


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor blackColor];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    updateTimer = nil;
    
    //Для проверки работоспособности контроллера в дальнейшем удалить
    selectedIndex = 2;
    soundFiles = [[BDSongsStorage sharedInstance] getSongsList];
    
    //создаю bar по стандарту из плеера ios
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    navigationBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    navigationBar.barStyle = UIBarStyleBlackOpaque;
    [self.view addSubview:navigationBar];
    //создаю  UINavigationItem чтобы он содержал информацию в стеке для navigationBar (чтобы была точка возврата для NavigationController)
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@""];
    [navigationBar pushNavigationItem:navItem animated:NO];
    //создаю кнопку возврата и инициализирую ее
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissAudioPlayer)];
    //добавляю клавишу на бар
    navItem.leftBarButtonItem = doneButton;
    
    //Создаю экземпляр класса BDSongAtributs для выбранной песни
    BDSongAtributs *selectedSong = [soundFiles objectAtIndex:selectedIndex];
    
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
    
    //TODO уточнить (самому)
    duration.adjustsFontSizeToFitWidth = YES;
    currentTime.adjustsFontSizeToFitWidth = YES;
    progressSlider.minimumValue = 0.0;
    
    //TODO разобраться для чего контейнер??
    containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44) ];
    [self. view addSubview:containerView];
    
    //при нажатии на клавишу открывается дополнительное окно (информация по треку) - клавиша размером с cover альбома
    artWorkView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    //для кнопки использовать катринку cover альбома
    [artWorkView setImage:[selectedSong getCoverImage] forState:UIControlStateNormal];
    [artWorkView addTarget:self action:@selector(showOverlayView) forControlEvents:UIControlEventTouchUpInside];
    //TODO уточнить (самому) - это настройки клавиши для отображения доп инфы по треку
    artWorkView.showsTouchWhenHighlighted = NO;
    artWorkView.adjustsImageWhenHighlighted = NO;
    artWorkView.backgroundColor = [UIColor clearColor];
    [containerView addSubview:artWorkView];
    
    //TODO уточнить что (сам)
    reflectionView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 320, 320, 96)];
    reflectionView.image = [self reflectedImage:artWorkView withHeight:artWorkView.bounds.size.height * kDefaultReflectionFraction];
    reflectionView.alpha = kDefaultReflectionFraction;
    [self.containerView addSubview:reflectionView];
    
    gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.frame = CGRectMake(0.0 , self.containerView.bounds.size.height - 96,  self.containerView.bounds.size.width, 48);
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor clearColor].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.5].CGColor, (id)[UIColor blackColor]. CGColor, (id)[UIColor blackColor].CGColor, nil];
    gradientLayer.zPosition = INT_MAX;
    
    //Панель управления исполнением (play и так далее)
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10) ];
    v.backgroundColor = [UIColor clearColor];
    

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark metod for init AVAudioPlayer
//метод используется для принятия данных после выбора пользователем песни
-(BDMediaPlayerController *)initWithMasSong:(NSArray *)masSong IndexSong:(int)index
{
    if (self = [super init]) {
        selectedIndex = index;
        soundFiles = masSong;
        NSError *error = nil;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[[soundFiles objectAtIndex:selectedIndex] getPath] error:&error];
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
