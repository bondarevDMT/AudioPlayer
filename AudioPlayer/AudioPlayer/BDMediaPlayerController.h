//
//  BDMediaPlayerController.h
//  AudioPlayer
//
//  Created by admin on 21.01.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BDMediaPlayerController : UIViewController 

@property (nonatomic, retain) NSTimer *updateTimer;
//отображение на Tab Bar названия песни, артиста, альбома, продолжительности
@property (nonatomic, retain) UILabel *titleLabel, *artistLabel, *albumLabel, *indexLabel, *duration, *currentTime;
//ползунок (для продолжительности трека)
@property (nonatomic, retain) UISlider *progressSlider;
//Содержит ??
@property (nonatomic, retain) UIView *containerView;
//Клавиша чтобы при нажатии на cover альбома открывалось дополнительное окно с длиной трека и прочей информацией
@property (nonatomic, retain) UIButton *artWorkView;

//??
@property (nonatomic, retain) UIImageView *reflectionView;
//??

@property (nonatomic, retain) CAGradientLayer *gradientLayer;

//TODO (описание почему создаю еще один массив с данными)мне приходится принимать массив выбранных пользователем песен (иначе я не мог бы группировать песни по алфавиту или по определенному исполнителю - у меня бы запускался MediaPlayer с нужной песней но нажимая на клавиши назад и вперед я бы открывал не группированные песни а те которые в массиве BDSongSyorege следуют за данным треком)
-(BDMediaPlayerController *)initWithMasSong:(NSArray *)masSong IndexSong:(int)index;

//метод для возврата к списку песен
-(void)dismissAudioPlayer;
//метод для клавиши (artWirkView) открывает дополнительную информацию по треку
-(void)showOverlayView;
//без понятия что это за метод
- (UIImage *)reflectedImage:(UIButton *)fromImage withHeight:(NSUInteger)height;
-(void)

@end

