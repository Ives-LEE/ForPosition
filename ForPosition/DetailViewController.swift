//
//  DetailViewController.swift
//  ForPosition
//
//  Created by 李一正 on 2018/6/28.
//  Copyright © 2018年 lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController {
    
    @IBOutlet weak var mainMapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var points: [CLLocationCoordinate2D] = []
    var isReport = false
    
    var detailItem: Friend? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func configureView() {
        // Ask user's permission.
        locationManager.requestAlwaysAuthorization()
        
        // Background loaction update support.
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        
        guard CLLocationManager.locationServicesEnabled() else {
            // Show hint to user.
            return
        }
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else {
            // Show hint to user.
            return
        }
        
        // Prepare locationManager.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        // distanceFilter 移動超過 20 公尺 才算移動
        locationManager.distanceFilter = 20.0
        locationManager.startUpdatingLocation()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        guard let location = locationManager.location else {
            print("Location is not ready.")
            return
        }
        
        guard let lat = detailItem?.lat else {
            return
        }
        guard let lon = detailItem?.lon else {
            return
        }
        
        
        // Add a annotationView at a fake place.
        var friendCoordinate = CLLocationCoordinate2D(latitude: Double(lat)!,longitude: Double(lon)!)
        friendCoordinate.latitude += 0.005
        friendCoordinate.longitude += 0.005
        print("\(friendCoordinate.latitude) : \(friendCoordinate.longitude)")
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = friendCoordinate
        annotation.title = detailItem?.friendName
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.mainMapView.addAnnotation(annotation)
        }
        
        // Move and zoom the map to the storeCoordinate.
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: friendCoordinate, span: span)
        
        mainMapView.setRegion(region, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchUser(_ sender: UISegmentedControl) {
        guard let lat = detailItem?.lat else {
            return
        }
        guard let lon = detailItem?.lon else {
            return
        }
        
        let coordinate = CLLocationCoordinate2DMake(Double(lat)!, Double(lon)!)
        
        switch sender.selectedSegmentIndex {
        case 0:
            mainMapView.centerCoordinate = coordinate
        case 1:
            mainMapView.userTrackingMode = .follow
        default:
            mainMapView.centerCoordinate = coordinate
        }
    }
    
    @IBAction func switchReport(_ sender: UISwitch) {
        isReport = sender.isOn
    }
    
    
}

extension DetailViewController : CLLocationManagerDelegate {
    // MARK: - CLLocationManagerDelegate methods.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let coordinate = locations.last?.coordinate else {
            assertionFailure("Invalid coordinate.")
            return
        }
        
        print("\(points.count)")
        points.append(coordinate)
        
        let geodesic = MKPolyline(coordinates: points, count: points.count)
        mainMapView.add(geodesic)
        
        let dataManager = DataManager()
        
        if isReport {
            dataManager.dataSender(lat: "\(coordinate.latitude)",lon: "\(coordinate.longitude)")
        }
        
    }
    
    
}

extension DetailViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline{
            let renderer = MKPolylineRenderer(overlay: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 3.0
            return renderer
        }
        fatalError("Something wrong...")
    }
}




