//
//  ContentView.swift
//  GlacierNP
//
//  Created by Ken Torimaru on 12/10/19.
//  Copyright © 2019 Torimaru & Williamson, LLC. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: DataManager
    var body: some View {
        return NavigationView {
            MapView()
            .navigationBarTitle("Glacier National Park", displayMode: .inline)
            .sheet(isPresented: $dataManager.alert) {
                QuickFormsView().environmentObject(self.dataManager)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
