//
//  NSObject_Instance.h
//  FEPosUniversal
//
//  Created by DennisHu on 12-8-6.
//  Copyright (c) 2012年 __iDennisHu__. All rights reserved.
//
#import "SNInstance.h"

typedef NS_ENUM(NSInteger, HDCharacterType) {
    
    HDCharacterTypeEnglish = 0,         
    HDCharacterTypeChinese,
    HDCharacterTypeOther,
};

#define _fileName_default__     @"default"
#define FONT_BODY               [UIFont fontWithName:@"Arial" size:13]
#define FONT_HEAD               [UIFont fontWithName:@"Arial" size:15]

#define SRV_CONNECTED       0
#define SRV_CONNECT_SUC     1
#define SRV_CONNECT_FAIL    2
#define debugMode           1

#ifdef DEBUG
#define debugLog(...) NSLog(__VA_ARGS__)
#define debugMethod() NSLog(@"%s", __func__)
#else
#define debugLog(...)
#define debugMethod()
#endif

#ifdef DEBUG
#define Dlog(fmt, ...) NSLog((@"====%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define Dlog(fmt, ...)
#endif

#define DEVICE_IS_IPHONE    [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone
#define DEVICE_IS_IPAD      [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
#define HDDeviceSize        [[UIScreen mainScreen] bounds].size
#define kWindow             [UIApplication sharedApplication].keyWindow
#define FORMAT(format, ...) [NSString stringWithFormat:(format), ##__VA_ARGS__]
#define DOCUMENTS_FOLDER    [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define FILEPATH            [DOCUMENTS_FOLDER stringByAppendingPathComponent:[self dateString]]
#define LS(s)  NSLocalizedString((s),nil)

#define ORITATION_IS_HORIZONTAL     ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft)

#define ORITATION_IS_VERTICAL       ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortraitUpsideDown)

#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define SYSBARBUTTON(ITEM, TARGET, SELECTOR) [[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:TARGET action:SELECTOR]

#ifndef IOS_VERSION
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#endif
#define IS_4INCH_SCREEN     (fabs((double)[[UIScreen mainScreen ] bounds].size.height - (double)568)  <  DBL_EPSILON )
#define IS_35INCH_SCREEN    (fabs((double)[[UIScreen mainScreen ] bounds].size.height - (double)568)  >= DBL_EPSILON )

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff; \
    _Pragma("clang diagnostic pop") \
} while (0)



