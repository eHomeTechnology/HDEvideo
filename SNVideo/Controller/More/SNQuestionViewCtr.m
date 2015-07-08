//
//  SNQuestionViewCtr.m
//  SNVideo
//
//  Created by Thinking on 14-10-9.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNQuestionViewCtr.h"

@interface SNQuestionViewCtr ()

@end

@implementation SNQuestionViewCtr

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
    self.title = @"常见问题";
    
    if (IOS_VERSION >= 7.0) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(backButtonAction:)];
    }else{
        UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_back.frame = CGRectMake(0, 0, 44, 25);
        [btn_back setImage:[UIImage imageNamed:@"icon_back.png"] forState:UIControlStateNormal];
        [btn_back addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_back];
    }
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
