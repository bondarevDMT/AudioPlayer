//
//  BDMediaPlayerController.h
//  AudioPlayer
//
//  Created by admin on 21.01.14.
//  Copyright (c) 2014 admin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BDMediaPlayerController : UIViewController 
{
    NSTimer				*updateTimer;
    UILabel				*titleLabel;
    UILabel				*artistLabel;
	UILabel				*albumLabel;
	UILabel				*indexLabel;
}

//TODO (описание почему создаю еще один массив с данными)мне приходится принимать массив выбранных пользователем песен (иначе я не мог бы группировать песни по алфавиту или по определенному исполнителю - у меня бы запускался MediaPlayer с нужной песней но нажимая на клавиши назад и вперед я бы открывал не группированные песни а те которые в массиве BDSongSyorege следуют за данным треком)
-(BDMediaPlayerController *)initWithMasSong:(NSArray *)masSong IndexSong:(int)index;

//метод для возврата к списку песен
-(void)dismissAudioPlayer;

@end

