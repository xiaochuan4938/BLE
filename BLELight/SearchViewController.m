//
//  SearchViewController.m
//  BLELight
//
//  Created by 姚小川 on 9/29/21.
//

#import "SearchViewController.h"
#import "SearchViewCell.h"
#import "YXCMusicView.h"
#import "LightViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

NSString *lightperipheralUUID = @"29112B93-2777-F928-FF19-88C5093687EE";
NSString *serviceUUID = @"FFB0";
NSString* redUUID = @"FFB1";
NSString* greenUUID = @"FFB2";
NSString* blueUUID = @"FFB3";
NSString* RGBWUUID = @"FFB5";




@interface SearchViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property(nonatomic, strong) CBCentralManager* centralManager;
@property(nonatomic, strong) CBPeripheral* lightPeripheral;
@property(nonatomic, strong) CBService* service;
@property(nonatomic, strong) CBCharacteristic* rwCharacteristic;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];

}

#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
        {
            
            CBUUID *services = [CBUUID UUIDWithString:serviceUUID];
            [self.centralManager scanForPeripheralsWithServices:@[services]
                                                        options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)}];
            
            break;
        }
        case CBCentralManagerStatePoweredOff:
        {
            
            break;
        }
        default:
        {
            
            break;
        }
    }
    
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI{
    NSLog(@"centralManager:didDiscoverPeripheral:advertisementData:RSSI. peripheral ID:%@", peripheral.identifier);
    //double check peripheral
    if ([peripheral.identifier.UUIDString isEqualToString:lightperipheralUUID]) {
        self.lightPeripheral = peripheral;
        [central connectPeripheral:peripheral options:nil];
      
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral{
    self.lightPeripheral = peripheral;
    self.lightPeripheral.delegate = self;
    [self.lightPeripheral discoverServices:@[[CBUUID UUIDWithString:serviceUUID]]];
    [self.tableView reloadData];
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"centralManager:didFailToConnectPeripheral: error: %@",error);
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    NSLog(@"centralManager:didDisconnectPeripheral. error:%@",error);
    
}


#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error{
    //Received Signal Strength Indicator
    NSLog(@"peripheral rssi %@",RSSI);
}





- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"peripheral:didDiscoverServices. error:%@",error);
    if (error == nil) {
        self.service = peripheral.services.firstObject;
        //RGBW is a read & write characteracteristics;
        [self.lightPeripheral discoverCharacteristics:@[[CBUUID UUIDWithString:RGBWUUID]]
                                           forService:self.service];
    }
    
   
    
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error{
    NSLog(@"peripheral:didDiscoverCharacteristicsForService:error: %@", error);
    for (CBCharacteristic * characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:RGBWUUID]]) {
            self.rwCharacteristic = characteristic;
        }
    }
    
    if (self.rwCharacteristic) {
        [peripheral setNotifyValue:YES forCharacteristic:self.rwCharacteristic];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    NSLog(@"peripheral:didUpdateNotificationStateForCharacteristic:error. error:%@",error);
   
}

- (void)peripheral:(CBPeripheral *)peripheral
didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    NSLog(@"peripheral:didWriteValueForCharacteristic:error. error:%@",error);
    
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    NSLog(@"peripheral:didUpdateValueForCharacteristic:error. error:%@",error);
   
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"
                                                            forIndexPath:indexPath];
    
    cell.mainLabel.text = self.lightPeripheral.name;
    cell.subLabel.numberOfLines = 0;
    cell.subLabel.font = [UIFont systemFontOfSize:13];
    cell.subLabel.text = [NSString stringWithFormat:@"UUID: %@", self.lightPeripheral.identifier];
    return cell;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    LightViewController* lightVC =  segue.destinationViewController;
    lightVC.rwCharacteristic = self.rwCharacteristic;
    
    
}
@end
