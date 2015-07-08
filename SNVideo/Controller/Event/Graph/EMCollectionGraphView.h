//
//  EMCollectionGraphView.h
//  EMTemperature
//
//  Created by Thinking on 14-3-1.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@protocol EMCollectionGraphViewDelegate;

@interface EMCollectionGraphView : UIView<CPTPlotDataSource,CPTAxisDelegate, CPTBarPlotDelegate>
{
    CPTXYAxis                   *y;
    CPTXYAxis                   *x;
    CPTXYPlotSpace              *plotSpace;
    CPTXYGraph                  *graph;             //画板
    CPTTimeFormatter            *timeFormatter;     
//    CPTScatterPlot              *dataSourceLinePlot;//线
    NSTimer                     *timer1;            //定时器
    int                         j;
    int                         r;
    float                       temperatuer;
}

@property (nonatomic, strong) NSMutableArray        *mar_dataForPlot;
@property (nonatomic, strong) NSMutableDictionary   *mdic_dataFprPlot;
@property (nonatomic, strong) NSDate                *firstTime;
@property (nonatomic, assign) float                 maxCount;
@property (nonatomic, assign) float                 minCount;

@property (nonatomic, strong)id <EMCollectionGraphViewDelegate> delegate;

- (void)drawGraph;

- (void)addLineWithIdentifier:(NSString *)identifier color:(CPTColor *)lineColor;

-(void)start;

-(void)refreshGraphView;

-(void)setAxis;

@end

@protocol EMCollectionGraphViewDelegate <NSObject>

@optional

-(void)backgroundButtonAction:(id)sender;
-(void)gotoInfoButtonAction:(id)sender;

@end