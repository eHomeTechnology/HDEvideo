//
//  SNViewController.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-2.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNViewController.h"

@interface SNViewController ()

@end

@implementation SNViewController

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
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doCancel:)];
    }else{
        UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_back.frame = CGRectMake(0, 0, 44, 25);
        [btn_back setImage:[UIImage imageNamed:@"icon_back.png"] forState:UIControlStateNormal];
        [btn_back addTarget:self action:@selector(doCancel:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_back];
    }
    
}

- (void)doCancel:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
