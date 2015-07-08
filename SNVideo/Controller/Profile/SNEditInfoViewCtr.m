//
//  SNEditInfoViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-17.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNEditInfoViewCtr.h"

@interface SNEditInfoViewCtr ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>{
    IBOutlet UIView         *vBack;
    IBOutlet UITextField    *tf_name;
    IBOutlet UITextField    *tf_email;
    IBOutlet UIButton       *btn_head;
    IBOutlet UITextField    *tf_phone;
    UIActionSheet           *as_headPhoto;
    SNUserInfo              *userInfo;
}

@end

@implementation SNEditInfoViewCtr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (IOS_VERSION >= 7.0) {
        self.navigationItem.leftBarButtonItem   = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_x.png"]
                                                                                   style:UIBarButtonItemStylePlain
                                                                                  target:self
                                                                                  action:@selector(doCancel)];
        self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_complete.png"]
                                                                                   style:UIBarButtonItemStylePlain
                                                                                  target:self
                                                                                  action:@selector(doComplete)];
    }else{
        UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_back.frame = CGRectMake(0, 0, 44, 25);
        [btn_back setImage:[UIImage imageNamed:@"icon_x.png"] forState:UIControlStateNormal];
        [btn_back addTarget:self action:@selector(doCancel) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_back];
        
        UIButton *btn_down = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_down.frame = CGRectMake(0, 0, 44, 25);
        [btn_down setImage:[UIImage imageNamed:@"icon_complete.png"] forState:UIControlStateNormal];
        [btn_down addTarget:self action:@selector(doComplete) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_down];
    }
    
    btn_head.layer.borderWidth      = 2;
    btn_head.layer.borderColor      = [UIColor whiteColor].CGColor;
    btn_head.layer.cornerRadius     = [btn_head frame].size.width/2;
    btn_head.layer.masksToBounds    = YES;
    vBack.layer.borderWidth         = 1.0f;
    vBack.layer.borderColor         = [UIColor colorWithRed:29/255.0f green:37/255.0f blue:48/255.0f alpha:1.0f].CGColor;
    self.navigationItem.title       = @"编辑";
    userInfo                        = [SNGlobalInfo instance].userInfo;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)viewWillAppear:(BOOL)animated{
    NSString *sPath = [SNGlobalInfo instance].userInfo.sHeadPath;
    if (sPath > 0) {
        [btn_head setImage:[UIImage imageWithContentsOfFile:sPath] forState:UIControlStateNormal];
    }
    tf_name.text    = userInfo.sUserName;
    tf_email.text   = userInfo.sEmail;
    tf_phone.text   = userInfo.sPhone;
}
#pragma mark - SEL
- (void)doCancel{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doComplete{
    if (![HDUtility isValidateAccount:tf_name.text]) {
        [HDUtility say:FORMAT(@"昵称不能包含特殊字符")];
        return;
    }
    if (tf_name.text.length > MAX_LENTH_NAME || tf_name.text.length < MIN_LENTH_NAME) {
        [HDUtility say:[NSString stringWithFormat:@"昵称请使用%d-%d位汉字、字母或数字", MIN_LENTH_NAME, MAX_LENTH_NAME]];
        return;
    }
    if (![HDUtility isValidateEmail:tf_email.text] && tf_email.text.length > MAX_LENTH_EMAIL) {
        [HDUtility say:@"请输入正确的邮箱地址！"];
        return;
    }
    [tf_email   resignFirstResponder];
    [tf_name    resignFirstResponder];
    userInfo.sUserName      = tf_name.text;
    userInfo.sEmail         = tf_email.text;
    [[SNHttpUtility sharedClient] userInfoUpdate_1:userInfo CompletionBlock:^(BOOL isSuccess, NSString *sMessage) {
        if (isSuccess) {
            [SNGlobalInfo instance].userInfo.sEmail     = tf_email.text;
            [SNGlobalInfo instance].userInfo.sUserName  = tf_name.text;
            [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
            [self doCancel];
        }
    }];
}
- (IBAction)doChooseHead:(id)sender{
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
        UIImagePickerController *imagePickerCtr = [[UIImagePickerController alloc] init];
        imagePickerCtr.delegate                 = self;
        imagePickerCtr.allowsEditing            = YES;
        imagePickerCtr.sourceType               = sourceType;
        [self presentViewController:imagePickerCtr animated:YES completion:^{}];
    }
    
}

#pragma mark- 压缩图片
- (UIImage *)compressImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(CGSizeMake(100, 100));
    [image drawInRect:CGRectMake(0, 0, 100, 100)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *img        = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *scaleImage = nil;
    if (img){
        scaleImage = [self compressImage:img];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    [[SNHttpUtility sharedClient] userImageHeadUpdate_1:[SNGlobalInfo instance].userInfo image:scaleImage imageName:@"head.png" CompletionBlock:^(BOOL isSuccess, NSString *sUrl, NSString *sMessage) {
        if (isSuccess) {
            NSString *sFileName = [sUrl lastPathComponent];
            NSString *sLocalPath = [HDUtility pathOfSavedImageName:sFileName folderName:@FOLDER_USER];
            BOOL isSuc = [HDUtility saveToDocument:img withFilePath:sLocalPath];
            if (isSuc) {
                [SNGlobalInfo instance].userInfo.sHeadPath = sLocalPath;
                [HDUtility saveUserInfo:[SNGlobalInfo instance].userInfo];
                [btn_head setImage:[UIImage imageWithContentsOfFile:sLocalPath] forState:UIControlStateNormal];
            }
        }
    }];
    return;
}

#pragma mark - touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

    [tf_email   resignFirstResponder];
    [tf_name    resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == tf_email) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -30, 320, self.view.frame.size.height);
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, 64, 320, self.view.frame.size.height);
        }];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 64, 320, self.view.frame.size.height);
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    if ([textField isEqual:tf_name]) {
        [tf_email becomeFirstResponder];
    }
    if ([textField isEqual:tf_email]) {
        
        [self doComplete];
    }
    return YES;
}

@end
