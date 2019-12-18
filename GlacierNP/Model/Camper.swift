//
//  Camper.swift
//  GlacierNP
//
//  Created by Ken Torimaru on 12/12/19.
//  Copyright © 2019 Torimaru & Williamson, LLC. All rights reserved.
//

import Foundation

class Camper {
    struct Keys {
        static let id = "id"
        static let name = "name"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let description = "description"
        static let phone = "phone"
    }

    var id: String
    var name: String
    var latitude: Double
    var longitude: Double
    var description: String
    var phone: String

    /// Creates a fictional camper vaugely associated with a campground
    init(_ camp: Campground) {
        self.id = UUID().uuidString
        self.name = "\(Names.name[Int.random(in: 0..<26)]) \(Names.name[Int.random(in: 0..<26)])"
        self.latitude = camp.latitude + (Bool.random() ? Double.random(in: 0.01..<0.08) : -Double.random(in: 0.01..<0.08))
        self.longitude = camp.longitude + (Bool.random() ? Double.random(in: 0.01..<0.08) : -Double.random(in: 0.01..<0.08))
        self.phone = "(\(Int.random(in: 300..<1000))) \(Int.random(in: 300..<1000))-\(Int.random(in: 1000..<10000))"
        self.description = "A \(Stature.name[Int.random(in: 0..<8)]) \(Sex.name[Int.random(in: 0..<2)]) in \(Color.name[Int.random(in: 0..<7)]) \(Clothes.name[Int.random(in: 0..<8)])"
    }

}
