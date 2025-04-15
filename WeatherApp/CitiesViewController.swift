//
//  CitiesViewController.swift
//  WeatherApp
//
//  Created by Gouravdeep Singh on 2025-04-15.
//

import UIKit

class CitiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var weatherData: [WeatherResponse] = []
    var isCelsius: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = weatherData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath)
        let temp = isCelsius ? "\(data.current.temp_c)°C" : "\(data.current.temp_f)°F"
        cell.textLabel?.text = "\(data.location.name) - \(temp)"
        cell.imageView?.image = getSymbolFor(conditionCode: data.current.condition.code)
        return cell
    }

    func getSymbolFor(conditionCode: Int) -> UIImage? {
        switch conditionCode {
        case 1000: return UIImage(systemName: "sun.max.fill")?.withTintColor(.orange, renderingMode: .alwaysOriginal)
        case 1003: return UIImage(systemName: "cloud.sun.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        case 1006: return UIImage(systemName: "cloud.fill")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        default: return UIImage(systemName: "questionmark.circle.fill")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        }
    }
}
