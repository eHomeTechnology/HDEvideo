//
//  SNNavigationController.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-19.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNNavigationController.h"
#import "SNMyInfoViewCtr.h"

@interface SNNavigationController ()

@end

@implementation SNNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"color_nav.jpg"] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.tintColor = [UIColor whiteColor];
        
        [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                         [UIColor whiteColor],
                                                                         UITextAttributeTextColor,
                                                    nil]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
