//
//  SNFriendViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-19.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNFriendViewCtr.h"
#import "SNFriendViewCtr.h"
#import "SNButtonItem.h"
#import "SNAccFriendViewCtr.h"
#import "SNScanViewCtr.h"
#import "SNBarcodeViewCtr.h"
#import "SNFrdDetailViewCtr.h"
#import "SNHttpUtility.h"

@interface SNFriendViewCtr ()<UIScrollViewDelegate, SNButtonItemDelegate>{

    IBOutlet UIButton       *btn_add;
    IBOutlet UIScrollView   *scrView;
    NSMutableArray          *mar_friendInfo;
    UIPageControl           *pageControl;
    HDBlurView              *v_blur;
    SNButtonItem            *buttonItem;
    SNAccFriendViewCtr      *accFriendCtr;
    SNBarcodeViewCtr        *barcodeCtr;
    SNScanViewCtr           *scanViewCtr;
    SNFrdDetailViewCtr      *friendDetailViewCtr;
    UIView                  *selectedView;
}

@end

@implementation SNFriendViewCtr

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title                  = @"家人好友";
    self.view.backgroundColor   = [UIColor colorWithPatternImage:[UIImage imageNamed:@"color_gray.jpg"]];
    CGFloat Y = IS_4INCH_SCREEN? CGRectGetHeight(self.view.frame)-70-84: CGRectGetHeight(self.view.frame)-70-160;
    if (IOS_VERSION < 7.0) {
        Y = Y + 20;
    }
    [btn_add setFrame:CGRectMake(125, Y, 70, 70)];
    [HDUtility circleWithNoBorder:btn_add];
    [self.view addSubview:btn_add];
    mar_friendInfo                              = [SNGlobalInfo instance].userInfo.mar_friend;
    pageControl                                 = [[UIPageControl alloc] init];
    pageControl.hidesForSinglePage              = NO;
    pageControl.numberOfPages                   = mar_friendInfo.count/10 + 1;
    pageControl.pageIndicatorTintColor          = [UIColor colorWithRed:57.0f/255.0f green:73.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
    pageControl.currentPageIndicatorTintColor   = [UIColor colorWithRed:24.0f/255.0f green:130.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
    pageControl.frame                           = CGRectMake(110, 390-(IS_4INCH_SCREEN? 0: 75), 100, 20);
    pageControl.currentPage                     = 0;
    [self.view insertSubview:pageControl aboveSubview:scrView];
    [NSThread detachNewThreadSelector:@selector(downloadImage) toTarget:self withObject:nil];
    [self refreshFriendInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)downloadImage{
    mar_friendInfo = [SNGlobalInfo instance].userInfo.mar_friend;
    BOOL hasNewImage = NO;
    for (int i = 0; i < mar_friendInfo.count; i++) {
        SNFriendInfo *fdInfo        = mar_friendInfo[i];
        if (fdInfo.sImagePath.length > 0) {
            continue;
        }
        hasNewImage = YES;
        if (fdInfo.sImageUrl.length > 0) {//如果有网络图片
//            NSString *sImagename    = [fdInfo.sImageUrl lastPathComponent];
//            NSString *sPath         = [HDUtility pathOfSavedImageName:sImagename folderName:@"friend"];
//            NSFileManager *manager  = [NSFileManager defaultManager];
//            if (![manager fileExistsAtPath:sPath]) {//图片本地路径若不存在，保存
//                UIImage *image      = [HDUtility imageWithUrl:fdInfo.sImageUrl];
//                BOOL isSuc = [HDUtility saveToDocument:image withFilePath:sPath];
//                if (!isSuc) {
//                    Dlog(@"保存图片失败");
//                }
//            }
            NSString *sPath     = [HDUtility imageWithUrl:fdInfo.sImageUrl savedFolderName:@FOLDER_FRIEND savedFileName:nil];
            fdInfo.sImagePath   = sPath;
        }
    }
    if (hasNewImage) {
        [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
        [self performSelectorOnMainThread:@selector(refreshFriendInfo) withObject:nil waitUntilDone:NO];
    }
}

- (void)refreshFriendInfo{

    for (UIView *v in scrView.subviews) {
        [v removeFromSuperview];
    }
    mar_friendInfo              = [SNGlobalInfo instance].userInfo.mar_friend;
    pageControl.numberOfPages   = mar_friendInfo.count/10 + 1;
    scrView.contentSize         = CGSizeMake(320*(mar_friendInfo.count/10 + 1), scrView.frame.size.height);
    for (int i = 0; i < mar_friendInfo.count; i++) {
        SNFriendInfo *info      = (SNFriendInfo *)mar_friendInfo[i];
        float fit               = IS_4INCH_SCREEN? 128.0f: 100;
        UIButton *btn           = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame               = CGRectMake(30 + (i%3)*98.0f + 320*(i/9), 20 + (i%9)/3*(fit), 65, 65);
        btn.layer.borderWidth   = 1.0f;
        btn.layer.borderColor   = [UIColor colorWithRed:183.0f/255.0f green:184.0f/255.0f blue:189.0f/255.0f alpha:1.0].CGColor;
        btn.layer.cornerRadius  = btn.frame.size.width/2;
        btn.layer.masksToBounds = YES;
        btn.tag                 = i;
        CGRect rect             = CGRectMake(30 + (i%3)*98.0f + 320*(i/9), 90 + (i%9)/3*(fit), 65, 30);
        UILabel *lb             = [[UILabel alloc] initWithFrame:rect];
        lb.backgroundColor      = [UIColor clearColor];
        lb.textColor            = [UIColor whiteColor];
        lb.font                 = [UIFont fontWithName:@"Arial" size:15];
        lb.textAlignment        = NSTextAlignmentCenter;
        NSString *sName         = info.sNickName;
        lb.text                 = sName.length <= 0? @"未命名" :sName;
        [btn addTarget:self action:@selector(doShowDetail:) forControlEvents:UIControlEventTouchUpInside];
        [btn setImage:[UIImage imageNamed:@"head_default.jpg"] forState:UIControlStateNormal];
        if (info.sImagePath.length > 0) {
            [btn setImage:[UIImage imageWithContentsOfFile:info.sImagePath] forState:UIControlStateNormal];
        }
        [scrView    addSubview:btn];
        [scrView    addSubview:lb];
    }
}

#pragma mark - SEL
- (void)doShowDetail:(UIButton *)sender{
    if (!v_blur) {
        v_blur                  = [[HDBlurView alloc] initWithFrame:kWindow.frame];
    }
    SNFriendInfo *info          = mar_friendInfo[sender.tag];
    friendDetailViewCtr         = [[SNFrdDetailViewCtr alloc] initWithInfo:info];
    [HDUtility view:friendDetailViewCtr.view appearAt:kWindow.center withDalay:0.1 duration:0.2];
    [kWindow addSubview:v_blur];
    [kWindow addSubview:friendDetailViewCtr.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doDetailCancel:) name:@KEY_NOTI_FRIEND_DETAIL object:nil];
}

- (IBAction)doAddAccount:(id)sender{
    accFriendCtr    = [[SNAccFriendViewCtr alloc] init];
    scanViewCtr     = [[SNScanViewCtr alloc] init];
    barcodeCtr      = [[SNBarcodeViewCtr alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doAddCancel) name:@KEY_NOTI_FRIEND_ADD object:nil];
    [UIView animateWithDuration:ANIMATION_DURATION/2 animations:^{
        btn_add.frame = CGRectMake(240, CGRectGetMinY(btn_add.frame), CGRectGetWidth(btn_add.frame),CGRectGetHeight(btn_add.frame));
    } completion:^(BOOL finished) {
        btn_add.hidden          = YES;
        [UIView animateWithDuration:ANIMATION_DURATION/2 animations:^{
            if (!v_blur) {
                v_blur          = [[HDBlurView alloc] initWithFrame:kWindow.frame];
            }
            [kWindow addSubview:v_blur];
        } completion:^(BOOL finished) {
            buttonItem          = [[SNButtonItem alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(btn_add.frame)+64, 320, 70)];//HDDeviceSize.height - 90
            buttonItem.delegate = self;
            [kWindow addSubview:buttonItem];
            [buttonItem show];
            [self SNDelegateTouchWithItem:SNButtonItemTypeAccount];
        }];
    }];
}
- (void)doDetailCancel:(NSNotification *)noti{
    NSString *s = noti.object;
    [v_blur removeFromSuperview];
    [friendDetailViewCtr.view removeFromSuperview];
    friendDetailViewCtr = nil;
    v_blur              = nil;
    if ([s isEqualToString:@"删除好友"]) {
        [self refreshFriendInfo];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@KEY_NOTI_FRIEND_DETAIL object:nil];
    
}
- (void)doAddCancel{
    [v_blur             removeFromSuperview];
    [accFriendCtr.view  removeFromSuperview];
    [buttonItem         removeFromSuperview];
    if (scanViewCtr) {
        [scanViewCtr.view removeFromSuperview];
    }
    if (barcodeCtr) {
        [barcodeCtr.view removeFromSuperview];
    }
    accFriendCtr        = nil;
    barcodeCtr          = nil;
    scanViewCtr         = nil;
    v_blur              = nil;
    buttonItem          = nil;
    btn_add.hidden      = NO;
    [UIView animateWithDuration:ANIMATION_DURATION/2 animations:^{
        btn_add.frame   = CGRectMake(125, CGRectGetMinY(btn_add.frame), 70, 70);
    } completion:^(BOOL finished) {
        [self refreshFriendInfo];
    }];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@KEY_NOTI_FRIEND_ADD object:nil];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    [pageControl setCurrentPage:scrollView.contentOffset.x/320];
}

#pragma mark - SNButtonItemDelegate
- (void)SNDelegateTouchWithItem:(SNButtonItemType)iType{
    accFriendCtr.v_sub.hidden   = YES;
    scanViewCtr.view.hidden     = YES;
    barcodeCtr.view.hidden      = YES;
    switch (iType) {
        case SNButtonItemTypeAccount:{
            accFriendCtr.v_sub.hidden = NO;
            [kWindow addSubview:accFriendCtr.view];
            [kWindow bringSubviewToFront:buttonItem];
            [HDUtility view:accFriendCtr.view appearAt:kWindow.center withDalay:0.1 duration:0.2];
            ((UIButton *)buttonItem.mar_buttons[2]).backgroundColor = COLOR_HILIGHT;
            break;
        }
        case SNButtonItemTypeScan:{
            scanViewCtr.view.hidden = NO;
            [accFriendCtr.view addSubview:scanViewCtr.view];
            [HDUtility view:scanViewCtr.view appearAt:accFriendCtr.v_sub.center withDalay:0.1 duration:0.2];
            break;
        }
        case SNButtonItemTypeBarcode:{
            barcodeCtr.view.hidden = NO;
            [accFriendCtr.view addSubview:barcodeCtr.view];
            [HDUtility view:barcodeCtr.view appearAt:accFriendCtr.v_sub.center withDalay:0.1 duration:0.2];
            break;
        }
        case SNButtonItemTypeAdd:{
            [self doAddCancel];
            break;
        }
        default:
            break;
    }
}
@end
