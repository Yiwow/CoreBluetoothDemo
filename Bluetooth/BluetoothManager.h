//
//  BluetoothManager.h
//  Bluetooth
//
//  Created by Landa on 2017/8/3.
//  Copyright © 2017年 Landa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BluetoothManagerDelegate <NSObject>

- (void)returnValue:(NSData *)value;

@end

@interface BluetoothManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic,weak)id<BluetoothManagerDelegate>delegate;
@property (nonatomic,strong)CBCentralManager *centralManager;   //中心管家
@property (nonatomic,strong)NSMutableArray *peripheralArr;      //保存扫描到的外部设备
@property (nonatomic,strong)CBPeripheral *peripheral;           //发现的有用外设
@property (nonatomic,strong)CBCharacteristic *character;        //可写的特征

+ (instancetype)sharedBluetoothManager;
//连接外设
- (void)connect;
//获取时间
- (void)getClock;
//断开链接
- (void)closeTheConnectWithPerpheral;

@end
