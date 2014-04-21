//
//  PNBarChart.m
//  PNChartDemo
//
//  Created by kevin on 11/7/13.
//  Copyright (c) 2013年 kevinzhow. All rights reserved.
//

#import "PNBarChart.h"
#import "PNColor.h"
#import "PNChartLabel.h"
#import "PNBar.h"

@interface PNBarChart () {
    NSMutableArray *_bars;
    NSMutableArray *_labels;
}

- (UIColor *)barColorAtIndex:(NSUInteger)index;
@end

@implementation PNBarChart

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds   = YES;
        _showLabel           = YES;
        _barBackgroundColor  = PNLightGrey;
        _labels              = [NSMutableArray array];
        _bars                = [NSMutableArray array];
        _minValueForYLabel   = 5;
    }

    return self;
}


- (void)setYValues:(NSArray *)yValues
{
    _yValues = yValues;
    [self setYLabels:yValues];

    _xLabelWidth = (self.frame.size.width - chartMargin * 2) / [_yValues count];
}


- (void)setYLabels:(NSArray *)yLabels
{
    NSInteger max = 0;

    for (NSString *valueString in yLabels) {
        NSInteger value = [valueString integerValue];

        if (value > max) {
            max = value;
        }
    }

    //Min value for Y label
    if (max < _minValueForYLabel) {
        max = _minValueForYLabel;
    }

    _yValueMax = (int)max;
}


- (void)setXLabels:(NSArray *)xLabels
{
    _xLabels = xLabels;

    if (_showLabel) {
        _xLabelWidth = (self.frame.size.width - chartMargin * 2) / [xLabels count];
    }
}


- (void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = strokeColor;
}


- (void)strokeChart
{
    [self viewCleanupForCollection:_labels];

    for (int index = 0; index < _xLabels.count; index++) {
        NSString *labelText = _xLabels[index];
        PNChartLabel *label = [[PNChartLabel alloc] initWithFrame:CGRectMake((index *  _xLabelWidth + chartMargin), self.frame.size.height - xLabelHeight - chartMargin, _xLabelWidth, xLabelHeight)];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.text = labelText;
        [_labels addObject:label];
        [self addSubview:label];
    }

    [self viewCleanupForCollection:_bars];

    CGFloat chartCavanHeight = self.frame.size.height - chartMargin * 2 - xLabelHeight * 2;
    NSInteger index = 0;

    for (NSString *valueString in _yValues) {
        float value = [valueString floatValue];

        float grade = (float)value / (float)_yValueMax;
        PNBar *bar;

        if (_showLabel) {
            bar = [[PNBar alloc] initWithFrame:CGRectMake((index *  _xLabelWidth + chartMargin + _xLabelWidth * 0.25), self.frame.size.height - chartCavanHeight - xLabelHeight - chartMargin, _xLabelWidth * 0.5, chartCavanHeight)];
        }
        else {
            bar = [[PNBar alloc] initWithFrame:CGRectMake((index *  _xLabelWidth + chartMargin + _xLabelWidth * 0.25), self.frame.size.height - chartCavanHeight, _xLabelWidth * 0.6, chartCavanHeight)];
        }

        bar.backgroundColor = _barBackgroundColor;
        bar.barColor = [self barColorAtIndex:index];
        bar.grade = grade;
        bar.tag = index;        
        [_bars addObject:bar];
        [self addSubview:bar];

        index += 1;
    }
}


- (void)viewCleanupForCollection:(NSMutableArray *)array
{
    if (array.count) {
        [array makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [array removeAllObjects];
    }
}


#pragma mark - Class extension methods

- (UIColor *)barColorAtIndex:(NSUInteger)index
{
    if ([self.strokeColors count] == [self.yValues count]) {
        return self.strokeColors[index];
    }
    else {
        return self.strokeColor;
    }
}


#pragma mark - Touch detection

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchPoint:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}


- (void)touchPoint:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Get the point user touched
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    UIView *subview = [self hitTest:touchPoint withEvent:nil];
    
    if ([subview isKindOfClass:[PNBar class]] && [self.delegate respondsToSelector:@selector(userClickedOnBarCharIndex:)]) {
        [self.delegate userClickedOnBarCharIndex:subview.tag];
    }
}


@end
