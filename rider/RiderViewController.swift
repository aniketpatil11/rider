//
//  RiderViewController.swift
//  rider
//
//  Created by Aniket Patil on 17/09/17.
//  Copyright © 2017 aniketpatil. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callAnUber: UIButton!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    //weather or not user is currently looking for uber
    var uberHasBeenCalled = false
    var driverOnTheWay = false
    var driverLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        //to get accuracy best accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //IF THE RIDE IS BOOKED THEN WE NEED TO SHOW THIS WHEN THE VIEW GET'S LOADED
        //checks if the rider has already booked the ride or not if yes then does following thing's
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                self.uberHasBeenCalled = true
                self.callAnUber.setTitle("Cancel Uber", for: .normal)
                //WE DONT NEED THIS WE ARE NOT GOING TO REMOVE WHEN VIEW LOADS snapshot.ref.removeValue()
                //we are making this because it wont delete all of your data !
                Database.database().reference().child("RideRequests").removeAllObservers()
                if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
                    if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                        if let driverLon = rideRequestDictionary["driverLon"] as? Double {
                            self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                            self.driverOnTheWay = true
                            self.displayDriverAndRider()
                            
                            if let email = Auth.auth().currentUser?.email{
                                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged, with: { (snapshot) in
                                    if let rideRequestDictionary = snapshot.value as? [String: AnyObject] {
                                        if let driverLat = rideRequestDictionary["driverLat"] as? Double {
                                            if let driverLon = rideRequestDictionary["driverLon"] as? Double {
                                                self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                                                self.driverOnTheWay = true
                                                self.displayDriverAndRider()
                                                
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            })
        }
    }
    func displayDriverAndRider() {
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude,longitude: userLocation.longitude)
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        callAnUber.setTitle("Your driver is \(roundedDistance)km away!", for: .normal)
        map.removeAnnotations(map.annotations)
        
        let latDelta = abs(driverLocation.latitude - userLocation.latitude) * 2 + 0.005
        let lonDelta = abs(driverLocation.longitude - userLocation.longitude) * 2 + 0.005
        
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpanMake(latDelta, lonDelta))
        map.setRegion(region, animated: true)
        let riderAnno = MKPointAnnotation()
        riderAnno.coordinate = userLocation
        riderAnno.title = "Your location "
        map.addAnnotation(riderAnno)
        let driverAnno = MKPointAnnotation()
        driverAnno.coordinate = driverLocation
        driverAnno.title = "Driver Location"
        map.addAnnotation(driverAnno)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //code tells the location if the location is updated or not
        if let coord = manager.location?.coordinate {
            //It gets the latitude and longitude
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            userLocation = center
            //It center's with given accuracy to the region
            if uberHasBeenCalled {
                displayDriverAndRider()
                
                
            }else {
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                //finaly setting the map
                map.setRegion(region, animated: true)
                
                //We need to remove previously created annotations in order to keep only one pin
                //so we remove those with the method called removeannotations and passing all the
                //present annotations on the map(basically map array ) so we access those by
                //map.annotations method REMOVE PIN
                
                //map.removeAnnotation(map.annotations)
                map.removeAnnotations(map.annotations)
                
                //annotations making pins drop pins
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = "Your Location "
                map.addAnnotation(annotation)
            }
        }
    }
    
    @IBAction func callUberTapped(_ sender: Any) {
        if !driverOnTheWay{
            if let email = Auth.auth().currentUser?.email {
                if uberHasBeenCalled {
                    uberHasBeenCalled = false
                    callAnUber.setTitle("Call An Uber", for: .normal)
                    //we are going to check the value in the database and then we will query it with order email
                    //THIS WILL DELETE THE DATA IN FIREBASE DATABASE
                    
                    Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded, with: { (snapshot) in
                        snapshot.ref.removeValue()
                        //we are making this because it wont delete all of your data !
                        Database.database().reference().child("RideRequests").removeAllObservers()
                    })
                }else {
                    let rideRequestDictionary : [String:Any] = ["email": email,"lat": userLocation.latitude,"lon": userLocation.longitude]
                    Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequestDictionary)
                    uberHasBeenCalled = true
                    callAnUber.setTitle("Cancel Uber", for: .normal)
                }
            }
        }
    }
    
    @IBAction func logOutTapped(_ sender: Any) {
        //navigation controller need to be dismissed
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
