//
//  SNEventSetViewCtr.m
//  SNVideo
//
//  Created by Thinking on 14-10-31.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNEventSetViewCtr.h"
#import "SNEventInfo.h"
#import "SNHttpUtility.h"
#import "HDBlurView.h"

@implementation SNEventButton


@end

@interface SNEventSetViewCtr (){
    
    IBOutlet UIScrollView   *scv_name;
    IBOutlet UIScrollView   *scv_cameras;
    IBOutlet UIButton       *btn_previous;
    IBOutlet UIButton       *btn_next;
    NSMutableArray          *mar_eventList;
    HDBlurView              *blurView;
    
    /*detail*/
    IBOutlet UIImageView    *imv_event;
    IBOutlet UIImageView    *imv_evntType;
    IBOutlet UILabel        *lb_eventName;
    IBOutlet UILabel        *lb_eventTypeName;
    IBOutlet UIView         *v_detail;
    IBOutlet UIButton       *btn_delete;
}

@end

@implementation SNEventSetViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    if (IS_35INCH_SCREEN) {
        scv_cameras.frame = CGRectMake(CGRectGetMinX(scv_cameras.frame), CGRectGetMinY(scv_cameras.frame), CGRectGetWidth(scv_cameras.frame), 325);
    }
    [[SNHttpUtility sharedClient] getEventSettingListCompletionBlock:^(BOOL isSuccess, NSArray *arList, NSString *sMessage) {
        Dlog(@"arList = %@", arList);
        mar_eventList = [[NSMutableArray alloc] initWithArray:arList];
        [self newCamerasPanel];
        [self newNameView];
        [NSThread detachNewThreadSelector:@selector(downLoadEventImages) toTarget:self withObject:nil];
    }];
    btn_previous.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    mar_eventList   = nil;
    scv_cameras     = nil;
    scv_name        = nil;
}

#pragma mark - privit

- (UIView *)newEventView:(SNEventInfo *)info{//构建一个事件的view
    UIView *v                   = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 100)];
    v.backgroundColor           = [UIColor clearColor];
    SNEventButton *btn_event    = [[SNEventButton alloc] initWithFrame:CGRectMake(0, 0, 140, 78)];
    btn_event.eventInfo         = info;
    btn_event.layer.borderColor = [UIColor whiteColor].CGColor;
    btn_event.layer.borderWidth = 1.0f;
    [btn_event setImage:[UIImage imageNamed:@"screenshot_pass.jpg"] forState:UIControlStateNormal];
    if (info.sImagePath.length > 0) {
        [btn_event setImage:[UIImage imageWithContentsOfFile:info.sImagePath] forState:UIControlStateNormal];
    }
    [btn_event addTarget:self action:@selector(showEventDetail:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imv_type           = [UIImageView new];
    imv_type.frame                  = CGRectMake(20, 88, 10, 10);
    imv_type.layer.cornerRadius     = CGRectGetHeight(imv_type.frame)/2;
    imv_type.layer.masksToBounds    = YES;
    UIImage *img                    = [self imageOfEventTypeId:info.sEventTypeID];
    imv_type.image                  = img;
    if (!img) {
        Dlog(@"获取事件类型image错误");
    }
    
    UILabel *lb_name        = [[UILabel alloc] init];
    lb_name.frame           = CGRectMake(35, 84, 90, 16);
    lb_name.font            = [UIFont fontWithName:@"Arial" size:13];
    lb_name.backgroundColor = [UIColor clearColor];
    lb_name.textColor       = [UIColor whiteColor];
    lb_name.textAlignment   = NSTextAlignmentCenter;
    lb_name.text            = info.sEventName;
    
    [v addSubview:lb_name];
    [v addSubview:imv_type];
    [v addSubview:btn_event];
    return v;
}

- (void)newNameView{//构建可左右滑动的name view
    for (int i = 0; i < mar_eventList.count; i++) {
        SNCameraEvents *cameraEvents = mar_eventList[i];
        UILabel *lb_name = [[UILabel alloc] init];
        lb_name.frame           = CGRectMake(i*130, 0, 130, 20);
        lb_name.font            = [UIFont fontWithName:@"Arial" size:15];
        lb_name.backgroundColor = [UIColor clearColor];
        lb_name.textColor       = COLOR_HILIGHT;
        lb_name.textAlignment   = NSTextAlignmentCenter;
        lb_name.text            = [self nameOfCameraWithId:cameraEvents.sDeviceID];
        [scv_name addSubview:lb_name];
        scv_name.contentSize    = CGSizeMake((i+1)*CGRectGetWidth(scv_name.frame), CGRectGetHeight(scv_name.frame));
    }
}

- (UIScrollView *)newEventsPanel:(SNCameraEvents *)cameraEvents{//构建一个摄像头的可上下拉动事件面板
    UIScrollView *scv_events = [[UIScrollView alloc] init];
    scv_events.frame = CGRectMake(10, 0, 300, CGRectGetHeight(scv_cameras.frame));
    for (int i = 0; i < cameraEvents.mar_events.count; i++) {
        UIView *v = [self newEventView:cameraEvents.mar_events[i]];
        v.frame = CGRectMake(160*(i%2), 20+130*(i/2), CGRectGetWidth(v.frame), CGRectGetHeight(v.frame));
        [scv_events addSubview:v];
        scv_events.contentSize = CGSizeMake(CGRectGetWidth(scv_events.frame), 130*(i/2+1));
    }
    return scv_events;
}

- (void)newCamerasPanel{//构建可左右滑动的多个camera的事件面板
    for (int i = 0; i < mar_eventList.count; i++) {
        UIScrollView *scv = [self newEventsPanel:mar_eventList[i]];
        scv.frame = CGRectMake(10+320*i, 0, CGRectGetWidth(scv.frame), CGRectGetHeight(scv.frame));
        [scv_cameras addSubview:scv];
        scv_cameras.contentSize = CGSizeMake(320*(i+1), CGRectGetHeight(scv_cameras.frame));
    }
}

- (void)showEventDetail:(SNEventButton *)sender{
    
    Dlog(@"sender.info = %@", sender.eventInfo);
    SNEventInfo *eventInfo  = sender.eventInfo;
    lb_eventName.text       = eventInfo.sEventName;
    lb_eventTypeName.text   = [self eventTypeNameWithTypeId:eventInfo.sEventTypeID];
    if (!blurView) {
        blurView        = [[HDBlurView alloc] initWithFrame:kWindow.frame];
    }
    [blurView.btn addTarget:self action:@selector(doCanelDetailView:) forControlEvents:UIControlEventTouchUpInside];
    imv_evntType.image  = [self imageOfEventTypeId:eventInfo.sEventTypeID];
    BOOL isSoundEvent = [eventInfo.sEventTypeID hasPrefix:@"ES"];
    v_detail.frame = CGRectMake(CGRectGetMinX(v_detail.frame), CGRectGetMinY(v_detail.frame), CGRectGetWidth(v_detail.frame), isSoundEvent? 270: 340);
    btn_delete.hidden = isSoundEvent;
    [HDUtility showView:v_detail centerAtPoint:kWindow.center duration:0.3];
    [self.navigationController.view addSubview:blurView];
    [self.navigationController.view addSubview:v_detail];
}
- (void)doCanelDetailView:(UIButton *)button{
    [blurView removeFromSuperview];
    [v_detail removeFromSuperview];
    blurView    = nil;
}
- (NSString *)nameOfCameraWithId:(NSString *)sID{
    if (sID.length == 0) {
        Dlog(@"参数“sID”不能为空");
        return nil;
    }
    SNUserInfo *user = [SNGlobalInfo instance].userInfo;
    for (SNCameraInfo *cameraInfo in user.mar_camera) {
        if ([cameraInfo.sDeviceId isEqualToString:sID]) {
            return cameraInfo.sDeviceName;
        }
    }
    return nil;
}

- (UIImage *)imageOfEventTypeId:(NSString *)sId{
    
    if ([sId isEqualToString:@"EP01"]) {
        return [UIImage imageNamed:@"小标识_ep01.png"];
    }
    if ([sId isEqualToString:@"ES01"]) {
        return [UIImage imageNamed:@"小标识_es01.png"];
    }
    if ([sId isEqualToString:@"ES02"]) {
        return [UIImage imageNamed:@"小标识_es02.png"];
    }
    return nil;
}
- (NSString *)eventTypeNameWithTypeId:(NSString *)sId{
    NSMutableArray *mar_eventType = [SNGlobalInfo instance].userInfo.mar_eventType;
    for (NSDictionary *dic in mar_eventType) {
        if ([dic[@"code"] isEqualToString:sId]) {
            return dic[@"name"];
        }
    }
    return nil;
}

- (void)downLoadEventImages{
    for (SNCameraEvents *cameraEnvents in mar_eventList) {
        for (SNEventInfo *eventInfo in cameraEnvents.mar_events) {
            NSString *sPath = [HDUtility imageWithUrl:eventInfo.sImageUrl savedFolderName:@FOLDER_EVENT savedFileName:nil];
            eventInfo.sImagePath = sPath;
        }
    }
    for (UIView *v in scv_cameras.subviews) {
        [v removeFromSuperview];
    }
    [self performSelectorOnMainThread:@selector(newCamerasPanel) withObject:nil waitUntilDone:NO];
}
#pragma mark - IBAction

- (IBAction)doShowNextOrPrevious:(UIButton *)sender{
    
    switch (sender.tag) {
        case 0:{//previous
            btn_next.enabled = YES;
            [scv_name setContentOffset:CGPointMake(scv_name.contentOffset.x - CGRectGetWidth(scv_name.frame), 0) animated:YES];
            [scv_cameras setContentOffset:CGPointMake(scv_cameras.contentOffset.x - CGRectGetWidth(scv_cameras.frame), 0) animated:YES];
            if (scv_name.contentOffset.x <= CGRectGetWidth(scv_name.frame)) {
                sender.enabled = NO;
            }
            break;
        }
        case 1:{//next
            btn_previous.enabled = YES;
            [scv_name setContentOffset:CGPointMake(scv_name.contentOffset.x + CGRectGetWidth(scv_name.frame), 0) animated:YES];
            [scv_cameras setContentOffset:CGPointMake(scv_cameras.contentOffset.x + CGRectGetWidth(scv_cameras.frame), 0) animated:YES];
            if (scv_name.contentOffset.x >= scv_name.contentSize.width - CGRectGetWidth(scv_name.frame)*2) {
                sender.enabled = NO;
            }
            Dlog(@"%f----%f", scv_name.contentOffset.x, scv_name.contentSize.width);
            break;
        }
        default:
            break;
    }
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
   
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.x == 0) {
        btn_previous.enabled = NO;
    }else{
        btn_previous.enabled = YES;
    }
    if (scrollView.contentOffset.x >= scrollView.contentSize.width - CGRectGetWidth(scrollView.frame)) {
        btn_next.enabled = NO;
    }else{
        btn_next.enabled = YES;
    }
    if ([scv_name isEqual:scrollView]) {
        CGPoint p = CGPointMake(scv_cameras.contentSize.width * (scv_name.contentOffset.x/scv_name.contentSize.width), 0);
        [scv_cameras setContentOffset:p animated:YES];
    }
    if ([scv_cameras isEqual:scrollView]) {
        CGPoint p = CGPointMake(scv_name.contentSize.width * (scv_cameras.contentOffset.x/scv_cameras.contentSize.width), 0);
        [scv_name setContentOffset:p animated:YES];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

    
}
@end
