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
    
}

@end

@implementation BDMediaPlayerController

static const CGFloat kDefaultReflectionFraction = 0.65;
static const CGFloat kDefaultReflectionOpacity = 0.40;

@synthesize player;
@synthesize updateTimer, titleLabel, artistLabel, albumLabel, indexLabel, duration, currentTime;
@synthesize progressSlider, volumeSlider;
@synthesize containerView;
@synthesize artWorkView;
@synthesize reflectionView;
@synthesize gradientLayer;
@synthesize playButton, pauseButton, nextButton, previousButton;
@synthesize overLayView;
@synthesize shuffleButton;
@synthesize shaffle;
@synthesize interrupted;






-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [player play];
    [self updateForPlayerInfo];
    [self updateViewForPlayerState];
}


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
    [self.view addSubview:containerView];
    
    //при нажатии на клавишу открывается дополнительное окно (информация по треку) - клавиша размером с cover альбома
    artWorkView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    //для кнопки использовать катринку cover альбома
    [artWorkView setImage:[selectedSong getCoverImage] forState:UIControlStateNormal];
    //если нажимаю на кнопку то отображается отдельная панель с доп информацией по треку (продолжительность оставшееся время)
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
    
    
    //подложка под панель управления песней
    UIImageView *buttonBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44+320, self.view.bounds.size.width, 96)];
    buttonBackground.image = [[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerBarBackground" ofType:@"png"]] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
   [self.view addSubview:buttonBackground];
    //клавиша PLAY
    playButton = [[UIButton alloc] initWithFrame:CGRectMake(144, 370, 40, 40)];
    [playButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerPlay" ofType:@"png"]] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    playButton.showsTouchWhenHighlighted = YES;
    [self.view addSubview:playButton];
    //клавиша Pause
    pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(140, 370, 40, 40)];
    [pauseButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerPause" ofType:@"png"]] forState:UIControlStateNormal];
    [pauseButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    pauseButton.showsTouchWhenHighlighted = YES;
    
    //Клавиша nextButton
    
    nextButton = [[UIButton alloc] initWithFrame: CGRectMake(220, 370, 40, 40)];
    [nextButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerNextTrack" ofType:@"png"]] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    nextButton.showsTouchWhenHighlighted = YES;
    //TODO разобраться
    nextButton.enabled = [self canGoToTheNextTrack];
    [self.view addSubview:nextButton];
    
    //клавиша previousButton
    previousButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 370, 40, 40) ];
    [previousButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"AudioPlayerPrevTrack" ofType:@"png"]] forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previous) forControlEvents:UIControlEventTouchUpInside];
    previousButton.showsTouchWhenHighlighted = YES;
    previousButton.enabled = [self canGoThePreviousTrack];
    [self.view addSubview:previousButton];
    
    //Клавиша volumeSlider
    volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(25, 420, 270, 9)];
    [volumeSlider setThumbImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerVolumeKnob" ofType:@"png"]] forState:UIControlStateNormal];
    //TODO уточнить (сам)
    [volumeSlider setMinimumTrackImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberLeft" ofType:@"png"]] stretchableImageWithLeftCapWidth:5 topCapHeight:3]forState:UIControlStateNormal];
    [volumeSlider setMaximumTrackImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberRight" ofType:@"png"]]stretchableImageWithLeftCapWidth:5 topCapHeight:3] forState:UIControlStateNormal];
    [volumeSlider addTarget:self action:@selector(volumeSliderMoved:) forControlEvents:UIControlEventValueChanged];
    if ([[NSUserDefaults standardUserDefaults] floatForKey:@"PlayerVolume"]) {
        volumeSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"PlayerVolume"];
    } else {
        volumeSlider.value = player.volume;
    }
    [self updateForPlayerInfo];
    [self updateViewForPlayerState];
    
    
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


#pragma mark methods for additional panel

//метод для клавиши (artWirkView) показывает доп панель с информацией по треку (сколько по времения трек и так далее)
-(void)showOverlayView
{
    if (overLayView == nil) {
        //Создание View  для отображения дополнительной панели
        overLayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 76) ];
        overLayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
        //TODO уточнить самому
        overLayView.opaque = NO;
        
        //Создание UISlider для отображения ползунка продолжительности
        progressSlider = [[UISlider alloc] initWithFrame: CGRectMake(54, 20, 212, 23)];
        [progressSlider setThumbImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberKnob" ofType:@"png"]] forState:UIControlStateNormal];
        //TODO уточнить самому
        [progressSlider setMinimumTrackImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberLeft" ofType:@"png"]] stretchableImageWithLeftCapWidth:5 topCapHeight:3]forState:UIControlStateNormal];
        [progressSlider setMaximumTrackImage:[[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerScrubberRight" ofType:@"png"]] stretchableImageWithLeftCapWidth:5 topCapHeight:3] forState:UIControlStateNormal];
        //устанавливаю действие на ползунок
        [progressSlider addTarget:self action:@selector(progressSliderMoved:) forControlEvents:UIControlEventValueChanged];
        //устанавливаю макс и мин значения
        progressSlider.maximumValue = player.duration;
        progressSlider.minimumValue = 0.0;
        [overLayView addSubview:progressSlider];
        
        //создание UILabel для отображение номера песни
        indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 2, 64, 21)];
        indexLabel.font = [UIFont boldSystemFontOfSize:12];
        indexLabel.shadowOffset = CGSizeMake(0, -1);
        indexLabel.backgroundColor = [UIColor clearColor];
        indexLabel.textColor = [UIColor whiteColor];
        indexLabel.textAlignment = NSTextAlignmentCenter;
        [overLayView addSubview:indexLabel];
        
        //создание UILable для отображения продолжительности песни (сколько осталось прослушать)
        duration = [[UILabel alloc] initWithFrame: CGRectMake(272, 21, 48, 21)];
        duration.font = [UIFont boldSystemFontOfSize:14];
        duration.shadowOffset = CGSizeMake(0, -1);
        duration.shadowColor = [UIColor clearColor];
        duration.textColor = [UIColor whiteColor];
        [overLayView addSubview:duration];
        
        //создание UILable для отображения сколько прослушано (начинается с 0:0)
        currentTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 21, 48, 21)];
        currentTime.font = [UIFont boldSystemFontOfSize:14];
        currentTime.shadowOffset = CGSizeMake(0, -1);
        currentTime.shadowColor = [UIColor blackColor];
        currentTime.backgroundColor = [UIColor clearColor];
        currentTime.textColor = [UIColor whiteColor];
        currentTime.textAlignment = NSTextAlignmentRight;
        [overLayView addSubview:currentTime];
        
        //TODO разобраться самому
        duration.adjustsFontSizeToFitWidth = YES;
        currentTime.adjustsFontSizeToFitWidth = YES;
        
        //Создание клавиши для перемешивания песен
        
        shuffleButton = [[UIButton alloc]initWithFrame: CGRectMake(280, 45, 32, 28) ];
        [shuffleButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerShuffleOff" ofType:@"png"]] forState:UIControlStateNormal];
        [shuffleButton addTarget:self action:@selector(toggleShuffle) forControlEvents:UIControlEventTouchUpInside];
        [overLayView addSubview:shuffleButton];
    }
    [self updateForPlayerInfo];
    [self updateViewForPlayerState];
    
    //TODO разобраться самому с анимацией
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    if ([overLayView superview]) {
        [overLayView removeFromSuperview];
    }
    else
    {
        [containerView addSubview:overLayView];
    }
    [UIView commitAnimations];
}


//TODO метод для отображения клавиши перемешивания

-(void)toggleShuffle
{
    //когда первый раз запускаю перемешивание shaffle = nil (поэтому перехожу на else)
    if (shaffle) {
        shaffle = NO;
        [shuffleButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerShuffleOff" ofType:@"png"]] forState:UIControlStateNormal];
    }
    else {
        shaffle = YES;
        [shuffleButton setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AudioPlayerShuffleOn" ofType:@"png"]] forState:UIControlStateNormal];
    }
    [self updateForPlayerInfo];
    [self updateViewForPlayerState];
}




#pragma mark Service methods to initialize the parameters (duration, currentTime, indexLabel, title, artist, album and others) and other service metod such as metod method to return to the list of songs


//метод для обновления данных о времени в течении проигрывания песни
-(void)updateCurrentTimeForPlayer
{
    //получение данных о прошедшем времени прослушивания (свойство currentTime является смещение текущей позиции воспроизведения и измеряется в секундах от начала звука, если звук не воспроизводится то currentTime содержит то место песни с которого начинать при воспроизведении)
    currentTime.text = [NSString stringWithFormat:@"%d:%02d", (int)player.currentTime / 60, (int)player.currentTime % 60, nil];
    //получение данных о оставшемся времени прослушивания
    duration.text = [NSString stringWithFormat:@"-%d:%02d", (int)(player.duration - player.currentTime) / 60, (int)(player.duration - player.currentTime) % 60, nil];
    //инициализация полученными данными UILabel (duration and currentTime)
    progressSlider.value = player.currentTime;
}

//метод специально для использования в методе -(void)updateViewForPlayerState:(AVAudioPlayer *)p для [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateCurrentTime!!!!) userInfo:p repeats:YES
-(void)updateCurrentTime
{
    [self updateCurrentTimeForPlayer];
}

//!метод инициализации и формата представления данных о номере песни, времени и "попловке" продолжительности песни
-(void)updateForPlayerInfo
{
    //Занесение в UILabel данных о продолжительности песни в формате минут:секунд
    duration.text = [NSString stringWithFormat:@"%d:%02d", (int)player.duration / 60, (int)player.duration % 60, nil];
    
    //Занесение в UILabel данных о номере песни из массива в формате "N песни" of "число песен"
    indexLabel.text = [NSString stringWithFormat:@"%d of %d", (selectedIndex + 1), [soundFiles count]];
    progressSlider.maximumValue = player.duration;
    if ([[NSUserDefaults standardUserDefaults] floatForKey:@"PlayerVolume"]) {
        volumeSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:@"PlayerVolume"];
    }
    else {
        volumeSlider.value = player.volume;
    }
}

//!метод для обновления вьюх с данными для плеера
-(void)updateViewForPlayerState
{
    //Занесение данных в UILabel название песни имя артиста и название альбома)
    titleLabel.text = [[soundFiles objectAtIndex:selectedIndex] getTitle];
    artistLabel.text = [[soundFiles objectAtIndex:selectedIndex] getArtist];
    albumLabel.text = [[soundFiles objectAtIndex:selectedIndex] getAlbum];
    
    [self updateCurrentTimeForPlayer];
    if (updateTimer) {
        [updateTimer invalidate];
    }
    //выбор какая клавиша будет отображаться (если проингрывается песня то отображается клавиша pause иначе клавиша play) если проигрывание трека то запускается таймер каждую секунду отправляющий сообщение updateCurrentTime
    if (player.playing) {
        [playButton removeFromSuperview];
        [self.view addSubview:pauseButton];
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateCurrentTime) userInfo:player repeats:YES];
    }
    else
    {
        [pauseButton removeFromSuperview];
        [self.view addSubview:playButton];
        updateTimer = nil;
    }
    //настройка для кнопок для отправки сообщения содержащего (YES NO на счет того какой трек далее если проигрывался полседний трек и не нажата клавиша перемешивание то плеер включает pause)
    nextButton.enabled = [self canGoToTheNextTrack];
    previousButton.enabled = [self canGoThePreviousTrack];
}



//метод для возврата к списку песен
-(void)dismissAudioPlayer
{
    //
}




#pragma mark Other metods


//метод для ползунка продолжительности песни
-(void)progressSliderMoved:(UISlider *)sender
{
    player.volume = sender.value;
    [self updateCurrentTimeForPlayer];
}


//метод для ползунка громкости
-(void)volumeSliderMoved:(UISlider *)sender
{
    player.volume = [sender value];
    [[NSUserDefaults standardUserDefaults] setFloat:[sender value] forKey:@"PlayerVolume"];
}



//без понятия что это за метод
- (UIImage *)reflectedImage:(UIButton *)fromImage withHeight:(NSUInteger)height
{
    UIImage *a = [[UIImage alloc] init];
    return a;
}


#pragma mark methods for control keys

//метод для клавиши playButton
-(void)play
{
    //если сейчас проигрывается трек, то останавливаем воспроизведение pause
    if (player.playing)
    {
        [player pause];
    }
    else
    {
        [player play];
    }
    [self updateForPlayerInfo];
    [self updateViewForPlayerState];

}


//метод для клавиши next
-(void)next
{
    NSUInteger newIndex;
    if (shaffle)
        newIndex = rand()%[soundFiles count];
    else
        newIndex = selectedIndex +1;
    
    selectedIndex = newIndex;
    NSError *error = nil;
    AVAudioPlayer *newAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[soundFiles objectAtIndex:selectedIndex] getPath] error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    [player stop];
    player = newAudioPlayer;
    [player play];
    [self updateForPlayerInfo];
    [self updateViewForPlayerState];
}


-(BOOL)canGoToTheNextTrack
{
    if (selectedIndex + 1 == [soundFiles count])
        return NO;
    else
        return YES;
}



//метод для клавиши previous
-(void)previous
{
    NSUInteger newInteger = selectedIndex - 1;
    selectedIndex = newInteger;
    NSError *error = nil;
    AVAudioPlayer *newAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[soundFiles objectAtIndex:selectedIndex] getPath] error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    [player stop];
    player = newAudioPlayer;
    [player play];
    [self updateForPlayerInfo];
    [self updateViewForPlayerState];
}


-(BOOL)canGoThePreviousTrack
{
    if (selectedIndex == 0)
        return NO;
    else
        return YES;
}





#pragma mark AVAudioPlayer delegate

//метод для переведения плеера в режим паузы (для случая когда мы дошли до последней песни в альбоме)
/*-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag == NO) {
        NSLog(@"Playback finished unsuccessfully");
        if ([self canGoToTheNextTrack]) {
            [self next];
        }
        else if (interrupted)
    }
}*/

@end
