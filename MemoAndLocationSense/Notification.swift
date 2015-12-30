//
//  Notification.swift
//  MemoAndLocationSense
//
//  Created by fantastic4 on 28/3/15.
//  Copyright (c) 2015 fantastic4. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

let LatitudeKey = "latitude"
let LongitudeKey = "longitude"
let RadiusKey = "radius"
let IdentifierKey = "identifier"
let NoteKey = "note"
let EventTypeKey = "eventType"

enum EventType: Int {
  case OnEntry = 0
  case OnExit
}

class Notification: NSObject, NSCoding, MKAnnotation {
  
  var coordinate: CLLocationCoordinate2D
  var radius: CLLocationDistance
  var identifier: String
  var note: String
  var eventType: EventType
  
  
  var title: String {
    if note.isEmpty {
      return "No Note"
    }
    return note
  }
  
  var subtitle: String {
    var eventTypeString = eventType == .OnEntry ? "On Entry" : "On Exit"
    return "Radius: \(radius)m - \(eventTypeString)"
  }
  
  init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, note: String, eventType: EventType) {
    self.coordinate = coordinate
    self.radius = radius
    self.identifier = identifier
    self.note = note
    self.eventType = eventType
    
  }
  
  // MARK: NSCoding
  
  required init(coder decoder: NSCoder) {
    let latitude = decoder.decodeDoubleForKey(LatitudeKey)
    let longitude = decoder.decodeDoubleForKey(LongitudeKey)
    coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    radius = decoder.decodeDoubleForKey(RadiusKey)
    identifier = decoder.decodeObjectForKey(IdentifierKey) as! String
    note = decoder.decodeObjectForKey(NoteKey)as! String
    eventType = EventType(rawValue: decoder.decodeIntegerForKey(EventTypeKey))!
    
  }
  
  func encodeWithCoder(coder: NSCoder) {
    coder.encodeDouble(coordinate.latitude, forKey: LatitudeKey)
    coder.encodeDouble(coordinate.longitude, forKey: LongitudeKey)
    coder.encodeDouble(radius, forKey: RadiusKey)
    coder.encodeObject(identifier, forKey: IdentifierKey)
    coder.encodeObject(note, forKey: NoteKey)
    coder.encodeInt(Int32(eventType.rawValue), forKey: EventTypeKey)
  }

}
