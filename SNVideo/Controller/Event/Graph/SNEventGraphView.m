//
//  SNEvnetGraphView.m
//  SNVideo
//
//  Created by Thinking on 14-11-10.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNEventGraphView.h"
#import "EMCollectionGraphView.h"
#import "SNEventReport.h"

@interface SNEventGraphView ()
{
    NSDictionary            *dic_data;
    EMCollectionGraphView   *view_emGraph;
    SNEventType             e_type;
}

@end

@implementation SNEventGraphView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame data:(NSDictionary *)dic_t
{
    if (self == [super initWithFrame:frame]) {
        dic_data = [[NSDictionary alloc] initWithDictionary:dic_t];
        view_emGraph = [[EMCollectionGraphView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [view_emGraph setBackgroundColor:[UIColor clearColor]];
        [self addSubview:view_emGraph];
        [self setChartAxis];
        [self selectEventTypeAll];
        
    }
    
    return self;
}


- (void)setChartAxis
{
    NSArray    *ar_event_t = [dic_data objectForKey:@"ES01"];
    for (int j = 0; j < ar_event_t.count; j++) {
        SNEventReportInfo *eInfo = [ar_event_t objectAtIndex:j];
        float vaule = [eInfo.count floatValue];
        if (j == 0) {
            view_emGraph.firstTime = eInfo.date;
            view_emGraph.maxCount  = vaule;
            view_emGraph.minCount  = vaule;
        }else{
            if (vaule > view_emGraph.maxCount) {
                view_emGraph.maxCount = vaule;
            }
            if (vaule < view_emGraph.minCount) {
                view_emGraph.minCount = vaule;
            }
        }
    }
    
    NSArray    *ar_event_t2 = [dic_data objectForKey:@"ES02"];
    for (int j = 0; j < ar_event_t2.count; j++) {
        SNEventReportInfo *eInfo = [ar_event_t2 objectAtIndex:j];
        NSDate  *date_t = eInfo.date;
        
        if (j == 0 && (view_emGraph.firstTime == nil || [date_t timeIntervalSinceDate:view_emGraph.firstTime] < 0)) {
            view_emGraph.firstTime = eInfo.date;
        }
        float vaule = [eInfo.count floatValue];
        if (vaule > view_emGraph.maxCount) {
            view_emGraph.maxCount = vaule;
        }
        if (vaule < view_emGraph.minCount) {
            view_emGraph.minCount = vaule;
        }
    }
    
    NSArray    *ar_event_t3 = [dic_data objectForKey:@"EP01"];
    for (int j = 0; j < ar_event_t3.count; j++) {
        SNEventReportInfo *eInfo = [ar_event_t3 objectAtIndex:j];
        NSDate  *date_t = eInfo.date;
        if (j == 0 && (view_emGraph.firstTime == nil || [date_t timeIntervalSinceDate:view_emGraph.firstTime] < 0)) {
            view_emGraph.firstTime = eInfo.date;
        }
        float vaule = [eInfo.count floatValue];
        if (vaule > view_emGraph.maxCount) {
            view_emGraph.maxCount = vaule;
        }
        if (vaule < view_emGraph.minCount) {
            view_emGraph.minCount = vaule;
        }
    }
    
    [view_emGraph drawGraph];
}

- (void)addChartLineWithData:(NSDictionary *)dic_event type:(NSString *)typeKey
{
    NSArray *ar_event = [dic_event objectForKey:typeKey];
    if ([typeKey isEqualToString:@"EP01"]) {
        [view_emGraph addLineWithIdentifier:@"EP01" color:[CPTColor colorWithComponentRed:235/255.0 green:67/255.0 blue:92/255.0 alpha:1]];
    }else if ([typeKey isEqualToString:@"ES01"]){
        [view_emGraph addLineWithIdentifier:@"ES01" color:[CPTColor colorWithComponentRed:218/255.0 green:158/255.0 blue:44/255.0 alpha:1]];
    }else if ([typeKey isEqualToString:@"ES02"]){
        [view_emGraph addLineWithIdentifier:@"ES02" color:[CPTColor colorWithComponentRed:156/255.0 green:68/255.0 blue:195/255.0 alpha:1]];
    }
    
    for (int j = 0; j < ar_event.count; j++) {
        SNEventReportInfo *eInfo = [ar_event objectAtIndex:j];
        NSDate  *date_t = eInfo.date;
        NSTimeInterval interval = [date_t timeIntervalSinceDate:view_emGraph.firstTime];
        NSString *xp = [NSString stringWithFormat:@"%d", (int)interval];
        NSString *yp = [NSString stringWithFormat:@"%@", eInfo.count];
        NSMutableDictionary *point1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:xp, @"x", yp, @"y", nil];
        [[view_emGraph.mdic_dataFprPlot valueForKey:typeKey] addObject:point1];
    }
}

- (void)refreshChartView:(NSDictionary *)dic_t
{
    for (UIView *v_t in self.subviews) {
        if (v_t == view_emGraph) {
            [v_t removeFromSuperview];
            view_emGraph = nil;
        }
    }
    
    dic_data = nil;
    dic_data = [[NSDictionary alloc] initWithDictionary:dic_t];
    
    view_emGraph = [[EMCollectionGraphView alloc] initWithFrame:CGRectMake(0, 0, 320, 210)];
    [view_emGraph setBackgroundColor:[UIColor clearColor]];
    
    [self setChartAxis];
    [self addSubview:view_emGraph];
    
    switch (e_type) {
        case event_type_all:
        {
            [self selectEventTypeAll];
        }
            break;
        case event_type_EP01:
        {
            [self selectEventTypeRed];
        }
            break;
        case event_type_ES01:
        {
            [self selectEventTypeYellow];
        }
            break;
        case event_type_ES02:
        {
            [self selectEventTypePurle];
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - selectType
- (void)selectEventType:(SNEventType)type_T
{
    switch (type_T) {
        case event_type_all:
            [self selectEventTypeAll];
            break;
        case event_type_EP01:
            [self selectEventTypeRed];
            break;
        case event_type_ES01:
            [self selectEventTypeYellow];
            break;
        case event_type_ES02:
            [self selectEventTypePurle];
            break;
        default:
            break;
    }
}

- (void)selectEventTypeAll
{
    [view_emGraph.mdic_dataFprPlot removeAllObjects];
    
    [self addChartLineWithData:dic_data type:@"EP01"];
    [self addChartLineWithData:dic_data type:@"ES01"];
    [self addChartLineWithData:dic_data type:@"ES02"];
    [view_emGraph refreshGraphView];
    
    e_type = event_type_all;
}

- (void)selectEventTypeRed
{
    [view_emGraph.mdic_dataFprPlot removeAllObjects];
   
    [self addChartLineWithData:dic_data type:@"EP01"];
    [view_emGraph refreshGraphView];
    
    e_type = event_type_EP01;
}

- (void)selectEventTypeYellow
{
    [view_emGraph.mdic_dataFprPlot removeAllObjects];
    
    [self addChartLineWithData:dic_data type:@"ES01"];
    [view_emGraph refreshGraphView];
    
    e_type = event_type_ES01;
}

- (void)selectEventTypePurle
{
    [view_emGraph.mdic_dataFprPlot removeAllObjects];
   
    [self addChartLineWithData:dic_data type:@"ES02"];
    [view_emGraph refreshGraphView];
    
    e_type = event_type_ES02;
}


@end
