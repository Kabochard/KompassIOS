//
//  ViewController.swift
//  Kompass
//
//  Created by Tim Consigny on 02/08/2015.
//  Copyright (c) 2015 Rsx. All rights reserved.
//

import UIKit
import  CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        but = UIButton(frame: CGRect(x: 50, y: 50, width: 100, height: 100))
        but.backgroundColor = UIColor.redColor()
        but.addTarget(self, action: "boum:", forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(but)
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func boum(sender: UIButton!)
    {
        write2Device()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
            let deviceName = "AMS-0D91"
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
            var enableValue = 1
            let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
    
            // check the uuid of each characteristic to find config and data characteristics
            for charateristic in service.characteristics! {
                let thisCharacteristic = charateristic as! CBCharacteristic
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
            
            self.but.backgroundColor = UIColor.purpleColor()
    
        }
    
        // Get data values when they are updated
        func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    
            print("Connected")
    
            if characteristic.UUID == CHARACTERISTIC_TRUCONNECT_PERIPHERAL_TX_UUID {
                // Convert NSData to array of signed 16 bit values
                let dataBytes = characteristic.value
                let dataLength = dataBytes!.length
                var dataArray = [Int16](count: dataLength, repeatedValue: 0)
                dataBytes!.getBytes(&dataArray, length: dataLength * sizeof(Int16))
    
                // Element 1 of the array will be ambient temperature raw value
                let degree = Double(dataArray[1])
    
                // Display on the temp label
                print(degree)
            }
        }
    
        //UpdatePos
        func write2Device()
        {
            let data = ("d0133b090\n" as NSString).dataUsingEncoding(NSUTF8StringEncoding)
            self.sensorTagPeripheral.writeValue(data!, forCharacteristic: rxChar!, type: CBCharacteristicWriteType.WithResponse)
    
           // sensorTagPeripheral!.writeValue(NSData("d120"), forCharacteristic: rxChar!, type: CBCharacteristicWriteType.WithResponse)
       
        }



}

