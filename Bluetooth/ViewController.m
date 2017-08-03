//
//  ViewController.m
//  Bluetooth
//
//  Created by Landa on 2017/8/3.
//  Copyright © 2017年 Landa. All rights reserved.
//

#import "ViewController.h"
#import "BluetoothManager.h"
@interface ViewController ()<BluetoothManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isContinue = YES;
        do {
            [weakSelf bluetoothRequestDataTospecifiedDevice];
            [NSThread sleepForTimeInterval:5];
        } while (isContinue == YES);
    });
}

#pragma mark - 向指定蓝牙设备循环请求数据
- (void)bluetoothRequestDataTospecifiedDevice
{
    BluetoothManager *bluetooth = [BluetoothManager sharedBluetoothManager];
    bluetooth.delegate = self;
    [bluetooth connect];
    [bluetooth getClock];
}

- (void)returnValue:(NSData *)value
{
    NSLog(@"%@",value);
}

@end
