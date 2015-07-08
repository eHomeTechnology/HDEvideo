//
//  SNAddDeviceViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-26.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNAddDeviceViewCtr.h"
#import "SNWIFIInfo.h"
#import "SNHttpUtility.h"
#import "SNGlobalInfo.h"
#import "SNSoundViewCtr.h"

@interface SNAddDeviceViewCtr ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>{

    IBOutlet UIView         *v_setWifi;
    IBOutlet UITableView    *tbv;
    IBOutlet UITextField    *tf_wifi;
    IBOutlet UITextField    *tf_pwd;
    IBOutlet UIImageView    *imv_lock;
    NSMutableArray          *mar_wifi;
    NSMutableArray          *mar_wifiShowInTableView;
    UIColor                 *borderColor;
    
}

@end

@implementation SNAddDeviceViewCtr

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
    self.view.backgroundColor   = [UIColor clearColor];
    borderColor                 = [UIColor colorWithRed:20/255.0f green:25/255.0f blue:32/255.0f alpha:1.0f];
    tbv.separatorStyle          = UITableViewCellSeparatorStyleNone;
    tbv.hidden                  = NO;
    tbv.backgroundColor         = [UIColor blackColor];
    tbv.frame                   = CGRectMake(tbv.frame.origin.x, tbv.frame.origin.y, tbv.frame.size.width, 0);
    tbv.layer.borderWidth       = 1;
    tbv.layer.borderColor       = [UIColor blackColor].CGColor;
    mar_wifi                    = [SNGlobalInfo instance].userInfo.mar_wifi;
    mar_wifiShowInTableView     = [[NSMutableArray alloc] initWithArray:mar_wifi];
    self.cameraInfo             = [[SNCameraInfo alloc] init];
    
    UIColor *color              = [UIColor colorWithRed:42/255.0f green:48/255.0f blue:55/255.0f alpha:1.0f];
    [tf_pwd setValue:color          forKeyPath:@"_placeholderLabel.textColor"];
    [tf_pwd setValue:[UIFont        fontWithName:@"Arial" size:13] forKeyPath:@"_placeholderLabel.font"];

    [self readConnectedWifi];
    imv_lock.hidden     = !tf_pwd.text.length;
    CGSize sz_self      = self.view.frame.size;
    CGSize sz_setWifi   = v_setWifi.frame.size;
    v_setWifi.frame     = CGRectMake(160-sz_setWifi.width/2, (sz_self.height-sz_setWifi.height)/2, sz_setWifi.width, sz_setWifi.height);
    [self.view addSubview:v_setWifi];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SEL

- (IBAction)doPulldowWifiList:(id)sender{
    [self readConnectedWifi];
    [tbv reloadData];
    CGFloat height = tbv.frame.size.height;
    if (!height) {
        [UIView animateWithDuration:0.2 animations:^{
            tbv.frame = CGRectMake(tbv.frame.origin.x, tbv.frame.origin.y, tbv.frame.size.width, MIN(200, 50*mar_wifiShowInTableView.count));
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            tbv.frame = CGRectMake(tbv.frame.origin.x, tbv.frame.origin.y, tbv.frame.size.width, 0);
        }];
    }
}

- (IBAction)doCancel:(id)sender{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@KEY_NOTI_ADD_DEVICE_CANCEL object:nil userInfo:nil];
}

- (IBAction)doNext:(id)sender{
    if ([tf_wifi.text length] <= 0) {
        [HDUtility say:@"WIFI名称不能为空！"];
        return;
    }
    if (tf_wifi.text.length > MAX_LENTH_WIFI) {
        [HDUtility say:FORMAT(@"wifi名称大小不能超过%d", MAX_LENTH_WIFI)];
        return;
    }
    [tf_pwd     resignFirstResponder];
    [tf_wifi    resignFirstResponder];
    //保存WIFI
    SNWIFIInfo *wifiInfo    = [[SNWIFIInfo alloc] initWithSSID:tf_wifi.text password:tf_pwd.text];
    mar_wifi                = [SNGlobalInfo instance].userInfo.mar_wifi;
    for (int i = 0; i < mar_wifi.count; i++) {
        SNWIFIInfo *info = mar_wifi[i];
        if ([info.sSSID isEqualToString:tf_wifi.text]) {
            [mar_wifi removeObjectAtIndex:i];
        }
    }
    [mar_wifi insertObject:wifiInfo atIndex:0];
    [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
    SNSoundViewCtr *soundViewCtr    = [[SNSoundViewCtr alloc] initWithWifiInfo:wifiInfo];
    soundViewCtr.view.frame         = CGRectMake(330, CGRectGetMinY(v_setWifi.frame), CGRectGetWidth(v_setWifi.frame), CGRectGetHeight(v_setWifi.frame));
    [self.view addSubview:soundViewCtr.view];
    [self addChildViewController:soundViewCtr];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iAmBack) name:@KEY_NOTIFICATION_ADD_DEVICE_BACK object:nil];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [v_setWifi setFrame:CGRectMake(-320, CGRectGetMinY(v_setWifi.frame), 0, CGRectGetHeight(v_setWifi.frame))];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            [soundViewCtr.view setFrame:CGRectMake(160-CGRectGetWidth(soundViewCtr.view.frame)/2, CGRectGetMinY(v_setWifi.frame), CGRectGetWidth(soundViewCtr.view.frame), CGRectGetHeight(soundViewCtr.view.frame))];
        }];
    }];
}

- (void)readConnectedWifi{

    NSDictionary *dic = [HDUtility getConectedWIFI];
    Dlog(@"dic = %@", dic);
    if (dic) {
        SNWIFIInfo *connectingWifi  = [[SNWIFIInfo alloc] init];
        connectingWifi.sSSID        = dic[@"SSID"];
        tf_wifi.text                = connectingWifi.sSSID;
        BOOL hasConnectedWifiBeSaved  = NO;
        for (int i = 0; i < mar_wifiShowInTableView.count; i++) {
            SNWIFIInfo *wifi = mar_wifiShowInTableView[i];
            if ([[wifi sSSID] isEqualToString:connectingWifi.sSSID]) {
                tf_pwd.text                 = wifi.sPassword;
                connectingWifi.sPassword    = wifi.sPassword;
                hasConnectedWifiBeSaved       = YES;
                break;
            }
        }
        if (!hasConnectedWifiBeSaved) {
            [mar_wifiShowInTableView insertObject:connectingWifi atIndex:0];
        }
        
    }else{
        if (mar_wifi.count > 0) {
            tf_wifi.text    = ((SNWIFIInfo *)mar_wifi[0]).sSSID;
            tf_pwd.text     = ((SNWIFIInfo *)mar_wifi[0]).sPassword;
        }
    }
}

- (void)iAmBack{
    
    v_setWifi.frame = CGRectMake(33, CGRectGetMinY(v_setWifi.frame), 254, 362);
}

#pragma mark - UITableViewDateSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return mar_wifiShowInTableView.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"111"];
	if (cell == nil){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"111"];
        cell.backgroundColor = [UIColor colorWithRed:34/255.0f green:44/255.0f blue:56/255.0f alpha:1.0f];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = FONT_BODY;
        cell.layer.borderWidth = .3f;
        cell.layer.borderColor = borderColor.CGColor;
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 23, 17)];
        [imv setImage:[UIImage imageNamed:@"信号_1.png"]];
        cell.accessoryView = imv;
	}
    for(UIView *v in cell.accessoryView.subviews) {
        [v removeFromSuperview];
    }

    SNWIFIInfo *wifiInfo   = mar_wifiShowInTableView[indexPath.row];
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
    SNWIFIInfo *wifi    = mar_wifiShowInTableView[indexPath.row];
    tf_wifi.text        = wifi.sSSID;
    tf_pwd.text         = wifi.sPassword;
    [UIView animateWithDuration:0.1 animations:^{
        tbv.frame = CGRectMake(tbv.frame.origin.x, tbv.frame.origin.y, tbv.frame.size.width, 0);
    }];
    imv_lock.hidden = !tf_pwd.text.length;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if ([textField isEqual:tf_wifi]) {
        [tf_pwd becomeFirstResponder];
    }
    if ([tf_pwd isEqual:textField]) {
        [textField resignFirstResponder];
        [self doNext:nil];
    }
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([tf_pwd isEqual:textField]) {
        imv_lock.hidden = !tf_pwd.text.length;
    }
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if ([tf_pwd isEqual:textField]) {
        imv_lock.hidden = !tf_pwd.text.length;
    }
}

#pragma mark - touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [tf_wifi resignFirstResponder];
    [tf_pwd resignFirstResponder];
    float heit = CGRectGetHeight(tbv.frame);
    if (heit) {
        [self doPulldowWifiList:nil];
    }
}
@end
