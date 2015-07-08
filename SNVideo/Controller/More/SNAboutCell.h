//
//  SNAboutCell.h
//  SNVideo
//
//  Created by Thinking on 14-10-8.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNAboutCell : UITableViewCell

@property (nonatomic, strong)IBOutlet UILabel        *lb_line_up;
@property (nonatomic, strong)IBOutlet UILabel        *lb_line_down;
@property (nonatomic, strong)IBOutlet UILabel        *lb_line_left;
@property (nonatomic, strong)IBOutlet UILabel        *lb_line_right;
@property (nonatomic, strong)IBOutlet UILabel        *lb_new;
@property (nonatomic, strong)IBOutlet UILabel        *lb_content;
@property (nonatomic, strong)IBOutlet UILabel        *lb_versions;
@property (nonatomic, strong)IBOutlet UIImageView    *imv_arrows;
@property (nonatomic, strong)IBOutlet UIImageView    *imv_newBg;

@end
