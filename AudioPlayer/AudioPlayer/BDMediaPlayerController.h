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

-(BDMediaPlayerController *)initWithIndexSong:(int)index;

//метод для возврата к списку песен
-(void)dismissAudioPlayer;

@end

