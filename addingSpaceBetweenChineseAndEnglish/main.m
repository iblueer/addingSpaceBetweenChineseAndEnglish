//
//  main.m
//  addingSpaceBetweenChineseAndEnglish
//
//  Created by 宅音かがや on 2018/01/07.
//  Copyright © 2018年 宅音かがや. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <readline/readline.h>
#import "MAEMOPathProcessor.h"
#import "MAEMOExtentionFilter.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // 预设内容
        /*-----------------------------------------------------------------------------------------------*/
        
        // 提前设定好中文特殊符号，不加空格的
        // 这些特殊字符都不会添加空格。
        NSArray *chineseSymbols = @[@"，", @"。", @"？", @"！", @"：", @"；", @"、", @"（", @"）", @"【", @"】", @"「", @"」", @"", @"『", @"』", @"《", @"》", @"…", @"—"];
        NSArray *syntaxSymbols = @[@"\n"];
        
        // 扩展名数组
        NSArray *extendNames = @[@".md", @".txt", @".html"];
        
        
        // 全局变量
        /*-----------------------------------------------------------------------------------------------*/
        // 声明新文件名的NSString
        NSMutableString *saveToFileStr = [[NSMutableString alloc] init];
        
        
        // 用户界面
        /*-----------------------------------------------------------------------------------------------*/
        // 用户输入文件所在目录，并将这个目录作为一个NSString
        NSLog(@"\n\n<-----------EAC v3----------->\n\n本程序支持对md/txt/html文件进行加工\n\n请输入正确的文件路径：");
        // 获取用户输入
        char *route = readline(NULL);
        NSString *readlineStr = [NSString stringWithCString:route encoding:NSASCIIStringEncoding];
        NSMutableString *routeStr = [[NSMutableString alloc] initWithString:readlineStr];
        
        
        // 目录处理
        /*-----------------------------------------------------------------------------------------------*/
        NSLog(@"🔺正在识别目录形式……");
        MAEMOPathProcessor *pathpro = [[MAEMOPathProcessor alloc] init];
        // 初始化目录判断机
        [pathpro setAppPathDefaultly];
        [pathpro getTargetPathString:routeStr];
        BOOL correctPath = pathpro.success;
        if (correctPath) {
            routeStr = [NSMutableString stringWithString:pathpro.targetPath];
        } else {
            // 如果是个不合法的目录形式，则退出程序
            return 0;
        }
        
        // 匹配输入的字符串中的扩展名
        /*-----------------------------------------------------------------------------------------------*/
        NSLog(@"🔺正在匹配扩展名……");
        MAEMOExtentionFilter *extfilt = [[MAEMOExtentionFilter alloc] init];
        // 判断扩展名是否正确，如果不能匹配成功，全部返回FALSE
        // 初始化扩展名判断机
        [extfilt setExtendNamesDefaultly];
        BOOL corExt = [extfilt correctExtension:routeStr];
        if (corExt) {
            // 匹配成功的话，就提取目标路径
            saveToFileStr = extfilt.spacedFileStr;
        } else {
            // 匹配失败的话，就直接停止运行
            return 0;
        }
        
        
        // 文件读取
        /*-----------------------------------------------------------------------------------------------*/
        // 读取md文件到NSMutableString
        NSError *error;
        NSMutableString *stringWithFile= [[NSMutableString alloc] initWithContentsOfFile:routeStr
                                                           encoding:NSUTF8StringEncoding
                                                              error:&error];
        if (!stringWithFile) {
            // 输出读取错误报告
            NSLog(@"❌读取文件失败：%@", error);
            // 读取都失败了，直接结束程序。
            return 0;
        } else {
            NSLog(@"⭕️读取文件成功");
        }
        
        
        // 加工准备中
        /*-----------------------------------------------------------------------------------------------*/
        // 查找紧挨着汉字的英文字母
        // 确定循环的次数
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
        NSLog(@"🔺初始化EAC: %c", EAC);
        
        
        // 加工过程
        /*-----------------------------------------------------------------------------------------------*/
        NSLog(@"🔺正在加工……");
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
            {
                // 如果是中文的限定的符号，则应使它识别为英文（为了不添加空格）
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
                NSLog(@"发现EAC，位置：%lu", nextRange.location);
                
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
                NSLog(@"未发现EAC");
                i++;
            }
        }while (i < ending);
        
        
        // 加工完成
        /*-----------------------------------------------------------------------------------------------*/
        // 最后输出当前的stringWithFile
//        NSLog(@"stringWithFile is [%@]", stringWithFile);

        // 将文件导出到一个新的md文件中，和源文件在同一个目录下
        BOOL success = [stringWithFile writeToFile:saveToFileStr atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (success) {
            NSLog(@"⭕️成功导出到文件 %@", saveToFileStr);
        } else {
            // 输出错误报告
            NSLog(@"❌文件导出失败：%@", [error localizedDescription]);
        }
    }
    return 0;
}
