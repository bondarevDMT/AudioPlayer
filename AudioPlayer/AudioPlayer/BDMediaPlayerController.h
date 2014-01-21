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

-(BDMediaPlayerController *)initWithSoundFiles:(NSMutableArray *)songs atPath:(NSURL *)path selectedIndex:(int)index;

//метод для возврата к списку песен
-(void)dismissAudioPlayer;

@end

