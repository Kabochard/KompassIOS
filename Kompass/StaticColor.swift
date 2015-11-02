//
//  StaticColor.swift
//  Dej-DeviOS
//
//  Created by Tim Consigny on 24/03/2015.
//  Copyright (c) 2015 Tim Consigny. All rights reserved.
//

import UIKit

public class StaticColor
{
    
    
    class func Orange()->UIColor
    {
        return UIColor(red: 1, green: 0.68, blue: 0.1, alpha: 1);
        //return UIColor(red: 255/255, green: 127/255, blue: 0, alpha: 1);
        
    }
    
    class func DarkOrange()->UIColor
    {
        return UIColor(red: 255/255, green: 127/255, blue: 0, alpha: 1);
    }
    
    class func Lime()->UIColor
    {
        return UIColor(red: 153/255, green: 255/255, blue: 0, alpha: 1)
    }
    
    class func FBBlue()->UIColor
    {
        return UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1);
    }
    
    class func White()->UIColor
    {
        return UIColor(red: 1, green: 1, blue: 1, alpha: 1);
    }
    
    class func Grey()->UIColor
    {
        return UIColor(red: 211/255,green:211/255, blue:211/255, alpha:1);
    }
    
    
    
    
    //    class func FromUrl(uri:String)->UIImage
    //    {
    //        var url = NSURL(fileURLWithPath: uri)
    //
    //        return UIImage.L(FromUrl(uri: url));
    //        
    //    }
}