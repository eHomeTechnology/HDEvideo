//
//  SNAboutViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-19.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNAboutViewCtr.h"
#import "SNAboutCell.h"
#import "SNFunctionViewCtr.h"
#import "SNQuestionViewCtr.h"
#import "SNCompanyViewCtr.h"
#import "SNPicketInfo.h"
#import "SNHttpUtility.h"

@interface SNAboutViewCtr ()
{
    IBOutlet UITableView    *tbv_about;
    SNPicketInfo            *picketInfo;
    NSArray                 *ar_title;
    
}
@end

@implementation SNAboutViewCtr

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
    self.title = @"关于e-see";
    ar_title = @[@[@"功能介绍", @"常见问题"], @[@"版本更新", @"公司介绍"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    /*检查版本更新*/
    [[SNHttpUtility sharedClient] checkVersion_1:[SNGlobalInfo instance].userInfo CompletionBlock:^(BOOL isSuccess, SNPicketInfo *picket, NSString *sMessage) {
        if (isSuccess) {
            picketInfo = picket;
            [tbv_about reloadData];
        }
    }];
}
#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v_section   = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
    [v_section  setBackgroundColor:[UIColor clearColor]];
    
    return v_section;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"SNAboutCell";
    SNAboutCell * cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"SNAboutCell" owner:self options:nil];
        for (NSObject *obj in objects) {
            
            if ([obj isKindOfClass:[SNAboutCell class]]) {
                
                cell = (SNAboutCell *)obj;
                break;
            }
        }
    }
    UIView *v_t             = [[UIView alloc] initWithFrame:cell.contentView.frame];
    v_t.backgroundColor     = [UIColor clearColor];
    UIView *v_t2            = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 304, 50)];
    UIColor *color          = [UIColor colorWithHue:157/255.0 saturation:157/255.0 brightness:157/255.0 alpha:1];
    v_t2.backgroundColor    = color;
    v_t2.center             = v_t.center;
    [v_t addSubview:v_t2];
    [cell setSelectedBackgroundView:v_t];
    if (indexPath.row != 0) {
        cell.lb_line_up.hidden = YES;
    }
    cell.lb_content.text = ar_title[indexPath.section][indexPath.row];
    if (indexPath.section == 1 && indexPath.row == 0) {
        cell.lb_new.hidden          = !picketInfo.iUpdate;
        cell.imv_newBg.hidden       = !picketInfo.iUpdate;
        cell.imv_arrows.hidden      = YES;
        cell.userInteractionEnabled = picketInfo.iUpdate;
        if (cell.imv_newBg.hidden) {
            NSDictionary *infoDictionary    = [[NSBundle mainBundle] infoDictionary];
            NSString *app_Version           = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            cell.lb_versions.text           = FORMAT(@"当前为最新版本V%@", app_Version);
        }
        
        cell.lb_versions.hidden     = !cell.imv_newBg.hidden;
        
    }else{
        cell.lb_new.hidden      = YES;
        cell.imv_newBg.hidden   = YES;
        cell.imv_arrows.hidden  = NO;
        cell.lb_versions.hidden = YES;
    }
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        SNFunctionViewCtr *funVCtr = [[SNFunctionViewCtr alloc] init];
        [self.navigationController pushViewController:funVCtr animated:YES];
    }else if (indexPath.section == 0 && indexPath.row == 1){
        SNQuestionViewCtr *queVCtr = [[SNQuestionViewCtr alloc] init];
        [self.navigationController pushViewController:queVCtr animated:YES];
    }else if (indexPath.section == 1 && indexPath.row == 0){
        if (picketInfo.iUpdate) {
//            NSString *appstoreUrlString = @"https://itunes.apple.com/cn/app/k-mi-quan-guoktv-dian-ge-yu-ding/id896914152?mt=8";
            NSURL *url                  = [NSURL URLWithString:picketInfo.sURL];
            if ([[UIApplication sharedApplication] canOpenURL:url]){
                [[UIApplication sharedApplication] openURL:url];
            }else{
                NSLog(@"can not open");
            }
        }
    }else if (indexPath.section == 1 && indexPath.row == 1){
        SNCompanyViewCtr *comVCtr = [[SNCompanyViewCtr alloc] init];
        [self.navigationController pushViewController:comVCtr animated:YES];
    }
}

@end
