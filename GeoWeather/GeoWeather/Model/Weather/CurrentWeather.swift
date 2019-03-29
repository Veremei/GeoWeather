//
//  CurrentWeather.swift
//  GeoWeather
//
//  Created by apple on 28/03/2019.
//  Copyright © 2019 DAN. All rights reserved.
//

import Foundation
import UIKit

struct CurrentWeather {
    let temperature: Double
    let summary: String
    let icon: UIImage
}

extension CurrentWeather : JSONDecodable {
    init?(JSON: [String : AnyObject]) {
        
        guard let temperature = JSON["temperature"] as? Double,
            let summary = JSON["summary"] as? String,
            let iconString = JSON["icon"] as? String else {
                return nil
        }
        
        let icon = WeatherIconManager(rawValue: iconString).image
        self.temperature = temperature
        self.summary = summary
        self.icon = icon
    }
}

extension CurrentWeather {
    var temperatureString: String {
        return "\(Int(5 / 9 * (temperature - 32)))˚C"
    }
}
