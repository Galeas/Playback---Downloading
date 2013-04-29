//
//  PDProgressView.h
//  PlaybackWDownloading
//
//  Created by Евгений Кратько on 24.04.13.
//  Copyright (c) 2013 Akki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface PDProgressView : UIView

@property (nonatomic, strong) UIColor *progressMainColor;
@property (nonatomic, strong) UIColor *progressBackColor;

@property (nonatomic, strong) UIColor *gradientStartColor;
@property (nonatomic, strong) UIColor *gradientEndColor;

@property (nonatomic, assign) CGFloat valueMain;
@property (nonatomic, assign) CGFloat valueBack;

- (void)setValueMain:(CGFloat)value animated:(BOOL)animated;
- (void)setValueBack:(CGFloat)value animated:(BOOL)animated;
@end
