//
//  SEFilterControl.m
//
//  Created by Shady A. Elyaski on 6/13/12.
//  Updated by Artur Grigor on 04/15/2013.
//  Copyright (c) 2012 mash, ltd. All rights reserved.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "SEFilterControl.h"
#import "SEFilterKnob.h"

#define TITLE_SELECTED_DISTANCE 5
#define TITLE_FADE_ALPHA .5f

#define kSEFilterControlEllipseImageViewStartingTag     50

#define kSEFilterControlValueLabelWidth                 40.f
#define kSEFilterControlValueLabelHeight                20.f

#define kSEFilterControlControlRightMargin              10

#define kSEFilterControlKnobTop                         5
#define kSEFilterControlKnobLeft                        4
#define kSEFilterControlTrackTop                        13
#define kSEFilterControlTrackLeft                       16
#define kSEFilterControlTrackHeight                     6
#define kSEFilterControlTrackCornerRadius               8
#define kSEFilterControlEllipseTop                      11
#define kSEFilterControlEllipseSize                     12

#define kSEFilterControlDefaultAnimationDuration        0.3f
#define kSEFilterControlDefaultAnimationDelay           0.f
#define kSEFilterControlDefaultAnimationOptions         UIViewAnimationOptionCurveEaseOut

#define kSEFilterControlDefaultValueFont                [UIFont fontWithName:@"Helvetica" size:14]
#define kSEFilterControlDefaultValueTextColor           [UIColor blackColor]

@interface SEFilterControl ()
{
    CGPoint diffPoint;
}

@property (nonatomic) CGFloat oneSlotSize;

//
//  Controls
//

@property (nonatomic, strong) UIImageView *controlView;
@property (nonatomic, strong) UIImageView *trackView;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) SEFilterKnob *knob;

//
//  Animations
//

- (void)animateKnobToIndex:(NSUInteger)index;

//
//  Actions
//

- (void)didTap:(UITapGestureRecognizer *)tapGestureRecognizer;

- (void)didTouchDownForKnob:(id)sender withEvent:(UIEvent *)event;
- (void)didTouchUpOutsideForKnob:(id)sender;
- (void)didTouchDragForKnob:(id)sender withEvent:(UIEvent *)event;

//
//  Calculations
//

- (CGFloat)xForIndex:(NSUInteger)index withSideMargin:(CGFloat)sideMargin;
- (CGPoint)fixFinalPoint:(CGPoint)point;

//
//  Others
//

- (NSUInteger)getSelectedTitleInPoint:(CGPoint)point;
- (void)updateValueTextForIndex:(NSUInteger)index;

@end

@implementation SEFilterControl

#pragma mark - Properties

@synthesize
    valueFont = _valueFont,
    valueTextColor = _valueTextColor,

    trackBackgroundImage = _trackBackgroundImage,
    ellipseTrackBackgroundImage = _ellipseTrackBackgroundImage,
    backgroundImage = _backgroundImage,
    knobBackgroundImage = _knobBackgroundImage;

@synthesize
    selectedIndex = _selectedIndex,
    controlView = _controlView,
    trackView = _trackView,
    valueLabel = _valueLabel,
    knob = _knob;

@synthesize
    titles = _titles;

@synthesize
    oneSlotSize = _oneSlotSize;

- (void)setValueFont:(UIFont *)valueFont
{
    self.valueLabel.font = valueFont;
}

- (void)setValueTextColor:(UIColor *)valueTextColor
{
    self.valueLabel.textColor = valueTextColor;
}

- (void)setTrackBackgroundImage:(UIImage *)trackBackgroundImage
{
    self.trackView.image = trackBackgroundImage;
}

- (void)setEllipseTrackBackgroundImage:(UIImage *)ellipseTrackBackgroundImage
{
    _ellipseTrackBackgroundImage = [ellipseTrackBackgroundImage copy];
    
    for (NSUInteger i = 0; i < self.titles.count; i++)
    {
        UIImageView *imageView = (UIImageView *)[self.controlView viewWithTag:i + kSEFilterControlEllipseImageViewStartingTag];
        imageView.image = ellipseTrackBackgroundImage;
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    self.controlView.image = backgroundImage;
}

- (void)setKnobBackgroundImage:(UIImage *)knobBackgroundImage
{
    [self.knob setBackgroundImage:knobBackgroundImage forState:UIControlStateNormal];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    
    [self updateValueTextForIndex:selectedIndex];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    if (selectedIndex >= self.titles.count) selectedIndex = self.titles.count - 1;
    
    if (animated)
    {
        [self animateKnobToIndex:selectedIndex];
    }
    
    self.selectedIndex = selectedIndex;
}

- (UIImageView *)controlView
{
    if (! _controlView)
    {
        _controlView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - kSEFilterControlControlRightMargin - kSEFilterControlValueLabelWidth, self.frame.size.height)];
        _controlView.autoresizesSubviews = YES;
        _controlView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        _controlView.image = self.backgroundImage;
        _controlView.userInteractionEnabled = YES;
        
        [_controlView addSubview:self.trackView];
        [_controlView addSubview:self.knob];
        
        // Gestures
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTap:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    
    return _controlView;
}

- (UIImageView *)trackView
{
    if (! _trackView)
    {
        _trackView = [[UIImageView alloc] initWithFrame:CGRectMake(kSEFilterControlTrackLeft, kSEFilterControlTrackTop, self.controlView.frame.size.width - (2 * kSEFilterControlTrackLeft), kSEFilterControlTrackHeight)];
        _trackView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _trackView.image = self.trackBackgroundImage;
    }
    
    return _trackView;
}

- (UILabel *)valueLabel
{
    if (! _valueLabel)
    {
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - kSEFilterControlValueLabelWidth, (self.frame.size.height - kSEFilterControlValueLabelHeight) / 2, kSEFilterControlValueLabelWidth, kSEFilterControlValueLabelHeight)];
        _valueLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth;
        _valueLabel.minimumFontSize = 8.f;
        _valueLabel.adjustsFontSizeToFitWidth = YES;
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.textAlignment = UITextAlignmentCenter;
        
        [self updateValueTextForIndex:self.selectedIndex];
    }
    
    return _valueLabel;
}

- (SEFilterKnob *)knob
{
    if (! _knob)
    {
        _knob = [SEFilterKnob buttonWithType:UIButtonTypeCustom];
        _knob.frame = CGRectMake(kSEFilterControlKnobLeft, kSEFilterControlKnobTop, 24, 24);
        _knob.adjustsImageWhenHighlighted = NO;
        
        [_knob addTarget:self action:@selector(didTouchDownForKnob:withEvent:) forControlEvents:UIControlEventTouchDown];
        [_knob addTarget:self action:@selector(didTouchUpOutsideForKnob:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_knob addTarget:self action:@selector(didTouchDragForKnob:withEvent:) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
    }
    
    return _knob;
}

- (void)setTitles:(NSArray *)titles
{
    // Remove old ellipses
    
    for (NSUInteger i = 0; i < self.titles.count; i++)
    {
        UIView *view = [self.controlView viewWithTag:i + kSEFilterControlEllipseImageViewStartingTag];
        [view removeFromSuperview];
    }
    
    _titles = titles;
    
    for (NSUInteger i = 0; i < _titles.count; i++)
    {
        CGFloat w = ceil((self.controlView.frame.size.width - (2 * kSEFilterControlTrackLeft)) / (_titles.count - 1));
        CGFloat x = (i * w) + kSEFilterControlTrackLeft;
        
        // Draw Selection Circles
        
        UIImageView *ellipseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x - (kSEFilterControlEllipseSize / 2), kSEFilterControlEllipseTop, kSEFilterControlEllipseSize, kSEFilterControlEllipseSize)];
        ellipseImageView.image = self.ellipseTrackBackgroundImage;
        ellipseImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        ellipseImageView.tag = i + kSEFilterControlEllipseImageViewStartingTag;
        
        [self.controlView addSubview:ellipseImageView];
    }
    
    [self.controlView bringSubviewToFront:self.knob];
}

#pragma mark - Initialization

- (void)dealloc
{
    [self.knob removeTarget:self action:@selector(didTouchDownForKnob:withEvent:) forControlEvents:UIControlEventTouchDown];
    [self.knob removeTarget:self action:@selector(TouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.knob removeTarget:self action:@selector(TouchMove:withEvent:) forControlEvents: UIControlEventTouchDragOutside | UIControlEventTouchDragInside];
}

- (id)initWithFrame:(CGRect)frame andTitles:(NSArray *)titles
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Defaults
        
        self.valueFont = kSEFilterControlDefaultValueFont;
        self.valueTextColor = kSEFilterControlDefaultValueTextColor;
        
        // Others
        
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = YES;
        self.titles = titles;
        
        // Controls
        [self addSubview:self.controlView];
        [self addSubview:self.valueLabel];
        
        self.selectedIndex = 0;
    }
    
    return self;
}

#pragma mark - Animations

- (void)animateKnobToIndex:(NSUInteger)index
{
    __weak SEFilterControl *weakSelf = self;
    
    CGFloat x = [self xForIndex:index withSideMargin:kSEFilterControlTrackLeft] - (self.knob.frame.size.width / 2.f);
    
    [UIView animateWithDuration:kSEFilterControlDefaultAnimationDuration delay:kSEFilterControlDefaultAnimationDelay options:kSEFilterControlDefaultAnimationOptions animations:^
     {
         __strong SEFilterControl *strongSelf = weakSelf;
         
         strongSelf.knob.frame = CGRectMake(x, strongSelf.knob.frame.origin.y, strongSelf.knob.frame.size.width, strongSelf.knob.frame.size.height);
     } completion:nil];
}

#pragma mark - Actions

- (void)didTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSUInteger index = [self getSelectedTitleInPoint:[tapGestureRecognizer locationInView:self]];
    [self setSelectedIndex:index animated:YES];
    
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)didTouchDownForKnob:(id)sender withEvent:(UIEvent *)event
{
    SEFilterKnob *knob = (SEFilterKnob *)sender;
    
    CGPoint currentPoint = [[[event allTouches] anyObject] locationInView:self.controlView];
    diffPoint = CGPointMake(currentPoint.x - knob.frame.origin.x, currentPoint.y - knob.frame.origin.y);
    
    [self sendActionsForControlEvents:UIControlEventTouchDown];
}

- (void)didTouchUpOutsideForKnob:(id)sender
{
    SEFilterKnob *knob = (SEFilterKnob *)sender;
    
    NSUInteger selectedIndex = [self getSelectedTitleInPoint:knob.center];
    [self setSelectedIndex:selectedIndex animated:YES];
    
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)didTouchDragForKnob:(id)sender withEvent:(UIEvent *)event
{
    SEFilterKnob *knob = (SEFilterKnob *)sender;
    
    CGPoint currentPoint = [[[event allTouches] anyObject] locationInView:self.controlView];
    CGPoint toPoint = CGPointMake(currentPoint.x - diffPoint.x, self.knob.frame.origin.y);
    toPoint = [self fixFinalPoint:toPoint];
    
    [self.knob setFrame:CGRectMake(toPoint.x, toPoint.y, self.knob.frame.size.width, self.knob.frame.size.height)];
    
    NSUInteger index = [self getSelectedTitleInPoint:knob.center];
    [self updateValueTextForIndex:index];
    
    [self sendActionsForControlEvents:UIControlEventTouchDragInside];
}

#pragma mark - Calculations

- (CGFloat)xForIndex:(NSUInteger)index withSideMargin:(CGFloat)sideMargin
{
    return floor((index / (float)(self.titles.count - 1)) * (self.controlView.frame.size.width - (2 * sideMargin))) + sideMargin;
}

- (CGPoint)fixFinalPoint:(CGPoint)point
{
    if (point.x < kSEFilterControlKnobLeft)
    {
        point.x = kSEFilterControlKnobLeft;
    }
    if (point.x + (self.knob.frame.size.width / 2.f) > (self.controlView.frame.size.width - kSEFilterControlTrackLeft))
    {
        point.x = self.controlView.frame.size.width - (self.knob.frame.size.width / 2.f) - kSEFilterControlTrackLeft;
    }
    
    return point;
}

#pragma mark - Others

- (NSUInteger)getSelectedTitleInPoint:(CGPoint)point
{
    return floor(point.x / (((self.controlView.frame.size.width - (2 * kSEFilterControlTrackLeft)) + kSEFilterControlTrackLeft) / (self.titles.count - 1)));
}

- (void)updateValueTextForIndex:(NSUInteger)index
{
    self.valueLabel.text = self.titles[index];
}

@end