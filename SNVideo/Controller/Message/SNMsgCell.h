//
//  SNMsgCell.h
//  SNVideo
//
//  Created by Thinking on 14-9-10.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNMsgCell : UITableViewCell
{
        
}

@property (nonatomic, strong)IBOutlet UILabel     *lb_time;
@property (nonatomic, strong)IBOutlet UILabel     *lb_date;
@property (nonatomic, strong)IBOutlet UILabel     *lb_title;
@property (nonatomic, strong)IBOutlet UILabel     *lb_content;
@property (nonatomic, strong)IBOutlet UIImageView *imv_timeLine;
@property (nonatomic, strong)IBOutlet UIImageView *imv_contentBg;

@end
