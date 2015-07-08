//
//  AOTMainViewCtr.m
//  AotSimba
//
//  Created by Hu Dennis on 13-10-19.
//  Copyright (c) 2013年 DennisHu. All rights reserved.
//

#import "AOTMainViewCtr.h"
#import "SNMainViewCtr.h"
@interface AOTMainViewCtr ()<UITableViewDataSource, UITableViewDelegate>{
    
    NSArray         *ar_tableData;
    NSArray         *ar_images;

    IBOutlet UIView         *vTabelHead;
    IBOutlet UIImageView    *imv_headBackglound;
    IBOutlet UILabel        *lb_name;
    IBOutlet UILabel        *lb_phone;
    IBOutlet UIView         *vTabelFooter;
    IBOutlet UIView         *vSelected;
    IBOutlet UIView         *vUnselected;
    IBOutlet UIImageView    *imv_lineBreak;
}

@end

@implementation AOTMainViewCtr

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
        
        imv_lineBreak.alpha = 0.0f;
    }else{
        self.tbv = [self.tbv initWithFrame:self.tbv.frame style:UITableViewStylePlain];
    }
    
    ar_tableData = [[NSArray alloc] initWithObjects:LS(@"mainGUI"), LS(@"setting"), LS(@"about"), LS(@"new function guide"), nil];
    ar_images = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"main_icon_mySimba.png"], [UIImage imageNamed:@"main_icon_setting.png"], [UIImage imageNamed:@"main_icon_aboutSimba.png"], [UIImage imageNamed:@"main_icon_showNewFunction.png"], nil];
    vTabelHead.backgroundColor   = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_dot_black.png"]];
    _tbv.tableHeaderView         = vTabelHead;
    _tbv.scrollEnabled           = NO;
    _tbv.backgroundColor         = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_dot_black.png"]];
    vTabelFooter.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_dot_black.png"]];
    vTabelFooter.frame = CGRectMake(0, HDDeviceSize.height - vTabelFooter.frame.size.height, vTabelFooter.frame.size.width, vTabelFooter.frame.size.height);
    
    vUnselected.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_dot_black.png"]];
    
    [self.btn_head.layer setCornerRadius:self.btn_head.frame.size.width/2];
    [self.btn_head.layer setMasksToBounds:YES];
    self.btn_head.center = imv_headBackglound.center;
//    UIImage *img_head    = [[AOTMyInfo instance].info getUserFaceImage];
//    [self.btn_head setBackgroundImage:img_head forState:UIControlStateNormal];
//    lb_name.text = [AOTMyInfo instance].info.sNickName;
//    lb_phone.text = [AOTMyInfo instance].info.sUserID;
    
}

- (void)viewDidAppear:(BOOL)animated{

//    UIImage *img    = [[AOTMyInfo instance].info getUserFaceImage];
//    lb_name.text    = [AOTMyInfo instance].info.sNickName;
//    lb_phone.text   = [AOTMyInfo instance].info.sUserID;
//    [self.btn_head setBackgroundImage:img forState:UIControlStateNormal];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    //ar_tableData        = nil;
    //ar_images           = nil;
    vTabelHead          = nil;
    imv_headBackglound  = nil;
    lb_name             = nil;
    lb_phone            = nil;
    vTabelFooter        = nil;
    //vSelected           = nil;
    vUnselected         = nil;
    imv_lineBreak       = nil;
    //_tbv                = nil;
}

#pragma mark - IBAction
- (IBAction)doHideLeftBar:(id)sender{

    //[self.viewDeckController toggleLeftView];
}

- (IBAction)go2UserProfileViewController:(id)sender{
    
//    AOTUserProfileViewCtr *ctr = [[AOTUserProfileViewCtr alloc] init];
//    MLNavigationController *nav = [[MLNavigationController alloc] initWithRootViewController:ctr withNavigationgType:AOTNavigationControllerTypeNormal];
//    [self.viewDeckController presentViewController:nav animated:YES completion:nil];
//    [self.viewDeckController closeLeftView];
}
#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 4;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"111"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"111"];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    if (indexPath.row == 0) {
        
        [cell setBackgroundView:vSelected];
    }else{
    
        [cell setBackgroundView:vUnselected];
    }
	cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_dot_black.png"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = ar_tableData[indexPath.row];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    Dlog(@"index.row = %d", (int)indexPath.row);
    
    //[cell.imageView setImage:ar_images[indexPath.row]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (IS_4INCH_SCREEN) {
        
        return 60;
    }
    
    return 50;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    for (int i = 0; i < 4; i++) {
        
        UITableViewCell *cell_ = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell_ setBackgroundView:vUnselected];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setBackgroundView:vSelected];
    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
        
        switch (indexPath.row) {
            case 0:{
                
                //self.viewDeckController.centerController = [AOTGlobalData instance].tab_mySimba;
                break;
            }
            case 1:{
                
//                MLNavigationController *nav;
//                AOTSettingViewCtr *ctr_setting = [[AOTSettingViewCtr alloc] init];
//                nav = [[MLNavigationController alloc] initWithRootViewController:ctr_setting withNavigationgType:AOTNavigationControllerTypeNormal];
//                self.viewDeckController.centerController = nav;
                break;
            }
            case 2:{
//                
//                MLNavigationController *nav;
//                AOTAboutViewCtr *ctr = [[AOTAboutViewCtr alloc] init];
//                nav = [[MLNavigationController alloc] initWithRootViewController:ctr withNavigationgType:AOTNavigationControllerTypeNormal];
//                self.viewDeckController.centerController = nav;
                break;
            }
            case 3:{
                
//                AOTIntroduceViewCtr *ctr = [[AOTIntroduceViewCtr alloc] init];
//                [self.viewDeckController presentViewController:ctr animated:YES completion:^{//选中状态设回原来的项
//                    
//                    [cell setBackgroundView:vUnselected];
//    
//                    int index = 0;
//                    if ([self.viewDeckController.centerController isKindOfClass:[UITabBarController class]]) {
//                        index = 0;
//                    }else{
//                        MLNavigationController *nav = (MLNavigationController *)self.viewDeckController.centerController;
//                        if (nav.viewControllers.count > 0) {
//                            if ([nav.viewControllers[0] isKindOfClass:[AOTSettingViewCtr class]]) {
//                                index = 1;
//                            }
//                            if ([nav.viewControllers[0] isKindOfClass:[AOTAboutViewCtr class]]) {
//                                index = 2;
//                            }
//                        }
//                    }
//                    UITableViewCell *cell_ = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//                    [cell_ setBackgroundView:vSelected];
//                }];
                break;
            }
            default:
                break;
        }
        
        self.view.userInteractionEnabled = YES;
    }];
    [tableView setUserInteractionEnabled:NO];
}

@end






