//
//  MAEMOExtentionFilter.h
//  addingSpaceBetweenChineseAndEnglish
//
//  Created by 宅音かがや on 2018/01/08.
//  Copyright © 2018年 宅音かがや. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAEMOExtentionFilter : NSObject
// 扩展名数组
@property (nonatomic) NSArray *extendNames;
// 声明新文件名的NSString
@property (nonatomic) NSMutableString *spacedFileStr;

- (void)setExtendNamesDefaultly;
- (BOOL)correctExtension:(NSString *)inputString;

@end
