//
//  MapTasks.swift
//  GMapsDemo
//
//  Created by Gabriel Theodoropoulos on 29/3/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MapTasks: NSObject {
    
    let baseURLGeocode = "https://maps.googleapis.com/maps/api/geocode/json?"
    
    var lookupAddressResults: Dictionary<NSObject, AnyObject>!
    
    var fetchedFormattedAddress: String!
    
    var fetchedAddressLongitude: Double!
    
    var fetchedAddressLatitude: Double!
    
    let googleKey = "AIzaSyDNNNiufjnqWM2LJ3oTxz77URVydRZgv0E"
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    let baseURLPlaces = "https://maps.googleapis.com/maps/api/place/search/json?"
    
    let baseURLPlacesLookUp = "https://maps.googleapis.com/maps/api/place/details/json?"
    
    let baseURLAutoComplete = "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
    
    var selectedRoute: Dictionary<NSObject, AnyObject>!
    
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    
    var originCoordinate: CLLocationCoordinate2D!
    
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var originAddress: String!
    
    var destinationAddress: String!
    
    var totalDistanceInMeters: UInt = 0
    
    var totalDistance: String!
    
    var totalDurationInSeconds: UInt = 0
    
    var totalDuration: String!
    
    
    override init() {
        super.init()
    }
    
    func getPlaces(location: CLLocationCoordinate2D!, radius: Double!, type: Array<String>!, completionHandler: ((status: String, success: Bool, res: Array<Place>?) -> Void)) {
        
        
        var placesURLString = baseURLPlaces + "location=\(location.latitude),\(location.longitude)&maxprice=3&radius=\(radius)&type=food|bar|cafe|restaurant&key=\(googleKey)"
        
        //location=-33.8670522,151.1957362&radius=500&types=food&name=cruise&key=AddYourOwnKeyHere
        
        
        
        
        
        placesURLString = placesURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        let placesURL = NSURL(string: placesURLString)
        
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let placesData = NSData(contentsOfURL: placesURL!)
            
            var error: NSError?
            let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(placesData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! Dictionary<NSObject, AnyObject>
            
            if (error != nil) {
                println(error)
                completionHandler(status: "", success: false, res: nil)
            }
            else {
                let status = dictionary["status"] as! String
                
                if status == "OK" {
                    
                    
                    let allResults = dictionary["results"] as! Array<Dictionary<NSObject, AnyObject>>
                    
                    var res = [Place]()
                    
                    
                    
                    for index in 0...allResults.count-1
                    {
                        
                        let placeRes: Dictionary<NSObject, AnyObject> = allResults[index]
                        
                        let geometry = placeRes["geometry"] as! Dictionary<NSObject, AnyObject>
                        let lat: Double  = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lat"] as! NSNumber).doubleValue
                        let lon: Double  = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lng"] as! NSNumber).doubleValue
                        
                        var pictureId: String? = nil
                        if placeRes["photos"] != nil
                        {
                            pictureId = ((placeRes["photos"] as! Array<AnyObject>)[0] as! Dictionary<NSObject, AnyObject>)["photo_reference"] as! String?
                        }
                        
                        
                        
                        let place =  Place(
                            id: placeRes["place_id"] as! String,
                            Name: placeRes["name"] as! String,
                            PictureId: pictureId,
                            LogoUrl: placeRes["icon"] as! String,
                            rating: placeRes["rating"] as! Double?,
                            pricing: placeRes["price_level"] as! Double?,
                            location: CLLocationCoordinate2D(
                                latitude: lat,
                                longitude: lon),
                            address: placeRes["vicinity"] as! String)
                        
                        res.append( place)
                        
                        
                        
                    }
                    
                    completionHandler(status: status, success: true, res: res )
                }
                    
                else {
                    completionHandler(status: status, success: false, res: nil )
                }
            }
        })
    }
    
    
    func placeLookUp(placeId:String, completionHandler: ((status:String, success:Bool, res: CLLocationCoordinate2D?) -> Void))
    {
        var placesURLString = baseURLPlacesLookUp + "placeid=\(placeId)&key=\(googleKey)"
        
        //location=-33.8670522,151.1957362&radius=500&types=food&name=cruise&key=AddYourOwnKeyHere
        
        
        
        
        
        placesURLString = placesURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        let placesURL = NSURL(string: placesURLString)
        
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let placesData = NSData(contentsOfURL: placesURL!)
            
            var error: NSError?
            let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(placesData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! Dictionary<NSObject, AnyObject>
            
            if (error != nil) {
                println(error)
                completionHandler(status: "", success: false, res: nil)
            }
            else {
                let status = dictionary["status"] as! String
                
                if status == "OK" {
                    
                    
                    let placeRes = dictionary["result"] as! Dictionary<NSObject, AnyObject>
                    
                    var res = [Place]()
                    
                    
                    
                    
                    
                    let geometry = placeRes["geometry"] as! Dictionary<NSObject, AnyObject>
                    let lat: Double  = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lat"] as! NSNumber).doubleValue
                    let lon: Double  = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lng"] as! NSNumber).doubleValue
                    
                    var pictureId: String? = nil
                    if placeRes["photos"] != nil
                    {
                        pictureId = ((placeRes["photos"] as! Array<AnyObject>)[0] as! Dictionary<NSObject, AnyObject>)["photo_reference"] as! String?
                    }
                    
                    
                    
                    //                        let place =  Place(
                    //                            id: placeRes["place_id"] as! String,
                    //                            Name: placeRes["name"] as! String,
                    //                            PictureId: pictureId,
                    //                            LogoUrl: placeRes["icon"] as! String,
                    //                            rating: placeRes["rating"] as! Double?,
                    //                            pricing: placeRes["price_level"] as! Double?,
                    //                            location: CLLocationCoordinate2D(
                    //                                latitude: lat,
                    //                                longitude: lon),
                    //                            address: placeRes["vicinity"] as! String)
                    //
                    
                    
                    
                    
                    
                    
                    completionHandler(status: status, success: true, res: CLLocationCoordinate2D(
                        latitude: lat,
                        longitude: lon) )
                }
                    
                else {
                    completionHandler(status: status, success: false, res: nil )
                }
            }
        })
        
    }
    
    func autoComplete(textinput: String, location: CLLocationCoordinate2D!, radius: Double!, completionHandler: ((status: String, success: Bool, res: [String:String]?) -> Void)) {
        
        
        
        
        var autoCompURLString = baseURLAutoComplete + "input=\(textinput)&location=\(location.latitude),\(location.longitude)&radius=\(radius)&key=\(googleKey)"
        
        //location=-33.8670522,151.1957362&radius=500&types=food&name=cruise&key=AddYourOwnKeyHere
        
        
        
        
        
        autoCompURLString = autoCompURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        let autoCompURL = NSURL(string: autoCompURLString)
        
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let placesData = NSData(contentsOfURL: autoCompURL!)
            
            var error: NSError?
            let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(placesData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! Dictionary<NSObject, AnyObject>
            
            if (error != nil) {
                println(error)
                completionHandler(status: "", success: false, res: nil)
            }
            else {
                let status = dictionary["status"] as! String
                
                if status == "OK" {
                    
                    
                    let allResults = dictionary["predictions"] as! Array<Dictionary<NSObject, AnyObject>>
                    
                    var res = [String:String]()
                    
                    
                    
                    for index in 0...allResults.count-1
                    {
                        
                        let placeRes: Dictionary<NSObject, AnyObject> = allResults[index]
                        
                        let id = placeRes["place_id"] as! String
                        let des = placeRes["description"] as! String
                        res[id] = des
                        
                    }
                    
                    completionHandler(status: status, success: true, res: res )
                }
                    
                else {
                    completionHandler(status: status, success: false, res: nil )
                }
            }
        })
    }
    
    
    
//    func geocodeAddress(address: String!, withCompletionHandler completionHandler: ((status: String, success: Bool) -> Void)) {
//        if let lookupAddress = address {
//            
//            
//            //Within 10km from the user location
//            var previousPoint =  DejUser.Instance.parseUser_?.objectForKey("Location") as! PFGeoPoint?
//            var test = DejUser.Instance.locationManager
//            // var coord: CLLocationCoordinate2D? = DejUser.Instance.locationManager.location.coordinate
//            var centerCoord = CLLocationCoordinate2D(latitude: CLLocationDegrees(previousPoint!.latitude), longitude: CLLocationDegrees(previousPoint!.longitude))
//            //
//            //            if coord == nil {
//            //                centerCoord = CLLocationCoordinate2D(latitude: CLLocationDegrees(previousPoint!.latitude), longitude: CLLocationDegrees(previousPoint!.longitude))
//            //            }
//            //            else
//            //            {
//            //                centerCoord = coord!
//            //            }
//            //
//            
//            
//            
//            var region: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(centerCoord, 10000, 10000);
//            
//            var latMin = region.center.latitude - 0.5 * region.span.latitudeDelta;
//            var latMax = region.center.latitude + 0.5 * region.span.latitudeDelta;
//            var lonMin = region.center.longitude - 0.5 * region.span.longitudeDelta;
//            var lonMax = region.center.longitude + 0.5 * region.span.longitudeDelta;
//            
//            var geocodeURLString = baseURLGeocode + "address=" + lookupAddress + " &bounds=\(latMin),\(lonMin)|\(latMax),\(lonMax)"
//            geocodeURLString = geocodeURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
//            
//            let geocodeURL = NSURL(string: geocodeURLString)
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                let geocodingResultsData = NSData(contentsOfURL: geocodeURL!)
//                
//                var error: NSError?
//                let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(geocodingResultsData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! Dictionary<NSObject, AnyObject>
//                
//                if (error != nil) {
//                    println(error)
//                    completionHandler(status: "", success: false)
//                }
//                else {
//                    // Get the response status.
//                    let status = dictionary["status"] as! String
//                    
//                    if status == "OK" {
//                        let allResults = dictionary["results"] as! Array<Dictionary<NSObject, AnyObject>>
//                        self.lookupAddressResults = allResults[0]
//                        
//                        // Keep the most important values.
//                        self.fetchedFormattedAddress = self.lookupAddressResults["formatted_address"] as! String
//                        let geometry = self.lookupAddressResults["geometry"] as! Dictionary<NSObject, AnyObject>
//                        self.fetchedAddressLongitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lng"] as! NSNumber).doubleValue
//                        self.fetchedAddressLatitude = ((geometry["location"] as! Dictionary<NSObject, AnyObject>)["lat"] as! NSNumber).doubleValue
//                        
//                        
//                        //                        for index in 0...allResults.count-1
//                        //                            {
//                        //                                println("google res \(index)")
//                        //                                println(allResults[index]["formatted_address"] as! String)
//                        //
//                        //                            }
//                        
//                        if  (DejUser.Instance.locationManager.location.distanceFromLocation(CLLocation(latitude: self.fetchedAddressLatitude, longitude: self.fetchedAddressLongitude))>10000)
//                        {
//                            completionHandler(status: "Result too far", success: false)
//                        }
//                        else
//                        {
//                            completionHandler(status: status, success: true)
//                        }
//                    }
//                    else {
//                        completionHandler(status: status, success: false)
//                    }
//                }
//            })
//        }
//        else {
//            completionHandler(status: "No valid address.", success: false)
//        }
//    }
    
    
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: TravelModes!, completionHandler: ((status: String, success: Bool) -> Void)) {
        
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation
                
                if let routeWaypoints = waypoints {
                    directionsURLString += "&waypoints=optimize:true"
                    
                    for waypoint in routeWaypoints {
                        directionsURLString += "|" + waypoint
                    }
                }
                
                if let travel = travelMode {
                    var travelModeString = ""
                    
                    switch travelMode.rawValue {
                    case TravelModes.walking.rawValue:
                        travelModeString = "walking"
                        
                    case TravelModes.bicycling.rawValue:
                        travelModeString = "bicycling"
                        
                    default:
                        travelModeString = "driving"
                    }
                    
                    
                    directionsURLString += "&mode=" + travelModeString
                }
                
                
                directionsURLString = directionsURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
                let directionsURL = NSURL(string: directionsURLString)
                
                
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let directionsData = NSData(contentsOfURL: directionsURL!)
                    
                    var error: NSError?
                    let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! Dictionary<NSObject, AnyObject>
                    
                    if (error != nil) {
                        println(error)
                        completionHandler(status: "", success: false)
                    }
                    else {
                        let status = dictionary["status"] as! String
                        
                        if status == "OK" {
                            self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<NSObject, AnyObject>>)[0]
                            self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<NSObject, AnyObject>
                            
                            let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
                            
                            let startLocationDictionary = legs[0]["start_location"] as! Dictionary<NSObject, AnyObject>
                            self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                            
                            let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<NSObject, AnyObject>
                            self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                            
                            self.originAddress = legs[0]["start_address"] as! String
                            self.destinationAddress = legs[legs.count - 1]["end_address"] as! String
                            
                            self.calculateTotalDistanceAndDuration()
                            
                            completionHandler(status: status, success: true)
                        }
                        else {
                            completionHandler(status: status, success: false)
                        }
                    }
                })
            }
            else {
                completionHandler(status: "Destination is nil.", success: false)
            }
        }
        else {
            completionHandler(status: "Origin is nil", success: false)
        }
    }
    
    
    func calculateTotalDistanceAndDuration() {
        let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
        
        totalDistanceInMeters = 0
        totalDurationInSeconds = 0
        
        for leg in legs {
            totalDistanceInMeters += (leg["distance"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
            totalDurationInSeconds += (leg["duration"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
        }
        
        
        let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
        totalDistance = "Total Distance: \(distanceInKilometers) Km"
        
        
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        totalDuration = "Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
    }
    
    
}


enum TravelModes: Int {
    case driving
    case walking
    case bicycling
}




struct Place{
    
    let id: String
    let Name: String
    let PictureId: String?
    let LogoUrl: String
    let rating: Double?
    let pricing: Double?
    let location: CLLocationCoordinate2D
    let address: String
    
    
    var img: UIImage?{
        get {
            if (PictureId == nil)
            {
                
                let url = NSURL(string: LogoUrl)
                let data = NSData(contentsOfURL: url!)
                return UIImage(data: data!)
            }
            else {
                let googleKey = "AIzaSyAAuObnFBEsFXx2p4QRgGNsD-r24ZWfapI"
                let baseURL = "https://maps.googleapis.com/maps/api/place/photo?"
                
                var pictureURLString = baseURL + "maxwidth=65&maxheight=65&photoreference=\(PictureId!)&key=\(googleKey)"
                
                
                pictureURLString = pictureURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                
                let pictureURL = NSURL(string: pictureURLString)
                if let pictureData = NSData(contentsOfURL: pictureURL!)
                {
                    return UIImage(data: pictureData)
                }
                else
                {
                    
                    let url = NSURL(string: LogoUrl)
                    let data = NSData(contentsOfURL: url!)
                    return UIImage(data: data!)
                    
                    
                }
                
            }
        }
    }
}