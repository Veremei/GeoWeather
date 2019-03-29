//
//  DetailViewController.swift
//  GeoWeather
//
//  Created by apple on 29/03/2019.
//  Copyright © 2019 DAN. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var adressLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    
    var detailData : History?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    func configureUI() {
        guard let data = detailData else { return }
        dateLabel.text = data.date
        coordinatesLabel.text = data.coordinates
        adressLabel.text = data.adress
        temperatureLabel.text = data.temperature
        summaryLabel.text = data.summary
    }
   

}
