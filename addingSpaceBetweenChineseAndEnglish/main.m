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
        // 提前设定好中文特殊符号，不加空格的
        // 这些特殊字符都不会添加空格。
        NSArray *chineseSymbols = @[@"，", @"。", @"？", @"！", @"：", @"；", @"、", @"（", @"）", @"【", @"】", @"「", @"」", @"", @"『", @"』", @"《", @"》", @"…", @"—"];
        NSArray *syntaxSymbols = @[@"\n"];
        
        // 读取md文件到NSMutableString
        NSError *error;
        NSMutableString *stringWithFile= [[NSMutableString alloc] initWithContentsOfFile:@"/tmp/test.md"
                                                           encoding:NSUTF8StringEncoding
                                                              error:&error];
        if (!stringWithFile) {
            NSLog(@"Reading from file failed: %@", error);
        } else {
            NSLog(@"Reading from file succeeded.");
        }
        
        // 查找紧挨着汉字的英文字母
        NSUInteger ending = [stringWithFile length] - 1;
        
        // 这两个整形用来标记当前字符和下个字符的类型；
        // 英文字符=0；中文字=1；中文不需要加空格的符号=2；
        // 只有中英紧挨着的时候，也就是EAC=1的时候需要加空格。
        // 至于为什么不用BOOL型，因为我发现BOOL型赋值的时候有BUG，只要第一个是false，后面的他就不看了。
        // 现在初始化都是默认英文符号
        NSUInteger thisCharacterIsEnglish = 0;
        NSUInteger nextCharacterIsEnglish = 0;
        
        // 得到EAC
        // 如果这个字符和下一个字符相同类型，那么EAC就是true，true就不添加空格；
        // 如果这个字符和下一个字符不同类型，那么EAC就是false，false就添加空格；
        // BOOL输出的时候是字符类型，%c。
        BOOL EAC = (thisCharacterIsEnglish + nextCharacterIsEnglish) == 1;
        NSLog(@"defalt EAC: %c", EAC);
        
        // 建立一个do while循环。
        // 为什么不用for循环？因为循环的次数会随着程序运行不断增加。
        NSUInteger i = 0;
        do {
            // 输出现在字符串的长度
//            NSLog(@"ending now is %lu", ending);
            
            // 得到索引i处的单个字符x2
            NSRange thisRange = NSMakeRange(i,1);
            NSRange nextRange = NSMakeRange(i+1, 1);
            
            // 得到字符的单字符子串x2
            NSString *thisSubString = [stringWithFile substringWithRange:thisRange];
            NSString *nextSubString = [stringWithFile substringWithRange:nextRange];
            
            // 将字符转化成C语言字符，判断长度x2
            const char *thisCString=[thisSubString UTF8String];
            const char *nextCString=[nextSubString UTF8String];
            
            // 判断this
            if (strlen(thisCString)==3)
            {
                // 如果是中文的限定的符号，则应使它识别为英文（为了不添加空格）
                if ([chineseSymbols containsObject:thisSubString]) {
                    NSLog(@"%lu 是汉字特殊符号", i);
                    thisCharacterIsEnglish = 2;
                } else {
                    NSLog(@"%lu 是汉字", i);
                    thisCharacterIsEnglish = 1;
                }
            }else if(strlen(thisCString)==1) {
                if ([syntaxSymbols containsObject:thisSubString]) {
                    NSLog(@"%lu 是格式符号", i);
                    thisCharacterIsEnglish = 2;
                } else {
                    NSLog(@"%lu 是字母", i);
                    thisCharacterIsEnglish = 0;
                }
            }
            
            // 判断next
            if (strlen(nextCString)==3)
            {                // 如果是中文的限定的符号，则应使它识别为英文（为了不添加空格）
                if ([chineseSymbols containsObject:nextSubString]) {
                    NSLog(@"%lu 是汉字特殊符号", i);
                    nextCharacterIsEnglish = 2;
                } else {
                    NSLog(@"%lu 是汉字", i);
                    nextCharacterIsEnglish = 1;
                }
            }else if(strlen(nextCString)==1) {
                if ([syntaxSymbols containsObject:thisSubString]) {
                    NSLog(@"%lu 是格式符号", i);
                    nextCharacterIsEnglish = 2;
                } else {
                    NSLog(@"%lu 是字母", i);
                    nextCharacterIsEnglish = 0;
                }
            }
            
            // 得到EAC
//            EAC = thisCharacterIsEnglish == nextCharacterIsEnglish? true : false;
            BOOL EAC = (thisCharacterIsEnglish + nextCharacterIsEnglish) == 1;
            if (EAC) {
                // 输出要插入空格的位置
                NSLog(@"Found EAC, at range {location: %lu, length: %lu}", nextRange.location, nextRange.length);
                
                // 在这里生成两个子字符串
                NSString *formerString  = [stringWithFile substringToIndex:nextRange.location];
//                NSLog(@"formerString is [%@]", formerString);
                NSString *laterString = [stringWithFile substringFromIndex:nextRange.location];
//                NSLog(@"laterString is [%@]", laterString);
                
                // 删掉stringWithFile的后半部分
                stringWithFile = [[NSMutableString alloc] initWithString:formerString];
//                NSLog(@"the temporary stringWithFile is [%@]", stringWithFile);
                
                // 给stringWithFile添加空格和后半部分
                [stringWithFile appendString:@" "];
                [stringWithFile appendString:laterString];
//                NSLog(@"the new stringWithFile is [%@]", stringWithFile);
                
                // 因为更新了stringWithFile的内容，所以字符串长度也有所变化
                ending = [stringWithFile length] - 1;
//                NSLog(@"The New Ending is %lu", ending);
                
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
