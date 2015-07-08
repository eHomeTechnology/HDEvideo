

#import <Foundation/Foundation.h>

#define _FILE_GLOBLE_ @"globleFile"


@interface HDFileUtility : NSObject {
	

}
+ (HDFileUtility *)instance;
- (NSMutableDictionary *)readDictInTheFile:(NSString *)fileName_;
- (void)saveDict:(NSMutableDictionary *)dict toFile:(NSString *)fileName_;

- (void)saveObject:(id)obj toFile:(NSString *)sFile;
- (id)readObjectFromFile:(NSString *)sFile;

- (NSString *)saveImag:(UIImage *)img imagName:(NSString *)name;
- (BOOL)removeFileWithName:(NSString *)name;

@end
