//
//  SNWifiViewCell.h
//  SNVideo
//
//  Created by Hu Dennis on 14-9-19.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_HEIGHT 60

@class SNWifiViewCell;
@protocol SNWifiViewCellDelegate <NSObject>

- (void)contextMenuCellDidSelectDeleteOption:(SNWifiViewCell *)cell;
- (void)contextMenuCellDidSelectResetOption:(SNWifiViewCell *)cell;
- (void)contextMenuCellDidSelectShareOption:(SNWifiViewCell *)cell;
- (void)contextMenuDidShowInCell:(SNWifiViewCell *)cell;
@optional
- (BOOL)shouldShowMenuOptionsViewInCell:(SNWifiViewCell *)cell;
- (void)contextMenuDidHideInCell:(SNWifiViewCell *)cell;
- (void)contextMenuWillHideInCell:(SNWifiViewCell *)cell;
- (void)contextMenuWillShowInCell:(SNWifiViewCell *)cell;


@end

@interface SNWifiViewCell : UITableViewCell<UIGestureRecognizerDelegate>{

    
}

@property (strong)UIView        *v_actureContentView;
@property (strong)UILabel       *lb_title;
@property (strong)UIButton      *btn_share;
@property (strong)UIButton      *btn_delete;
@property (strong)UIButton      *btn_reset;
@property (assign)BOOL          isShowMenu;
@property (assign)int           iRow;
@property (weak, nonatomic)     id<SNWifiViewCellDelegate> delegate;

- (void)setMenuOptionsViewHidden:(BOOL)isHidden animated:(BOOL)isAnimated completionHandler:(void (^)(void))completionHandler;

@end
