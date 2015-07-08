//
//  SNEventReportViewCtr.m
//  SNVideo
//
//  Created by Thinking on 14-10-31.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNEventReportViewCtr.h"
#import "SNEventReportCell.h"
#import "SNHttpUtility.h"
#import "MBProgressHUD.h"
#import "SNEventGraphView.h"
#import "SNPageControl.h"

@interface SNEventReportViewCtr ()
{
    IBOutlet UIScrollView   *scr_time;
    IBOutlet UIView         *v_report;
    IBOutlet UIScrollView   *scr_chart;
    IBOutlet UIView         *v_eventType;
    IBOutlet UIButton       *btn_all;
    IBOutlet UIButton       *btn_red;
    IBOutlet UIButton       *btn_yellow;
    IBOutlet UIButton       *btn_purle;
    IBOutlet SNPageControl  *pgc_time;
    IBOutlet UITableView    *tbv_result;
    
    SNEventType             e_type;
    int                     index_Device;
    NSMutableArray          *mar_devices;
    NSMutableArray          *mar_data;
    NSMutableArray          *mar_tbvData;
    NSDictionary            *dic_tbvData;
    NSMutableArray          *mar_graphView;
    
}
@end

@implementation SNEventReportViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    
    index_Device    = 0;
    mar_devices     = [[NSMutableArray alloc] init];
    mar_data        = [[NSMutableArray alloc] init];
    mar_tbvData     = [[NSMutableArray alloc] init];
    mar_graphView   = [[NSMutableArray alloc] init];
    e_type          = event_type_all;
    
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    [mar_devices addObjectsFromArray:user.mar_camera];
    
    pgc_time.imageRect      = CGRectMake(0, 0, 6, 6);
    pgc_time.img_active     = [UIImage imageNamed:@"event_pageCtr_02.png"];
    pgc_time.img_inactive   = [UIImage imageNamed:@"event_pageCtr_01.png"];
    pgc_time.currentPage    = 0;
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    HUD.labelText = @"网络加载中...";
    HUD.dimBackground = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    [HUD show:YES];
    
     [[SNHttpUtility sharedClient] getEventReport:user deviceID:nil date:nil CompletionBlock:^(BOOL isSuccess, NSArray *arrayReports, NSString *sMessage) {
         if (isSuccess) {
             [mar_data removeAllObjects];
             [mar_data addObjectsFromArray:arrayReports];
             NSMutableArray *mar_device_t = [[NSMutableArray alloc] init];
             
             for (int i = 0; i < mar_data.count; i++) {
                 SNEventReport *eventRep = [mar_data objectAtIndex:i];
                 SNCameraInfo *cInfo = nil;
                 for (int j = 0; j < mar_devices.count; j++) {
                     cInfo = [mar_devices objectAtIndex:j];
                     if ([cInfo.sDeviceId isEqualToString:eventRep.deviceID]) {
                         NSDictionary *dic_t = [SNEventReport classFullForEventType:eventRep.ar_weekReport];
                         SNEventGraphView *view_Graph = [[SNEventGraphView alloc] initWithFrame:CGRectMake(320 * i, 0, 320, 180) data:dic_t];
                         [scr_chart addSubview:view_Graph];
                         [view_Graph setBackgroundColor:[UIColor clearColor]];
                         [mar_graphView addObject:view_Graph];
                         
                         [mar_device_t addObject:cInfo];
                         
                         break;
                     }
                 }
                 
             }
             [mar_devices removeAllObjects];
             [mar_devices addObjectsFromArray:mar_device_t];
             [self refreshDeviceScrollView];
             
             [scr_chart setContentSize:CGSizeMake(320 * mar_data.count, 180)];
             
             [self refreshTableView];
         }
         
         [HUD hide:YES];
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - refresh view
- (void)refreshDeviceScrollView
{
    for (UIView *v_t in scr_time.subviews) {
        [v_t removeFromSuperview];
    }
    
    pgc_time.numberOfPages = mar_devices.count;
    pgc_time.currentPage   = 0;
    
    float width = scr_time.frame.size.width;
    for (int i = 0; i < mar_devices.count; i++) {
        UILabel *lb_time_t = [[UILabel alloc] initWithFrame:CGRectMake(width * i, 0, width, 15)];
        [lb_time_t setBackgroundColor:[UIColor clearColor]];
        [lb_time_t setTextAlignment:NSTextAlignmentCenter];
        [lb_time_t setTextColor:[UIColor colorWithRed:23/255.0 green:178/255.0 blue:178/255.0 alpha:1]];
        [lb_time_t setFont:[UIFont systemFontOfSize:15]];
        SNCameraInfo *cInfo = [mar_devices objectAtIndex:i];
        lb_time_t.text = cInfo.sDeviceName;
        [scr_time addSubview:lb_time_t];
    }
    
    [scr_time setContentSize:CGSizeMake(width * mar_devices.count, scr_time.frame.size.height)];
    [scr_time setContentOffset:CGPointMake(scr_time.frame.size.width * pgc_time.currentPage, 0) animated:NO];
    
}

- (void)refreshChartView
{
    switch (e_type) {
        case event_type_all:
            [self selectEventTypeAll:btn_all];
            break;
        case event_type_EP01:
            [self selectEventTypeRed:btn_red];
            break;
        case event_type_ES01:
            [self selectEventTypeYellow:btn_yellow];
            break;
        case event_type_ES02:
            [self selectEventTypePurle:btn_purle];
            break;
        default:
            break;
    }
    
}

- (void)refreshTableView
{
    SNCameraInfo *cInfo = [mar_devices objectAtIndex:index_Device];
    
    for (int i = 0; i < mar_data.count; i++) {
        SNEventReport *eventRep = [mar_data objectAtIndex:i];
        if ([cInfo.sDeviceId isEqualToString:eventRep.deviceID]) {
            dic_tbvData = [SNEventReport classFullForEventTime:eventRep.ar_weekReport];
            [mar_tbvData removeAllObjects];
            [mar_tbvData addObjectsFromArray:[dic_tbvData valueForKey:@"time"]];
            [tbv_result reloadData];
        }
    }
    
}

#pragma mark - button Action
- (IBAction)leftButtonAction:(UIButton *)btn
{
    if (pgc_time.currentPage >= pgc_time.numberOfPages - 1) {
        [HDUtility mbSay:@"没有了"];
        return;
    }
    pgc_time.currentPage++;
    [scr_time setContentOffset:CGPointMake(scr_time.frame.size.width * pgc_time.currentPage, 0) animated:YES];
    [scr_chart setContentOffset:CGPointMake(scr_chart.frame.size.width * pgc_time.currentPage, 0) animated:YES];
    index_Device = (int)pgc_time.currentPage;
    [self refreshChartView];
    [self refreshTableView];
}

- (IBAction)rightButtonAction:(UIButton *)btn
{
    if (pgc_time.currentPage <= 0) {
        [HDUtility mbSay:@"没有了"];
        return;
    }
    pgc_time.currentPage--;
    [scr_time setContentOffset:CGPointMake(scr_time.frame.size.width * pgc_time.currentPage, 0) animated:YES];
    [scr_chart setContentOffset:CGPointMake(scr_chart.frame.size.width * pgc_time.currentPage, 0) animated:YES];
    index_Device = (int)pgc_time.currentPage;
    [self refreshChartView];
    [self refreshTableView];
}

/* 初始化事件类型按钮图片 */
- (void)initEventTypeButton
{
    btn_all.selected    = NO;
    btn_red.selected    = NO;
    btn_yellow.selected = NO;
    btn_purle.selected  = NO;
}

- (IBAction)selectEventTypeAll:(UIButton *)btn
{
    [self initEventTypeButton];
    btn.selected = YES;
    e_type = event_type_all;
    SNEventGraphView *view_Graph = [mar_graphView objectAtIndex:index_Device];
    [view_Graph selectEventType:e_type];
}

- (IBAction)selectEventTypeRed:(UIButton *)btn
{
    [self initEventTypeButton];
    btn.selected = YES;
    e_type = event_type_EP01;
    SNEventGraphView *view_Graph = [mar_graphView objectAtIndex:index_Device];
    [view_Graph selectEventType:e_type];

}

- (IBAction)selectEventTypeYellow:(UIButton *)btn
{
    [self initEventTypeButton];
    btn.selected = YES;
    e_type = event_type_ES01;
    SNEventGraphView *view_Graph = [mar_graphView objectAtIndex:index_Device];
    [view_Graph selectEventType:e_type];
}

- (IBAction)selectEventTypePurle:(UIButton *)btn
{
    [self initEventTypeButton];
    btn.selected = YES;
    e_type = event_type_ES02;
    SNEventGraphView *view_Graph = [mar_graphView objectAtIndex:index_Device];
    [view_Graph selectEventType:e_type];
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mar_tbvData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"SNEventReportCell";
    SNEventReportCell * cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SNEventReportCell" owner:self options:nil];
        for (NSObject *obj in objects) {
            if ([obj isKindOfClass:[SNEventReportCell class]]) {
                
                cell = (SNEventReportCell *)obj;
                break;
            }
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.lb_time.text = [mar_tbvData objectAtIndex:indexPath.row];
    NSArray *ar_t = [dic_tbvData valueForKey:cell.lb_time.text];
    for (int i = 0; i < ar_t.count; i++) {
        SNEventReportInfo *reInfo = [ar_t objectAtIndex:i];
        
        UILabel *lb_ev_t = [[UILabel alloc] initWithFrame:CGRectMake(105, (5 + 30 * i), 170, 30)];
        [lb_ev_t setBackgroundColor:[UIColor clearColor]];
        [lb_ev_t setTextColor:[UIColor whiteColor]];
        [lb_ev_t setFont:[UIFont systemFontOfSize:15]];
        [cell.contentView addSubview:lb_ev_t];
        
        UIImageView *imv_ev_t = [[UIImageView alloc] initWithFrame:CGRectMake(85, lb_ev_t.frame.origin.y + 10, 10, 10)];
        [cell.contentView addSubview:imv_ev_t];
        
        if ([reInfo.type isEqualToString:@"EP01"]) {
            lb_ev_t.text = [NSString stringWithFormat:@"%@个沉迷报警", reInfo.count];
            [imv_ev_t setImage:[UIImage imageNamed:@"小标识_ep01.png"]];
        }else if ([reInfo.type isEqualToString:@"ES01"]){
            lb_ev_t.text = [NSString stringWithFormat:@"%@个高分贝报警", reInfo.count];
            [imv_ev_t setImage:[UIImage imageNamed:@"小标识_es01.png"]];
        }else if ([reInfo.type isEqualToString:@"ES02"]){
            lb_ev_t.text = [NSString stringWithFormat:@"%@个玻璃破碎报警", reInfo.count];
            [imv_ev_t setImage:[UIImage imageNamed:@"小标识_es02.png"]];
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == scr_time) {
        CGFloat pageWith = scrollView.frame.size.width;//页面宽度
        int pageNumber = floor((scrollView.contentOffset.x - pageWith / 2) / pageWith) + 1;
        pgc_time.currentPage = pageNumber;
        
    }else if (scrollView == scr_chart){
        CGFloat pageWith = scrollView.frame.size.width;//页面宽度
        int pageNumber = floor((scrollView.contentOffset.x - pageWith / 2) / pageWith) + 1;
        pgc_time.currentPage = pageNumber;
        
    }
    
     index_Device = (int)pgc_time.currentPage;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == scr_time){
        
        [scr_chart setContentOffset:CGPointMake(scr_chart.frame.size.width * index_Device, 0) animated:YES];
        [self refreshChartView];
        [self refreshTableView];
    }else if (scrollView == scr_chart){
        
        [scr_time setContentOffset:CGPointMake(scr_time.frame.size.width * index_Device, 0) animated:YES];
        [self refreshChartView];
        [self refreshTableView];
    }
}

- (IBAction)pageControlAction:(UIPageControl *)sender
{
    [scr_time setContentOffset:CGPointMake(scr_time.frame.size.width * sender.currentPage, 0) animated:YES];
    [scr_chart setContentOffset:CGPointMake(scr_chart.frame.size.width * index_Device, 0) animated:YES];
    [self refreshChartView];
    [self refreshTableView];
}

@end
