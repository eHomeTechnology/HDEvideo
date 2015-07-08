//
//  HDFileUtility.m
//  Created by Hu Dennis on 11-7-3.
//

#import "HDFileUtility.h"

#ifndef __FILE_USER_SETTING__ 
#define __FILE_USER_SETTING__ @"userSetting"
#endif

static HDFileUtility *kMyFileInstance = nil;

@implementation HDFileUtility


+(HDFileUtility *)instance {
    
	@synchronized(self) {
        
		if (kMyFileInstance == nil) {
            
			kMyFileInstance = [[HDFileUtility alloc] init];
		}
	}
	return kMyFileInstance;
}


-(NSString *)getDocumentPath{
	
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

-(NSString *)filePath:(NSString *)fileName_ {
	
    return [NSString stringWithFormat:@"%@/%@", [self getDocumentPath], fileName_];
}

-(void)saveDict:(NSMutableDictionary *)dict toFile:(NSString *)fileName_{
    
	[dict writeToFile:[self filePath:fileName_] atomically:YES];
}

- (NSMutableDictionary *)readDictInTheFile:(NSString *)fileName_{
    
	NSMutableDictionary *localSettingDict = nil;
	if ([[NSFileManager defaultManager] fileExistsAtPath:[self filePath:fileName_]]) {
        
		localSettingDict = [[NSMutableDictionary alloc] initWithContentsOfFile:[self filePath:fileName_]];
		return localSettingDict;
	}else {
        
        return nil;
	}
}

-(void)saveObject:(id)obj toFile:(NSString *)sFile{
    
    NSString *sPath = [self filePath:sFile];
    BOOL isSuc = [NSKeyedArchiver archiveRootObject:obj toFile:sPath];
    if (!isSuc) {
        
        NSLog(@"Error:写入文件失败");
    }
}

-(id)readObjectFromFile:(NSString *)sFile{
    
    NSString *sPath = [self filePath:sFile];
    id obj = [NSKeyedUnarchiver unarchiveObjectWithFile:sPath];
    
    return obj;
}

- (NSString *)saveImag:(UIImage *)img imagName:(NSString *)name
{
    NSString *sPath = [self filePath:name];
    NSData *data_t = UIImagePNGRepresentation(img);
    BOOL isSuc = [data_t writeToFile:sPath atomically:YES];;
    if (!isSuc) {
        
        NSLog(@"Error:写入文件失败");
    }else{
        return sPath;
    }
    
    return nil;
}

- (BOOL)removeFileWithName:(NSString *)name
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *sPath = [self filePath:name];
    BOOL bRet = [fileMgr fileExistsAtPath:sPath];
    if (bRet) {
        //
        NSError *err;
        BOOL removFig = [fileMgr removeItemAtPath:sPath error:&err];
        return removFig;
    }
    
    return bRet;
}

@end
