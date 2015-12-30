//
//  GeotificationsViewController.swift
//  MemoAndLocationSense
//
//  Created by fantastic4 on 28/3/15.
//  Copyright (c) 2015 fantastic4. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

var addressArray = [String]()
let kSavedItemsKey = " "
var notifications = [Notification]()
var DetailVArray :Notification!
var LocAdress = " "

var count = 0

typealias LMGeocodeCompletionHandler = ((gecodeInfo:NSDictionary?,placemark:CLPlacemark?, error:String?)->Void)?
typealias LMLocationCompletionHandler = ((latitude:Double, longitude:Double, status:String, verboseMessage:String, error:String?)->())?

class GeotificationsViewController: UIViewController, AddGeotificationsViewControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate , UITableViewDelegate ,UITableViewDataSource {
  var AddReminderClass : AddGeotificationViewController = AddGeotificationViewController()
  
  func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
    mapView.centerCoordinate = userLocation.coordinate
  }
 
  var vc1 : Notification!
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet var Tview :UITableView!
  // table view functions 
   func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1
  }
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete method implementation.
    // Return the number of rows in the section.
    return notifications.count
  }
  
  
  
   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath) as! UITableViewCell
    
    let xyz :Notification = notifications[indexPath.row] as Notification
    cell.textLabel?.text = xyz.note
    
    return cell
  }
  

  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
 
  override func viewWillAppear(animated: Bool) {
   DetailVArray = nil
    
    Tview.reloadData()
  }

  
  let locationManager = CLLocationManager()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    
mapView.delegate = self
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
 self.locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    
    // 1
    locationManager.delegate = self
    // 2
    locationManager.requestAlwaysAuthorization()
    // 3
    loadAllGeotifications()
    mapView.mapType = MKMapType.Standard
    
  // self.Tview.reloadData()
  }
  
  
  //problem while transferinggggg

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "addGeotification" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let vc = navigationController.viewControllers.first as! AddGeotificationViewController
      vc.delegate = self
    }
    
   else if segue.identifier == "viewReminder"{
    let viewReminder  = segue.destinationViewController as! UINavigationController
      let viewc = viewReminder.viewControllers.first as! AddGeotificationViewController
     var selected = Tview.indexPathForSelectedRow()?.row
      DetailVArray = (notifications[selected!])
     
      //LocAdress = addressArray[selected!]
      
     
viewc.vc = notifications[selected!]
      
    }
  }

  // MARK: Loading and saving functions

  func loadAllGeotifications() {
    notifications = []

    if let savedItems = NSUserDefaults.standardUserDefaults().arrayForKey(kSavedItemsKey) {
      for savedItem in savedItems {
        if let geotification = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? Notification {
          addGeotification(geotification)
        }
      }
    }
  }
  // Type button
  // changes the type of MapView 
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
  
  // Swipe to Delete
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == UITableViewCellEditingStyle.Delete {
    
    notifications.removeAtIndex(indexPath.row)
     
     var ind = indexPath.row
      mapView.removeAnnotation(vc1)
    // removeGeotification(Geotification.coordinate)
      updateGeotificationsCount()
      self.Tview.reloadData()
    
    }
  }

  func saveAllGeotifications() {
    var items = NSMutableArray()
    for geotification in notifications {
      let item = NSKeyedArchiver.archivedDataWithRootObject(geotification)
      items.addObject(item)
      
    }
     // addressArray.append(self.addgeo.Adress.text!)
    NSUserDefaults.standardUserDefaults().setObject(items, forKey: kSavedItemsKey)
    NSUserDefaults.standardUserDefaults().synchronize()
  }

  // MARK: Functions that update the model/associated views with geotification changes

  func addGeotification(geotification: Notification) {
    notifications.append(geotification)
    mapView.addAnnotation(geotification)
    addRadiusOverlayForGeotification(geotification)
    
    
    updateGeotificationsCount()
    
  }

  func removeNotification(geotification: Notification) {
    if let indexInArray = find(notifications, geotification) {
      notifications.removeAtIndex(indexInArray)
      self.Tview.reloadData()
      
      
    }

    mapView.removeAnnotation(geotification)
    removeRadiusOverlayForGeotification(geotification)
    updateGeotificationsCount()
  }
    
    var addgeo : AddGeotificationViewController = AddGeotificationViewController()

  func updateGeotificationsCount() {
    title = "Reminders (\(notifications.count))"
    navigationItem.rightBarButtonItem?.enabled = (notifications.count < 20)
  }

  // MARK: AddGeotificationViewControllerDelegate

  func addGeotificationViewController(controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: EventType) {
    controller.dismissViewControllerAnimated(true, completion: nil)
    // 1
    let clampedRadius = (radius > locationManager.maximumRegionMonitoringDistance) ? locationManager.maximumRegionMonitoringDistance : radius

    let geotification = Notification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType )
    addGeotification(geotification)
    
   //addressArray.append(self.addgeo.Adress.text!)
    // 2
    startMonitoringGeotification(geotification)
    
    

    saveAllGeotifications()
  }

  // MARK: MKMapViewDelegate

  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    let identifier = "myGeotification"
    if annotation is Notification {
      var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView?.canShowCallout = true
        var removeButton = UIButton.buttonWithType(.Custom) as! UIButton
        removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        removeButton.setImage(UIImage(named: "DeleteGeotification")!, forState: .Normal)
        annotationView?.leftCalloutAccessoryView = removeButton
      } else {
        annotationView?.annotation = annotation
      }
      return annotationView
    }
    return nil
  }

  func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
    if overlay is MKCircle {
      var circleRenderer = MKCircleRenderer(overlay: overlay)
      circleRenderer.lineWidth = 1.0
      circleRenderer.strokeColor = UIColor.purpleColor()
      circleRenderer.fillColor = UIColor.purpleColor().colorWithAlphaComponent(0.4)
      return circleRenderer
    }
    return nil
  }

  func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
    // Delete geotification
    var geotification = view.annotation as! Notification
    stopMonitoringGeotification(geotification)
    removeNotification(geotification)
    
    saveAllGeotifications()
  }

  // MARK: Map overlay functions

  func addRadiusOverlayForGeotification(geotification: Notification) {
    mapView?.addOverlay(MKCircle(centerCoordinate: geotification.coordinate, radius: geotification.radius))
  }

  func removeRadiusOverlayForGeotification(geotification: Notification) {
    // Find exactly one overlay which has the same coordinates & radius to remove
    if let overlays = mapView?.overlays {
      for overlay in overlays {
        if let circleOverlay = overlay as? MKCircle {
          var coord = circleOverlay.coordinate
          if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
            mapView?.removeOverlay(circleOverlay)
            break
          }
        }
      }
    }
  }

  // MARK: Other mapview functions

  @IBAction func zoomToCurrentLocation(sender: AnyObject) {
    zoomToUserLocationInMapView(mapView)
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
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    mapView.showsUserLocation = (status == .AuthorizedAlways)
  }

  func regionWithGeotification(geotification: Notification) -> CLCircularRegion {
    // 1
    let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
    // 2
    region.notifyOnEntry = (geotification.eventType == .OnEntry)
    region.notifyOnExit = !region.notifyOnEntry
    return region
  }

  func startMonitoringGeotification(geotification: Notification) {
    // 1
    if !CLLocationManager.isMonitoringAvailableForClass(CLCircularRegion) {
      showSimpleAlertWithTitle("Error", message: "LocationSense  is not supported on this device!", viewController: self)
      return
    }
    // 2
    if CLLocationManager.authorizationStatus() != .AuthorizedAlways {
      showSimpleAlertWithTitle("Warning", message: "Your  Notification  is saved but will only be activated once you grant location sense  permission to access the device location.", viewController: self)
    }
    // 3
    let region = regionWithGeotification(geotification)
    // 4
    locationManager.startMonitoringForRegion(region)
  }

  func stopMonitoringGeotification(geotification: Notification) {
    for region in locationManager.monitoredRegions {
      if let circularRegion = region as? CLCircularRegion {
        if circularRegion.identifier == geotification.identifier {
          locationManager.stopMonitoringForRegion(circularRegion)
        }
      }
    }
  }

  func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
    println("Monitoring failed for region with identifier: \(region.identifier)")
  }

  func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
    println("\(error)")
  }
  
 
}
