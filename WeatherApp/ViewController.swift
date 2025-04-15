//
//  ViewController.swift
//  WeatherApp
//
//  Created by Gouravdeep Singh on 2025-04-15.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    // MARK: - Outlets
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    @IBOutlet weak var celsiusButton: UIButton!
    @IBOutlet weak var fahrenheitButton: UIButton!

    // MARK: - Variables
    let locationManager = CLLocationManager()
    var isCelsius: Bool = true
    var searchedCities: [WeatherResponse] = []

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cityTextField.delegate = self
        setupButtons()
    }

    func setupButtons() {
        celsiusButton.layer.cornerRadius = 8
        fahrenheitButton.layer.cornerRadius = 8
        highlightSelectedButton()
    }

    // MARK: - IBActions
    @IBAction func searchTapped(_ sender: UIButton) {
        if let city = cityTextField.text, !city.isEmpty {
            fetchWeather(for: city)
            cityTextField.resignFirstResponder()
        }
    }

    @IBAction func locationTapped(_ sender: UIButton) {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    @IBAction func useCelsiusTapped(_ sender: UIButton) {
        isCelsius = true
        updateTemperatureDisplay()
        highlightSelectedButton()
    }

    @IBAction func useFahrenheitTapped(_ sender: UIButton) {
        isCelsius = false
        updateTemperatureDisplay()
        highlightSelectedButton()
    }

    // MARK: - Highlight Unit Buttons
    func highlightSelectedButton() {
        if isCelsius {
            celsiusButton.backgroundColor = .systemBlue
            celsiusButton.setTitleColor(.white, for: .normal)
            fahrenheitButton.backgroundColor = .clear
            fahrenheitButton.setTitleColor(.systemBlue, for: .normal)
        } else {
            fahrenheitButton.backgroundColor = .systemBlue
            fahrenheitButton.setTitleColor(.white, for: .normal)
            celsiusButton.backgroundColor = .clear
            celsiusButton.setTitleColor(.systemBlue, for: .normal)
        }
    }

    // MARK: - Location Manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let city = placemarks?.first?.locality {
                    self.fetchWeather(for: city)
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }

    // MARK: - API Call
    func fetchWeather(for city: String) {
        let apiKey = "YOUR_API_KEY"  // Replace with your actual API key
        let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(city)"
        
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.updateUI(with: weather)
                    self.searchedCities.append(weather)
                }
            } catch {
                print("JSON error: \(error)")
            }
        }.resume()
    }

    // MARK: - Update UI
    func updateUI(with weather: WeatherResponse) {
        cityLabel.text = weather.location.name
        conditionLabel.text = weather.current.condition.text
        temperatureLabel.text = isCelsius ?
            "\(weather.current.temp_c)°C" :
            "\(weather.current.temp_f)°F"
        weatherImageView.image = getSymbolFor(conditionCode: weather.current.condition.code)
    }

    func updateTemperatureDisplay() {
        if let last = searchedCities.last {
            temperatureLabel.text = isCelsius ?
                "\(last.current.temp_c)°C" :
                "\(last.current.temp_f)°F"
        }
    }

    // MARK: - SF Symbols
    func getSymbolFor(conditionCode: Int) -> UIImage? {
        switch conditionCode {
        case 1000: return UIImage(systemName: "sun.max.fill")?.withTintColor(.orange, renderingMode: .alwaysOriginal)
        case 1003: return UIImage(systemName: "cloud.sun.fill")?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        case 1006: return UIImage(systemName: "cloud.fill")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        default: return UIImage(systemName: "questionmark")?.withTintColor(.red, renderingMode: .alwaysOriginal)
        }
    }

    // MARK: - Keyboard Return Key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTapped(UIButton())
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCities" {
            if let destination = segue.destination as? CitiesViewController {
                destination.weatherData = self.searchedCities
                destination.isCelsius = self.isCelsius
            }
        }
    }
}
