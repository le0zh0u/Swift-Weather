//
//  ViewController.swift
//  Swift Weather
//
//  Created by 周椿杰 on 16/2/15.
//  Copyright © 2016年 周椿杰. All rights reserved.
//

import UIKit
import CoreLocation
import AFNetworking

class ViewController: UIViewController,CLLocationManagerDelegate {

    let locationManager:CLLocationManager = CLLocationManager()
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
//        if(ios8()){
//            locationManager.requestAlwaysAuthorization()
//        }
        ////发送授权申请
        locationManager.requestAlwaysAuthorization()
        if (CLLocationManager.locationServicesEnabled())
        {
            //允许使用定位服务的话，开启定位服务更新
            locationManager.startUpdatingLocation()
            print("定位开始")
        }
        
    }
    
    func ios8() -> Bool{
        return UIDevice.currentDevice().systemVersion == "8.0"
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location:CLLocation=locations.last!
        if location.horizontalAccuracy > 0{
            print(location.coordinate.latitude)
            print(location.coordinate.longitude)
            self.updateWeatherInfo(location.coordinate.latitude,longitude:location.coordinate.longitude)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func updateWeatherInfo(latitude:CLLocationDegrees,longitude:CLLocationDegrees){
        
        let manager = AFHTTPRequestOperationManager()
        let url = "http://api.openweathermap.org/data/2.5/weather"
        let appid = "8c1934967b2ff01415f0cb6f2d878176"
        let params = ["lat": latitude,"lon": longitude, "appid":appid]
        
        manager.GET(url, parameters: params, success: {(operation:AFHTTPRequestOperation!,responseObject:AnyObject!) in print("JSON: "+responseObject.description!)
                self.updateUISuccess(responseObject as! NSDictionary)
            },
            failure: {(operation:AFHTTPRequestOperation?,error:NSError) in print("Error: "+error.localizedDescription)})
        
    }
    
    func updateUISuccess(jsonResult:NSDictionary){
        if let tempResult = jsonResult["main"]?["temp"] as? Double{
            var temperature:Double = 0
            if jsonResult["sys"]?["country"] as! String == "US" {
                temperature = round(((tempResult-273.15)*1.8)+32)
            }
            else{
                temperature = round(tempResult-273.15)
            }
            
            self.temperature.text = "\(temperature)°"
            self.temperature.font = UIFont.boldSystemFontOfSize(60)
            
//            let name = jsonResult["name"] as! String
            let name = jsonResult["sys"]!["country"] as! String
            self.location.font = UIFont.boldSystemFontOfSize(25)
            self.location.text = "\(name)"
            
            let condition = (jsonResult["weather"] as! NSArray)[0]["id"] as! Int
            let sunrise = jsonResult["sys"]!["sunrise"] as! Double
            let sunset = jsonResult["sys"]!["sunset"] as! Double
            
            var nightTime = false
            let now = NSDate().timeIntervalSince1970
            if now < sunrise || now > sunset {
                nightTime = true
            }
            self.updateWeatherIcon(condition,nightTime:nightTime)
        }
        else{
            
        }
    }
    
    func updateWeatherIcon(condition:Int, nightTime:Bool){
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }

}

