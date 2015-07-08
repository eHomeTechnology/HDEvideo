//
//  SNBarcodeViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-25.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNBarcodeViewCtr.h"
#import "QRCodeGenerator.h"

@interface SNBarcodeViewCtr (){

    IBOutlet UIImageView    *imv_head;
    IBOutlet UILabel        *lb_name;
    IBOutlet UIView         *v_barcode;
    
}

@end

@implementation SNBarcodeViewCtr

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
    [HDUtility circleWithNoBorder:imv_head];
    NSString *sPath = [SNGlobalInfo instance].userInfo.sHeadPath;
    if (sPath.length > 0) {
        [imv_head setImage:[UIImage imageWithContentsOfFile:sPath]];
    }
    lb_name.text = [SNGlobalInfo instance].userInfo.sUserName;
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(v_barcode.frame), CGRectGetHeight(v_barcode.frame))];
    imageView.image = [QRCodeGenerator qrImageForString:[SNGlobalInfo instance].userInfo.sPhone imageSize:imageView.bounds.size.width];
    [v_barcode addSubview:imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
