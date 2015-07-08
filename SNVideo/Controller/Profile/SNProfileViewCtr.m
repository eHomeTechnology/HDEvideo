//
//  SNProfileViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-19.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNProfileViewCtr.h"
#import "SNUserInfo.h"
#import "SNGlobalInfo.h"
#import "SNHttpUtility.h"

typedef NS_ENUM(NSInteger, SNEditType) {

    SNEditTypeNone = 0,
    SNEditTypeName,
    SNEditTypePwd,
    SNEditTypeSex,
    SNEditTypeEmail,
    SNEditTypeBirthday,
    SNEditTypeHead,
};

@interface SNProfileViewCtr ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>{

    IBOutlet UIView         *v_tableHead;
    IBOutlet UIButton       *btn_head;
    IBOutlet UITextField    *tf_name;
    IBOutlet UILabel        *lb_account;
    IBOutlet UITableView    *tbv;
    IBOutlet UITextView     *tv_edit;
    IBOutlet UIDatePicker   *dp_birthday;
    
    IBOutlet UIView         *v_changePwd;
    IBOutlet UITextField    *tf_pwdOld;
    IBOutlet UITextField    *tf_pwdNew;
    IBOutlet UITextField    *tf_pwdConfirm;
    
    NSArray         *ar_title;
    NSMutableArray  *mar_value;
    UIActionSheet   *as_headPhoto;
    UIActionSheet   *as_sex;
    SNEditType      editType;
}

@end

@implementation SNProfileViewCtr

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
    
    editType = SNEditTypeNone;
    self.title = @"个人中心";
    
    btn_head.layer.cornerRadius = btn_head.frame.size.width/2;
    [btn_head.layer setMasksToBounds:YES];
    tbv.tableHeaderView = v_tableHead;
    
    tf_name.text        = [SNGlobalInfo instance].userInfo.sUserName;
    lb_account.text     = [SNGlobalInfo instance].userInfo.sPhone;
    if ([[SNGlobalInfo instance].userInfo.sBirthday length] > 0) {
        NSDate *date = [HDUtility convertDateFromString:[SNGlobalInfo instance].userInfo.sBirthday];
        if (date) {
            [dp_birthday setDate:date];
        }
    }
    
    dp_birthday.frame   = CGRectMake(0, 600, 320, dp_birthday.frame.size.height);
    ar_title            = @[@"性别", @"邮箱", @"生日"];
    [self refreshTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)refreshTableView{
    mar_value = [[NSMutableArray alloc] init];
    NSString *sSex = @"";
    if ([SNGlobalInfo instance].userInfo.sSex.length > 0) {
        sSex = [[SNGlobalInfo instance].userInfo.sSex isEqualToString:@"0"]? @"男": @"女";
    }
    [mar_value addObject:sSex];
    [mar_value addObject:[SNGlobalInfo instance].userInfo.sEmail.length    == 0? @"": [SNGlobalInfo instance].userInfo.sEmail];
    [mar_value addObject:[SNGlobalInfo instance].userInfo.sBirthday.length == 0? @"": [SNGlobalInfo instance].userInfo.sBirthday];
    [tbv reloadData];
}
#pragma mark - SEL

- (IBAction)datePickerValueChanged:(id)sender{

    Dlog(@"11111");
    editType = SNEditTypeBirthday;
    [SNGlobalInfo instance].userInfo.sBirthday = [HDUtility formatterDate:dp_birthday.date];
    [self refreshTableView];
}

- (IBAction)doChangePwdConfirm:(id)sender{
    BOOL isEmpty    = [tf_pwdOld.text length] == 0 || [tf_pwdNew.text length] == 0 || [tf_pwdConfirm.text length] == 0;
    BOOL isSamePwd  = [tf_pwdOld.text isEqualToString:tf_pwdNew.text];
    BOOL isConfirm  = [tf_pwdNew.text isEqualToString:tf_pwdConfirm.text];
    if (isEmpty) {
        [HDUtility say:@"密码不能为空！"];
        return;
    }
    if (isSamePwd) {
        [HDUtility say:@"新密码不能与旧密码一样！"];
        return;
    }
    if (!isConfirm) {
        [HDUtility say:@"两次输入新密码不同，请核实！"];
        return;
    }
    
    //保存密码操作
    
    
    [self doChangePwdCancel:nil];
}

- (IBAction)doChangePwdCancel:(id)sender{
    [UIView animateWithDuration:0.3 animations:^{
        v_changePwd.frame = CGRectMake(0, 600, 320, v_changePwd.frame.size.height);
    }];
}

- (IBAction)doChooseHeadPhoto:(id)sender{
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){//判断是否支持相机
        as_headPhoto  = [[UIActionSheet alloc] initWithTitle:@"选择图像"
                                                    delegate:self
                                           cancelButtonTitle:nil
                                      destructiveButtonTitle:@"取消"
                                           otherButtonTitles:@"拍照", @"从相册选择",
                         nil];
    }else{
        as_headPhoto = [[UIActionSheet alloc] initWithTitle:@"选择图像"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:@"取消"
                                          otherButtonTitles:@"从相册选择",
                        nil];
    }
    [as_headPhoto showInView:self.view];
    
}

- (void)doCancel:(id)sender{

    if (editType != SNEditTypeNone) {
        [tf_name resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^{
            tv_edit.frame = CGRectMake(0, -370, 320, 370);
            dp_birthday.frame = CGRectMake(0, 600, 320, dp_birthday.frame.size.height);
        }];
        [tv_edit resignFirstResponder];
        self.navigationItem.rightBarButtonItem = nil;
        
        editType = SNEditTypeNone;
        self.navigationItem.title = @"个人中心";
        return;
    }
    [super doCancel:nil];
}

- (void)doSave:(id)sender{
    switch (editType) {
        case SNEditTypeName:{
            if (tf_name.text.length == 0) {
                [HDUtility say:@"请输入昵称！"];
                return;
            }
            [SNGlobalInfo instance].userInfo.sUserName = tf_name.text;
            break;
        }
        case SNEditTypePwd:{
            [SNGlobalInfo instance].userInfo.sPassword = tf_pwdNew.text;
            break;
        }
        case SNEditTypeSex:{
            
            break;
        }
        case SNEditTypeEmail:{
            if (tv_edit.text.length == 0) {
                [HDUtility say:@"请输入邮箱地址！"];
                return;
            }
            if (![HDUtility isValidateEmail:tv_edit.text]) {
                [HDUtility say:@"请输入正确的邮箱地址！"];
                return;
            }
            [SNGlobalInfo instance].userInfo.sEmail = tv_edit.text;
            break;
        }
        case SNEditTypeBirthday:{
            break;
        }
        case SNEditTypeHead:{
            
            break;
        }
        default:
            break;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *mar = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:LOGIN_USER]];
    NSDictionary *dic = [[SNGlobalInfo instance].userInfo dictionaryValue];
    for (int i = 0; i < mar.count; i++) {
        NSDictionary *d = mar[i];
        if ([[d objectForKey:K_LOGIN_USER_PHONE] isEqualToString:[dic objectForKey:K_LOGIN_USER_PHONE]]) {
            [mar removeObjectAtIndex:i];
        }
    }
    [mar insertObject:dic atIndex:0];
    
    [[SNHttpUtility sharedClient] userInfoUpdate_1:[SNGlobalInfo instance].userInfo CompletionBlock:^(BOOL isSuccess, NSString *sMessage) {
        if (isSuccess) {
            
            [self refreshTableView];
        }else{
        
        }
    }];
    [self doCancel:nil];
}

#pragma mark - UITableViewDateSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    switch (section) {
        case 0:{
            return 1;
        }
        case 1:{
            return 3;
        }
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"111"];
	if (cell == nil){
        
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"111"];
	}
    cell.textLabel.textColor        = [UIColor grayColor];
    cell.detailTextLabel.textColor  = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section) {
        case 0:{
            cell.textLabel.text         = @"密码";
            cell.detailTextLabel.text   = @"修改";
            break;
        }
        case 1:{
            cell.textLabel.text         = ar_title[indexPath.row];
            cell.detailTextLabel.text   = mar_value[indexPath.row];
        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:{
            v_changePwd.frame = CGRectMake(0, 600, 320, v_changePwd.frame.size.height);
            [self.navigationController.view addSubview:v_changePwd];
            [UIView animateWithDuration:0.3 animations:^{
                v_changePwd.frame = CGRectMake(0, 0, v_changePwd.frame.size.width, v_changePwd.frame.size.height);
            }];
            editType = SNEditTypePwd;
            break;
        }
        case 1:{
            switch (indexPath.row) {
                case 0:{//性别
                    as_sex = [[UIActionSheet alloc] initWithTitle:@"选择性别"
                                                         delegate:self
                                                cancelButtonTitle:nil
                                           destructiveButtonTitle:@"取消"
                                                otherButtonTitles:@"男", @"女",
                              nil];
                    [as_sex showInView:self.view];
                    editType = SNEditTypeSex;
                    break;
                }
                case 1:{//邮箱
                    [tv_edit becomeFirstResponder];
                    [UIView animateWithDuration:0.3 animations:^{
                        tv_edit.frame = CGRectMake(0, 64, tv_edit.frame.size.width, tv_edit.frame.size.height);
                    }];
                    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(doSave:)];
                    self.navigationItem.title = @"修改邮箱";
                    editType = SNEditTypeEmail;
                    break;
                }
                case 2:{//birthday
                    [UIView animateWithDuration:0.3 animations:^{
                        dp_birthday.frame = CGRectMake(0, HDDeviceSize.height-dp_birthday.frame.size.height, 320, dp_birthday.frame.size.height);
                    }];
                    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(doSave:)];
                    editType = SNEditTypeBirthday;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(doSave:)];
    editType = SNEditTypeName;
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [SNGlobalInfo instance].userInfo.sUserName = tf_name.text;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    self.navigationItem.rightBarButtonItem = nil;
    [textField resignFirstResponder];
    [self doSave:nil];
    return YES;
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet == as_headPhoto) {
        NSUInteger sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    return;
                case 1: //相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 2: //相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }else {
            if (buttonIndex == 0){
                return;
            }else{
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        [self presentViewController:imagePickerController animated:YES completion:^{}];
    }
    if (actionSheet == as_sex) {
        editType = SNEditTypeSex;
        switch (buttonIndex) {
            case 0:{//取消
                
                break;
            }
            case 1:{//男
                [SNGlobalInfo instance].userInfo.sSex = @"0";
                break;
            }
            case 2:{//女
                [SNGlobalInfo instance].userInfo.sSex = @"1";
                break;
            }
            default:
                break;
        }
        [self doSave:nil];
    }
}

#pragma mark- 缩放图片
-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    if ( img )
    {
        NSData *data = UIImagePNGRepresentation(img);
        if (([data length] > 1024 * 150) && [data length] <= 1024 * 500 )  /// 图片小于300K 不压缩
        {
            UIImage* scaleImage = [self scaleImage:img toScale:0.7];
            data = UIImagePNGRepresentation(scaleImage);
        }
        else if( [data length] > 1024 * 500 )
        {
            UIImage* scaleImage = [self scaleImage:img toScale:0.3];
            data = UIImagePNGRepresentation(scaleImage);
        }
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter	setDateFormat:@"yyyymmddHHmmss"];
        NSString *sTime = [formatter stringFromDate:[NSDate date]];
        NSLog(@"sTime = %@", sTime);
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    //    [imv_headIcon setImage:img];
    return;
}
@end
