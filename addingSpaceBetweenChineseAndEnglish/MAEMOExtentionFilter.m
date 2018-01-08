//
//  MAEMOExtentionFilter.m
//  addingSpaceBetweenChineseAndEnglish
//
//  Created by 宅音かがや on 2018/01/08.
//  Copyright © 2018年 宅音かがや. All rights reserved.
//

#import "MAEMOExtentionFilter.h"

@implementation MAEMOExtentionFilter

- (void)setExtendNamesDefaultly {
    self.extendNames = @[@".md", @".txt", @".html"];
}

- (BOOL)correctExtension:(NSString *)inputString {
    // 倒着匹配扩展名，哈哈哈哈哈哈哈哈哈
    for (NSInteger i = [inputString length] - 1; i >= 0; i--) {
        NSRange range = NSMakeRange(i, 1);
        NSString *charStr = [inputString substringWithRange:range];
        
        if ([charStr isEqualToString:@"."]) {
            NSLog(@"⭕️找到扩展名");
            // 寻找.号之后
            NSString *extendStr = [inputString substringFromIndex:i];
            // 转换大小写吗？至少这一步就转换一下吧
            NSString *extendStrLower = [extendStr lowercaseString];
            NSLog(@"🔺文件扩展名为：%@", extendStrLower);
            
            if ([self.extendNames containsObject:extendStrLower]) {
                NSLog(@"⭕️文件名合法");
                // 如果文件名匹配成功
                // 检测newFileStr是否存在，不存在的话就创建一下
                if (!self.spacedFileStr) {
                    self.spacedFileStr = [[NSMutableString alloc] init];
                }
                // 生成新的目标文件名
                [self.spacedFileStr appendString:[inputString substringToIndex:i]];
                [self.spacedFileStr appendString:@"_SpacesAdded"];
                [self.spacedFileStr appendString:extendStrLower];
                NSLog(@"🔺新文件名为：%@", self.spacedFileStr);
                // 接下来的循环就不用继续了，直接返回TURE，跳出for循环
                return TRUE;
            } else {
                NSLog(@"❌文件名不合法");
                // 如果文件名匹配失败，就直接结束程序
                return FALSE;
            }
        } else {
            if (i == 0) {
                NSLog(@"❌未找到扩展名");
                return FALSE;
            }
        }
    }
    return FALSE;
}


@end
