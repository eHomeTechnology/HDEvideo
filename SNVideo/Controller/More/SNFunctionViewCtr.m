//
//  SNFunctionViewCtr.m
//  SNVideo
//
//  Created by Thinking on 14-10-9.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNFunctionViewCtr.h"

@interface SNFunctionViewCtr ()
{
    IBOutlet UIScrollView *scv_function;
    
}
@end

@implementation SNFunctionViewCtr

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
    self.title = @"功能介绍";
    if (IOS_VERSION >= 7.0) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonAction:)];
    }else{
        UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_back.frame = CGRectMake(0, 0, 44, 25);
        [btn_back setImage:[UIImage imageNamed:@"icon_back.png"] forState:UIControlStateNormal];
        [btn_back addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_back];
    }
    scv_function.contentSize = CGSizeMake(self.view.frame.size.width, 980);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button action
-(void)backButtonAction:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
