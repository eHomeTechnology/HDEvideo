//
//  SNPhotoViewCtr.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-19.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "SNPhotoViewCtr.h"
#import "SNHttpUtility.h"
#import "HDFileUtility.h"
#import "SNPhotoSeePicture.h"
#import "SNPhotoSeeVideo.h"

@interface SNPhotoViewCtr ()
{
    IBOutlet UITableView    *tbv_photo;
    NSMutableArray          *ar_photo;
    BOOL                    editFig;
    NSMutableDictionary     *dic_selectFig;
    NSMutableArray          *ar_remove;
    
    UIButton                *btn_edit;
    UIBarButtonItem         *item_edit;
}
@end

@implementation SNPhotoViewCtr

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
/* 如果是视频格式，需要保存一张图片和对应的视频文件，所以PhotoInfo类需要加一个本地视频文件的路径，和本地视频对应图片的路径*/
- (void)viewDidAppear:(BOOL)animated
{
    NSArray *array_t = [SNPhotoInfo classFullForTime:[HDUtility readPhotoInfo]];
    if ([ar_photo count] > 0) {
        [ar_photo removeAllObjects];
    }
    
    Dlog(@"photo %@", array_t);
    
    [ar_photo addObjectsFromArray:array_t];
    
    [tbv_photo reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title      = @"家庭相册";
    editFig         = NO;
    dic_selectFig   = [[NSMutableDictionary alloc] init];
    ar_remove       = [[NSMutableArray alloc] init];
    ar_photo        = [[NSMutableArray alloc] init];
    
    if (IOS_VERSION >= 7.0) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(doBack:)];
        item_edit = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_edit.png"] style:UIBarButtonItemStylePlain target:self action:@selector(editItemAction:)];
        self.navigationItem.rightBarButtonItem = item_edit;
        
    }else{
        UIButton *btn_back = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_back.frame = CGRectMake(0, 0, 44, 25);
        [btn_back setImage:[UIImage imageNamed:@"icon_back.png"] forState:UIControlStateNormal];
        [btn_back addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_back];
        
        btn_edit = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_edit.frame = CGRectMake(0, 0, 44, 25);
        [btn_edit setImage:[UIImage imageNamed:@"icon_edit.png"] forState:UIControlStateNormal];
        [btn_edit addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_edit];
    }
    
    tbv_photo.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    SNUserInfo *user = [HDUtility readLocalUserInfo];
    [[SNHttpUtility sharedClient] getPhotoList_1:user CompletionBlock:^(BOOL isSuccess, NSArray *ar_list, NSString *sMessage) {
        [self downImage:ar_list];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)downImage:(NSArray *)ar
{

    NSArray *array_old = [HDUtility readPhotoInfo];
    for (int i = 0; i < ar.count; i++) {
        SNPhotoInfo *pInfo = [ar objectAtIndex:i];
        BOOL haveFig = NO;
        for (int j = 0; j < array_old.count; j++) {
            SNPhotoInfo *pInfo_old = [SNPhotoInfo serverInfoWithDictionary:[array_old objectAtIndex:j]];
            if (pInfo_old.photoID && [pInfo.photoID isEqualToString:pInfo_old.photoID]) {
                if (pInfo_old.photoPath == nil || [pInfo_old.photoPath isEqualToString:@""]) {
                    haveFig = NO;
                }else{
                    haveFig = YES;
                }
                break;
            }
        }
        if (!haveFig) {
            [[SNHttpUtility requestImageWithURL:pInfo.photoURL] requestStart_1WithCompletionBlock:^(BOOL isSuccess, UIImage *img, NSString *sMessage) {
                if (isSuccess) {
                    if (pInfo.photoName == nil || [pInfo.photoName isEqualToString:@""]) {
                        pInfo.photoName = [pInfo.photoURL lastPathComponent];
                    }
                    NSString *path = [[HDFileUtility instance] saveImag:img imagName:pInfo.photoName];
                    pInfo.photoPath = path;
                    [HDUtility savePhotoInfo:pInfo];
                    [ar_photo removeAllObjects];
                    NSArray *array_t2 = [SNPhotoInfo classFullForTime:[HDUtility readPhotoInfo]];
                    [ar_photo addObjectsFromArray:array_t2];
                    [tbv_photo reloadData];
                }
            }];
        }
        
    }
   
}

#pragma mark - button Action
-(void)doBack:(id)sender
{
    if (editFig) {
        [self cancelDelImage];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)buttonPhotoAction:(UIButton *)btn
{
    int section         = (int)btn.tag / 1000;
    int row_i           = btn.tag % 1000;
//    Dlog(@"section=%d rowi=%d", section, row_i);
    NSArray *array_t    = [[ar_photo objectAtIndex:section] valueForKey:@K_PHOTO_ARRAY];
    SNPhotoInfo *pInfo  = [SNPhotoInfo serverInfoWithDictionary:[array_t objectAtIndex:row_i]];
    if (editFig) {
        NSString *key   = [NSString stringWithFormat:@"%d_%d", section, row_i];
        BOOL fig = ![[dic_selectFig valueForKey:key] boolValue];
        [dic_selectFig setObject:[NSString stringWithFormat:@"%d", fig] forKey:key];
        if (fig) {
            [ar_remove addObject:pInfo];
        }else{
            for (int i = 0; i < ar_remove.count; i++) {
                SNPhotoInfo *pInfo_t = [ar_remove objectAtIndex:i];
                if ([pInfo.photoName isEqualToString:pInfo_t.photoName]) {
                    [ar_remove removeObjectAtIndex:i];
                    break;
                }
            }
        }
        [tbv_photo reloadData];
    }else{
        
        if (pInfo.pType == SNPhotoPicture) {
            SNPhotoSeePicture *seeP = [[SNPhotoSeePicture alloc] initWithImageName:pInfo.photoName];
            [self.navigationController pushViewController:seeP animated:YES];
        }else{
            SNPhotoSeeVideo *seeV = [[SNPhotoSeeVideo alloc] init];
            [self.navigationController pushViewController:seeV animated:YES];
            
        }
        
        
    }
}

-(void)editItemAction:(UIBarItem *)item
{
    if (!editFig) {
        editFig = YES;
        [item setImage:[UIImage imageNamed:@"icon_del.png"]];
    }else if(ar_remove.count == 0){
        [self cancelDelImage];
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LS(@"prompt")
                                                        message:@"该操作将同时删除云端相片，确定要删除吗？"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"删除", nil];
        [alert show];
    }
    
    [tbv_photo reloadData];
}

-(void)editButtonAction:(UIButton *)btn
{
    if (!editFig) {
        editFig = YES;
        [btn setImage:[UIImage imageNamed:@"icon_del.png"] forState:UIControlStateNormal];
    }else if(ar_remove.count == 0){
        [self cancelDelImage];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LS(@"prompt")
                                                        message:@"该操作将同时删除云端相片，确定要删除吗？"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"删除", nil];
        [alert show];
    }
    
    [tbv_photo reloadData];
}

- (void)deleteImage
{
    for (int i = 0; i < ar_remove.count; i++) {
        SNPhotoInfo *pInfo  = [ar_remove objectAtIndex:i];
        if (pInfo.photoID == nil || [pInfo.photoID isEqualToString:@""]) {
            [HDUtility removeFileWithPath:pInfo.photoPath];
            [HDUtility removePhotoInfo:pInfo];
            NSArray *array_t = [SNPhotoInfo classFullForTime:[HDUtility readPhotoInfo]];
            [ar_photo removeAllObjects];
            [ar_photo addObjectsFromArray:array_t];
            continue;
        }
        SNUserInfo *user    = [HDUtility readLocalUserInfo];
        [[SNHttpUtility sharedClient] deletePhoto_1:user photoID:pInfo.photoID CompletionBlock:^(BOOL isSuccess, NSString *sMessage) {
            if (isSuccess || [pInfo.photoID isEqualToString:@""]) {
                [HDUtility removeFileWithPath:pInfo.photoPath];
                [HDUtility removePhotoInfo:pInfo];
                NSArray *array_t = [SNPhotoInfo classFullForTime:[HDUtility readPhotoInfo]];
                [ar_photo removeAllObjects];
                [ar_photo addObjectsFromArray:array_t];
            }
        }];
        
    }
    
    [self cancelDelImage];
}

-(void)cancelDelImage
{
    [ar_remove removeAllObjects];
    dic_selectFig = nil;
    dic_selectFig = [[NSMutableDictionary alloc] init];
    editFig = NO;
    if (IOS_VERSION >= 7.0) {
        [item_edit setImage:[UIImage imageNamed:@"icon_edit.png"]];
    }else{
        [btn_edit setImage:[UIImage imageNamed:@"icon_edit.png"] forState:UIControlStateNormal];
    }
    
    [tbv_photo reloadData];
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ar_photo.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array_t = [[ar_photo objectAtIndex:indexPath.section] valueForKey:@K_PHOTO_ARRAY];
    int i = array_t.count % 3 == 0? ((int)array_t.count / 3) : ((int)array_t.count / 3 + 1);
    return 77 * i + 3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v_section   = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)];
    [v_section  setBackgroundColor:[UIColor clearColor]];
    
    UILabel *lb_section = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 20, 22)];
    [lb_section setBackgroundColor:[UIColor clearColor]];
    [lb_section setTextColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"color_photo_02.png"]]];
    [lb_section setFont:[UIFont systemFontOfSize:12]];
    [v_section  addSubview:lb_section];
    lb_section.text = [[ar_photo objectAtIndex:section] valueForKey:@K_PHOTO_TIME];
    
    return v_section;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SNPhotoViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //    UITableViewCell *cell = nil;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //如果时新创建的cell，则要创建cell的内容
    }
    else{
        //cell中本来就有一个subview，如果是重用cell，则把cell中自己添加的subview清除掉，避免出现重叠问题
        //         [[cell.subviews objectAtIndex:1] removeFromSuperview];
        for (UIView *subView in cell.contentView.subviews)
        {
            [subView removeFromSuperview];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"color_photo_01.png"]]];

    NSArray *array_t        = [[ar_photo objectAtIndex:indexPath.section] valueForKey:@K_PHOTO_ARRAY];
    for (int i = 0; i < array_t.count; i++) {
        SNPhotoInfo *pInfo  = [SNPhotoInfo serverInfoWithDictionary:[array_t objectAtIndex:i]];
        int k               = i % 3;
        int j               = i / 3;
        UIImageView *imv_t  = [[UIImageView alloc] initWithFrame:CGRectMake(k * 106 + 3, j * 77 + 3, 103, 74)];
//        [imv_t setImage:[UIImage imageNamed:@"head_femal.png"]];
        Dlog(@"===%@", pInfo.photoPath);
        UIImage *img_t = [UIImage imageWithContentsOfFile:pInfo.photoPath];
        [imv_t setImage: img_t];
        [cell.contentView addSubview:imv_t];
       
        if (pInfo.pType == SNPhotoVideo) {
            UIImageView *imv_playIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
            imv_playIcon.center = imv_t.center;
            [imv_playIcon setImage:[UIImage imageNamed:@"photo_video.png"]];
            [cell.contentView addSubview:imv_playIcon];
        }
        
        if (editFig) {
            NSString *key = [NSString stringWithFormat:@"%ld_%d", (long)indexPath.section, i];
            BOOL fig = [[dic_selectFig valueForKey:key] boolValue];
            UIImageView *imv_select = [[UIImageView alloc] initWithFrame:CGRectMake((imv_t.frame.origin.x + imv_t.frame.size.width - 21), imv_t.frame.origin.y, 21, 21)];
            if (fig) {
                [imv_select setImage:[UIImage imageNamed:@"photo_select_02.png"]];
            }else{
                [imv_select setImage:[UIImage imageNamed:@"photo_select_01.png"]];
            }
            
            [cell.contentView addSubview:imv_select];
        }
        
        UIButton *btn_photo     = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_photo.frame         = imv_t.frame;
        [btn_photo addTarget:self action:@selector(buttonPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
        btn_photo.tag           = indexPath.section * 1000 + i;
        [cell.contentView addSubview:btn_photo];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self deleteImage];
    }else{
        [self cancelDelImage];
    }
}


@end
