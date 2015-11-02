//
//  AddressSearchVC.swift
//  Dej-DeviOS
//
//  Created by Tim Consigny on 09/06/2015.
//  Copyright (c) 2015 Tim Consigny. All rights reserved.
//

import UIKit

class AddressVC: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var taskMng = MapTasks()
    var txtBar : UIView!
    var resTable : UITableView!
    var searchBar : UITextField!
    //    var OkButton : UIButton!
    //    var cancelButton : UIButton!
    
    var resDic = [String:String]()
    
    var root: MapVC?
    
    
    override func viewDidLoad() {
        
        txtBar = UIView(frame: CGRect(x: 0.05 * view.frame.width, y: 30, width: 0.9 * view.frame.width, height: 30))
        
        resTable = UITableView(frame: CGRect(x: 0, y: 0.1 * view.frame.height, width: view.frame.width, height: 0.9 * view.frame.height))
        
        resTable.dataSource = self
        resTable.delegate = self
        
        
        searchBar = UITextField(frame: CGRect(x: 0.1 * txtBar.frame.width, y: 0.1 * txtBar.frame.height, width:  0.5 * txtBar.frame.width, height: 0.9 * txtBar.frame.height))
        
        //        OkButton = UIButton(frame: CGRect(x: 0.7 * txtBar.frame.width, y: 0.1 * txtBar.frame.height, width:  0.1 * txtBar.frame.width, height: 0.9 * txtBar.frame.height))
        //
        //        cancelButton = UIButton(frame: CGRect(x: 0.85 * txtBar.frame.width, y: 0.1 * txtBar.frame.height, width:  0.1 * txtBar.frame.width, height: 0.9 * txtBar.frame.height))
        
        searchBar.delegate = self
        
        txtBar.addSubview(searchBar)
        //        txtBar.addSubview(OkButton)
        //        txtBar.addSubview(cancelButton)
        
        
        //        OkButton.backgroundColor = StaticColor.DarkOrange()
        //        cancelButton.backgroundColor = StaticColor.DarkOrange()
        
        searchBar.backgroundColor = StaticColor.White()
        searchBar.textColor = StaticColor.DarkOrange()
        searchBar.layer.cornerRadius = 5
        searchBar.layer.borderColor = StaticColor.DarkOrange().CGColor
        searchBar.layer.borderWidth = 1
        
        
        //txtBar.backgroundColor = StaticColor.Lime()
        
        
        view.addSubview(txtBar)
        view.addSubview(resTable)
        
        
    }
    
    override func viewWillLayoutSubviews() {
        txtBar.frame = CGRect(x: 0, y: 0, width: 1 * view.frame.width, height: 0.1 * view.frame.height)
        resTable.frame = CGRect(x: 0, y: 0.1 * view.frame.height, width: view.frame.width, height: 0.9 * view.frame.height)
        
        println(view.frame.width)
        
        searchBar.frame = CGRect(x: 0.1 * txtBar.frame.width, y: 0.1 * txtBar.frame.height, width:  0.8 * txtBar.frame.width, height: 0.9 * txtBar.frame.height)
        
        //        OkButton.frame = CGRect(x: 0.7 * txtBar.frame.width, y: 0.1 * txtBar.frame.height, width:  0.1 * txtBar.frame.width, height: 0.9 * txtBar.frame.height)
        //
        //        cancelButton.frame = CGRect(x: 0.85 * txtBar.frame.width, y: 0.1 * txtBar.frame.height, width:  0.1 * txtBar.frame.width, height: 0.9 * txtBar.frame.height)
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
        println("Fuck")
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        
        let string2search = textField.text + string
        if count (string2search) > 2
        {
            
            taskMng.autoComplete(string2search, location: root!.mapView.myLocation.coordinate, radius: 10000, completionHandler: { (status, success, res) -> Void in
                
                if res != nil {
                    self.resDic = res!
                }
                
                self.resTable.reloadData()
            })
        }
        else
        {
            resDic = [String:String]()
            self.resTable.reloadData()
        }
        
        
        return true
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        println("You")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let id = resDic.keys.array[indexPath.row]
        
        
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: id)
        
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
        var placeId = resTable.cellForRowAtIndexPath(indexPath)?.reuseIdentifier
        
        if (placeId != nil)
        {
            taskMng.placeLookUp(placeId!, completionHandler: { (status, success, res) -> Void in
                self.root!.markerDej.position = res!
                self.root!.SearchBar.text = self.searchBar.text
                self.view.removeFromSuperview()
                //self.root!.changeMeeting()
                // self.root!.fitCamera()
                
                
            })
        }
        resDic.removeAll(keepCapacity: false)
        
        resTable.reloadData()
        
        searchBar.resignFirstResponder()
    }
    
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        root = parent as? MapVC
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        searchBar.resignFirstResponder()
    }
    
    
}