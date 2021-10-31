//
//  ViewController.swift
//  GeoWeather
//
//  Created by apple on 28/03/2019.
//  Copyright © 2019 DAN. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class GeoWeatherViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        determineMyCurrentLocation()
    }
    
    
    
    let locationManager = CLLocationManager()
    lazy var geocoder = CLGeocoder()
    lazy var weatherManager = APIWeatherManager(apiKey: "")
    var latitude = 0
    var longitude = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        determineMyCurrentLocation()
    }
    
    
    func getCurrentWeatherData() {
        let coordinates = Coordinates(latitude: latitude, longitude: longitude)
        weatherManager.fetchCurrentWeatherWith(coordinates: coordinates) { [weak self] (result) in
            switch result {
            case .Success(let currentWeather):
                self?.updateUIWith(currentWeather: currentWeather)
                self?.saveRequest()
            case .Failure(let error as NSError):
                let alertController = UIAlertController(title: "Unable to get data", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self?.present(alertController,animated: true, completion: nil)
            }
        }
    }
    
    
    
    func determineMyCurrentLocation() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.distanceFilter = 10
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            latitude = location.coordinate.latitude
            longitude = location.coordinate.longitude
            let location = CLLocation(latitude: latitude, longitude: longitude)
            geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
                self?.processResponse(withPlacemarks: placemarks, error: error)
            }
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")
            locationLabel.text = "Unable to Find Address for Location"
            
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                getCurrentWeatherData()
                locationLabel.text = placemark.compactAddress
            } else {
                locationLabel.text = "No matching addresses found,try again"
            }
        }
    }
    
    func updateUIWith(currentWeather: CurrentWeather) {
        self.imageView.image = currentWeather.icon
        self.temperatureLabel.text = currentWeather.temperatureString
        self.descriptionLabel.text = currentWeather.summary
        coordinatesLabel.text = "\(latitude)˚ , \(longitude)˚"

    }
    
    func saveRequest() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "History", in: context)
        let requestObject = NSManagedObject(entity: entity!, insertInto: context) as! History
        
        var currentDate : String {
            let formatter = DateFormatter()
            formatter.dateFormat = "d.M.y hh:mm"
            let date = formatter.string(from: Date())
            return date
        }
        
        requestObject.coordinates = self.coordinatesLabel.text
        requestObject.adress = self.locationLabel.text
        requestObject.summary = self.descriptionLabel.text
        requestObject.temperature = self.temperatureLabel.text
        requestObject.date = currentDate
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
   
    
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Location Access Disabled",
                                                message: "In order to check weather we need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}


extension CLPlacemark {
    var compactAddress: String? {
        if let name = name {
            var result = name
            if let city = locality {
                result += ", \(city)"
            }
            return result
        }
        return nil
    }
}
