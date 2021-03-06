//
//  KompassVC.swift
//  Kompass
//
//  Created by Tim Consigny on 02/11/2015.
//  Copyright © 2015 Rsx. All rights reserved.
//

import Foundation
import UIKit

class KompassVC: UIViewController, GMSMapViewDelegate, UITextFieldDelegate {
    
    var KompassManager: KompassMngr!
    var targetMarker: GMSMarker!
    var deviceV: DeviceView!
    var searchBar: UITextField!
    var deviceHeading: Double = 0.0
    var tableScreen: LookUpVC!
    
    override func viewDidLoad() {

        let mapView = GMSMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        mapView.delegate = self
        view.addSubview(mapView)
        
        mapView.stretchToWidthOfSuperView()
        mapView.constrainHeightTo(view, pct: 0.5)
        
        deviceV = DeviceView()
        deviceV.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(deviceV)
        deviceV.stretchToWidthOfSuperView()
        
        let menuBar = MenuBarView()
        menuBar.translatesAutoresizingMaskIntoConstraints = false
        menuBar.backgroundColor = StaticInfo.MainColor

        
        view.addSubview(menuBar)
        menuBar.stretchToWidthOfSuperView()
        menuBar.constrainHeightTo(self.view, pct: 0.1)

        let statusbarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        
        let constV = NSLayoutConstraint.constraintsWithVisualFormat("V:|-spacing-[box][map][dev]|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: ["spacing":statusbarHeight], views: ["box":menuBar,"map":mapView, "dev":deviceV])
        
        view.addConstraints(constV)
        
        
        searchBar = menuBar.searchBar
        searchBar.delegate = self
       
     
        
        //Init Kompass manager
        KompassManager = KompassMngr(kompasss: self)
        menuBar.BLEButton.addTarget(KompassManager!, action: "BLEConnect", forControlEvents: UIControlEvents.TouchUpInside)
        
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        
        
        targetMarker = GMSMarker()
        targetMarker.map = mapView
        
        tableScreen = LookUpVC()
        addChildViewController(tableScreen)
        tableScreen.didMoveToParentViewController(self)
        
        update()
    }
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        setTarget(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        reverseGeoCodeMarker()
     
    }
    
    func setTarget(loc:CLLocation)
    {
        KompassManager!.target = loc // CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        targetMarker.position = KompassManager!.target!.coordinate
        
        
        update()

    }
    
    func reverseGeoCodeMarker() {
        let geocoder = GMSGeocoder()
        searchBar.text = "Searching..."
        geocoder.reverseGeocodeCoordinate( targetMarker.position) { response , error in
            
            if error == nil && response != nil {
                
                if let address = response.firstResult() {
                    let lines = address.lines as! [String]
                    self.searchBar.text = lines.joinWithSeparator(", ")
                    
                    
                }
                    
                else
                {
                    print(error.description)
                    self.searchBar.text = "????"
                }
            }
        }
    }
    
    
    func update()
    {
        //print("Update heading")
        let xform = CGAffineTransformMakeRotation(CGFloat((KompassManager!.bearing - deviceHeading) / 180 * M_PI))
        
        deviceV.roseDesVents.transform = xform
        deviceV.recapText.text = "Target is \(round(KompassManager!.dist) / 1000) km away,\n heading at \(round(KompassManager!.bearing))° North"
        
        
    }
    
    func DisplayTable()
    {
        
        tableScreen.view.frame = view.frame
        
        tableScreen.view.backgroundColor = StaticColor.White()
        
        view.addSubview(tableScreen.view)
        tableScreen.searchBar.becomeFirstResponder()
        
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        DisplayTable()
        return false
    }


}



class DeviceView: UIView{
    
    var recapText :  UILabel!
    
    var roseDesVents : UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        //        setupViewWithVisualFormat()
        setupView()//WithConveninceMethods()
        
    }
    
    func setupView()
    {
       
        roseDesVents = UIImageView()
        roseDesVents.image = UIImage(named: "rdesVents")
        roseDesVents.translatesAutoresizingMaskIntoConstraints = false
        
        
        self.addSubview(roseDesVents)
        roseDesVents.constrainHeightTo(self, pct: 0.8)
        roseDesVents.constrainToBeSquare()
        
        recapText = UILabel()
        recapText.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(recapText)
        recapText.text = "you are far away!"
        recapText.numberOfLines = 2
        recapText.stretchToWidthOfSuperView()
        recapText.constrainHeightTo(self, pct: 0.2)
        recapText.backgroundColor = StaticInfo.MainColor

        
        let constV = NSLayoutConstraint.constraintsWithVisualFormat("V:|[lbl1][img]|", options: NSLayoutFormatOptions.AlignAllCenterX, views: ["lbl1":recapText,"img":roseDesVents])
        
        self.addConstraints(constV)
    }
    
    
}

class MenuBarView: UIView{
    
   var searchBar: UITextField!
    
    var BLEButton : UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        
        setupView()
        
        
    }
    
    func setupView()
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar = UITextField()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.textColor = StaticInfo.MainColor
        searchBar.backgroundColor = StaticInfo.SecondColor
      
        
        self.addSubview(searchBar)
        
        BLEButton = UIButton()
        BLEButton.translatesAutoresizingMaskIntoConstraints = false
        BLEButton.backgroundColor = StaticInfo.SecondColor
        
        self.addSubview(BLEButton)

        BLEButton.constrainHeightTo(self, pct: 0.8)
        BLEButton.constrainToBeSquare()
        
        searchBar.constrainHeightTo(self, pct: 0.8)
        
        let menuBarConstH = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[butt]-[txt]-|", views: ["butt":BLEButton,"txt":searchBar])
        
        self.addConstraints(menuBarConstH)
        searchBar.text = "Search"

        searchBar.centerVerticallyTo(self)
        BLEButton.centerVerticallyTo(self)

    }
    
}
