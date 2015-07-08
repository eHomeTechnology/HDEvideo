//
//  SNMainWifiViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-18.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNMainWifiViewCtr.h"
#import "SNSoundViewCtr.h"
#import "HDBlurView.h"
#import "SNAddWifiViewCtr.h"
#import "SNResetWifiViewCtr.h"
#import "SNCameraInfo.h"

@interface SNMainWifiViewCtr ()<UITableViewDataSource, UITableViewDelegate, SNWifiViewCellDelegate>{

    IBOutlet UITableView    *tbv;
    IBOutlet UIButton       *btn_add;
    HDBlurView              *blurView;
    NSMutableArray          *mar_wifi;
    SNWifiViewCell          *menuingCell;
    SNSoundViewCtr          *soundViewCtr;
    SNAddWifiViewCtr        *addWifiViewCtr;
    SNResetWifiViewCtr      *resetWifiCtr;
    SNCameraInfo            *cameraInfo;
}

@end

@implementation SNMainWifiViewCtr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCamera:(SNCameraInfo *)cInfo
{
    if (self = [super init]) {
        cameraInfo = cInfo;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"摄像头Wi-Fi";
    
    if (IOS_VERSION >= 7.0) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    }else{
        UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_back.frame = CGRectMake(0, 0, 44, 25);
        [btn_back setImage:[UIImage imageNamed:@"icon_back.png"] forState:UIControlStateNormal];
        [btn_back addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_back];
    }
    
    if (!IS_4INCH_SCREEN) {
        btn_add.frame = CGRectMake(btn_add.frame.origin.x, btn_add.frame.origin.y - 88, btn_add.frame.size.width, btn_add.frame.size.height);
        tbv.frame = CGRectMake(0, 0, tbv.frame.size.width, tbv.frame.size.height - 88);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    mar_wifi = [SNGlobalInfo instance].userInfo.mar_wifi;
    [tbv reloadData];
}

#pragma mark - button action
-(void)backButtonAction:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SEL
- (IBAction)doAddWifi:(id)sender{
    UIView *keyWindow   = [UIApplication sharedApplication].keyWindow;
    blurView            = [[HDBlurView alloc] initWithFrame:keyWindow.frame];
    [keyWindow addSubview:blurView];
    addWifiViewCtr = [[SNAddWifiViewCtr alloc] init];
    [HDUtility showView:addWifiViewCtr.view centerAtPoint:keyWindow.center duration:ANIMATION_DURATION];
    [keyWindow addSubview:addWifiViewCtr.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doAddWifiCancel) name:@KEY_NOTI_WIFI_ADD object:nil];
}
- (void)doAddWifiCancel{
    [addWifiViewCtr.view removeFromSuperview];
    [blurView removeFromSuperview];
    addWifiViewCtr = nil;
    mar_wifi = [SNGlobalInfo instance].userInfo.mar_wifi;
    [tbv reloadData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@KEY_NOTI_WIFI_ADD object:nil];
    
}
- (void)doShareCancel{
    [blurView removeFromSuperview];
    [soundViewCtr.view removeFromSuperview];
    soundViewCtr    = nil;
    blurView        = nil;
    mar_wifi = [SNGlobalInfo instance].userInfo.mar_wifi;
    [tbv reloadData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@KEY_NOTI_WIFI_SHARE object:nil];
}
- (void)doResetCancel{
    [blurView removeFromSuperview];
    [resetWifiCtr.view removeFromSuperview];
    resetWifiCtr    = nil;
    blurView        = nil;
    [tbv reloadData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@KEY_NOTI_WIFI_SHARE object:nil];

}
#pragma mark - UITableViewDateSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return mar_wifi.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SNWifiViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"111"];
	if (cell == nil){
		cell = [[SNWifiViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"111"];
        cell.backgroundColor                = [UIColor clearColor];
        cell.contentView.backgroundColor    = [UIColor clearColor];
        cell.textLabel.textColor            = [UIColor whiteColor];
        cell.selectionStyle                 = UITableViewCellSelectionStyleNone;
        cell.textLabel.font                 = FONT_HEAD;
        cell.delegate                       = self;
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(0, CELL_HEIGHT - 2, cell.frame.size.width, 2.0f)];
        [imv setImage:[UIImage imageNamed:@"wifi_line.png"]];
        [cell addSubview:imv];
	}
    for(UIView *v in cell.accessoryView.subviews) {
        [v removeFromSuperview];
    }
    
    SNWIFIInfo *wifiInfo   = mar_wifi[indexPath.row];
    if (wifiInfo.sPassword.length > 0) {
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(14, 7, 9, 10)];
        [imv setImage:[UIImage imageNamed:@"加密.png"]];
        [cell.accessoryView addSubview:imv];
    }
    cell.textLabel.text = wifiInfo.sSSID;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (menuingCell) {
        [menuingCell setMenuOptionsViewHidden:YES animated:YES completionHandler:nil];
        return NO;
    }
    return YES;
}

#pragma mark - SNWifiViewCellDelegate
- (void)contextMenuDidShowInCell:(SNWifiViewCell *)cell{
    if (menuingCell) {
        [menuingCell setMenuOptionsViewHidden:YES animated:YES completionHandler:nil];
    }
    menuingCell = cell;
}
- (void)contextMenuCellDidSelectShareOption:(SNWifiViewCell *)cell{
    UIView *keyWindow   = [UIApplication sharedApplication].keyWindow;
    blurView            = [[HDBlurView alloc] initWithFrame:keyWindow.frame];
    [keyWindow addSubview:blurView];
    
    soundViewCtr = [[SNSoundViewCtr alloc] initWithSharedWifiInfo:mar_wifi[[tbv indexPathForCell:cell].row] camera:cameraInfo];
    [HDUtility showView:soundViewCtr.view centerAtPoint:keyWindow.center duration:ANIMATION_DURATION];
    [keyWindow addSubview:soundViewCtr.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doShareCancel) name:@KEY_NOTI_WIFI_SHARE object:nil];
}

- (void)contextMenuCellDidSelectResetOption:(SNWifiViewCell *)cell{
    UIView *keyWindow   = [UIApplication sharedApplication].keyWindow;
    blurView            = [[HDBlurView alloc] initWithFrame:keyWindow.frame];
    [keyWindow addSubview:blurView];
    
    resetWifiCtr = [[SNResetWifiViewCtr alloc] initWithWifiInfo:mar_wifi[[tbv indexPathForCell:cell].row]];
    [HDUtility showView:resetWifiCtr.view centerAtPoint:keyWindow.center duration:ANIMATION_DURATION];
    [keyWindow addSubview:resetWifiCtr.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doResetCancel) name:@KEY_NOTI_WIFI_RESET object:nil];
    
}

- (void)contextMenuCellDidSelectDeleteOption:(SNWifiViewCell *)cell{
    mar_wifi = [SNGlobalInfo instance].userInfo.mar_wifi;
    Dlog(@"------%ld", (long)[tbv indexPathForCell:cell].row);
    [mar_wifi removeObjectAtIndex:[tbv indexPathForCell:cell].row];
    Dlog(@"--%@", [SNGlobalInfo instance].userInfo);
    [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
    [tbv reloadData];
}

@end
