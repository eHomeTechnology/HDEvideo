//
//  SNMyInfoViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-15.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNMyInfoViewCtr.h"
#import "SNUserInfo.h"
#import "SNEditInfoViewCtr.h"
#import "SNNavigationController.h"
#import "SNHttpUtility.h"
#import "RESideMenu.h"
#import "SNLoginViewCtr.h"
#import "SNModifyPwdViewCtr.h"
#import "HDBlurView.h"

@interface SNMyInfoViewCtr ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{

    IBOutlet UIView     *vBack;
    IBOutlet UILabel    *lb_phone;
    IBOutlet UILabel    *lb_email;
    IBOutlet UIButton   *btn_head;
    IBOutlet UILabel    *lb_name;
    IBOutlet UIButton   *btn_modify;
    IBOutlet UIButton   *btn_loginOut;
    
    UIActionSheet       *as_headPhoto;
    SNUserInfo          *myInfo;
    SNModifyPwdViewCtr  *modifyPwdVCtr;
    HDBlurView          *v_blur;
}


@end

@implementation SNMyInfoViewCtr

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
    if (IOS_VERSION >= 7.0) {
        self.navigationItem.leftBarButtonItem   = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doCancel:)];
        self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_edit.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doEdit:)];
    }else{
        UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_back.frame = CGRectMake(0, 0, 44, 25);
        [btn_back setImage:[UIImage imageNamed:@"icon_back.png"] forState:UIControlStateNormal];
        [btn_back addTarget:self action:@selector(doCancel:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_back];
        
        UIButton *btn_edit = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_edit.frame = CGRectMake(0, 0, 44, 25);
        [btn_edit setImage:[UIImage imageNamed:@"icon_edit.png"] forState:UIControlStateNormal];
        [btn_edit addTarget:self action:@selector(doEdit:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_edit];
    }
    
    btn_head.layer.cornerRadius     = btn_head.frame.size.width/2;
    btn_head.layer.masksToBounds    = YES;
    btn_head.layer.borderColor      = [UIColor whiteColor].CGColor;
    btn_head.layer.borderWidth      = 2.0f;
    vBack.layer.borderWidth         = 1.0f;
    vBack.layer.borderColor         = [UIColor colorWithRed:28/255.0f green:36/255.0f blue:47/255.0f alpha:1.0f].CGColor;
    self.navigationItem.title       = @"个人中心";
    self.navigationItem.titleView.tintColor = [UIColor whiteColor];
    
    if (!IS_4INCH_SCREEN) {
        btn_modify.center = CGPointMake(btn_modify.center.x, btn_modify.center.y - 88);
        btn_loginOut.center = CGPointMake(btn_loginOut.center.x, btn_loginOut.center.y - 88);
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    NSString *sPath = [SNGlobalInfo instance].userInfo.sHeadPath;
    if (sPath > 0) {
        [btn_head setImage:[UIImage imageWithContentsOfFile:sPath] forState:UIControlStateNormal];
    }
    myInfo          = [SNGlobalInfo instance].userInfo;
    lb_email.text   = myInfo.sEmail;
    lb_name.text    = myInfo.sUserName;
    lb_phone.text   = myInfo.sPhone;
}

#pragma mark - SEL
- (IBAction)doChangePassword{

    if (!v_blur) {
        v_blur = [[HDBlurView alloc] initWithFrame:kWindow.frame];
    }
    modifyPwdVCtr = [[SNModifyPwdViewCtr alloc] init];
    [HDUtility view:modifyPwdVCtr.view appearAt:kWindow.center withDalay:0.1 duration:0.2];
    [kWindow addSubview:v_blur];
    [kWindow addSubview:modifyPwdVCtr.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modifyPwdCancel) name:@KEY_NOTI_MODIFY_PWD object:nil];
}

- (void)modifyPwdCancel
{
    [v_blur             removeFromSuperview];
    [modifyPwdVCtr.view removeFromSuperview];
    modifyPwdVCtr = nil;
    v_blur        = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@KEY_NOTI_MODIFY_PWD object:nil];
}

- (IBAction)doLogout{
    [[SNHttpUtility sharedClient] userLogout_1:[SNGlobalInfo instance].userInfo CompletionBlock:^(BOOL isSuccess, NSString *sMessage) {
        if (1) {
            SNUserInfo *userInfo    = [SNGlobalInfo instance].userInfo;
            userInfo.sSessionId     = nil;
            [HDUtility saveUserInfo:userInfo];
            [[SNGlobalInfo instance].appDelegate stopHaretRequest];
            for (UIView *v in kWindow.subviews) {
                [v removeFromSuperview];
            }
            [kWindow setRootViewController:[[SNLoginViewCtr alloc] init]];
        }
        
    }];
    
}
- (void)doCancel:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doEdit:(id)sender{
    
    SNEditInfoViewCtr *ctr = [SNEditInfoViewCtr new];
    [self.navigationController presentViewController:[[SNNavigationController alloc] initWithRootViewController:ctr] animated:YES completion:nil];
}
- (IBAction)doChangeHead:(id)sender{

}

@end
