//
//  MAEMOPathProcessor.h
//  addingSpaceBetweenChineseAndEnglish
//
//  Created by 宅音かがや on 2018/01/08.
//  Copyright © 2018年 宅音かがや. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAEMOPathProcessor : NSObject
@property (nonatomic) BOOL success; //是否提取成功
@property (nonatomic) NSUInteger lamda; // 扒皮的层数
@property (nonatomic) NSString *appPath; // 程序所在目录
@property (nonatomic) NSString *fileName; //文件名
@property (nonatomic) NSString *targetPath; // 最后的结果

- (void)setAppPathDefaultly;
- (void)getTargetPathString:(NSString *)inputString;
- (void)getThisPathString:(NSString *)inputString;
- (void)getFatherPathString:(NSString *)inputString;
- (NSString *)removeFileCover:(NSString *)inputString;
- (NSString *)removePathCover:(NSString *)inputString;

@end

