//
//  SNPhotoSeePicture.m
//  SNVideo
//
//  Created by Thinking on 14-9-12.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNPhotoSeePicture.h"
#import "SNHttpUtility.h"
#import "HDFileUtility.h"
#import "UMSocial.h"
#import "SNPhotoScrollView.h"

@interface SNPhotoSeePicture ()<SNPhotoScrollViewDelegate>
{
   
    IBOutlet UILabel      *lb_imageName;
    
    SNPhotoScrollView     *scv_between;
    SNPhotoScrollView     *scv_bottom;
    int                   iFlag_selectedImage;
    
    NSMutableArray *ar_scrll_data;
    NSMutableArray *ar_imv_sBetween;
    NSMutableArray *ar_imv_sBottom;
    NSMutableArray *ar_imv_empty;
}
@end

@implementation SNPhotoSeePicture


/* 还没有去除视频部分*/
-(id)initWithImageName:(NSString *)imgName
{
    if (self == [super init]) {
        iFlag_selectedImage = 0;
        ar_imv_sBetween     = [[NSMutableArray alloc] init];
        ar_imv_sBottom      = [[NSMutableArray alloc] init];
        ar_scrll_data       = [[NSMutableArray alloc] initWithArray:[HDUtility readPhotoInfo]];
    
        for (int i = 0; i < ar_scrll_data.count; i++) {
            SNPhotoInfo *pInfo = [SNPhotoInfo serverInfoWithDictionary:[ar_scrll_data objectAtIndex:i]];
            if ([pInfo.photoName isEqualToString:imgName]) {
                iFlag_selectedImage = i;
                break;
            }
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IOS_VERSION >= 7.0) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doBack:)];
    }else{
        UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_back.frame = CGRectMake(0, 0, 44, 25);
        [btn_back setImage:[UIImage imageNamed:@"icon_back.png"] forState:UIControlStateNormal];
        [btn_back addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_back];
    }
    
    UIView *v_title = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [v_title setBackgroundColor:[UIColor clearColor]];
    self.navigationItem.titleView = v_title;
    
    UIButton *btn_share = [[UIButton alloc] initWithFrame:CGRectMake(110, 0, 54, 44)];
    [btn_share setImage:[UIImage imageNamed:@"icon_share.png"] forState:UIControlStateNormal];
    [btn_share addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [v_title addSubview:btn_share];
    
    UIButton *btn_cloud = [[UIButton alloc] initWithFrame:CGRectMake(160, 0, 54, 44)];
    [btn_cloud setImage:[UIImage imageNamed:@"icon_icoud.png"] forState:UIControlStateNormal];
    [btn_cloud addTarget:self action:@selector(cloudButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [v_title addSubview:btn_cloud];
    
    UIButton *btn_del = [[UIButton alloc] initWithFrame:CGRectMake(206, 0, 54, 44)];
    [btn_del setImage:[UIImage imageNamed:@"icon_del.png"] forState:UIControlStateNormal];
    [btn_del addTarget:self action:@selector(delButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [v_title addSubview:btn_del];
    
    float delta = IS_4INCH_SCREEN? 60 : 0;
    scv_between =  [[SNPhotoScrollView alloc] initWithFrame:CGRectMake(0, 20 + delta, self.view.frame.size.width, 200) imageFrame:CGRectMake(0, 0, self.view.frame.size.width, 200) images:ar_scrll_data gap:0 imageButton:NO];
    scv_between.delegate = self;
    [self.view addSubview:scv_between];
    [scv_between selectImageWithIndex:iFlag_selectedImage];
    
    SNPhotoInfo *pInfo  = [SNPhotoInfo serverInfoWithDictionary:[ar_scrll_data objectAtIndex:iFlag_selectedImage]];
    lb_imageName.frame  = CGRectMake(lb_imageName.frame.origin.x, 230, lb_imageName.frame.size.width, lb_imageName.frame.size.height);
    lb_imageName.text   = pInfo.photoName;
    
    scv_bottom = [[SNPhotoScrollView alloc] initWithFrame:CGRectMake(0, 330 + delta, self.view.frame.size.width, 47) imageFrame:CGRectMake(0, 0, 60, 47) images:ar_scrll_data gap:5 imageButton:YES];
    scv_bottom.delegate = self;
    [self.view addSubview:scv_bottom];
    [scv_bottom selectImageWithIndex:iFlag_selectedImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SNPhotoScrollViewDelegate
- (void)selectButton:(UIButton *)pBtn
{
    [scv_between selectImageWithIndex:(int)pBtn.tag];
    SNPhotoInfo *pInfo  = [SNPhotoInfo serverInfoWithDictionary:[ar_scrll_data objectAtIndex:scv_between.iSelected]];
    lb_imageName.text   = pInfo.photoName;
    iFlag_selectedImage = (int)pBtn.tag;
}

- (void)getScrollViewStatus:(SNPhotoScrollView *)pScv
{
    if (pScv == scv_between) {
        [scv_bottom selectImageWithIndex:scv_between.iSelected];
        SNPhotoInfo *pInfo  = [SNPhotoInfo serverInfoWithDictionary:[ar_scrll_data objectAtIndex:scv_between.iSelected]];
        lb_imageName.text   = pInfo.photoName;
        iFlag_selectedImage = scv_between.iSelected;
    }
}


#pragma mark - button action
-(void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)shareButtonAction:(UIButton *)btn
{
    SNPhotoInfo *pInfo  = [SNPhotoInfo serverInfoWithDictionary:[ar_scrll_data objectAtIndex:iFlag_selectedImage]];
    NSString *shareText = @"分享了一个照片";       //分享内嵌文字
    UIImage *shareImage = [UIImage imageWithContentsOfFile:pInfo.photoPath];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@UmengAppkey
                                      shareText:shareText
                                     shareImage:shareImage
                                shareToSnsNames:[NSArray arrayWithObjects:
                                                 UMShareToSina,
                                                 UMShareToTencent,
                                                 UMShareToQzone,
                                                 UMShareToWechatTimeline,
                                                 UMShareToEmail,
                                                 UMShareToSms,
                                                 UMShareToWechatSession,
                                                 UMShareToQQ, nil]
                                       delegate:nil];

                  //分享内嵌图片
    
//    //如果得到分享完成回调，需要设置delegate为self
//    [UMSocialSnsService presentSnsIconSheetView:self appKey:@UmengAppkey shareText:shareText shareImage:shareImage shareToSnsNames:nil delegate:nil];
}

-(void)cloudButtonAction:(UIButton *)btn
{
    
    SNPhotoInfo *pInfo = [SNPhotoInfo serverInfoWithDictionary:[ar_scrll_data objectAtIndex:iFlag_selectedImage]];
    if (pInfo.photoID != nil && ![pInfo.photoID isEqualToString:@""]) {
        [HDUtility say:@"已经上传过了，无需重复上传。"];
        return;
    }
    
    UIImage *imge_t = [UIImage imageWithContentsOfFile:pInfo.photoPath];
    
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    [[SNHttpUtility sharedClient] importPhoto_1:user pInfo:pInfo image:imge_t CompletionBlock:^(BOOL isSuccess, NSString *sMessage) {
        if (isSuccess) {
            [ar_scrll_data removeAllObjects];
            [ar_scrll_data addObjectsFromArray:[HDUtility readPhotoInfo]];
            [HDUtility say:@"上传图片成功"];
        }
    }];
    
}

-(void)delButtonAction:(UIButton *)btn
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LS(@"prompt")
                                                    message:@"该操作将同时删除云端相片，确定要删除吗？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"删除", nil];
    [alert show];
}

-(void)deleteImage
{
    SNPhotoInfo *pInfo = [SNPhotoInfo serverInfoWithDictionary:[ar_scrll_data objectAtIndex:iFlag_selectedImage]];
    if (pInfo.photoID == nil || [pInfo.photoID isEqualToString:@""]) {
        [HDUtility removeFileWithPath:pInfo.photoPath];
        [HDUtility removePhotoInfo:pInfo];
        [ar_scrll_data removeAllObjects];
        [ar_scrll_data addObjectsFromArray:[HDUtility readPhotoInfo]];
        iFlag_selectedImage--;
        if (iFlag_selectedImage < 0) {//第一次判断可能后面还有图片
            iFlag_selectedImage = (int)ar_scrll_data.count - 1;
        }
        scv_between.iSelected = iFlag_selectedImage;
        scv_bottom.iSelected  = iFlag_selectedImage;
        
        if (iFlag_selectedImage < 0) {//第二次判断是小于0那么就是没有图片了
            scv_bottom.hidden = YES;
            scv_between.hidden = YES;
        }else{
            [scv_between refreshScroolView];
            [scv_bottom  refreshScroolView];
        }
        
        if (scv_bottom.iSelected < 0) {
            lb_imageName.text = @"";
        }else{
            SNPhotoInfo *pInfo  = [SNPhotoInfo serverInfoWithDictionary:[ar_scrll_data objectAtIndex:scv_between.iSelected]];
            lb_imageName.text   = pInfo.photoName;
        }
        
        [HDUtility sayAfterSuccess:@"删除成功！"];
        
        return;
    }
    
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    [[SNHttpUtility sharedClient] deletePhoto_1:user photoID:pInfo.photoID CompletionBlock:^(BOOL isSuccess, NSString *sMessage) {
        if (isSuccess || [pInfo.photoID isEqualToString:@""]) {
            [HDUtility removeFileWithPath:pInfo.photoPath];
            [HDUtility removePhotoInfo:pInfo];
            [ar_scrll_data removeAllObjects];
            [ar_scrll_data addObjectsFromArray:[HDUtility readPhotoInfo]];
            
            iFlag_selectedImage--;
            if (iFlag_selectedImage < 0) {//第一次判断可能后面还有图片
                iFlag_selectedImage = (int)ar_scrll_data.count - 1;
            }
            scv_between.iSelected = iFlag_selectedImage;
            scv_bottom.iSelected  = iFlag_selectedImage;
            if (iFlag_selectedImage < 0) {//第二次判断是小于0那么就是没有图片了
                scv_bottom.hidden = YES;
                scv_between.hidden = YES;
            }else{
                [scv_between refreshScroolView];
                [scv_bottom  refreshScroolView];
            }
            
            if (scv_bottom.iSelected < 0) {
                lb_imageName.text = @"";
            }else{
                SNPhotoInfo *pInfo  = [SNPhotoInfo serverInfoWithDictionary:[ar_scrll_data objectAtIndex:scv_between.iSelected]];
                lb_imageName.text   = pInfo.photoName;
            }
            
            [HDUtility sayAfterSuccess:@"删除成功！"];
        }else{
            [HDUtility sayAfterSuccess:@"删除失败！"];
        }
        
    }];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self deleteImage];
    }
}

@end
