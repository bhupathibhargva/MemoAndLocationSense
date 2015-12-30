//
//  Utilities.swift
//  MemoAndLocationSense
//
//  Created by fantastic4 on 28/3/15.
//  Copyright (c) 2015 fantastic4. All rights reserved.
//

import UIKit
import MapKit

// MARK: Helper Functions

func showSimpleAlertWithTitle(title: String!, #message: String, #viewController: UIViewController) {
  let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
  let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
  alert.addAction(action)
  viewController.presentViewController(alert, animated: true, completion: nil)
}

func zoomToUserLocationInMapView(mapView: MKMapView) {
  if let coordinate = mapView.userLocation.location?.coordinate {
    let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
    mapView.setRegion(region, animated: true)
  }
}
