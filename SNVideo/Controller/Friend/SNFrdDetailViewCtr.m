//
//  SNFrdDetailViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-25.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNFrdDetailViewCtr.h"
#import "SNHttpUtility.h"
@interface SNFrdDetailViewCtr (){
    IBOutlet UIView         *v_sub;
    IBOutlet UIView         *v_cell;
    IBOutlet UIImageView    *imv_head;
    IBOutlet UILabel        *lb_name;
    IBOutlet UILabel        *lb_phone;
    IBOutlet UILabel        *lb_email;
    SNFriendInfo            *friendInfo;
}

@end

@implementation SNFrdDetailViewCtr

- (id)initWithInfo:(SNFriendInfo *)info{

    if (self = [super init]) {
        if (!info) {
            Dlog(@"传入参数错误！");
            return nil;
        }
        friendInfo = info;
        return self;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    v_sub.frame = CGRectMake(25, 100, CGRectGetWidth(v_sub.frame), CGRectGetHeight(v_sub.frame));
    [self.view addSubview:v_sub];
    v_cell.layer.borderWidth    = 0.5f;
    v_cell.layer.borderColor    = [UIColor colorWithRed:20/255. green:25/255. blue:32/255. alpha:1.0f].CGColor;
    [HDUtility circleTheView:imv_head];
    if (friendInfo.sImagePath.length > 0) {
        imv_head.image          = [UIImage imageWithContentsOfFile:friendInfo.sImagePath];
    }
    lb_phone.text               = friendInfo.sAccount;
    lb_email.text               = friendInfo.sEmail;
    lb_name.text = friendInfo.sNickName.length <= 0? @"未命名": friendInfo.sNickName;
}

#pragma mark - SEL

- (IBAction)doDeleteFriend:(id)sender{

    [[SNHttpUtility sharedClient] deleteFriend_1:[SNGlobalInfo instance].userInfo account:friendInfo.sAccount CompletionBlock:^(BOOL isSuccess, NSString *sMessage) {
        if (isSuccess) {
            SNUserInfo *user = [SNGlobalInfo instance].userInfo;
            for (int i = 0; i < user.mar_friend.count; i++) {
                SNFriendInfo *info = user.mar_friend[i];
                if ([info.sAccount isEqualToString:friendInfo.sAccount]) {
                    [user.mar_friend removeObjectAtIndex:i];
                    break;
                }
            }
            [HDUtility saveUserInfo:user];
            //更新摄像头列表
            [[SNHttpUtility sharedClient] referDevice_1:[SNGlobalInfo instance].userInfo deviceType:SNDeviceTypeCamera CompletionBlock:^(BOOL isSuccess, NSArray *ar_cameraInfo, NSString *sMessage) {
                if (isSuccess) {
                    [[SNGlobalInfo instance].userInfo.mar_camera removeAllObjects];
                    [SNGlobalInfo instance].userInfo.mar_camera = [[NSMutableArray alloc] initWithArray:ar_cameraInfo];
                    [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
                }else{
                    [HDUtility say:sMessage];
                }
            }];
            [HDUtility sayAfterSuccess:@"删除成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_FRIEND_DETAIL object:@"删除好友"];
        }else{
            [HDUtility sayAfterFail:@"删除失败"];
        }
    }];
}
- (void)doCancel:(UIButton *)sender{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_FRIEND_DETAIL object:@"取消"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    v_sub       = nil;
    v_cell      = nil;
    lb_email    = nil;
    lb_name     = nil;
    lb_phone    = nil;
    imv_head    = nil;
    friendInfo  = nil;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch          = [touches anyObject];
    UIView  *v              = [touch view];
    if ([v isEqual:self.view]) {
        [self doCancel:nil];
    }
    
}

@end
