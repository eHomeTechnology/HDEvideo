//
//  SNMsgCenterViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-19.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNMsgCenterViewCtr.h"
#import "SNMsgCell.h"
#import "SNHttpUtility.h"
#import "QBArrowRefreshControl.h"

@interface SNMsgCenterViewCtr ()<QBRefreshControlDelegate>
{
    IBOutlet UITableView *tbv_msg;
    NSMutableArray *ar_msgData;
    QBArrowRefreshControl *refreshCtr_msg;
}
@end

@implementation SNMsgCenterViewCtr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"消息中心";
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    ar_msgData = [[NSMutableArray alloc] init];
    refreshCtr_msg = [[QBArrowRefreshControl alloc] init];
    refreshCtr_msg.delegate = self;
    [tbv_msg addSubview:refreshCtr_msg];
    
    [refreshCtr_msg beginRefreshing];
    
    if (!IS_4INCH_SCREEN) {
        tbv_msg.frame = CGRectMake(tbv_msg.frame.origin.x, tbv_msg.frame.origin.y, tbv_msg.frame.size.width, tbv_msg.frame.size.height);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (int)distanceBetweenNowAndDate:(NSString *)sDate{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"YYYYMMDDHHMMSS"];
    NSDate *date=[formatter dateFromString:sDate];
    
    NSTimeInterval distance = -[date timeIntervalSinceNow];
    
    NSString *s = [NSString stringWithFormat:@"%f", distance / 86400];
    return [s intValue];
    
}

- (NSString *)getTimeFormMsgTime:(NSString *)mTime
{
    if ([mTime length] != 14) {
        Dlog(@"时间格式错误")
        return nil;
    }
    NSString *time_t1 = [mTime substringWithRange:NSMakeRange(8, 2)];
    NSString *time_t2 = [mTime substringWithRange:NSMakeRange(10, 2)];
    NSString *time = [NSString stringWithFormat:@"%@:%@", time_t1, time_t2];
    return time;
}

- (NSString *)getDateFormMsgTime:(NSString *)mTime
{
    if ([mTime length] != 14) {
        Dlog(@"时间格式错误")
        return nil;
    }
    NSString *date = nil;
    int fTime = [self distanceBetweenNowAndDate:mTime];
    if (fTime == 0) {
        date = @"";
    }else if(fTime == 1){
        date = @"昨天";
    }else{
        date = [mTime substringWithRange:NSMakeRange(4, 4)];
    }
    
    return date;
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ar_msgData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"msgCell";
    SNMsgCell * cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SNMsgCell" owner:self options:nil];
        for (NSObject *obj in objects) {
            if ([obj isKindOfClass:[SNMsgCell class]]) {
                
                cell = (SNMsgCell *)obj;
                break;
            }
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.imv_timeLine.frame = CGRectMake(55, 25, 4, 75);
        
    }else if (indexPath.row == [ar_msgData count] - 1){
        cell.imv_timeLine.frame = CGRectMake(55, 0, 4, 25);
        
    }else{
        cell.imv_timeLine.frame = CGRectMake(55, 0, 4, 100);
    }
    
    SNMessageInfo *msgInfo = [ar_msgData objectAtIndex:indexPath.row];
    if ([msgInfo.sMsgTime length] > 7) {
        cell.lb_time.text = [msgInfo.sMsgTime substringToIndex:5];
        cell.lb_date.text = [msgInfo.sMsgTime substringFromIndex:6];
    }

    cell.lb_content.text = msgInfo.sContent;
    if (msgInfo.msgType == SNMsgSystem) {
        cell.lb_title.text = MSG_SYSTEM;
    }else if (msgInfo.msgType == SNMsgDevicePush){
        cell.lb_title.text = MSG_DEVICEPUSH;
    }else if (msgInfo.msgType == SNMsgEvent){
        cell.lb_title.text = MSG_EVENT;
    }
//    [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"color_photo_01.png"]]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - QBRefreshControlDelegate

- (void)refreshControlDidBeginRefreshing:(QBRefreshControl *)refreshControl
{
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    [[SNHttpUtility sharedClient] referMessage_1:user CompletionBlock:^(BOOL isSuccess, NSArray *arrayMessage, NSString *sMessage) {
        if (isSuccess) {
            [ar_msgData removeAllObjects];
            [ar_msgData addObjectsFromArray:arrayMessage];
            [tbv_msg reloadData];
            
            [refreshControl endRefreshing];
        }
        
    }];
}
@end
