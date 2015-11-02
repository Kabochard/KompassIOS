//
//  HomeVC.swift
//  Kompass
//
//  Created by Tim Consigny on 04/08/2015.
//  Copyright (c) 2015 Rsx. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class HomeVC: UIViewController, GMSMapViewDelegate, UITextFieldDelegate,CLLocationManagerDelegate{
    
    var mapView: GMSMapView!
    var SearchBox: UIView!
    var SearchBar: UITextField!
    var targetMarker: GMSMarker!
    var infoBox: UIView!
    var distanceLbl: UILabel!
    var bearingLbl: UILabel!
    
    
    var device: deviceVC!
    
    
    var tableScreen: LookUpVC!
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = GMSMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        mapView.delegate = self
        
        view.addSubview(mapView)
        
        let constraintV = //NSLayoutConstraint(item: mapView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 100)
        NSLayoutConstraint.constraintsWithVisualFormat("V:|[item]|", options: [], metrics: nil, views: ["item" : mapView!])
        
        self.view.addConstraints(constraintV)
        
        
        let constraintH = NSLayoutConstraint(item: mapView!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0)
        //let constraintH = NSLayoutConstraint.constraintsWithVisualFormat("H:|[item(100)]", options: nil, metrics: nil, views: ["item" : mapView])
        
        self.view.addConstraints([constraintH])
        
        let constraintH2 = NSLayoutConstraint(item: mapView!, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0)
        
        self.view.addConstraints([constraintH2])
        
        //view.addConstraint(constraintH)
        //view.addConstraint(constraintV)
        
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        
        
        targetMarker = GMSMarker()
        targetMarker.map = mapView
        
        
//       var camera = GMSCameraPosition.cameraWithLatitude(mapView.myLocation.coordinate.latitude,
//                    longitude: mapView.myLocation.coordinate.longitude, zoom: 14)
//        mapView.camera = camera
        
        
        
        SearchBox = UIView(frame: CGRect(x: 0.05 * view.frame.width, y: 30, width: 0.9 * view.frame.width, height: 30))
        
        SearchBar = UITextField(frame: CGRect(x: 0.05 * SearchBox.frame.width, y: 0.1 * SearchBox.frame.height, width: 0.9 * SearchBox.frame.width, height: 0.9 * SearchBox.frame.height))
        
        SearchBar.backgroundColor = StaticColor.White()
        SearchBar.textColor = StaticColor.DarkOrange()
        SearchBar.text = "Enter text or tap on the map"
        
        SearchBar.layer.cornerRadius = 5
        SearchBar.layer.borderColor = StaticColor.DarkOrange().CGColor
        SearchBar.layer.borderWidth = 1
        
        SearchBar.delegate = self
        
        SearchBox.addSubview(SearchBar)
        
        view.addSubview(SearchBox)
        
        
        infoBox = UIView(frame: CGRect(x: 0.05 * view.frame.width, y: view.frame.height - 110, width: 200, height: 80))
        infoBox.backgroundColor = StaticColor.White()
        
        infoBox.layer.cornerRadius = 5
        infoBox.layer.masksToBounds = true
        infoBox.layer.borderColor = StaticColor.DarkOrange().CGColor
        infoBox.layer.borderWidth = 1
        
        bearingLbl = UILabel(frame: CGRect(x: 10, y: 10, width: 180, height: 20))
        bearingLbl.textColor = StaticColor.DarkOrange()
        bearingLbl.text = "Bearing: "
        
        distanceLbl = UILabel(frame: CGRect(x: 10, y: 50, width: 180, height: 20))
        distanceLbl.textColor = StaticColor.DarkOrange()
        distanceLbl.text = "Distance: "
        
        infoBox.addSubview(bearingLbl)
        infoBox.addSubview(distanceLbl)
        
        view.addSubview(infoBox)
        
        tableScreen = LookUpVC()
        addChildViewController(tableScreen)
        tableScreen.didMoveToParentViewController(self)
        
        device = deviceVC()//(frame: CGRect(x: 0, y: 500, width: 500, height: 250))
       // device.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        device.view.frame =  CGRect(x: 0, y: view.frame.height - 150, width: view.frame.width, height: 150)
        view.addSubview(device.view)
        
   // let constDevice = NSLayoutConstraint.constraintsWithVisualFormat("V:|-500-[item]|", options: nil, metrics: nil, views: ["item" : device!])
        
//         let constV2 = NSLayoutConstraint(item: device!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0)
        
     //   self.view.addConstraints(constDevice)
        
        
        //initBLE()

    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        DisplayTable()
        return false
    }
    
    func DisplayTable()
    {
        
        tableScreen.view.frame = view.frame
        
        tableScreen.view.backgroundColor = StaticColor.White()
        
        
        
        
        view.addSubview(tableScreen.view)
        tableScreen.searchBar.becomeFirstResponder()
        
    }
    
    
    func setTarget(loc: CLLocation)
    {
        targetMarker.position = loc.coordinate
        let bearing = getBearingBetweenTwoPoints1(mapView.myLocation, point2: loc)
        bearingLbl.text = "Bearing: \(round(bearing * 10)/10)°"
        let dist = loc.distanceFromLocation(mapView.myLocation)
        distanceLbl.text = "Distance: \(round(dist/10)/100) km"
        
        //device.update(bearing, distance: dist)
        
        device.defineTarget(loc, initPos: mapView.myLocation)
    }
    
    
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
    

    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
      
        
        setTarget(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
      
        
        reverseGeoCodeMarker()
        
        
        
               //test.setCap(<#bearing: Double#>)
        
        //}
    }
    
    func reverseGeoCodeMarker() {
        let geocoder = GMSGeocoder()
        SearchBar.text = "Searching..."
        geocoder.reverseGeocodeCoordinate( targetMarker.position) { response , error in
            
            if error == nil && response != nil {
                
                if let address = response.firstResult() {
                    let lines = address.lines as! [String]
                    self.SearchBar.text = lines.joinWithSeparator(", ")
                    
                    
                }
                    
                else
                {
                    print(error.description)
                    self.SearchBar.text = "????"
                }
            }
        }
    }
    
//    //BLE------------------
//    
//    // Check status of BLE hardware
//    func centralManagerDidUpdateState(central: CBCentralManager!) {
//        if central.state == CBCentralManagerState.PoweredOn {
//            // Scan for peripherals if BLE is turned on
//            central.scanForPeripheralsWithServices(nil, options: nil)
//           println("Searching for BLE Devices")
//        }
//        else {
//            // Can have different conditions for all states if needed - print generic message for now
//            println("Bluetooth switched off or not initialized")
//        }
//    }
//    
//    // Check out the discovered peripherals to find Sensor Tag
//    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
//        
//        let deviceName = "AMS-0D91"
//        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
//        
//        if (nameOfDeviceFound == deviceName) {
//            // Update Status Label
//            println("Device Found")
//            
//            // Stop scanning
//            self.centralManager.stopScan()
//            // Set as the peripheral to use and establish connection
//            self.sensorTagPeripheral = peripheral
//            self.sensorTagPeripheral.delegate = self
//            self.centralManager.connectPeripheral(peripheral, options: nil)
//        }
//        else {
//            println("Sensor Tag NOT Found")
//        }
//    }
//    
//    // Discover services of the peripheral
//    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
//        println( "Discovering peripheral services")
//        peripheral.discoverServices(nil)
//    }
//    
//    // Check if the service discovered is a valid IR Temperature Service
//    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
//        println( "Looking at peripheral services")
//        for service in peripheral.services {
//            let thisService = service as! CBService
//            if service.UUID == SERVICE_TRUCONNECT_UUID {
//                // Discover characteristics of IR Temperature Service
//                peripheral.discoverCharacteristics(nil, forService: thisService)
//            }
//            // Uncomment to print list of UUIDs
//            //println(thisService.UUID)
//        }
//    }
//    
//    
//    // Enable notification and sensor for each characteristic of valid service
//    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
//        
//        // update status label
//        println("Enabling Device comunicatoin")
//        
//        // 0x01 data byte to enable sensor
//        var enableValue = 1
//        let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
//        
//        // check the uuid of each characteristic to find config and data characteristics
//        for charateristic in service.characteristics {
//            let thisCharacteristic = charateristic as! CBCharacteristic
//            // check for data characteristic
//            if thisCharacteristic.UUID == CHARACTERISTIC_TRUCONNECT_PERIPHERAL_TX_UUID {
//                // Enable Sensor Notification
//                txChar = thisCharacteristic
//                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
//            }
//            // check for config characteristic
//            if thisCharacteristic.UUID == CHARACTERISTIC_TRUCONNECT_PERIPHERAL_RX_UUID {
//                // Enable Sensor
//                rxChar = thisCharacteristic
//                            }
//        }
//        
//    }
//   
//    // Get data values when they are updated
//    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
//        
//        println("Connected")
//        
//        if characteristic.UUID == CHARACTERISTIC_TRUCONNECT_PERIPHERAL_TX_UUID {
//            // Convert NSData to array of signed 16 bit values
//            let dataBytes = characteristic.value
//            let dataLength = dataBytes.length
//            var dataArray = [Int16](count: dataLength, repeatedValue: 0)
//            dataBytes.getBytes(&dataArray, length: dataLength * sizeof(Int16))
//            
//            // Element 1 of the array will be ambient temperature raw value
//            let degree = Double(dataArray[1])
//            
//            // Display on the temp label
//            println(degree)
//        }
//    }
//    
//    //UpdatePos
//    func write2Device()
//    {
//        let data = ("d123" as NSString).dataUsingEncoding(NSUTF8StringEncoding)
//        self.sensorTagPeripheral.writeValue(data, forCharacteristic: rxChar!, type: CBCharacteristicWriteType.WithResponse)
//
//       // sensorTagPeripheral!.writeValue(NSData("d120"), forCharacteristic: rxChar!, type: CBCharacteristicWriteType.WithResponse)
//   
//    }
}


