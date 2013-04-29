//
//  PDSlider.h
//  PlaybackWDownloading
//
//  Created by Евгений Кратько on 24.04.13.
//  Copyright (c) 2013 Akki. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDSlider : UISlider

@property (nonatomic, assign) CGFloat loaded;
@property (nonatomic, strong) UIColor *backProgressColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *playbackColor;

//- (void)setValue:(float)value animated:(BOOL)animated;

@end
