//
//  MapViewController.swift
//  goHome
//
//  Created by Raul Silva on 4/6/18.
//  Copyright © 2018 Silva. All rights reserved.
//

import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var destinationAddress:String?                      //Should be set by the calling view
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate                                        = self
        mapView.showsUserLocation                               = true
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                self.getCoords(address: destinationAddress!)
            }
        } else {
            print("Location services are not enabled")
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let _ = locations.first {
             self.getCoords(address: destinationAddress!)
        }
    }
    
    func mapView(_ rendererFormapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
        } else {
            var location: CLLocation?
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                debugPrint("We are golden, let's get directions.")
                self.getDirections(destination: coordinate)
            } else {
                debugPrint("\("No Matching Location Found")")
            }
        }
    }
    

    private func getCoords(address:String){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address, completionHandler: {(placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
        })
    }
    
    private func getDirections(destination:CLLocationCoordinate2D){
        let  origin = (Manager.shared.locationManager.location?.coordinate)!           //Let's get where we are
        //Let's get our placemarks
        let sourcePlacemark = MKPlacemark(coordinate: origin, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destination, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }

        //Ok, show our pins
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: false )
        
        //Let's calculate directions
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        let directions = MKDirections(request: directionRequest)
        directions.calculate {
            (response, error) -> Void in
            guard let response = response else {
                if let error = error {
                    debugPrint("Error: \(error)")
                }
                return
            }
            let route = response.routes[0]
            //Display our route
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            //Zoom out to show entire route
            if let first = self.mapView.overlays.first {
                let rect = self.mapView.overlays.reduce(first.boundingMapRect, {MKMapRectUnion($0, $1.boundingMapRect)})
                self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
            }
        }
        
    }
}
