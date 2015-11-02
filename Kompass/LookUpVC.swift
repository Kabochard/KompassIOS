//
//  AddressSearchVC.swift
//  Dej-DeviOS
//
//  Created by Tim Consigny on 09/06/2015.
//  Copyright (c) 2015 Tim Consigny. All rights reserved.
//

import UIKit

class LookUpVC: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var taskMng = MapTasks()
    var txtBar : UIView!
    var resTable : UITableView!
    var searchBar : UITextField!
    var cancelButton : UIButton!
   
    var resDic = [String:String]()
    
    var root: KompassVC?
    
    
    override func viewDidLoad() {
        
        txtBar = UIView(frame: CGRect(x: 0.05 * view.frame.width, y: 30, width: 0.9 * view.frame.width, height: 30))
        
        resTable = UITableView(frame: CGRect(x: 0, y: 60, width: view.frame.width, height: view.frame.height - 60))
        
        resTable.dataSource = self
        resTable.delegate = self
        
        
        searchBar = UITextField(frame: CGRect(x: 0.1 * txtBar.frame.width, y: 0.1 * txtBar.frame.height, width:  0.65 * txtBar.frame.width, height: 0.9 * txtBar.frame.height))
        
        cancelButton = UIButton(frame: CGRect(x: 0.8 * txtBar.frame.width, y: 0.1 * txtBar.frame.height, width:  0.1 * txtBar.frame.width, height: 0.9 * txtBar.frame.height))
        
        searchBar.delegate = self
        
        txtBar.addSubview(searchBar)
        
        txtBar.addSubview(cancelButton)
        
        
        cancelButton.backgroundColor = StaticInfo.MainColor
        
        searchBar.backgroundColor = StaticColor.White()
        searchBar.textColor =  StaticInfo.MainColor
        searchBar.layer.cornerRadius = 5
        searchBar.layer.borderColor =  StaticInfo.MainColor.CGColor
        searchBar.layer.borderWidth = 1
        
       cancelButton.addTarget(self, action: "dismiss", forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(txtBar)
        view.addSubview(resTable)
        
        
    }
    
    override func viewWillLayoutSubviews() {
        txtBar.frame = CGRect(x: 0.05 * view.frame.width, y: 30, width: 0.9 * view.frame.width, height: 30)
        resTable.frame = CGRect(x: 0, y: 60, width: view.frame.width, height: 1 * view.frame.height - 60)
        
        print(view.frame.width)
        
        searchBar.frame = CGRect(x: 0.1 * txtBar.frame.width, y: 0.1 * txtBar.frame.height, width:  0.65 * txtBar.frame.width, height: 0.9 * txtBar.frame.height)

        cancelButton.frame = CGRect(x: 0.8 * txtBar.frame.width, y: 0.1 * txtBar.frame.height, width:  0.1 * txtBar.frame.width, height: 0.9 * txtBar.frame.height)
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
        print("Fuck")
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        
        let string2search = textField.text! + string
        if string2search.characters.count > 2
        {
            if let coord = root!.KompassManager.locmanager.location?.coordinate {
            
            taskMng.autoComplete(string2search, location: coord, radius: 10000, completionHandler: { (status, success, res) -> Void in
                
                if res != nil {
                    self.resDic = res!
                }
                
                self.resTable.reloadData()
            })
            }
        }
        else
        {
            resDic = [String:String]()
            self.resTable.reloadData()
        }
        
        
        return true
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        print("You")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let ids = resDic.map { (x:(String, String)) -> String in
            x.0
        }
        
        let id = ids[indexPath.row]
        
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: id)
        
        cell.textLabel?.text = resDic[id]
        
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 60//round(dicSize["Resto"]!.height / 3)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
        
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resDic.count //min(3, restoList.count)
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        searchBar.text = resTable.cellForRowAtIndexPath(indexPath)?.textLabel?.text
        let placeId = resTable.cellForRowAtIndexPath(indexPath)?.reuseIdentifier
        
        if (placeId != nil)
        {
            taskMng.placeLookUp(placeId!, completionHandler: { (status, success, res) -> Void in
                
                let loc = CLLocation(latitude: res!.latitude, longitude: res!.longitude)
                
               // self.root!.targetMarker.position = res!
                self.root!.setTarget(loc)
                
                //Comm
                self.root?.searchBar.text = self.searchBar.text
                self.view.removeFromSuperview()
                
            })
        }
        resDic.removeAll(keepCapacity: false)
        
        resTable.reloadData()
        
        searchBar.resignFirstResponder()
    }
    
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        root = parent as? KompassVC
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        searchBar.resignFirstResponder()
    }
    
    func dismiss()
    {
        self.view.removeFromSuperview()
        searchBar.resignFirstResponder()
    }
    
       
    
}