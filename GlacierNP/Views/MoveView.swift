//
//  MoveView.swift
//  GlacierNP
//
//  Created by Ken Torimaru on 12/16/19.
//  Copyright © 2019 Torimaru & Williamson, LLC. All rights reserved.
//

import SwiftUI

struct ShortFormViews: View {
    @EnvironmentObject var dataManager: DataManager
    var body: some View {
        switch self.dataManager.alertType {
        case .move:
            return VStack {
                Text("Moving a Campground")
                Text("Are you sure?")
                Button("Save") {
                    print("Save")
                }
                Button("Cancel") {
                    print("Cancel")
                }
            }
        case .newCamp:
            return VStack {
                Text("New Campground")
                Text("Are you sure?")
                
                Button("Save") {
                    print("Save")
                }
                Button("Cancel") {
                    print("Cancel")
                }
            }
        case .close:
            return VStack {
                Text("Close")
                Text("Are you sure?")
                Button("Save") {
                    print("Save")
                }
                Button("Cancel") {
                    print("Cancel")
                }
            }
        }
    }
}

struct ShortFormViews_Previews: PreviewProvider {
    static var previews: some View {
        ShortFormViews()
    }
}
