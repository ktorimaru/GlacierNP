//
//  CampgroundAPI.swift
//  GlacierNP
//
//  Created by Ken Torimaru on 12/12/19.
//  Copyright © 2019 Torimaru & Williamson, LLC. All rights reserved.
//

import Foundation

class CampgroundAPI: API {
    private struct Endpoints {
        static let campground = "Campground"
    }
    private let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    /**
     Get the bundled json file and put the data in the campground array
        - Parameters:
        - returns: a dictionary
     */
    func getBundledCampgrounds() -> [Campground] {
        var campgrounds = [Campground]()
        if let json = open(fileName: Endpoints.campground) {
            if let grounds = json["campgrounds"] as? [[String: Any]] {
                for camp in grounds {
                    if let tempCamper = try? Campground(data: camp) {
                        campgrounds.append(tempCamper)
                    }
                }
            }
        }
        return campgrounds
    }

    /**
     Get the campground data from the document directory
        if it does not exist then get it from the main bundle
        - Parameters:
        - returns: the campground array
     */
    func getCampgrounds() -> [Campground] {
        var campgrounds = [Campground]()
        do {
            // Load the stored data
            let path = documentDirectoryUrl!.appendingPathComponent("data.json")
            let datafile = try Data(contentsOf: path, options: .mappedIfSafe)
            let decoder = JSONDecoder()
            let json = try decoder.decode(Array<Campground>.self, from: datafile)
            return json
        } catch {
            print(error)
            // Get the bundled starting data
            campgrounds = getBundledCampgrounds()
            // store it in the document directory
            encode(campgrounds: campgrounds)
        }
        return campgrounds
    }

    /**
     Write the campground data into the document directoy as json
        - Parameters:
             - campgrounds: the Campground array
        - returns: void
     */
    func encode(campgrounds: [Campground]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(campgrounds)
            let path = documentDirectoryUrl!.appendingPathComponent("data.json")
            try data.write(to: path)
        } catch {
            print("Whoops, an error occured: \(error)")
        }
    }
}
