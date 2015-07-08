//
//  SNPhotoScrollView.h
//  SNVideo
//
//  Created by Thinking on 14-10-24.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SNPhotoScrollViewDelegate;

@interface SNPhotoScrollView : UIView

@property (nonatomic, strong)NSMutableArray                 *mar_images;
@property (nonatomic, assign)int                            iSelected;
@property (nonatomic, assign)id <SNPhotoScrollViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame imageFrame:(CGRect)iFrame images:(NSMutableArray *)marImg gap:(float)fGap imageButton:(BOOL)iBtn;
- (void)selectImageWithIndex:(int)idex;
- (void)refreshScroolView;

@end

@protocol SNPhotoScrollViewDelegate <NSObject>

- (void)selectButton:(UIButton *)pBtn;
- (void)getScrollViewStatus:(SNPhotoScrollView *)pScv;

@optional



@end