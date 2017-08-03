//
//  BluetoothManager.m
//  Bluetooth
//
//  Created by Landa on 2017/8/3.
//  Copyright © 2017年 Landa. All rights reserved.
//

#import "BluetoothManager.h"

#define Server_UUID @"6E400001"
#define Write_Characteristic_UUID @"6E400002"
#define Value_Characteristic_UUID @"6E400003"

@implementation BluetoothManager

static BluetoothManager *blueManager = nil;
+ (instancetype)sharedBluetoothManager
{
    @synchronized (self) {
        if (!blueManager) {
            blueManager = [[BluetoothManager alloc]init];
        }
    }
    return blueManager;
}
//连接外设
- (void)connect
{
    if (!self.centralManager) {
        self.centralManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }
    else
    {
        if (self.centralManager.state == CBCentralManagerStatePoweredOn && self.centralManager.delegate != nil) {
            [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:Server_UUID]] options:nil];
        }
        else
        {
            //如果手机蓝牙关闭后重新打开走此处方法
            self.centralManager.delegate = nil;
            self.centralManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil];
        }
    }
}
//获取时间
- (void)getClock
{
    Byte dataArr[4];
    dataArr[0]=0x1A;
    dataArr[1]=0x01;
    dataArr[2]=0x02;
    dataArr[3]=0x03;
    NSData *param=[NSData dataWithBytes:dataArr length:4];
    [self writeCharacteristic:self.peripheral characteristic:self.character value:param];
}

//断开链接
- (void)closeTheConnectWithPerpheral
{
    [self.centralManager stopScan];
    
    if (self.peripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
        self.centralManager.delegate = nil;
        self.peripheral.delegate = nil;
    }
}

- (NSMutableArray *)peripheralArr
{
    if (!_peripheralArr) {
        _peripheralArr = [NSMutableArray array];
    }
    return _peripheralArr;
}

/************************************************************/
#pragma mark - 写数据
-(void)writeCharacteristic:(CBPeripheral *)peripheral
            characteristic:(CBCharacteristic *)characteristic
                     value:(NSData *)value{
    
    if(characteristic.properties & CBCharacteristicPropertyWrite){
        
        [peripheral writeValue:value forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
    }else{
        //NSLog(@"该特征不可写");
    }
}
#pragma mark - 中心管家代理
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //在开机状态下进行扫描外部设备
    if (central.state == CBCentralManagerStatePoweredOn) {
        
        [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:Server_UUID]] options:nil];
    }
    
}
#pragma mark - 发现外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if ([peripheral.name hasPrefix:@"LandaBluetooth"] )
    {
        if (![self.peripheralArr containsObject:peripheral]) {
            [self.peripheralArr addObject:peripheral];
        }
        
        self.peripheral = peripheral;
        peripheral.delegate = self;
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}
#pragma mark - 链接到外设
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //扫描所有服务
    [peripheral discoverServices:nil];
}
#pragma mark - 与外设断开链接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    //尝试重新连接外设
    [self.centralManager connectPeripheral:peripheral options:nil];
}

#pragma mark - 外部设备代理
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    [peripheral.services enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CBService *service = obj;
        [peripheral discoverCharacteristics:nil forService:service];
    }];
}
#pragma mark - 发现服务里面的所有特征
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *cts in service.characteristics) {
        
        [peripheral setNotifyValue:YES forCharacteristic:cts];//接收外设数据
        [peripheral readValueForCharacteristic:cts];
        [peripheral discoverDescriptorsForCharacteristic:cts];
        
        CBUUID *uuid=[CBUUID UUIDWithString:Write_Characteristic_UUID];
        if ([cts.UUID isEqual:uuid]){
            self.character = cts;
        }
    }
}
#pragma mark-读取特征的值
-   (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    CBUUID *uuid=[CBUUID UUIDWithString:Value_Characteristic_UUID];
    if ([characteristic.UUID isEqual:uuid]) {
        //获得数据
        NSData *data=characteristic.value;
        
        if ([self.delegate respondsToSelector:@selector(returnValue:)]) {
            [self.delegate returnValue:data];
        }
        
    }
}

@end
