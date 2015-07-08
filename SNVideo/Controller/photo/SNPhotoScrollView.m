//
//  SNPhotoScrollView.m
//  SNVideo
//
//  Created by Thinking on 14-10-24.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNPhotoScrollView.h"

@interface SNPhotoScrollView()<UIScrollViewDelegate>
{
    CGRect          imgFrame;
    BOOL            iImgBtn;
    NSMutableArray  *mar_imvs;
    NSMutableArray  *mar_coverLbs;
    NSMutableArray  *mar_border;
    UIScrollView    *scv_bg;
    float           fGap_img;
    int             page_scr;
}

@end

@implementation SNPhotoScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame imageFrame:(CGRect)iFrame  images:(NSMutableArray *)marImg gap:(float)fGap imageButton:(BOOL)iBtn
{
    self = [super initWithFrame:frame];
    if (self) {
        imgFrame        = iFrame;
        iImgBtn         = iBtn;
        fGap_img        = fGap;
        self.mar_images = marImg;
        page_scr        = 0;
        mar_imvs        = [[NSMutableArray alloc] init];
        mar_coverLbs    = [[NSMutableArray alloc] init];
        mar_border      = [[NSMutableArray alloc] init];
        scv_bg          = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [scv_bg setBackgroundColor:[UIColor clearColor]];
        scv_bg.pagingEnabled = !iBtn;
        scv_bg.delegate = self;
        scv_bg.showsHorizontalScrollIndicator = NO;
        
        [self addSubview:scv_bg];
        
        [self createImage];
        [self selectImageWithIndex:0];
    }
    
    return self;
}

- (void)selectImageWithIndex:(int)idex
{
    self.iSelected = idex;
    if (idex < 0) {
        self.iSelected = 0;
    }else if(idex > self.mar_images.count - 1){
        self.iSelected = (int)self.mar_images.count - 1;
    }
    
    if (!iImgBtn) {
        [self resetScrollViewImag];
    }else{
        for (int i = 0; i < mar_coverLbs.count; i++) {
            UILabel *lb_t = [mar_coverLbs objectAtIndex:i];
            UIImageView *imv_b = [mar_border objectAtIndex:i];
            if (i == idex) {
                lb_t.hidden = YES;
                imv_b.hidden = NO;
            }else{
                lb_t.hidden = NO;
                imv_b.hidden = YES;
            }
        }
        int iCount = (self.iSelected * imgFrame.size.width - self.frame.size.width) / self.frame.size.width;
        [scv_bg setContentOffset:CGPointMake((iCount * imgFrame.size.width - self.frame.size.width) / imgFrame.size.width, 0) animated:YES];
    }

}

- (void)addImag:(int)index
{
    UIImageView *imv_t = [[UIImageView alloc] initWithFrame:CGRectMake((imgFrame.size.width + fGap_img) * index, (self.frame.size.height - imgFrame.size.height) / 2, imgFrame.size.width, imgFrame.size.height)];
    SNPhotoInfo *pInfo = [SNPhotoInfo serverInfoWithDictionary:[self.mar_images objectAtIndex:index]];
    [imv_t setImage:[UIImage imageWithContentsOfFile:pInfo.photoPath]];
    [scv_bg addSubview:imv_t];
    [mar_imvs addObject:imv_t];
    
    if (iImgBtn) {
        UILabel *lb_cover = [[UILabel alloc] initWithFrame:imv_t.frame];
        [lb_cover setBackgroundColor:[UIColor blackColor]];
        lb_cover.alpha = 0.8;
        lb_cover.hidden = YES;
        lb_cover.text = @"";
        [scv_bg addSubview:lb_cover];
        [mar_coverLbs addObject:lb_cover];
        
        UIImageView *imv_border = [[UIImageView alloc] initWithFrame:imv_t.frame];
        [imv_border setImage:[UIImage imageNamed:@"photo_bg_01.png"]];
        imv_border.hidden = YES;
        [scv_bg addSubview:imv_border];
        [mar_border addObject:imv_border];
        
        UIButton *btn_cover     = [[UIButton alloc] initWithFrame:imv_t.frame];
        btn_cover.tag           = index;
        [btn_cover setBackgroundColor:[UIColor clearColor]];
        [btn_cover addTarget:self action:@selector(coverButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [scv_bg addSubview:btn_cover];
    }
}

- (void)createImage
{
    [mar_imvs removeAllObjects];
    [mar_coverLbs removeAllObjects];
    
//    int count = self.frame.size.width / (imgFrame.size.width + fGap_img) + 2;
//    if (count % 2 == 0) {
//        count++;
//    }
    int count = 0;
    if (!iImgBtn) {
        count = (int)self.mar_images.count >= 3? 3 : (int)self.mar_images.count;
    }else{
        count = (int)self.mar_images.count;
    }
    scv_bg.contentSize = CGSizeMake((imgFrame.size.width + fGap_img) * count, scv_bg.frame.size.height);
    for (int i = 0; i < count; i++) {
        [self addImag:i];
    }
//    /*计算偏移x坐标*/
//    float x_off = (imgFrame.size.width + fGap_img) * count / 2 - self.center.x;
//    
//    [scv_bg setContentOffset:CGPointMake(x_off, 0) animated:NO];
    
}

- (void)refreshScroolView
{
    for (UIView *v in scv_bg.subviews) {
        [v removeFromSuperview];
    }
    
    [self createImage];
    
    [self selectImageWithIndex:self.iSelected];
}

-(void)resetScrollViewImag
{
    
    if (!iImgBtn) {
        int pag_img = self.iSelected;
        
        if (pag_img <= 0) {
            self.iSelected = 0;
            return;
        }else if (pag_img >= self.mar_images.count - 1){
            self.iSelected = (int)self.mar_images.count - 1;
            return;
        }
        Dlog(@"select==%d", pag_img);
        
        for (int i = 0; i < mar_imvs.count; i++) {
            UIImageView *imv_t = [mar_imvs objectAtIndex:i];
            int index = i + pag_img - 1;
            SNPhotoInfo *pInfo = [SNPhotoInfo serverInfoWithDictionary:[self.mar_images objectAtIndex:index]];
            [imv_t setImage:[UIImage imageWithContentsOfFile:pInfo.photoPath]];
            index++;
        }
        [scv_bg setContentOffset:CGPointMake(imgFrame.size.width, 0) animated:NO];
        
    }else{
        
        
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark button action
-(void)coverButtonAction:(UIButton *)btn
{
    [self selectImageWithIndex:(int)btn.tag];
    [self.delegate selectButton:btn];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    Dlog(@"======bigin======");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!iImgBtn) {
        CGFloat pageWith = scrollView.frame.size.width;//页面宽度
        int pageNumber = floor((scrollView.contentOffset.x - pageWith / 2) / pageWith) + 1;
        page_scr = pageNumber;
        
    }else{
        CGFloat pageWith = imgFrame.size.width;//页面宽度
        int pageNumber = floor((scrollView.contentOffset.x - pageWith / 2) / pageWith) + 1;
        page_scr = pageNumber;
    }
    
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (!iImgBtn) {
        
    }else{
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //代码设置ContentOffset移动完成后不回调此方法
    if (!iImgBtn) {
        
        if (self.mar_images.count >= 3) {
            if (self.iSelected == self.mar_images.count - 1 && page_scr == 1) {
                self.iSelected--;
            }else if (page_scr == 1 && self.iSelected == 0){
                self.iSelected++;
            }else if (page_scr == 0) {
                self.iSelected--;
            }else if(page_scr == 2){
                self.iSelected++;
            }
        }else{
            self.iSelected = page_scr;
        }
        
        [self resetScrollViewImag];
        
        [self.delegate getScrollViewStatus:self];
    }else{
        
    }
    
}


@end
