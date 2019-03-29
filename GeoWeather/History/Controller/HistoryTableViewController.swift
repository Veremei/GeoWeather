//
//  HistoryTableViewController.swift
//  GeoWeather
//
//  Created by apple on 29/03/2019.
//  Copyright © 2019 DAN. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController {
    
    var array = [History]()
    var detailLocation : History?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
        
        do {
            array = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let customCell = cell as? HistoryCell {
            let location = array[indexPath.row]
            customCell.icon.image = UIImage(named: "watches")
            customCell.adressLabel.text = location.adress
            customCell.dateLabel.text = location.date
            customCell.coordinatesLabel.text = location.coordinates
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = array[indexPath.row]
        detailLocation = location
        performSegue(withIdentifier: "detailSegue", sender: location)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailSegue") {
            if let detailVC = segue.destination as? DetailViewController {
                detailVC.detailData = detailLocation
            }
        }
    }
}
