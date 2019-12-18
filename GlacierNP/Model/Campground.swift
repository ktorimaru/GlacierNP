//
//  Campground.swift
//  GlacierNP
//
//  Created by Ken Torimaru on 12/12/19.
//  Copyright © 2019 Torimaru & Williamson, LLC. All rights reserved.
//

import Foundation

class Campground: Codable {
    struct Keys {
        static let id = "id"
        static let name = "name"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let descript = "descript"
        static let open = "open"
    }

    var id: String
    var name: String
    var latitude: Double
    var longitude: Double
    var descript: String
    var open: Bool

    required init(data: [String: Any]) throws {
        guard let id = data[Keys.id] as? String else {
            throw DataError.missingRequiredField(name: Keys.id)
        }

        guard let name = data[Keys.name] as? String else {
            throw DataError.missingRequiredField(name: Keys.name)
        }
        guard let latitude = data[Keys.latitude] as? NSNumber else {
            throw DataError.missingRequiredField(name: Keys.latitude)
        }
        guard let longitude = data[Keys.longitude] as? NSNumber else {
            throw DataError.missingRequiredField(name: Keys.longitude)
        }
        guard let descript = data[Keys.descript] as? String else {
            throw DataError.missingRequiredField(name: Keys.descript)
        }
        guard let open = data[Keys.open] as? Bool else {
            throw DataError.missingRequiredField(name: Keys.open)
        }

        self.id = id
        self.name = name
        self.latitude = latitude.doubleValue
        self.longitude = longitude.doubleValue
        self.descript = descript
        self.open = open
    }
    
    init(id: String, name: String, latitude: Double, longitude: Double, descript: String, open: Bool) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.descript = descript
        self.open = open
    }
}
