//
//  ShortFormsView.swift
//  GlacierNP
//
//  Created by Ken Torimaru on 12/16/19.
//  Copyright © 2019 Torimaru & Williamson, LLC. All rights reserved.
//

import SwiftUI
/// Used for the modal form for modifying annotations
/// Two forms are on a single page because SwiftUI didn't like individual pages
/// The inactive form is hidden by changing it's frame height to 0
struct QuickFormsView: View {
    @EnvironmentObject var dataManager: DataManager
    @State var name: String = ""
    @State var descript: String = ""
    @State var open: Bool = true
    var body: some View {
        return GeometryReader { geometry in
            VStack(alignment: .center) {
                Form {
                    Text("Move a Campground").font(.title).frame(width: geometry.size.width)
                    Button(action: {
                        self.dataManager.alert = false
                        let camp = Campground(
                            id: self.dataManager.startAnnotation!.id!,
                            name: self.dataManager.startAnnotation!.title!,
                            latitude: self.dataManager.dragCoordinates?.latitude ?? 0,
                            longitude: self.dataManager.dragCoordinates?.longitude ?? 0,
                            descript: self.dataManager.startAnnotation!.subtitle!,
                            open: self.dataManager.startAnnotation!.open!)
                        self.dataManager.campgrounds.append(camp)
                        self.dataManager.saveCampgroundChanges()
                    } ) {
                        Text("Save").font(.title)
                    }
                    Button(action: {
                        self.dataManager.alert = false
                        let camp = Campground(
                            id: self.dataManager.startAnnotation!.id!,
                            name: self.dataManager.startAnnotation!.title!,
                            latitude: self.dataManager.startCoordinates?.latitude ?? 0,
                            longitude: self.dataManager.startCoordinates?.longitude ?? 0,
                            descript: self.dataManager.startAnnotation!.subtitle!,
                            open: self.dataManager.startAnnotation!.open!)
                        self.dataManager.campgrounds.append(camp)
                        self.dataManager.saveCampgroundChanges()
                    } ) {
                        Text("Cancel").foregroundColor(.red)
                    }
                }.frame(width: geometry.size.width , height: (self.dataManager.alertType != .move ? 0 : geometry.size.height ), alignment: .bottom)
                Form {
                    Text("A New Campground").font(.title).frame(width: geometry.size.width)
                    TextField("Name", text: self.$name)
                    TextField("Description", text: self.$descript)
                    Toggle("Open", isOn: self.$open)
                    Button(action: {
                        self.dataManager.alert = false
                        let camp = Campground(id: UUID().uuidString, name: self.name, latitude: self.dataManager.dragCoordinates?.latitude ?? 0, longitude: self.dataManager.dragCoordinates?.longitude ?? 0, descript: self.descript, open: self.open)
                        self.dataManager.campgrounds.append(camp)
                        
                        self.dataManager.saveCampgroundChanges()
                    } ) {
                        Text("Save").font(.title).disabled(!(self.name != "" && self.descript != ""))
                    }
                    Button(action: {
                        self.dataManager.alert = false
                    } ) {
                        Text("Cancel").foregroundColor(.red)
                    }
                }.frame(width: geometry.size.width , height: (self.dataManager.alertType != .newCamp ? 0 : geometry.size.height), alignment: .bottom)
            }
        }
    }
}

struct QuickFormsView_Previews: PreviewProvider {
    static var previews: some View {
        QuickFormsView()
    }
}
