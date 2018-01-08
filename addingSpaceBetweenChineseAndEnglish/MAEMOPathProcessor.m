//
//  MAEMOPathProcessor.m
//  addingSpaceBetweenChineseAndEnglish
//
//  Created by 宅音かがや on 2018/01/08.
//  Copyright © 2018年 宅音かがや. All rights reserved.
//

#import "MAEMOPathProcessor.h"

@implementation MAEMOPathProcessor

- (void)setAppPathDefaultly {
    // 获得当前工作目录，替代相对目录
    self.appPath =[[NSBundle mainBundle] bundlePath];
    //    NSLog(@"appPath: %@",self.appPath);
}

- (void)getTargetPathString:(NSString *)inputString {
    // 判断是否为相对目录
    if ([inputString containsString:@"../"]) {
        NSLog(@"⭕️相对目录：预期文件在父目录下");
        [self getFatherPathString:inputString];
        self.success = TRUE;
    } else if ([inputString containsString:@"./"]) {
        NSLog(@"⭕️相对目录：预期文件在当前目录下");
        [self getThisPathString:inputString];
        self.success = TRUE;
    } else if([[inputString substringToIndex:0] isEqualToString:@"/"]){
        NSLog(@"⭕️绝对目录");
        self.targetPath = inputString;
        self.success = TRUE;
    } else {
        NSLog(@"❌错误的目录形式");
        self.success = FALSE;
    }
}

- (void)getThisPathString:(NSString *)inputString {
    BOOL contains = [inputString containsString:@"./"];
    if (contains) //表示它存在
    {
        NSString *trimmedString = [inputString stringByReplacingOccurrencesOfString:@"./" withString:@""];
//        NSLog(@"trimmedString is %@", trimmedString);
        
        // 设定文件名
        self.fileName = trimmedString;
        
        // 嫁接
        NSMutableString *path = [[NSMutableString alloc] init];
        [path appendString:self.appPath];
        [path appendString:@"/"];
        [path appendString:self.fileName];
//        NSLog(@"path is %@",path);
        
        // 传给属性
        self.targetPath = path;
    }
    
}

// 这个方法处理用户输入的串
- (void)getFatherPathString:(NSString *)inputString {
    
    BOOL contains = [inputString containsString:@"../"];
    
    if (contains) //表示它存在
    {
        NSString *trimmedString = [self removeFileCover:inputString];
        // 获取最后的文件名
        self.fileName = trimmedString;
//        NSLog(@"fileName is %@", self.fileName);
        // 递归
        [self getFatherPathString:trimmedString];
    } else { // 为什么这里要用else，我也不是很懂，反正能避免递归过程中产生重复运算
        // 开始对appPath扒皮
        NSString *formerStr = self.appPath;
        for (int i = 0; i < self.lamda; i++) {
            formerStr = [self removePathCover:formerStr];
        }
//        NSLog(@"formerStr is %@", formerStr);
        _lamda = 0;
        
        // 开始嫁接
        NSMutableString *path = [[NSMutableString alloc] init];
        [path appendString:formerStr];
        [path appendString:@"/"];
        [path appendString:self.fileName];
//        NSLog(@"path is %@",path);
        
        // 传给属性
        self.targetPath = path;
    }
}

- (NSString *)removeFileCover:(NSString *)inputString {
    //查找@””的位置 返回值是一个 NSRange 类型的值
    NSRange range = [inputString rangeOfString:@"../"];
    NSString *laterStr = [inputString substringFromIndex:range.location+range.length];
//    NSLog(@"laterStr is %@", laterStr);
    
    // 计算扒皮层数
    _lamda++;
    // 扒一层皮
    return laterStr;
}

// 这个方法处理appPath，给他后面扒皮
- (NSString *)removePathCover:(NSString *)inputString {
    for (NSInteger i = [inputString length] - 1; i >= 0; i--) {
        NSRange range = NSMakeRange(i, 1);
        NSString *charStr = [inputString substringWithRange:range];
        if ([charStr isEqualToString:@"/"]) {
            return [inputString substringToIndex:i];
        }
    }
    return 0;
}

@end

