import Foundation
import UIKit


class MapVC: UIViewController,  GMSMapViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    

    
    
    var SearchBar: UITextField!
    var SearchBox: UIView!
 
    
    var availableX: CGFloat!
    var availableY: CGFloat!
    var startY: CGFloat!
    
    var dicCoord: Dictionary<String, CGPoint>!
    var dicSize: Dictionary<String, Size>!

    
    var tableScreen: AddressVC!
    
    var markerDej: GMSMarker!
    var markerMe: GMSMarker!
    var markerResto: GMSMarker?
    var mapView : GMSMapView!
    var cameraButton: UIButton!
    
    var mapTask: MapTasks!
    var mode : DisplayType = DisplayType.map
    
    let locationManager = CLLocationManager()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        dicCoord =  Dictionary<String, CGPoint>()
        dicSize = [String: Size]()
        
       
        mapView = GMSMapView()
        
       
        
        
        defineLayout()
        
        
        mapTask = MapTasks()
        
        initMapView()
        
       
        
        initSearchBox()
        
        
        
        tableScreen = AddressVC()
        addChildViewController(tableScreen)
        tableScreen.didMoveToParentViewController(self)
        
        
        displayItems()
        
    }
    
    override func viewWillLayoutSubviews() {
        if view.superview != nil && count(dicSize) > 0 && count(dicCoord) > 0
        {
            drawLayout()
        }
    }
    
    
    

  
    private func drawSearchBox()
    {
        SearchBox.frame = CGRect(x: 10, y: 10, width: 0.9 * view.frame.width, height: 30)
        
        SearchBar.frame = CGRect(x: 0.1 * SearchBox.frame.width, y: 0.1 * SearchBox.frame.height, width: 0.9 * SearchBox.frame.width, height: 0.9 * SearchBox.frame.height)
        
        //      searchOkButton.frame = CGRect(x: 0.75 * SearchBox.frame.width, y: 0.1 * SearchBox.frame.height, width:  0.1 * SearchBox.frame.width, height: 0.9 * SearchBox.frame.height)
        //        searchdismissButton.frame = CGRect(x: 0.9 * SearchBox.frame.width, y: 0.1 * SearchBox.frame.height, width:  0.1 * SearchBox.frame.width, height: 0.9 * SearchBox.frame.height)
        
    }
    
    
    private func initSearchBox()
    {
        SearchBox = UIView(frame: CGRect(x: 10, y: 10, width: 0.9 * view.frame.width, height: 30))
        
        SearchBar = UITextField(frame: CGRect(x: 0.1 * SearchBox.frame.width, y: 0.1 * SearchBox.frame.height, width: 0.6 * SearchBox.frame.width, height: 0.9 * SearchBox.frame.height))
        
        SearchBar.backgroundColor = StaticColor.White()
        SearchBar.textColor = StaticColor.DarkOrange()
        SearchBar.text = "Enter text or tap on the map"
        
        SearchBar.layer.cornerRadius = 5
        SearchBar.layer.borderColor = StaticColor.DarkOrange().CGColor
        SearchBar.layer.borderWidth = 1
        
        SearchBar.delegate = self
        
        //        searchOkButton = UIButton(frame: CGRect(x: 0.75 * SearchBox.frame.width, y: 0.1 * SearchBox.frame.height, width:  0.1 * SearchBox.frame.width, height: 0.9 * SearchBox.frame.height))
        //        searchOkButton.backgroundColor = StaticColor.DarkOrange()
        //        searchOkButton.setTitleColor(StaticColor.White(), forState: UIControlState.Normal)
        //        searchOkButton.setTitle("Ok", forState: UIControlState.Normal)
        //        searchOkButton.addTarget(self, action: "changeMeeting:", forControlEvents: UIControlEvents.TouchUpInside)
        //
        //        searchdismissButton = UIButton(frame: CGRect(x: 0.9 * SearchBox.frame.width, y: 0.1 * SearchBox.frame.height, width:  0.1 * SearchBox.frame.width, height: 0.9 * SearchBox.frame.height))
        //        searchdismissButton.backgroundColor = StaticColor.DarkOrange()
        //        searchdismissButton.setTitleColor(StaticColor.White(), forState: UIControlState.Normal)
        //        searchdismissButton.setTitle("X", forState: UIControlState.Normal)
        //        searchdismissButton.addTarget(root, action: "dismiss", forControlEvents: UIControlEvents.TouchUpInside)
        
        SearchBox.addSubview(SearchBar)
        //        SearchBox.addSubview(searchOkButton)
        //        SearchBox.addSubview(searchdismissButton)
        
        
        
    }
    
    
    private func drawMapView()
    {
        if mapView != nil
        {
            cameraButton.frame = CGRect(x: mapView.frame.width - 30, y: mapView.frame.height - 30, width: 25, height: 25)
           // fitCamera()
        }
    }
    
    private func initMapView()
    {
        cameraButton = UIButton()
        cameraButton.setImage(UIImage(named: "target"), forState: UIControlState.Normal)
        cameraButton.addTarget(self, action: "fitCamera", forControlEvents: UIControlEvents.TouchUpInside)
        mapView.delegate = self
        let markerSize = CGSize(width: 20, height: 20)
        mapView.myLocationEnabled = true
        
        
        markerMe = GMSMarker()
       // var myLoc = DejUser.Instance.parseUser_?.objectForKey("Location") as! PFGeoPoint?
       // markerMe.position = CLLocationCoordinate2DMake(myLoc!.latitude , myLoc!.longitude)
        //markerMe.icon = imageResize(UIImage(named: "MarkerMe")!, sizeChange: markerSize)
//        markerMe.title = "me"
//        markerMe.map = mapView
//        
        mapView.settings.myLocationButton = true
        
//        var camera = GMSCameraPosition.cameraWithLatitude(myLoc!.latitude,
//            longitude: myLoc!.longitude, zoom: 14)
//        mapView.camera = camera
        
        mapView.settings.compassButton = true
        //mapView.settings.myLocationButton = true
        
        
        markerDej = GMSMarker()
        
        //   markerDej.position = CLLocationCoordinate2DMake(dej!.meetingPoint_!.latitude , dej!.meetingPoint_!.longitude)
//        markerDej.icon = imageResize(UIImage(named: "MarkerDej")!, sizeChange: markerSize)
        markerDej.title = "Dej"
        markerDej.map = mapView
//
        //        mapView.myLocationEnabled = true
        //        mapView.settings.myLocationButton = false
        //        fitCamera()
        //mapView.addSubview(cameraButton)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        
        mapView.clear()
        mapView.removeFromSuperview()
        mapView = nil
        
    }
    
    
    private func defineLayout(){
        
        var availableX = view.frame.width
        var availableY = view.frame.height
        
        dicCoord["Map"] = CGPoint(x: 0.0   , y: 0.00)//CGPoint(x: 0.45 * availableX , y: 0.05 * availableY)
        dicSize["Map"] = Size(width: availableX * 1, height: 1 * availableY )//Size(width: availableX * 0.525, height: 0.925 * availableY )
        
        dicCoord["Clock"] = CGPoint(x: 0.0  * availableX , y: 0.0 * availableY)
        dicSize["Clock"] = Size(width: availableX * 1, height: availableY * 1)
        
        dicCoord["Resto"] = CGPoint(x: 0.025 * availableX, y: 0.025 * availableX)
        dicSize["Resto"] = Size(width: availableX * 0.4, height: availableY * 0.4)
        
        dicCoord["SearchBar"] = CGPoint(x: availableX * 0.1 , y: 0.025 * availableX)
        dicSize["SearchBar"] = Size(width: availableX * 0.8, height: availableY * 0.2)
        
        
        
    }
    
    private func drawLayout()
    {
        defineLayout()
        
      
        mapView?.frame = GetRec("Map", center: false)
               SearchBox.frame = GetRec("SearchBar", center: false)
        
               drawMapView()
        drawSearchBox()
       
    }
    
    private func cleanViews(){
       
        mapView.removeFromSuperview()
        
        SearchBox.removeFromSuperview()
    }
    
    func displayItems()
    {
        defineLayout()
        cleanViews()
        drawLayout()
        
    
            view.addSubview(mapView)
            view.addSubview(SearchBox)
            
        
    }
    
    
    
    
    
    //MARK: TableView
    
    
    
 
    
    
    //MARK: Util
    
    
    
    
    func GetRec(viewName: String, center: Bool) -> CGRect
    {
        var siz = dicSize[viewName]!
        var coord = dicCoord[viewName]!
        var startY = CGFloat(0.0)
        
        if center{
            return CGRect(
                x: coord.x - siz.width / 2,
                y: startY + coord.y - siz.height / 2,
                width: siz.width ,
                height: siz.height)
        }
        else
        {
            return CGRect(
                x: coord.x,
                y: startY + coord.y,
                width: siz.width ,
                height: siz.height)
            
        }
    }
    
    func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = true// false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
    //    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
    //        if (mode == DisplayType.search)
    //        {markerDej.position = position.target
    //         //reverseGeoCodeMarker()
    //        }
    //    }
    
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        //if (mode == DisplayType.search)
        //{
        markerDej.position = coordinate
        //var camera = GMSCameraPosition.cameraWithTarget(coordinate, zoom: 14)
        //mapView.animateToCameraPosition(camera)
        reverseGeoCodeMarker()
        //}
    }
    
    func reverseGeoCodeMarker() {
        let geocoder = GMSGeocoder()
        SearchBar.text = "Searching..."
        geocoder.reverseGeocodeCoordinate( markerDej.position) { response , error in
            
            if error == nil && response != nil {
                
                if let address = response.firstResult() {
                    let lines = address.lines as! [String]
                    self.SearchBar.text = join(", ", lines)
                    
                  
                }
                    
                else
                {
                    println(error.description)
                    self.SearchBar.text = "????"
                }
            }
        }
    }
    
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        DisplayTable()
        return false
    }
    
    func DisplayTable()
    {
        
        tableScreen.view.frame = GetRec("Map", center: false)
        tableScreen.view.backgroundColor = StaticColor.White()
        
        
        
        
        view.addSubview(tableScreen.view)
        tableScreen.searchBar.becomeFirstResponder()
        
    }
    

}

struct Size {
    var width: CGFloat
    var height: CGFloat
}

enum DisplayType: Int {
    case map
    case clock
    case resto
    case search
}
