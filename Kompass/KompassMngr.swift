//
//  KompassMngr.swift
//  Kompass
//
//  Created by Tim Consigny on 02/11/2015.
//  Copyright © 2015 Rsx. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion
import CoreBluetooth

class KompassMngr: NSObject, CLLocationManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate  {
    
    // BLE
    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!
  //var but : UIButton!
    
    let SERVICE_TRUCONNECT_UUID = CBUUID(string: "175f8f23-a570-49bd-9627-815a6a27de2a")
    let CHARACTERISTIC_TRUCONNECT_PERIPHERAL_RX_UUID =  CBUUID(string:"1cce1ea8-bd34-4813-a00a-c76e028fadcb")
    let CHARACTERISTIC_TRUCONNECT_PERIPHERAL_TX_UUID =  CBUUID(string:"cacc07ff-ffff-4c48-8fae-a9ef71b75e26")
    let CHARACTERISTIC_TRUCONNECT_MODE_UUID =  CBUUID(string:"20b9794f-da1a-4d14-8014-a0fb9cefb2f7")
    
    var rxChar:CBCharacteristic?;   // corresponds to Rx characteristic
    var txChar:CBCharacteristic?;
    var modeChar:CBCharacteristic?;
    
    
   // let queue = NSOperationQueue()

    //Location
    var locmanager: CLLocationManager!
    var target_: CLLocation?
    
    
    //ViewController
    var kompass: KompassVC!
    
    
    
    //Properties
    var target: CLLocation?
        {
        get {
            return target_
        }
        set (loc) {
            //send new target info to device
            target_ = loc
            write2Device()
        }
    }
    
    var dist: Double
        {
        get {
        
            if locmanager.location == nil || target == nil
            {
                return 0.0
            }
            else
            {
                return target!.distanceFromLocation(locmanager.location!)
            }
        }
    }
    
    var bearing: Double
        {
        get {
            
            if locmanager.location == nil || target == nil
            {
                return 0.0
            }
            else
            {
                return getBearingBetweenTwoPoints1(locmanager.location!, point2: target!)
            }
        }
    }
    
     init(kompasss : KompassVC){
      
        super.init()
        
        locmanager = CLLocationManager()
        locmanager.headingFilter = 5
        locmanager.headingOrientation = CLDeviceOrientation.FaceUp
        locmanager.distanceFilter = 0.05
        locmanager.startUpdatingLocation()
        locmanager.startUpdatingHeading()
        
        locmanager.delegate = self
        
        //init BLE
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        //init KompassVC
        self.kompass = kompasss
        kompasss.KompassManager = self


        
    }
    
    //UpdatePos
    func write2Device()
    {
        if sensorTagPeripheral != nil && rxChar != nil
        {
            let rdist = Int(round(dist/100))
            let rbearing = max(15, min(345, 180 + Int(bearing)))
            
            let distString = rdist.format("04")
            let bearingString = rbearing.format("03")
            
            let formatedString = "d\(distString)b\(bearingString)\n"
            
            
            let data = (formatedString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            self.sensorTagPeripheral.writeValue(data!, forCharacteristic: rxChar!, type: CBCharacteristicWriteType.WithResponse)
            print(formatedString)
            print("msg sent")
        }
        
    }

    
    func BLEConnect()
    {
        if centralManager.state == CBCentralManagerState.PoweredOn {
            // Scan for peripherals if BLE is turned on
            centralManager.scanForPeripheralsWithServices(nil, options: nil)
            print("Searching for BLE Devices")
        }
        else {
            // Can have different conditions for all states if needed - print generic message for now
            print("Bluetooth switched off or not initialized")
        }

    }
    
    


    //MARK: BLE
    // Check status of BLE hardware
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == CBCentralManagerState.PoweredOn {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil)
            print("Searching for BLE Devices")
        }
        else {
            // Can have different conditions for all states if needed - print generic message for now
            print("Bluetooth switched off or not initialized")
        }
    }
    
    // Check out the discovered peripherals to find Sensor Tag
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        let deviceName = "AMS-07F4"
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        
        if (nameOfDeviceFound == deviceName) {
            // Update Status Label
            print("Device Found")
            
            // Stop scanning
            self.centralManager.stopScan()
            // Set as the peripheral to use and establish connection
            self.sensorTagPeripheral = peripheral
            self.sensorTagPeripheral.delegate = self
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
        else {
            print("Sensor Tag NOT Found")
        }
    }
    
    // Discover services of the peripheral
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print( "Discovering peripheral services")
        peripheral.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Disconnected WTF-------------")
        BLEConnect()
    }
    

    
    // Check if the service discovered is a valid IR Temperature Service
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print( "Looking at peripheral services")
        for service in peripheral.services! {
            let thisService = service as CBService
            if service.UUID == SERVICE_TRUCONNECT_UUID {
                // Discover characteristics of IR Temperature Service
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
            // Uncomment to print list of UUIDs
            //println(thisService.UUID)
        }
    }
    
    
    
    
    // Enable notification and sensor for each characteristic of valid service
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        // update status label
        print("Enabling Device comunicatoin")
        
        // 0x01 data byte to enable sensor
        //var enableValue = 1
        //let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
        
        // check the uuid of each characteristic to find config and data characteristics
        for charateristic in service.characteristics! {
            let thisCharacteristic = charateristic 
            // check for data characteristic
            if thisCharacteristic.UUID == CHARACTERISTIC_TRUCONNECT_PERIPHERAL_TX_UUID {
                // Enable Sensor Notification
                txChar = thisCharacteristic
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
                print("yo")
            }
            // check for config characteristic
            if thisCharacteristic.UUID == CHARACTERISTIC_TRUCONNECT_PERIPHERAL_RX_UUID {
                // Enable Sensor
                rxChar = thisCharacteristic
                print("gros")
            }
        }
        
        
    }
    
    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        print("Connected")
        
        if characteristic.UUID == CHARACTERISTIC_TRUCONNECT_PERIPHERAL_TX_UUID {
            
//            NSData *data = characteristic.value;
//            NSString *value = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
//            
//            NSLog(@"Value %@",value);
//            NSString *stringFromData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//            
//            NSLog(@"Data ====== %@", stringFromData);
//            
            // Convert NSData to array of signed 16 bit values
            let dataBytes = characteristic.value
            //let dataLength = dataBytes!.length
            
            var msg = NSString(data: dataBytes!, encoding: NSUTF8StringEncoding)
            
//            //let msg = NSString(bytes: dataBytes, length: dataLength, encoding: let dataLength = dataBytes!.length)
//            var dataArray = [NSUTF8StringEncoding](count: dataLength, repeatedValue: 0)
//            dataBytes!.getBytes(&dataArray, length: dataLength * sizeof(Int16))
//            
//            // Element 1 of the array will be ambient temperature raw value
//            let degree = Double(dataArray[1])
            
            // Display on the temp label
            print(msg)
        }
        
       
    }
    
    
    
    
    //MARK: Location
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / M_PI }
    
    func getBearingBetweenTwoPoints1(point1 : CLLocation, point2 : CLLocation) -> Double {
        
        let lat1 = degreesToRadians(point1.coordinate.latitude)
        let lon1 = degreesToRadians(point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(point2.coordinate.latitude);
        let lon2 = degreesToRadians(point2.coordinate.longitude);
        
        let dLon = lon2 - lon1;
        
        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        return radiansToDegrees(radiansBearing)
    }
    
//    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//       //send new bearing and distance to device
//        write2Device()
//        
//        print("location has changed: \(locations[0].description)")
//        //display on phone
//        kompass!.update()
//    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        //send new bearing and distance to device
        write2Device()
        
        //print("location has changed: \(newLocation.description)")
        //display on phone
        kompass!.update()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
       // print(newHeading.trueHeading)
        kompass!.deviceHeading = newHeading.trueHeading
        kompass!.update()
    }

    
}

extension Int {
    func format(f: String) -> String {
        return NSString(format: "%\(f)d", self) as String
    }
}

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}

    
    