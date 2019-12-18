//
//  DataManager.swift
//  GlacierNP
//
//  Created by Ken Torimaru on 12/11/19.
//  Copyright © 2019 Torimaru & Williamson, LLC. All rights reserved.
//

import Foundation
import Combine
import UIKit
import MapKit

enum AlertType {
    case move
    case newCamp
}
/// Manages the data and state of the app
class DataManager: ObservableObject {
    var willChange: PassthroughSubject<Void, Never> = PassthroughSubject<Void, Never>()
    typealias PublisherType = PassthroughSubject<Void, Never>
    
    @Published var campgrounds = [Campground]()
    @Published var campers = [Camper]()
    @Published var alert = false
    @Published var action = false
    var activeCampgroundId: String?
    var alertType: AlertType = .move
    var startAnnotation: CampgroundAnnotation?
    var startCoordinates: CLLocationCoordinate2D?
    var dragCoordinates: CLLocationCoordinate2D?
    let cgAPI: CampgroundAPI

    
    init() {
        //Load the cqmpgrounds
        cgAPI = CampgroundAPI()
        campgrounds = cgAPI.getCampgrounds()

        //Seed the app with 11 campers
        for _ in 0...10 {
            campers.append(Camper(campgrounds[Int.random(in: 0..<campgrounds.count)]))
        }
        // Add a new camper every 30 seconds
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self!.campers.append(Camper(self!.campgrounds[Int.random(in: 0..<self!.campgrounds.count)]))
        }
    }

    /**
     Action fired to update the data store
        Toggles a campground's Open or Closed state
        this toggles the state
        - Parameters:
            - id: the campground's id
        - returns: void
     */
    func toggleOpen(id: String)  {
        if let index = campgrounds.firstIndex(where: {$0.id == id}) {
            campgrounds[index].open.toggle()
        }
    }

    /**
     Action fired to update the data store
        Removes a campground from the data store
        this triggers an update cycle
        - Parameters:
            - id: the campground's id
        - returns: void
     */
    func removeCampground(id: String)  {
        if let index = campgrounds.firstIndex(where: {$0.id == id}) {
            campgrounds.remove(at: index)
        }
    }

    /**
     Action fired to update the data store
        Writes the data store into the document directory
        - Parameters:
            - campgrounds: the list of campgrounds
        - returns: void
     */
    func saveCampgroundChanges() {
        cgAPI.encode(campgrounds: campgrounds) 
    }
}
