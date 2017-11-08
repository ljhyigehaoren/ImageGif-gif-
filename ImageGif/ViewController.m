//
//  ViewController.m
//  ImageGif
//
//  Created by LJH on 2017/11/8.
//  Copyright © 2017年 LJH. All rights reserved.
//

#import "ViewController.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self deCompositionGif];
    [self createGif]; //合成GIF图片
}

//1.拿到gif数据
//2.将GIF分解为帧图片
//3.获取每一帧的图片
//4.遍历图片保存、将单帧图片进行保存进沙盒
-(void)deCompositionGif{
//    拿到GIF数据
    NSString *gifPathSource = [[NSBundle mainBundle]pathForResource:@"timg-2" ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:gifPathSource];
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
//    gif分解成为一帧一帧的图片
    size_t count = CGImageSourceGetCount(source);
    NSLog(@"count: %ld",count);
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
//    获取每一帧图片
    for (size_t i = 0; i < count; i++){
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, i, NULL);
//        将单帧数据转化为UIImage
        UIImage *image = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
//        将图片添加进数组中
        [tempArray addObject:image];
//        释放掉缓存
        CGImageRelease(imageRef);
    }
//    释放掉图片资源
    CFRelease(source);
    
//    4.遍历图片保存、将单帧图片进行保存
    int i = 0;
    NSArray *path =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *gifPath = [path[0] stringByAppendingString:@"/gifImage"];
    for (UIImage *image in tempArray) {
        NSData *data = UIImagePNGRepresentation(image);
        NSString *pathNum = [gifPath stringByAppendingString:[NSString stringWithFormat:@"%d.png",i]];
        [data writeToFile:pathNum atomically:NO];
        i++;
    }
    
}

//生成一个GIF
//1 获取GIF数据
//2.创建GIF文件
//3. 配置GIF属性
//4. 单帧添加到gif

-(void)createGif{
//    获取数据
    NSMutableArray *images = [[NSMutableArray alloc]initWithObjects:[UIImage imageNamed:@"2453054422051391284.jpg"],[UIImage imageNamed:@"46f8d639aa07ebf5313d0a236fceb6aeec575b92e4c4-1HXUjP.jpg"],[UIImage imageNamed:@"235721by9jzmyeeppjtqyy.jpg"],[UIImage imageNamed:@"img.jpg"], nil];
//    创建GIF文件
    NSArray *document =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentStr = [document objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *textDic = [documentStr stringByAppendingString:@"/gif"];
    [fileManager createDirectoryAtPath:textDic withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *path = [textDic stringByAppendingString:@"stext1.gif"];
    NSLog(@"path = %@",path);
//    配置GIF属性
    CGImageDestinationRef destion;
    CFURLRef url =CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, false);
     destion = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, NULL);
    NSDictionary *frameDic = [NSDictionary dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.3],kCGImagePropertyGIFDelayTime, nil] forKey:(NSString *)kCGImagePropertyGIFDelayTime];
    NSMutableDictionary *gifDic = [NSMutableDictionary dictionaryWithCapacity:2];
    [gifDic setObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCGImagePropertyGIFHasGlobalColorMap];
    [gifDic setObject:(NSString *)kCGImagePropertyColorModelRGB forKey:(NSString *)kCGImagePropertyColorModel];
    [gifDic setObject:[NSNumber numberWithUnsignedInt:8] forKey:(NSString *)kCGImagePropertyDepth];
    [gifDic setObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount];
    
    NSDictionary *gifProperty = [NSDictionary dictionaryWithObject:gifDic forKey:(NSString *)kCGImagePropertyGIFDictionary];
    
//    单帧图片天际进Gif
    for (UIImage *image in images) {
        CGImageDestinationAddImage(destion, image.CGImage,(__bridge CFDictionaryRef)frameDic);
    }
    
    CGImageDestinationSetProperties(destion, (__bridge CFDictionaryRef)gifProperty);
    
    CGImageDestinationFinalize(destion);
    
    CFRelease(destion);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
