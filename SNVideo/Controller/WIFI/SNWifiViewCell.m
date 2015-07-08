//
//  SNWifiViewCell.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-19.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "SNWifiViewCell.h"

@interface SNWifiViewCell(){

    CGFloat initialTouchPositionX;
}

@end


@implementation SNWifiViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView bringSubviewToFront:self.v_actureContentView];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUp];
}
- (void)prepareForReuse
{
    [super prepareForReuse];
    [self setMenuOptionsViewHidden:YES animated:NO completionHandler:nil];
}
- (void)setUp{
    
    self.v_actureContentView                    = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 440, CELL_HEIGHT)];
    self.v_actureContentView.backgroundColor    = [UIColor clearColor];
    self.frame      = self.v_actureContentView.frame;
    self.isShowMenu = NO;
    self.btn_share  = [[UIButton alloc] initWithFrame:CGRectMake(265, (CELL_HEIGHT-49)/2, 49, 49)];
    self.btn_delete = [[UIButton alloc] initWithFrame:CGRectMake(365, (CELL_HEIGHT-49)/2, 49, 49)];
    self.btn_reset  = [[UIButton alloc] initWithFrame:CGRectMake(315, (CELL_HEIGHT-49)/2, 49, 49)];
    [self.btn_share setTitle:@"分享" forState:UIControlStateNormal];
    [self.btn_share titleLabel].font = FONT_HEAD;
    [self.btn_share setBackgroundImage:[UIImage imageNamed:@"button_分享.png"] forState:UIControlStateNormal];
    [self.btn_share addTarget:self action:@selector(doShare) forControlEvents:UIControlEventTouchUpInside];
    [self.btn_reset setTitle:@"重置" forState:UIControlStateNormal];
    [self.btn_reset titleLabel].font = FONT_HEAD;
    [self.btn_reset setBackgroundImage:[UIImage imageNamed:@"button_重置.png"] forState:UIControlStateNormal];
    [self.btn_reset addTarget:self action:@selector(doReset) forControlEvents:UIControlEventTouchUpInside];
    [self.btn_delete setTitle:@"删除" forState:UIControlStateNormal];
    [self.btn_delete titleLabel].font = FONT_HEAD;
    [self.btn_delete setBackgroundImage:[UIImage imageNamed:@"button_删除.png"] forState:UIControlStateNormal];
    [self.btn_delete addTarget:self action:@selector(doDelete) forControlEvents:UIControlEventTouchUpInside];
    [self.v_actureContentView addSubview:self.btn_reset];
    [self.v_actureContentView addSubview:self.btn_share];
    [self.v_actureContentView addSubview:self.btn_delete];
    [self.contentView addSubview:self.v_actureContentView];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    panRecognizer.delegate = self;
    [self addGestureRecognizer:panRecognizer];
    [self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer;
{
    if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panRecognizer = (UIPanGestureRecognizer *)recognizer;
        
        CGPoint currentTouchPoint = [panRecognizer locationInView:self.contentView];
        CGFloat currentTouchPositionX = currentTouchPoint.x;
        CGPoint velocity = [recognizer velocityInView:self.contentView];
        BOOL isEnd = (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled);
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            initialTouchPositionX = currentTouchPositionX;
            if (velocity.x > 0) {
                //[self.delegate contextMenuWillHideInCell:self];
            } else {
                [self.delegate contextMenuDidShowInCell:self];
            }
        } else if (recognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint velocity = [recognizer velocityInView:self.contentView];
            if (self.selected) {
                [self setSelected:NO animated:NO];
            }
            CGFloat panAmount       = currentTouchPositionX - initialTouchPositionX;
            initialTouchPositionX   = currentTouchPositionX;
            CGFloat minOriginX      = -([self menuButtonWith] + 30);
            CGFloat maxOriginX      = 0.;
            CGFloat originX         = CGRectGetMinX(self.v_actureContentView.frame) + panAmount;
            originX = MIN(maxOriginX, originX);
            originX = MAX(minOriginX, originX);
            if ((originX < -0.5 * [self menuButtonWith] && velocity.x < 0.) || velocity.x < -100) {
                self.isShowMenu = YES;
            } else if ((originX > -0.3 * [self menuButtonWith] && velocity.x > 0.) || velocity.x > 100) {
                self.isShowMenu = NO;
            }
            self.v_actureContentView.frame = CGRectMake(originX, 0., CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
        } else if (isEnd) {
            [self setMenuOptionsViewHidden:!self.isShowMenu animated:YES completionHandler:nil];
        }
    }
}
- (CGFloat)menuButtonWith{

    return CGRectGetWidth(self.btn_reset.frame) + CGRectGetWidth(self.btn_delete.frame);
}
- (void)setMenuOptionsViewHidden:(BOOL)isHidden animated:(BOOL)isAnimated completionHandler:(void (^)(void))completionHandler
{
    if (self.selected) {
        [self setSelected:NO animated:NO];
    }
    CGRect frame = CGRectMake(isHidden? 0: -[self menuButtonWith], 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    [UIView animateWithDuration:(isAnimated)? 0.2: 0.
                          delay:0.
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.v_actureContentView.frame = frame;
     }completion:^(BOOL finished) {
         if (completionHandler) {
             completionHandler();
         }
     }];
}

#pragma mark - SEL
- (void)doShare{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contextMenuCellDidSelectShareOption:)]) {
        [self.delegate contextMenuCellDidSelectShareOption:self];
    }
}
- (void)doReset{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contextMenuCellDidSelectResetOption:)]) {
        [self.delegate contextMenuCellDidSelectResetOption:self];
    }
    
}
- (void)doDelete{
    if (self.delegate && [self.delegate respondsToSelector:@selector(contextMenuCellDidSelectDeleteOption:)]) {
        [self.delegate contextMenuCellDidSelectDeleteOption:self];
    }
    
}

#pragma mark * UIPanGestureRecognizer delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:self];
        return fabs(translation.x) > fabs(translation.y);
    }
    return YES;
}

@end
