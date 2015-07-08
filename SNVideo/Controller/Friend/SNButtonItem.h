//
//  SNButtonItem.h
//  SNVideo
//
//  Created by Hu Dennis on 14-9-24.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SNButtonItemType){
    SNButtonItemTypeAdd = 0,
    SNButtonItemTypeAccount,
    SNButtonItemTypeBarcode,
    SNButtonItemTypeScan,
};
@class SNButtonItem;
@protocol SNButtonItemDelegate <NSObject>
- (void)SNDelegateTouchWithItem:(SNButtonItemType)iType;
@end

@interface SNButtonItem : UIView{
    

}
@property (strong)NSMutableArray                        *mar_buttons;
@property (weak, nonatomic) id<SNButtonItemDelegate>    delegate;
- (void)show;
- (void)hide;

@end
