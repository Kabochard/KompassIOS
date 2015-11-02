//
//  deviceVC.swift
//  Kompass
//
//  Created by Tim Consigny on 07/08/2015.
//  Copyright (c) 2015 Rsx. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion
import CoreBluetooth

class deviceVC: UIViewController, CLLocationManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    var bearing_: Double = 0.0
    var dist: Double = 0.0
    
    var distJauge: UISlider!
    var capArrow: UIImageView!
    
    var magneto: CMMotionManager!
    var deviceheading: Double = 0.0
    var locManager: CLLocationManager!
    
    var target: CLLocation!
    var position: CLLocation!
    
    
    // BLE
    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!
    var but : UIButton!
    
    let SERVICE_TRUCONNECT_UUID = CBUUID(string: "175f8f23-a570-49bd-9627-815a6a27de2a")
    let CHARACTERISTIC_TRUCONNECT_PERIPHERAL_RX_UUID =  CBUUID(string:"1cce1ea8-bd34-4813-a00a-c76e028fadcb")
    let CHARACTERISTIC_TRUCONNECT_PERIPHERAL_TX_UUID =  CBUUID(string:"cacc07ff-ffff-4c48-8fae-a9ef71b75e26")
    let CHARACTERISTIC_TRUCONNECT_MODE_UUID =  CBUUID(string:"20b9794f-da1a-4d14-8014-a0fb9cefb2f7")
    
    var rxChar:CBCharacteristic?;   // corresponds to Rx characteristic
    var txChar:CBCharacteristic?;
    var modeChar:CBCharacteristic?;
    
    
    let queue = NSOperationQueue()
    
    
    func defineTarget(loc: CLLocation, initPos: CLLocation)
    {
        position = initPos
        target = loc
        
        dist = target.distanceFromLocation(position)
        
        bearing_ = getBearingBetweenTwoPoints1(position, point2: target)
        
        distJauge.maximumValue = Float(dist)
        distJauge.value = Float(dist)
        
        locManager.headingFilter = 5
        locManager.startUpdatingHeading()
        
        locManager.distanceFilter = 0.1
        locManager.startUpdatingLocation()
        
        write2Device()
        
    }
    
    override func viewDidLoad() {
        
        distJauge = UISlider(frame: CGRect(x: 30, y: 30, width: view.frame.width - 60, height: 30))
        
        distJauge.maximumValue = 100
        
        capArrow = UIImageView(frame: CGRect(x: 30, y: 90, width: 100, height: 30))
        
        capArrow.image = UIImage(named: "Arrow")
        
        var xform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        
        capArrow.transform = xform
        
        
        
        view.addSubview(capArrow)
        view.addSubview(distJauge)
        
        //setCap(240)
        
        magneto = CMMotionManager()
        
        locManager = CLLocationManager()
        locManager.delegate = self
        
        
        
        //        magneto.startMagnetometerUpdatesToQueue(queue, withHandler: { (data, error) in
        //
        //            if data == nil
        //            {
        //
        //            }
        //            else
        //            {
        //                let res : CMMagnetometerData = data!
        //
        //                self.deviceheading = 0.0;
        //                var x = res.magneticField.x;
        //                var y = res.magneticField.y;
        //                var z = res.magneticField.z;
        //
        //                if (y > 0)
        //                {self.deviceheading = 90.0 - atan(x/y)*180.0/M_PI;}
        //                if (y < 0)
        //                {self.deviceheading = 270.0 - atan(x/y)*180.0/M_PI;}
        //                if (y == 0 && x < 0)
        //                {self.deviceheading = 180.0;}
        //
        //                if (y == 0 && x > 0)
        //                {self.deviceheading = 0.0;}
        //
        //                self.update(self.bearing_, distance: self.dist)
        //
        //                println(self.deviceheading)
        //            }
        //        })
        
        
        //init BLE
        but = UIButton(frame: CGRect(x: 10, y: 10, width: 10, height: 10))
        but.backgroundColor = UIColor.redColor()
        but.addTarget(self, action: "boum:", forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(but)
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateHeading newHeading: CLHeading!) {
        deviceheading = locManager.heading.trueHeading
        
        refreshScreen()
    }
    
    func update(bearing: Double, distance: Double)
    {
        
        dist = distance
        distJauge.maximumValue = Float(distance)
        distJauge.value = Float(distance)
        bearing_ = bearing
        var xform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2 + (bearing_ - deviceheading) / 180 * M_PI))
        
        capArrow.transform = xform
        
        write2Device()
        
    }
    
    func refreshScreen()
    {
        
        dist = target.distanceFromLocation(position)
        
        bearing_ = getBearingBetweenTwoPoints1(position, point2: target)
        
        distJauge.value = Float(dist)
        
        var xform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2 + (bearing_ - deviceheading) / 180 * M_PI))
        
        capArrow.transform = xform
        
    }
    
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
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / M_PI }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        if locations.count > 0
        {
            self.position = locations[locations.count - 1] as! CLLocation
            refreshScreen()
        }
        
    }
    
    
    //BLE Funtions
    func boum(sender: UIButton!)
    {
        write2Device()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Check status of BLE hardware
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil)
            println("Searching for BLE Devices")
        }
        else {
            // Can have different conditions for all states if needed - print generic message for now
            println("Bluetooth switched off or not initialized")
        }
    }
    
    // Check out the discovered peripherals to find Sensor Tag
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        let deviceName = "AMS-0D91"
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        
        if (nameOfDeviceFound == deviceName) {
            // Update Status Label
            println("Device Found")
            
            // Stop scanning
            self.centralManager.stopScan()
            // Set as the peripheral to use and establish connection
            self.sensorTagPeripheral = peripheral
            self.sensorTagPeripheral.delegate = self
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
        else {
            println("Sensor Tag NOT Found")
        }
    }
    
    // Discover services of the peripheral
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println( "Discovering peripheral services")
        peripheral.discoverServices(nil)
    }
    
    // Check if the service discovered is a valid IR Temperature Service
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        println( "Looking at peripheral services")
        for service in peripheral.services {
            let thisService = service as! CBService
            if service.UUID == SERVICE_TRUCONNECT_UUID {
                // Discover characteristics of IR Temperature Service
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
            // Uncomment to print list of UUIDs
            //println(thisService.UUID)
        }
    }
    
    
    // Enable notification and sensor for each characteristic of valid service
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        
        // update status label
        println("Enabling Device comunicatoin")
        
        // 0x01 data byte to enable sensor
        var enableValue = 1
        let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
        
        // check the uuid of each characteristic to find config and data characteristics
        for charateristic in service.characteristics {
            let thisCharacteristic = charateristic as! CBCharacteristic
            // check for data characteristic
            if thisCharacteristic.UUID == CHARACTERISTIC_TRUCONNECT_PERIPHERAL_TX_UUID {
                // Enable Sensor Notification
                txChar = thisCharacteristic
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
                println("yo")
            }
            // check for config characteristic
            if thisCharacteristic.UUID == CHARACTERISTIC_TRUCONNECT_PERIPHERAL_RX_UUID {
                // Enable Sensor
                rxChar = thisCharacteristic
                println("gros")
            }
        }
        
        self.but.backgroundColor = UIColor.purpleColor()
        
    }
    
    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        println("Connected")
        
        if characteristic.UUID == CHARACTERISTIC_TRUCONNECT_PERIPHERAL_TX_UUID {
            // Convert NSData to array of signed 16 bit values
            let dataBytes = characteristic.value
            let dataLength = dataBytes.length
            var dataArray = [Int16](count: dataLength, repeatedValue: 0)
            dataBytes.getBytes(&dataArray, length: dataLength * sizeof(Int16))
            
            // Element 1 of the array will be ambient temperature raw value
            let degree = Double(dataArray[1])
            
            // Display on the temp label
            println(degree)
        }
    }
    
    //UpdatePos
    func write2Device()
    {
        if sensorTagPeripheral != nil
        {
            var rdist = Int(round(dist/10))
            var rbearing = max(15, min(345, 180 + Int(bearing_)))
            
            var distString = rdist.format("04")
            var bearingString = rbearing.format("03")
            
            var formatedString = "d\(distString)b\(bearingString)\n"
            
            
            
            //            var distFormated = "d \((dist as Int).format("04")) "
            //            let someInt = 4, someIntFormat = "03"
            //            println("The integer number \(someInt) formatted with \"\(someIntFormat)\" looks like \(someInt.format(someIntFormat))")
            // The integer number 4 formatted with "03" looks like 004
            
            let data = (formatedString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            self.sensorTagPeripheral.writeValue(data, forCharacteristic: rxChar!, type: CBCharacteristicWriteType.WithResponse)
        }
        
        
        // sensorTagPeripheral!.writeValue(NSData("d120"), forCharacteristic: rxChar!, type: CBCharacteristicWriteType.WithResponse)
        
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
