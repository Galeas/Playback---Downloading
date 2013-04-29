//
//  PDSlider.m
//  PlaybackWDownloading
//
//  Created by Евгений Кратько on 24.04.13.
//  Copyright (c) 2013 Akki. All rights reserved.
//

#import "PDSlider.h"
#import <QuartzCore/QuartzCore.h>

#define kBorderWidth 2.0

static NSString *const kChangeValue = @"value";
static NSString *const kChangeProgress = @"loaded";

@interface PDSliderLayer : CALayer;
@property (nonatomic, assign) CGFloat loaded;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, strong) UIColor *backProgressColor;
@property (nonatomic, strong) UIColor *playbackColor;
@property (nonatomic, strong) UIColor *borderlineColor;
@end

@implementation PDSliderLayer

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:kChangeProgress] || [key isEqualToString:kChangeValue])
        return YES;
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx
{
    [self drawOutline:self.bounds context:ctx];
    if (self.loaded > 0)
        [self drawBackProgress:self.bounds context:ctx];
    if (self.value > 0)
        [self drawPlaybackProgress:self.bounds context:ctx];
}

- (void)drawOutline:(CGRect)rect context:(CGContextRef)ctx
{
    CGRect r = CGRectInset(rect, kBorderWidth, kBorderWidth);
    CGFloat radius = r.size.height / 2.0;

    CGContextSetStrokeColorWithColor(ctx, self.borderlineColor.CGColor);

    CGContextSaveGState(ctx);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, CGRectGetMaxX(r) - radius, kBorderWidth);
    CGPathAddArc(path, NULL, radius+kBorderWidth, radius+kBorderWidth, radius, -M_PI/2.0, M_PI/2.0, true);
    CGPathAddArc(path, NULL, CGRectGetMaxX(r) - radius, radius+kBorderWidth, radius, M_PI/2.0, -M_PI/2.0, true);
    CGPathCloseSubpath(path);
    
    CGContextAddPath(ctx, path);
    CGContextSetLineWidth(ctx, kBorderWidth);
    CGContextStrokePath(ctx);
    CGContextAddPath(ctx, path);
    CGContextClip(ctx);
    CGPathRelease(path);
    CGContextRestoreGState(ctx);
}


- (void)drawBackProgress:(CGRect)rect context:(CGContextRef)ctx
{
    CGRect r = CGRectInset(rect, kBorderWidth, kBorderWidth);
    CGFloat radius = (r.size.height-kBorderWidth) / 2.0;
    
    CGContextSetFillColorWithColor(ctx, self.backProgressColor.CGColor);
    
    CGContextSaveGState(ctx);
    CGMutablePathRef fillPath = CGPathCreateMutable();
    CGPathMoveToPoint(fillPath, NULL, CGRectGetMaxX(r) - radius, 1.5*kBorderWidth);
    CGPathAddArc(fillPath, NULL, radius+1.5*kBorderWidth, radius+1.5*kBorderWidth, radius, -M_PI/2.0, M_PI/2.0, true);
    CGPathAddArc(fillPath, NULL, ((CGRectGetMaxX(r) - radius)*self.loaded)-.5*kBorderWidth, radius+1.5*kBorderWidth, radius, M_PI/2.0, -M_PI/2.0, true);
    CGPathCloseSubpath(fillPath);
    
    CGContextAddPath(ctx, fillPath);
    CGContextFillPath(ctx);
    CGContextAddPath(ctx, fillPath);
    CGContextClip(ctx);
    CGPathRelease(fillPath);
    CGContextRestoreGState(ctx);
}

- (void)drawPlaybackProgress:(CGRect)rect context:(CGContextRef)ctx
{
    CGRect r = CGRectInset(rect, kBorderWidth, kBorderWidth);
    CGFloat radius = (r.size.height-kBorderWidth) / 2.0;
    
    CGContextSetFillColorWithColor(ctx, self.playbackColor.CGColor);
    
    CGContextSaveGState(ctx);
    CGMutablePathRef fillPath = CGPathCreateMutable();
    CGPathMoveToPoint(fillPath, NULL, CGRectGetMaxX(r) - radius, 1.5*kBorderWidth);
    CGPathAddArc(fillPath, NULL, radius+1.5*kBorderWidth, radius+1.5*kBorderWidth, radius, -M_PI/2.0, M_PI/2.0, true);
    CGPathAddArc(fillPath, NULL, (CGRectGetMaxX(r) - radius)*self.value, radius+1.5*kBorderWidth, radius, M_PI/2.0, -M_PI/2.0, true);
    CGPathCloseSubpath(fillPath);
    
    CGContextAddPath(ctx, fillPath);
    CGContextFillPath(ctx);
    CGContextAddPath(ctx, fillPath);
    CGContextClip(ctx);
    CGPathRelease(fillPath);
    CGContextRestoreGState(ctx);
}

@end

@implementation PDSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.loaded = 0;
        self.value = 0;
        self.borderColor = [UIColor whiteColor];
        self.backProgressColor = [UIColor darkGrayColor];
        self.playbackColor = [UIColor redColor];
    }
    return self;
}

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    CGRect result = [super trackRectForBounds:bounds];
    result.size.height = 0;
    return result;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    CGRect tRect = [super thumbRectForBounds:bounds trackRect:[super trackRectForBounds:bounds] value:value];
    return tRect;
}

- (PDSliderLayer*)currentLayer
{
    PDSliderLayer *layer = (PDSliderLayer*)self.layer;
    return layer;
}

+ (Class)layerClass
{
    return [PDSliderLayer class];
}

- (void)drawRect:(CGRect)rect {}

- (UIColor *)backProgressColor
{
    return [[self currentLayer] backProgressColor];
}

- (UIColor *)playbackColor
{
    return [[self currentLayer] playbackColor];
}

- (UIColor *)borderColor
{
    return [[self currentLayer] borderlineColor];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    [[self currentLayer] setBorderlineColor:borderColor];
    [self setNeedsDisplay];
}

- (void)setBackProgressColor:(UIColor *)backProgressColor
{
    [[self currentLayer] setBackProgressColor:backProgressColor];
    [self setNeedsDisplay];
}

- (void)setPlaybackColor:(UIColor *)playbackColor
{
    [[self currentLayer] setPlaybackColor:playbackColor];
    [self setNeedsDisplay];
}

- (void)setLoaded:(CGFloat)loaded
{
    [[self currentLayer] setLoaded:loaded];
    [self setNeedsDisplay];
}

- (void)setValue:(float)value
{
    [super setValue:value];
    [[self currentLayer] setValue:value];
    [self setNeedsDisplay];
}

- (void)setValue:(float)value animated:(BOOL)animated
{
    [super setValue:value animated:animated];
    [[self currentLayer] setValue:value];
    [self setNeedsDisplay];
}
@end
