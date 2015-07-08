//
//  SNSetDeviceViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-28.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNSetDeviceViewCtr.h"
#import "SNMainWifiViewCtr.h"
#import "HDBlurView.h"
#import "SNHttpUtility.h"
#import "SNDeleteDeviceViewCtr.h"

#define HEIGHT_ROW 60
#define COLOR_BORDER    [UIColor colorWithRed:28/255.0f green:36/255.0f blue:49/255.0f alpha:1.0f]
#define COLOR_CELL_BACK [UIColor colorWithRed:41/255.0f green:52/255.0f blue:66/255.0f alpha:1.0f];
@interface SNSetDeviceViewCtr ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MBProgressHUDDelegate, UIAlertViewDelegate>{

    IBOutlet UITableView    *tbv;
    IBOutlet UISwitch       *sw_share;      //共享开关
    IBOutlet UIButton       *btn_delete;
    IBOutlet UITextField    *tf_name;
    IBOutlet UIButton       *btn_shutUp;
    IBOutlet UIButton       *btn_high;
    IBOutlet UIButton       *btn_low;
    HDBlurView              *blurView;
    NSArray                 *ar_title;
    NSMutableDictionary     *mdic_code;
    SNDeleteDeviceViewCtr   *deleteViewCtr;
    BOOL                    hasUserChangedSomthing;
    SNUserInfo              *userInfo;
}

@property (strong) SNCameraInfo *cameraInfo;

@end

@implementation SNSetDeviceViewCtr

- (id)initWithCamera:(SNCameraInfo *)info{
    if (!info) {
        Dlog(@"传入参数错误！");
        return nil;
    }
    if (self = [super init]) {
        _cameraInfo = info;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    Dlog(@"userInfo = %@", [SNGlobalInfo instance].userInfo);
    self.navigationItem.title   = @"设置设备";
    if (!IS_4INCH_SCREEN) {
        btn_delete.center = CGPointMake(btn_delete.center.x, btn_delete.center.y - 88);
    }
    hasUserChangedSomthing      = NO;
    if (IOS_VERSION >= 7.0) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonAction:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_complete.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(completeButtonAction:)];
    }else{
        UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_back.frame = CGRectMake(0, 0, 25, 25);
        [btn_back setImage:[UIImage imageNamed:@"icon_back.png"] forState:UIControlStateNormal];
        [btn_back addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_back];
        
        UIButton *btn_complete = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_complete.frame = CGRectMake(0, 0, 25, 25);
        [btn_complete setImage:[UIImage imageNamed:@"icon_complete.png"] forState:UIControlStateNormal];
        [btn_complete addTarget:self action:@selector(completeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_complete];
    }
    userInfo                        = [SNGlobalInfo instance].userInfo;
    sw_share.on                     = _cameraInfo.shareStatus;
    tf_name.hidden                  = YES;
    tf_name.backgroundColor         = COLOR_CELL_BACK;
    tf_name.text                    = _cameraInfo.sDeviceName;
    NSMutableArray *mar_eventName   = [[NSMutableArray alloc] init];
    for (NSDictionary *dc in userInfo.mar_eventType) {
        [mar_eventName addObject:dc[@"name"]];
    }
    ar_title                        = @[@[@"名称", @"共享", @"智能码流", @"当前WIFI"],
                                        mar_eventName,
                                        @[@"在线状态", @"设备号"]
                                        ];
    [self refreshCodeStreamUI:_cameraInfo.staticStream];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonAction:(UIButton *)btn
{
    if (hasUserChangedSomthing) {
        [HDUtility say2:@"当前修改未提交，确定返回？" Delegate:self];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)completeButtonAction:(UIButton *)btn{
    if ([tf_name isFirstResponder]) {
        [tf_name resignFirstResponder];
    }
    if (!hasUserChangedSomthing) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    _cameraInfo.sDeviceName = tf_name.text;
    if (![HDUtility isValidateName:self.cameraInfo.sDeviceName]) {
        [HDUtility say:@"请输入2-8位数字字母或汉字"];
        return;
    }
    [[SNHttpUtility sharedClient] deviceInfoUpdate_1:[SNGlobalInfo instance].userInfo devicInfo:_cameraInfo CompletionBlock:^(BOOL isSuccess, NSString *sMessage) {
        if (isSuccess) {
            userInfo = [SNGlobalInfo instance].userInfo;
            for (int i = 0; i < userInfo.mar_camera.count; i++) {
                SNCameraInfo *cInfo = userInfo.mar_camera[i];
                if ([cInfo.sDeviceId isEqualToString:_cameraInfo.sDeviceId]) {
                    [userInfo.mar_camera replaceObjectAtIndex:i withObject:_cameraInfo];
                    break;
                }
            }
            [HDUtility saveUserInfo:userInfo];
            [HDUtility sayAfterSuccess:@"修改成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [HDUtility sayAfterFail:@"提交失败"];
        }
    }];
}

#pragma mark - UITableViewDateSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return HEIGHT_ROW;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 4;
    }
    if (section == 1) {
        return _cameraInfo.mar_event.count;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
     UITableViewCell *cell;
    UIColor *color_cellBack         = [UIColor colorWithRed:41/255. green:52/255. blue:66/255. alpha:1.0f];
    cell                            = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"111"];
    cell.backgroundColor            = color_cellBack;
    cell.textLabel.text             = ar_title[indexPath.section][indexPath.row];
    cell.textLabel.textColor        = [UIColor whiteColor];
    cell.detailTextLabel.textColor  = COLOR_HILIGHT;

    switch (indexPath.section) {
        case 0:{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            switch (indexPath.row) {
                case 0:{
                    cell.detailTextLabel.text   = _cameraInfo.sDeviceName;
                    UIView *v                   = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0.5)];
                    v.backgroundColor           = COLOR_BORDER;
                    [cell addSubview:v];
                    [cell.contentView addSubview:tf_name];
                    break;
                }
                case 1:{
                    sw_share.hidden             = NO;
                    sw_share.frame              = CGRectMake(0, 0, CGRectGetWidth(sw_share.frame), CGRectGetHeight(sw_share.frame));
                    cell.accessoryView          = sw_share;
                    cell.accessoryType          = UITableViewCellAccessoryNone;
                    cell.selectionStyle         = UITableViewCellSelectionStyleNone;
                    cell.layer.borderWidth      = 0.5f;
                    cell.layer.borderColor      = COLOR_BORDER.CGColor;
                    break;
                }
                case 2:{
                    cell.accessoryType          = UITableViewCellAccessoryNone;
                    cell.selectionStyle         = UITableViewCellSelectionStyleNone;
                    btn_low.frame               = CGRectMake(140, 7, CGRectGetWidth(btn_low.frame), CGRectGetHeight(btn_low.frame));
                    btn_high.frame              = CGRectMake(200, 7, CGRectGetWidth(btn_high.frame), CGRectGetHeight(btn_high.frame));
                    btn_shutUp.frame            = CGRectMake(260, 7, CGRectGetWidth(btn_shutUp.frame), CGRectGetHeight(btn_shutUp.frame));
                    [cell addSubview:btn_low];
                    [cell addSubview:btn_high];
                    [cell addSubview:btn_shutUp];
                    break;
                }
                case 3:{
                    cell.layer.borderWidth      = 0.5f;
                    cell.layer.borderColor      = COLOR_BORDER.CGColor;
                    cell.detailTextLabel.text   = _cameraInfo.wifiInfo.sSSID;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1:{
            cell.selectionStyle             = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.text       = nil;
            cell.accessoryType              = UITableViewCellAccessoryNone;
            UISwitch *sw                    = [[UISwitch alloc] init];
            sw.frame                        = CGRectMake(0, 0, 50, 50);
            if (cell.accessoryView) {
                cell.accessoryView = nil;
            }
            cell.accessoryView              = sw;
            sw.tag                          = indexPath.row;
            sw.on                           = [_cameraInfo.mar_event[indexPath.row][@"value"] boolValue];
            [sw addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
            if (indexPath.row%2 == 0) {
                cell.layer.borderWidth      = 0.5f;
                cell.layer.borderColor      = COLOR_BORDER.CGColor;
            }
            break;
        }
        case 2:{
            cell.detailTextLabel.alpha      = 0.5;
            cell.userInteractionEnabled     = NO;
            if (indexPath.row == 0) {
                cell.detailTextLabel.text   = _cameraInfo.lineStatus? @"在线": @"离线";
                cell.layer.borderWidth      = 0.5f;
                cell.layer.borderColor      = COLOR_BORDER.CGColor;
            }else{
                UIImageView *imv            = [[UIImageView alloc] initWithFrame:CGRectMake(0, HEIGHT_ROW-0.5f, CGRectGetWidth(cell.frame), 0.5f)];
                imv.backgroundColor         = COLOR_BORDER;
                cell.detailTextLabel.text   = _cameraInfo.sDeviceCode;
                [cell addSubview:imv];
            }
            break;
        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    hasUserChangedSomthing = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section > 0) {
        return;
    }
    if (indexPath.row == 0) {
        tf_name.hidden = NO;
        [tf_name becomeFirstResponder];
    }
    if (indexPath.row == 3) {
        SNMainWifiViewCtr *ctr = [[SNMainWifiViewCtr alloc] initWithCamera:_cameraInfo];
        [self.navigationController pushViewController:ctr animated:YES];
    }
}

#pragma mark - SEL
- (IBAction)doDelete:(id)sender{
    blurView            = [[HDBlurView alloc] initWithFrame:kWindow.frame];
    deleteViewCtr       = [[SNDeleteDeviceViewCtr alloc] initWithInfo:_cameraInfo];
    [HDUtility showView:deleteViewCtr.view centerAtPoint:kWindow.center duration:ANIMATION_DURATION];
    [kWindow addSubview:blurView];
    [kWindow addSubview:deleteViewCtr.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteDeviceViewCtrCancel:) name:@KEY_NOTI_DELETE_DEVICE_CANCEL object:nil];
}

- (void)deleteDeviceViewCtrCancel:(NSNotification *)noti{
    BOOL isConfirmDelete = [[noti object] boolValue];
    [blurView           removeFromSuperview];
    [deleteViewCtr.view removeFromSuperview];
    blurView        = nil;
    deleteViewCtr   = nil;
    
    if (isConfirmDelete) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_MAIN_VIEW_REFRESH object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)switchValueChanged:(UISwitch *)sender{
    hasUserChangedSomthing = YES;
    if (sender == sw_share) {
        _cameraInfo.shareStatus         = sender.on;
        return;
    }
    if (sender.tag >= _cameraInfo.mar_event.count) {
        Dlog(@"逻辑性错误");
        return;
    }
    Dlog(@"_cameraInfo = %@", _cameraInfo);
    NSDictionary *dic = _cameraInfo.mar_event[sender.tag];
    NSMutableDictionary *mdc = [[NSMutableDictionary alloc] initWithDictionary:dic];
    [mdc setValue:FORMAT(@"%d", sender.on) forKeyPath:@"value"];
    Dlog(@"_cameraInfo = %@", _cameraInfo);
    [_cameraInfo.mar_event replaceObjectAtIndex:sender.tag withObject:mdc];
    Dlog(@"_cameraInfo = %@", _cameraInfo);
}

- (IBAction)doChangeCodeStream:(UIButton *)sender{
    hasUserChangedSomthing = YES;
    _cameraInfo.staticStream = sender.tag;
    [self refreshCodeStreamUI:sender.tag];
}
- (void)refreshCodeStreamUI:(NSInteger)iTag{
    [btn_low    setImage:[UIImage imageNamed:@"icon_lowNor.png"]    forState:UIControlStateNormal];
    [btn_high   setImage:[UIImage imageNamed:@"icon_highNor.png"]   forState:UIControlStateNormal];
    [btn_shutUp setImage:[UIImage imageNamed:@"icon_shutUpNor.png"] forState:UIControlStateNormal];
    switch (iTag) {
        case 0:{
            [btn_shutUp setImage:[UIImage imageNamed:@"icon_shutUp.png"] forState:UIControlStateNormal];
            break;
        }
        case 1:{
            [btn_low setImage:[UIImage imageNamed:@"icon_lowHi.png"] forState:UIControlStateNormal];
            break;
        }
        case 2:{
            [btn_high setImage:[UIImage imageNamed:@"icon_highHi.png"] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
    
}
#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField.superview bringSubviewToFront:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if ([textField isEqual:tf_name]) {
        textField.hidden    = YES;
        if ([tf_name.text isEqualToString:_cameraInfo.sDeviceName]) {
            return YES;
        }
        if (tf_name.text.length > MAX_LENTH_DEVICENAME) {
            [HDUtility say:FORMAT(@"设备名称不超过%d个字符", MAX_LENTH_DEVICENAME)];
            tf_name.text    = _cameraInfo.sDeviceName;
            return YES;
        }
        _cameraInfo.sDeviceName = tf_name.text;
        [tbv reloadData];
    }
    return YES;
}
#pragma touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [tf_name        resignFirstResponder];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:{
            
            break;
        }
        case 1:{
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
}
@end
