//
//  WeatherResponse.swift
//  WeatherApp
//
//  Created by Gouravdeep Singh on 2025-04-15.
//

import Foundation

struct WeatherResponse: Codable {
    let location: Location
    let current: Current
}

struct Location: Codable {
    let name: String
}

struct Current: Codable {
    let temp_c: Double
    let temp_f: Double
    let condition: Condition
}

struct Condition: Codable {
    let text: String
    let code: Int
}
