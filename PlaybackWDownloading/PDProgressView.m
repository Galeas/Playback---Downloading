//
//  PDProgressView.m
//  PlaybackWDownloading
//
//  Created by Евгений Кратько on 24.04.13.
//  Copyright (c) 2013 Akki. All rights reserved.
//

#import "PDProgressView.h"

NSString *const kChangeMainValue = @"valueMain";
NSString *const kChangeBackValue = @"valueBack";

@interface PDLayer : CALayer
@property (nonatomic, strong) UIColor *progressMainColor;
@property (nonatomic, strong) UIColor *progressBackColor;
@property (nonatomic, strong) UIColor *gradientStartColor;
@property (nonatomic, strong) UIColor *gradientEndColor;
@property (nonatomic, assign) CGFloat valueMain;
@property (nonatomic, assign) CGFloat valueBack;
@end

@implementation PDLayer

- (id)initWithLayer:(PDLayer*)layer
{
    if (self = [super initWithLayer:layer]) {
        [self setProgressBackColor:layer.progressBackColor];
        [self setProgressMainColor:layer.progressMainColor];
        [self setGradientEndColor:layer.gradientEndColor];
        [self setGradientStartColor:layer.gradientStartColor];
        [self setValueMain:layer.valueMain];
        [self setValueBack:layer.valueBack];
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:kChangeMainValue] || [key isEqualToString:kChangeBackValue]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGRect currentRect = self.bounds;
    CGContextClipToRect(ctx, currentRect);
    
    //Back gradient
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.0f, 1.0f};
    NSArray *colors = @[ (id)self.gradientStartColor.CGColor, (id)self.gradientEndColor.CGColor ];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    CGPoint start = CGPointMake(CGRectGetMidX(currentRect), CGRectGetMinY(currentRect));
    CGPoint end = CGPointMake(CGRectGetMidX(currentRect), CGRectGetMaxY(currentRect));
    CGContextSaveGState(ctx);
    CGContextAddRect(ctx, currentRect);
    CGContextClip(ctx);
    CGContextDrawLinearGradient(ctx, gradient, start, end, 0);
    CGContextRestoreGState(ctx);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    //Progress Back
    if (self.valueBack != 0.0f) {
        CGContextSaveGState(ctx);
        CGContextClipToRect(ctx, self.bounds);
        CGMutablePathRef backPath = CGPathCreateMutable();
        CGPathMoveToPoint(backPath, NULL, 0.0f, self.bounds.size.height/2);
        CGPathAddLineToPoint(backPath, NULL, self.valueBack * self.bounds.size.width, self.bounds.size.height/2);
        CGContextAddPath(ctx, backPath);
        CGPathRelease(backPath);
        CGContextSetLineWidth(ctx, self.bounds.size.height);
        CGContextSetLineCap(ctx, kCGLineCapSquare);
        CGContextSetStrokeColorWithColor(ctx, self.progressBackColor.CGColor);
        CGContextDrawPath(ctx, kCGPathStroke);
        CGContextRestoreGState(ctx);
    }
    
    //Progress Main
    if (self.valueMain != 0.0f) {
        CGContextSaveGState(ctx);
        CGContextClipToRect(ctx, self.bounds);
        CGMutablePathRef mainPath = CGPathCreateMutable();
        CGPathMoveToPoint(mainPath, NULL, 0.0f, self.bounds.size.height/2);
        CGPathAddLineToPoint(mainPath, NULL, self.valueMain * self.bounds.size.width, self.bounds.size.height/2);
        CGContextAddPath(ctx, mainPath);
        CGPathRelease(mainPath);
        CGContextSetLineWidth(ctx, self.bounds.size.height);
        CGContextSetLineCap(ctx, kCGLineCapButt);
        CGContextSetStrokeColorWithColor(ctx, self.progressMainColor.CGColor);
        CGContextDrawPath(ctx, kCGPathStroke);
        CGContextRestoreGState(ctx);
    }
}

@end

@interface PDProgressView()
- (void)prepare;
@end

@implementation PDProgressView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

- (PDLayer *)progressLayer
{
    return (PDLayer*)self.layer;
}

+ (Class)layerClass
{
    return [PDLayer class];
}

- (void)prepare
{
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self setGradientStartColor:[UIColor colorWithWhite:.9f alpha:1.0f]];
    [self setGradientEndColor:[UIColor colorWithWhite:.8f alpha:1.0f]];
    [self setProgressMainColor:[UIColor colorWithRed:1.0f green:0 blue:0 alpha:.5f]];
    [self setProgressBackColor:[UIColor colorWithRed:0 green:1.0f blue:0 alpha:.5f]];
    [self setValueMain:0];
    [self setValueBack:0];
}

- (void)drawRect:(CGRect)rect {}

#pragma mark Value
- (CGFloat)valueMain
{
    return [[self progressLayer] valueMain];
}

- (CGFloat)valueBack
{
    return [[self progressLayer] valueBack];
}

- (void)setValueMain:(CGFloat)valueMain
{
    [self setValueMain:valueMain animated:NO];
}

- (void)setValueBack:(CGFloat)valueBack
{
    [self setValueBack:valueBack animated:NO];
}

- (void)setValueMain:(CGFloat)value animated:(BOOL)animated
{
    CGFloat newValue = MIN(MAX(value, 0.0f), 1.0f);
    
    if (animated) {
        CGFloat oldValue = [[self progressLayer] valueMain];
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:kChangeMainValue];
        [animation setDuration:oldValue - newValue];
        [animation setFromValue:[NSNumber numberWithFloat:oldValue]];
        [animation setToValue:[NSNumber numberWithFloat:newValue]];
        [[self progressLayer] addAnimation:animation forKey:kChangeMainValue];
    }
    else {
        [[self progressLayer] setNeedsDisplay];
    }
    
    [[self progressLayer] setValueMain:newValue];
}

- (void)setValueBack:(CGFloat)value animated:(BOOL)animated
{
    CGFloat newValue = MIN(MAX(value, 0.0f), 1.0f);
    
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:kChangeBackValue];
        [animation setDuration:(self.valueBack - newValue)*10];
        [animation setFromValue:@(self.valueBack)];
        [animation setToValue:@(newValue)];
        [[self progressLayer] addAnimation:animation forKey:kChangeBackValue];
    }
    else {
        [[self progressLayer] setNeedsDisplay];
    }
    
    [[self progressLayer] setValueBack:newValue];
}

#pragma mark Gradient Color
- (UIColor *)gradientStartColor
{
    return [[self progressLayer] gradientStartColor];
}

- (UIColor *)gradientEndColor
{
    return [[self progressLayer] gradientEndColor];
}

- (void)setGradientStartColor:(UIColor *)gradientStartColor
{
    [[self progressLayer] setGradientStartColor:gradientStartColor];
    [[self progressLayer] setNeedsDisplay];
}

- (void)setGradientEndColor:(UIColor *)gradientEndColor
{
    [[self progressLayer] setGradientEndColor:gradientEndColor];
    [[self progressLayer] setNeedsDisplay];
}

#pragma mark Progress Color
- (UIColor *)progressMainColor
{
    return [[self progressLayer] progressMainColor];
}

- (UIColor *)progressBackColor
{
    return [[self progressLayer] progressBackColor];
}

- (void)setProgressMainColor:(UIColor *)progressMainColor
{
    UIColor *trueColor = progressMainColor;
    CGFloat components[4];
    [trueColor getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    if (components[3] != 1) {
        trueColor = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:1];
    }
    [[self progressLayer] setProgressMainColor:trueColor];
    [[self progressLayer] setNeedsDisplay];
}

- (void)setProgressBackColor:(UIColor *)progressBackColor
{
    [[self progressLayer] setProgressBackColor:progressBackColor];
    [[self progressLayer] setNeedsDisplay];
}
@end
