//
//  SEFilterControl.h
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


#import <UIKit/UIKit.h>

@interface SEFilterControl : UIControl
{

}

@property (nonatomic, strong) UIFont *valueFont UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *valueTextColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) UIImage *trackBackgroundImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIImage *ellipseTrackBackgroundImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIImage *backgroundImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIImage *knobBackgroundImage UI_APPEARANCE_SELECTOR;

@property (nonatomic) NSUInteger selectedIndex;

@property (nonatomic, strong) NSArray *titles;

- (id)initWithFrame:(CGRect)frame andTitles:(NSArray *)titles;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

@end