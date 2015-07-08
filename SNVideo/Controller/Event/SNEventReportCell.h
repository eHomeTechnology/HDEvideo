//
//  SNEventReportCell.h
//  SNVideo
//
//  Created by Thinking on 14-11-2.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNEventReportCell : UITableViewCell

@property (nonatomic, strong)IBOutlet UILabel     *lb_time;
@property (nonatomic, strong)IBOutlet UIImageView *imv_timeLine;
@property (nonatomic, strong)IBOutlet UIImageView *imv_contentBg;

@end
