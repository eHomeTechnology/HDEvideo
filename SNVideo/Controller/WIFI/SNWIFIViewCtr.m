//
//  SNWIFIViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-1.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNWIFIViewCtr.h"
#import "SNGlobalInfo.h"
#import "SNWIFIInfo.h"
#import "SNResetWifiViewCtr.h"
#import "SNAddWifiViewCtr.h"
#import "SNShareWifiViewCtr.h"

@interface SNWIFIViewCtr (){

    NSMutableArray *mar_wifi;
}

@end

@implementation SNWIFIViewCtr

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
    self.navigationItem.title = @"WIFI管理";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doCancel)];
    mar_wifi = [SNGlobalInfo instance].userInfo.mar_wifi;
    Dlog(@"[SNGlobalInfo instance].userInfo = %@", [SNGlobalInfo instance].userInfo);
    UIButton *btn_add = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_add.backgroundColor = [UIColor orangeColor];
    btn_add.frame = CGRectMake(0, 0, 280, 50);
    [btn_add setTitle:@"添加" forState:UIControlStateNormal];
    [btn_add addTarget:self action:@selector(doAddWifi) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableFooterView = btn_add;
}

- (void)viewWillAppear:(BOOL)animated{

    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)doCancel{

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doAddWifi{
    
    SNAddWifiViewCtr *addViewCtr = [[SNAddWifiViewCtr alloc] init];
    [self.navigationController pushViewController:addViewCtr animated:YES];
    
}
#pragma mark * Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mar_wifi.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DAContextMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"111"];
	if (cell == nil){
        
		cell = [[DAContextMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"111"];
	}
    cell.lb_title.text =((SNWIFIInfo *) mar_wifi[indexPath.row]).sSSID;
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

}
#pragma mark * DAContextMenuCell delegate

- (void)contextMenuCellDidSelectDeleteOption:(DAContextMenuCell *)cell
{
    [super contextMenuCellDidSelectDeleteOption:cell];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [mar_wifi removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

- (void)contextMenuCellDidSelectMoreOption:(DAContextMenuCell *)cell
{
    NSInteger r = [self.tableView indexPathForCell:cell].row;
    SNResetWifiViewCtr *ctr = [[SNResetWifiViewCtr alloc] initWithWifiInfo:mar_wifi[r]];
    [self addChildViewController:ctr];
    [self.view addSubview:ctr.view];
    [UIView animateWithDuration:0.3 animations:^{
        ctr.view.frame = CGRectMake(0, 0, 320, ctr.view.frame.size.height);
        self.navigationController.navigationBarHidden = YES;
    }];
    
}

@end
