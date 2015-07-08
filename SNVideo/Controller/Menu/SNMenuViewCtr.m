//
//  SNMenuViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-2.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNMenuViewCtr.h"
#import "SNGuideViewCtr.h"
#import "SNHttpUtility.h"
#import "SNEventCenterViewCtr.h"

@interface SNMenuViewCtr ()<RESideMenuDelegate>{
    IBOutlet UIView         *v_head;
    IBOutlet UIButton       *btn_head;
    IBOutlet UILabel        *lb_name;
    HDBlurView              *blurView;
    SNGuideViewCtr          *guideViewCtr;
}

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation SNMenuViewCtr


- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IS_4INCH_SCREEN) {
        v_head.frame = CGRectMake(30, 80, v_head.frame.size.width, v_head.frame.size.height);
    }else{
        v_head.frame = CGRectMake(30, 30, v_head.frame.size.width, v_head.frame.size.height);
    }
    
    [self.view addSubview:v_head];
    self.sideMenuViewController.delegate    = self;
    btn_head.layer.cornerRadius             = btn_head.frame.size.width/2;
    btn_head.layer.masksToBounds            = YES;
    btn_head.layer.borderWidth              = 2.0f;
    btn_head.layer.borderColor              = [UIColor whiteColor].CGColor;
   
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(30, (self.view.frame.size.height - 54 * 5 - 123) / 2.0f + 123, self.view.frame.size.width/2, 54 * 5) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate          = self;
        tableView.dataSource        = self;
        tableView.opaque            = NO;
        tableView.backgroundColor   = [UIColor clearColor];
        tableView.backgroundView    = nil;
        tableView.separatorStyle    = UITableViewCellSeparatorStyleNone;
        tableView.bounces           = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];
}

- (IBAction)doShowProfile:(id)sender{
    [self.sideMenuViewController hideMenuViewController];
    if ([SNGlobalInfo instance].userInfo.registerType == SNRegisterTypeImei) {
        blurView            = [[HDBlurView alloc] initWithFrame:kWindow.frame];
        guideViewCtr        = [[SNGuideViewCtr alloc] init];
        [HDUtility showView:guideViewCtr.view centerAtPoint:kWindow.center duration:ANIMATION_DURATION];
        [kWindow addSubview:blurView];
        [kWindow addSubview:guideViewCtr.view];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doGuideViewCancel) name:@KEY_NOTI_GUIDE_VIEW object:nil];
        return;
    }
    UINavigationController *nav = (UINavigationController *)self.sideMenuViewController.contentViewController;
    [nav pushViewController:[[SNMyInfoViewCtr alloc] init] animated:YES];
}

- (void)doGuideViewCancel{

    [blurView removeFromSuperview];
    [guideViewCtr.view removeFromSuperview];
    blurView    = nil;
    guideViewCtr = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@KEY_NOTI_GUIDE_VIEW object:nil];
}
#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.sideMenuViewController hideMenuViewController];
    UINavigationController *nav = (UINavigationController *)self.sideMenuViewController.contentViewController;
    switch (indexPath.row) {
        case 0:{
            SNEventCenterViewCtr *event = [[SNEventCenterViewCtr alloc] init];
            [nav pushViewController:event animated:YES];
            break;
        }
        case 1:{
            if ([SNGlobalInfo instance].userInfo.registerType == SNRegisterTypeImei) {
                blurView            = [[HDBlurView alloc] initWithFrame:kWindow.frame];
                guideViewCtr        = [[SNGuideViewCtr alloc] init];
                [HDUtility showView:guideViewCtr.view centerAtPoint:kWindow.center duration:ANIMATION_DURATION];
                [kWindow addSubview:blurView];
                [kWindow addSubview:guideViewCtr.view];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doGuideViewCancel) name:@KEY_NOTI_GUIDE_VIEW object:nil];
                return;
            }
            [[SNHttpUtility sharedClient] referFriend_1:[SNGlobalInfo instance].userInfo CompletionBlock:^(BOOL isSuccess, NSArray *arrayFriend, NSString *sMessage) {
                if (isSuccess) {
                    
                    [SNGlobalInfo instance].userInfo.mar_friend = [[NSMutableArray alloc] initWithArray:arrayFriend];
                    [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
                }
            }];
            SNFriendViewCtr *ctr = [[SNFriendViewCtr alloc] init];
            [nav pushViewController:ctr animated:YES];
            break;
        }
        case 2:{
            SNPhotoViewCtr *ctr = [[SNPhotoViewCtr alloc] init];
            [nav pushViewController:ctr animated:YES];
            break;
        }
        case 3:{
            SNMsgCenterViewCtr *ctr =  [[SNMsgCenterViewCtr alloc] init];
            [nav pushViewController:ctr animated:YES];
            break;
        }
        case 4:{
            SNAboutViewCtr *ctr = [[SNAboutViewCtr alloc] init];
            [nav pushViewController:ctr animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor                = [UIColor clearColor];
        cell.textLabel.font                 = [UIFont fontWithName:@"HelveticaNeue" size:15];
        cell.textLabel.textColor            = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView         = [[UIView alloc] init];
        UIImageView *imv_line               = [[UIImageView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height-1, cell.frame.size.width, 0.5f)];
        imv_line.backgroundColor            = [UIColor whiteColor];
        imv_line.alpha                      = 0.5f;
        [cell.contentView addSubview:imv_line];
    }
    NSArray *titles         = @[@"我的事件", @"家人好友", @"家人相册", @"消息中心", @"关于e-see"];
    NSArray *images         = @[@"icon_menuEvent", @"icon_00", @"icon_02", @"icon_03", @"icon_04"];
    cell.textLabel.text     = titles[indexPath.row];
    cell.imageView.image    = [UIImage imageNamed:images[indexPath.row]];
    return cell;
}

#pragma mark - RESideMenuDelegate
- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController{
    NSString *sPath = [SNGlobalInfo instance].userInfo.sHeadPath;
    if (sPath.length > 0) {
        [btn_head setImage:[UIImage imageWithContentsOfFile:sPath] forState:UIControlStateNormal];
    }
    lb_name.text = [SNGlobalInfo instance].userInfo.sUserName;
}

@end
