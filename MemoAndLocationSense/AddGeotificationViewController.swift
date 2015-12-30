//
//  AddGeotificationViewController.swift
//  MemoAndLocationSense
//
//  Created by fantastic4 on 28/3/15.
//  Copyright (c) 2015 fantastic4. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

enum GeoCodingType{
  
  case Geocoding
  case revGeoCode
  
}
protocol AddGeotificationsViewControllerDelegate {
  func addGeotificationViewController(controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D,
    radius: Double, identifier: String, note: String, eventType: EventType)
}

class AddGeotificationViewController: UITableViewController , MKMapViewDelegate , CLLocationManagerDelegate , UITextFieldDelegate {
  let searchRequest = MKLocalSearchRequest()
// searchRequest.naturalLanguageQuery = " "
//  searchRequest.region  = mapView.region
  var vc : Notification!
  
  var geocoder = CLGeocoder()
  
  
  
  @IBAction func textFieldReturn(sender:AnyObject){
  sender.resignFirstResponder()
    mapView.removeAnnotations(mapView.annotations)
  //self.performSearch()
  }
  @IBOutlet var Adress: UILabel!
  @IBOutlet var Search: UITextField!

  @IBOutlet var addButton: UIBarButtonItem!
  @IBOutlet var zoomButton: UIBarButtonItem!

  @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!
  @IBOutlet weak var radiusTextField: UITextField!
  @IBOutlet weak var noteTextField: UITextField!
  @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var sliderValue: UISlider!
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        var currentValue = sliderValue.value
        radiusTextField.text = "\(currentValue)"
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Search.resignFirstResponder()
        noteTextField.resignFirstResponder()
    }
    
    //@IBOutlet var radiusLabel: UILabel!
  override func viewWillAppear(animated: Bool) {
    var address = self.Adress.text
    
    
    // adress in the detail view controller
  
    if addressArray.count != 0 {
    addressArray.append(address!)
      
     
      if addressArray.count == 1 {
        
        addressArray.removeAtIndex(0)
      }
    }
    
//    geocoder.geocodeAddressString(address) {
//      if let placemarks = $0 {
//        println(placemarks)
//      } else {
//        println($1)
//      }
//    }
    
    
    
    geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [AnyObject]!, error: NSError!) -> Void in
      if let placemark = placemarks?[0] as? CLPlacemark {
        self.mapView.addAnnotation(MKPlacemark(placemark: placemark))
      }
    })
  }

  var delegate: AddGeotificationsViewControllerDelegate!
//    override func viewDidAppear(animated: Bool) {
//      
//      Adress.text = Search.text
//
//    }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Search.delegate = self
    radiusTextField.delegate = self
    noteTextField.delegate = self
    
    activityIndicator.center = self.view.center
    activityIndicator.hidesWhenStopped = true
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
    activityIndicator.color = UIColor.blueColor()
    locationManager.autoUpdate = true
    var address = " "
    
    
    Search.text = address
    
    
    
    mapView.delegate = self
mapView.showsUserLocation = true
    mapView.mapType = MKMapType.Standard
    navigationItem.rightBarButtonItems = [addButton, zoomButton]
    addButton.enabled = false

    tableView.tableFooterView = UIView()
    
    if DetailVArray != nil {
    radiusTextField.text = "\(DetailVArray.radius)"
    noteTextField.text = DetailVArray.note
    mapView.addAnnotation(vc)
      
      if addressArray.count != 0 {
      Adress.text = addressArray[0]
      }
      println(addressArray)
      println(LocAdress)
    }
    
    
    var uilpgr = UILongPressGestureRecognizer(target: self, action: "action:")
    uilpgr.minimumPressDuration = 0.3
    mapView.addGestureRecognizer(uilpgr)
  }
  // activating add button only after filling min req entities
  @IBAction func textFieldEditingChanged(sender: UITextField) {
    addButton.enabled = !radiusTextField.text.isEmpty && !noteTextField.text.isEmpty
  }
  
  
  
  @IBAction func onCancel(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction private func onAdd(sender: AnyObject) {
    
    
      
    
    var coordinate = mapView.centerCoordinate
    var radius = (radiusTextField.text as NSString).doubleValue
    var identifier = NSUUID().UUIDString
    var note = noteTextField.text
    var eventType = (eventTypeSegmentedControl.selectedSegmentIndex == 0) ? EventType.OnEntry : EventType.OnExit
    delegate!.addGeotificationViewController(self, didAddCoordinate: coordinate, radius: radius, identifier: identifier, note: note, eventType: eventType)
    addressArray.append(self.Adress.text!)
  
  }
  
  var activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
  
  var locationManager = LocationManager.sharedInstance
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //changing the type of mapView 
  
  var noOfTouches = 0
  @IBAction func Type(sender:UIButton) {
    
    self.noOfTouches++
  
    
    
  if self.noOfTouches == 1 {
  mapView.mapType = MKMapType.Satellite
    
  }
    if self.noOfTouches == 2 {
  mapView.mapType = MKMapType.Standard
  
  }
  if self.noOfTouches == 3{
   mapView.mapType = MKMapType.Hybrid
    self.noOfTouches = 0
    }
  }
  
  // Search button
  // converts the input into a coordinate and points it on the map
  
  
  @IBAction func geocode(sender:UIButton) {
    
    activityIndicator.startAnimating()
    view.addSubview(activityIndicator)
    var address = Search.text!
  Adress.resignFirstResponder()
    
    
    plotOnMapWithAddress(address)
    
  }
  
  func locationManagerStatus(status:NSString) {
    
    println(status)
  }
  
  func locationManagerReceivedError(error:NSString) {
    
    println(error)
    activityIndicator.stopAnimating()
  }
  

  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    
    //Adress.resignFirstResponder()
    radiusTextField.resignFirstResponder()
    noteTextField.resignFirstResponder()
    Search.resignFirstResponder()
    return true
  }
  
  
  
  func plotOnMapWithAddress(address:NSString) {
    
    locationManager.geocodeAddressString(address: address) { (geocodeInfo,placemark, error) -> Void in
      
      self.performActionWithPlacemark(placemark, error: error)        }
  }
  
  //  func plotOnMapWithCoordinates(#latitude: Double, longitude: Double) {
  //
  //    locationManager.reverseGeocodeLocationUsingGoogleWithLatLon(latitude: latitude, longitude: longitude) { (reverseGeocodeInfo, placemark, error) -> Void in
  //
  //      self.performActionWithPlacemark(placemark, error: error)
  //    }
  //  }
  //
  
  func performActionWithPlacemark(placemark:CLPlacemark?,error:String?) {
    
    if error != nil {
      
      println(error)
      
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        
        if self.activityIndicator.superview != nil {
          
          self.activityIndicator.stopAnimating()
          self.activityIndicator.removeFromSuperview()
        }
      })
    } else {
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.plotPlacemarkOnMap(placemark)
      })
    }
  }
  
  func removeAllPlacemarkFromMap(#shouldRemoveUserLocation:Bool) {
    
    if let mapView = self.mapView {
      for annotation in mapView.annotations{
        if shouldRemoveUserLocation {
          if annotation as? MKUserLocation !=  mapView.userLocation {
            mapView.removeAnnotation(annotation as! MKAnnotation)
          }
        }
      }
    }
  }
  
  func plotPlacemarkOnMap(placemark:CLPlacemark?) {
    
    removeAllPlacemarkFromMap(shouldRemoveUserLocation:true)
    
    if self.locationManager.isRunning {
      self.locationManager.stopUpdatingLocation()
    }
    
    if self.activityIndicator.superview != nil {
      
      self.activityIndicator.stopAnimating()
      self.activityIndicator.removeFromSuperview()
    }
    
    var latDelta:CLLocationDegrees = 0.1
    var longDelta:CLLocationDegrees = 0.1
    var theSpan:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
    
    var latitudinalMeters = 100.0
    var longitudinalMeters = 100.0
    var theRegion:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(placemark!.location.coordinate, latitudinalMeters, longitudinalMeters)
    
    self.mapView?.setRegion(theRegion, animated: true)
    
    self.mapView?.addAnnotation(MKPlacemark(placemark: placemark))
  }
  


  
  
     var TiTle : String = "UnKnown"
  
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    Search.resignFirstResponder()
        self.view.endEditing(true)
    }



    @IBOutlet weak var SegmentControl: UISegmentedControl!
    @IBAction func TypeChanged(sender: UISegmentedControl) {
      switch SegmentControl.selectedSegmentIndex{
      case 0:
        mapView.mapType = MKMapType.Standard
      case 1:
        mapView.mapType = MKMapType.Hybrid
      case 2:
        mapView.mapType = MKMapType.Satellite
      default:
        break
      }
    }
  @IBAction private func onZoomToCurrentLocation(sender: AnyObject) {
    zoomToUserLocationInMapView(mapView)
  }
  
  
    // This method provides data to the long press gesture
    
    func action (gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
            var touchPoint = gestureRecognizer.locationInView(self.mapView)
            
            var newLoc = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            var location = CLLocation(latitude: newLoc.latitude, longitude: newLoc.longitude)
            
          var TiTle : String
         
          
            // near by adress added to the description label and to the title of the reminder
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                
                var title : String = ""
                if error != nil {
                    
                    println(error)
                } else {
                    
                    var subT = ""
                    var thru = ""
                    if  let p = CLPlacemark(placemark: placemarks[0] as! CLPlacemark){
                        if p.subThoroughfare != nil && p.thoroughfare != nil {
                            subT = "\(p.subThoroughfare)"
                            
                            thru = "\(p.thoroughfare)"
                            title = "\(p.subThoroughfare),\(p.thoroughfare)"
                             self.TiTle = title
                        }
                        
                        
                        
                        if title == ""  {
                            title = "Added \(NSDate())"
                           self.TiTle = title
                          println("\(p.country)\n \(p.subAdministrativeArea)\n\(p.subLocality)\n\(p.subThoroughfare)\n\(p.postalCode)\n\(p.thoroughfare)")
                        }
                       self.Adress.text = "\(p.country), \(p.subAdministrativeArea),\(p.subLocality) ,\(p.subThoroughfare),\(p.postalCode),\(p.thoroughfare)"
                       // self.Description.text = DescriptioninReminder
                        
                    
                    }
                }
                var annotation = MKPointAnnotation()
                
                
                
                // newloc is added as the point clicked location
                annotation.coordinate = newLoc
                annotation.title = title
                
                self.mapView.addAnnotation(annotation)
              
             
                
            //    places.append(["name":title,"lat":"\(newLoc.latitude)","lon":"\(newLoc.longitude)","Desc":DescriptioninReminder] )
                
                
                
            })
          
      }
  
    }
    
    
}
