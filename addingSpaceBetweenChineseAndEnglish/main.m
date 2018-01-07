//
//  main.m
//  addingSpaceBetweenChineseAndEnglish
//
//  Created by 宅音かがや on 2018/01/07.
//  Copyright © 2018年 宅音かがや. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // 读取md文件到NSMutableString
        NSError *error;
        NSMutableString *stringWithFile= [[NSString alloc] initWithContentsOfFile:@"/tmp/test.md"
                                                           encoding:NSUTF8StringEncoding
                                                              error:&error];
        if (!stringWithFile) {
            NSLog(@"Reading from file failed: %@", error);
        } else {
            NSLog(@"Reading from file succeeded.");
        }
        
        // 查找紧挨着汉字的英文字母
        NSUInteger ending = [stringWithFile length] - 1;
        
        NSUInteger thisCharacter = 0;
        NSUInteger nextCharacter = 0;
        BOOL EAC = thisCharacter == nextCharacter? true : false;
        NSLog(@"defalt EAC: %c", EAC);
        
        NSUInteger i = 0;
        do {
            NSLog(@"ending now is %lu", ending);
            // 得到索引i处的单个字符
            NSRange thisRange = NSMakeRange(i,1);
            NSRange nextRange = NSMakeRange(i+1, 1);
            
            NSString *thisSubString = [stringWithFile substringWithRange:thisRange];
            NSString *nextSubString = [stringWithFile substringWithRange:nextRange];
            // 将这个字符转化成C语言字符，判断长度
            const char *thisCString=[thisSubString UTF8String];
            const char *nextCString=[nextSubString UTF8String];
            // 判断this
            if (strlen(thisCString)==3)
            {
                NSLog(@"%lu 是汉字", i);
                thisCharacter = 0;
            }else if(strlen(thisCString)==1) {
                NSLog(@"%lu 是字母", i);
                thisCharacter = 1;
            }
            // 判断next
            if (strlen(nextCString)==3)
            {
                NSLog(@"%lu 是汉字", i+1);
                nextCharacter = 0;
            }else if(strlen(nextCString)==1) {
                NSLog(@"%lu 是字母", i+1);
                nextCharacter = 1;
            }
            // 得到EAC
            // 如果这个字符和下一个字符相同类型，那么EAC就是true，true就不添加空格；
            // 如果这个字符和下一个字符不同类型，那么EAC就是false，false就添加空格；
            EAC = thisCharacter == nextCharacter? true : false;
            if (!EAC) {
                NSLog(@"Found EAC, at range {location: %lu, length: %lu}", nextRange.location, nextRange.length);
                // 在这里生成两个子字符串
                NSString *formerString  = [stringWithFile substringToIndex:nextRange.location];
                NSLog(@"formerString is [%@]", formerString);
                NSString *laterString = [stringWithFile substringFromIndex:nextRange.location];
                NSLog(@"laterString is [%@]", laterString);
                
                // 删掉stringWithFile的后半部分
                stringWithFile = [[NSMutableString alloc] initWithString:formerString];
                NSLog(@"the temporary stringWithFile is [%@]", stringWithFile);
                // 给stringWithFile添加空格和后半部分
                [stringWithFile appendString:@" "];
                [stringWithFile appendString:laterString];
                NSLog(@"the new stringWithFile is [%@]", stringWithFile);
                // 因为更新了stringWithFile的内容，所以字符串长度也有所变化
                ending = [stringWithFile length] - 1;
                NSLog(@"The New Ending is %lu", ending);
                // 现在修改记数符号，为什么是nextRange + 1，我也不是很懂。
                // 应该是为了跳过这一次循环中添加的空格的位置。
                i = nextRange.location + 1;
//                i++;
                
                // 先测试一下第一次成功
                //return 0;
            } else {
                NSLog(@"No EAC");
                i++;
            }
        }while (i < ending);
        // 最后输出当前的stringWithFile
        NSLog(@"stringWithFile is [%@]", stringWithFile);
        // 将文件导出到一个新的md文件中
        BOOL success = [stringWithFile writeToFile:@"/tmp/test_spaced.md" atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (success) {
            NSLog(@"已经写入到文件");
        } else {
            NSLog(@"写入到文件失败");
        }
    }
    return 0;
}
