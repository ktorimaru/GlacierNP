//
//  MapView.swift
//  GlacierNP
//
//  Created by Ken Torimaru on 12/11/19.
//  Copyright © 2019 Torimaru & Williamson, LLC. All rights reserved.
//

import SwiftUI
import MapKit
import UIKit

struct MapView: UIViewRepresentable {
    @EnvironmentObject var dataManager: DataManager
    let map = MKMapView(frame: .zero)

    // This is a workaround for a bug in UIViewRepresentable
    class RandomClass { }
    let xray = RandomClass()
    // End workaround for a bug in UIViewRepresentable

    /**
     UIViewRepresentable protocol Method
     Creates the underlying UIView
        - Parameters:
            - context: the map view
        - Returns: MKMapView
     */
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        // Maps are hard to read in dark mode
        map.overrideUserInterfaceStyle = .light

        // Set the starting location
        let location = CLLocationCoordinate2D(latitude: 48.6063832, longitude: -113.8855648)
        let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        let region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
        map.delegate = context.coordinator
        registerMapAnnotationViews(map)
        
        // Adding the new campground gesture
        let longPress = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.longPressed(gestureRecognized:)))
        //long press (2 sec duration)
        longPress.minimumPressDuration = 2
        //add a delegate to the long press gesture
        longPress.delegate = context.coordinator
        map.addGestureRecognizer(longPress)
        
        // Add Open Street Map Tiles
        context.coordinator.addTileOverlay(mapView: map)
        
        return map
    }
    

    /**
      UIViewRepresentable protocol Method
      Updates the presented `UIView` (and coordinator) to the latest configuration.
        This is how SwiftUI triggers updates
        - Parameters:
        - context: the map view
        - Returns: MKMapView
     */
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        updateCampgroundAnnotations(uiView)
        updateCamperAnnotations(uiView)
    }

    /**
        Registers the annotation view we are using
        - Parameters:
            - uiView: the map view
     */
    private func registerMapAnnotationViews(_ uiView: MKMapView) {
        uiView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CamperAnnotation.self))
        uiView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CampgroundAnnotation.self))
        uiView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(GroupAnnotation.self))
        uiView.register(GroupAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
    }

    /**
      Clears the existing campground annotations and creates a new set
        - Parameters:
            - uiView: the map view
        - Returns: MKMapView
     */
    func updateCampgroundAnnotations(_ uiView: MKMapView) {
        let anno = uiView.annotations
        let campers = anno.compactMap { $0 as? CampgroundAnnotation }
        for camp in dataManager.campgrounds {
            // Find matching annotations
            let matchingCamper = campers.filter {$0.coordinate.latitude == camp.latitude && $0.coordinate.longitude == camp.longitude}
            // Add new annotations
            if matchingCamper.count == 0 {
                let location = CLLocationCoordinate2D(latitude: camp.latitude, longitude: camp.longitude)
                let annotation = CampgroundAnnotation()
                annotation.id = camp.id
                annotation.coordinate = location
                annotation.title = camp.name
                annotation.subtitle = camp.descript
                annotation.open = camp.open
                uiView.addAnnotation(annotation)
            }
        }
    }

    /**
      Clears the existing camper annotations and creates a new set
        - Parameters:
            - uiView: the map view
        - Returns: MKMapView
     */
    func updateCamperAnnotations(_ uiView: MKMapView) {
        let anno = uiView.annotations
        let campers = anno.compactMap { $0 as? CamperAnnotation }
        for camp in dataManager.campers {
            // Find matching annotations
            let matchingCamper = campers.filter {$0.coordinate.latitude == camp.latitude && $0.coordinate.longitude == camp.longitude}
            // Add new annotations
            if matchingCamper.count == 0 {
                let location = CLLocationCoordinate2D(latitude: camp.latitude, longitude: camp.longitude)
                let annotation = CamperAnnotation()
                annotation.coordinate = location
                annotation.title = camp.name
                annotation.subtitle = camp.description
                annotation.phone = camp.phone
                uiView.addAnnotation(annotation)
            }
        }
    }

    /// The coordinator is the mapviews delegate
    /**
     UIViewRepresentable protocol Method
     A place to instantiate helper object like a delegate object

        - Returns: the mapview's deletgate
     */
    func makeCoordinator() -> Coordinator {
         Coordinator(self)
    }

    /// The mapview's delegate
    class Coordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {
        var parent: MapView
        var tileRenderer: MKTileOverlayRenderer?

        init(_ control: MapView) {
            self.parent = control
        }
        
        /**
         MKMapView Delegate Method
         mapView:viewForAnnotation: provides the view for each annotation.
         This method may be called for all or some of the added annotations.
         For MapKit provided annotations (eg. MKUserLocation) return nil to use the MapKit provided annotation view.

            - Parameters:
                - mapView: the map view
                - annotation: the annotation the view will display
            - Returns: A custom view of the annotation
         */
        func mapView(_ mapView: MKMapView, viewFor
            annotation: MKAnnotation) -> MKAnnotationView? {
            guard !annotation.isKind(of: MKUserLocation.self) else {
                // MKUserLocation, not an annotation view to customize.
                return nil
            }
            var annotationView: MKAnnotationView?
            if let annotation = annotation as? CampgroundAnnotation {
                annotationView = createCampgroundAnnotationView(for: annotation, on: mapView)
                annotationView?.isDraggable = true
            } else if let annotation = annotation as? CamperAnnotation {
                annotationView = createCamperAnnotationView(for: annotation, on: mapView)
            }
            return annotationView
        }
        
        /**
         MKMapView Delegate Method
         Fired when dragging a campground

            - Parameters:
                - mapView: the map view
                - view: the annotation the view will display
                - newState: flag for tracking the cureent state of the method
                - oldState: flag for tracking the cureent state of the method
            - Returns: void
         */
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
            // Tell the dataManager where this started. Used when rejecting the move
            if newState == .starting {
                let startAnno = view.annotation as! CampgroundAnnotation
                parent.dataManager.startAnnotation = startAnno
                parent.dataManager.startCoordinates = startAnno.coordinate
                parent.dataManager.removeCampground(id: startAnno.id!)
            }
            // Tell the dataManager the ending location
            if newState == .ending {
                parent.dataManager.alert = true
                parent.dataManager.alertType = .move
                let anno = view.annotation as! CampgroundAnnotation
                parent.dataManager.activeCampgroundId = anno.id
                parent.dataManager.dragCoordinates = anno.coordinate
                // Remove the annotation because it will be updated when we update the data store
                parent.map.removeAnnotation(anno)
            }
        }
        
        /**
         Creates an Campground Annotation
            - Parameters:
                - mapView: the map view
                - annotation: the annotation the view will display
            - Returns: A custom view of the annotation
         */
        private func createCampgroundAnnotationView(for annotation: CampgroundAnnotation, on mapView: MKMapView) -> MKAnnotationView {
            let reuseIdentifier = NSStringFromClass(CampgroundAnnotation.self)
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
            annotationView.canShowCallout = true
            // Icon shown based on the Open or Closed state
            annotationView.image = (annotation.open! ? UIImage(named: "Campground") : UIImage(named: "Closed"))
            // Button for changing open or closed state
            let button = UIButton(type: .system)
            button.frame = CGRect(x: 0, y: 0, width: 50, height: 25)
            button.setTitle((annotation.open! ? "Close" : "Open"), for: .normal)
            button.addTarget(self, action: #selector(toggleCampgroundOpen), for: .touchUpInside)
            annotationView.rightCalloutAccessoryView = button
            return annotationView
        }
        
        /**
         Creates an Camper Annotation
            - Parameters:
                - mapView: the map view
                - annotation: the annotation the view will display
            - Returns: A custom view of the annotation
         */
        private func createCamperAnnotationView(for annotation: CamperAnnotation, on mapView: MKMapView) -> MKAnnotationView {
            let reuseIdentifier = NSStringFromClass(CamperAnnotation.self)
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
            annotationView.clusteringIdentifier = "camper"
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "Camper")
            annotationView.loadCustomLines(customLines: [(annotation.subtitle ?? ""), annotation.phone ?? ""])
            return annotationView
        }

        /**
         MKMapView Delegate Method
         mapView:rendererFor overlay: provides the tile renderer for custom tiles

            - Parameters:
                - mapView: the map view
                - overlay: the overlay to be rendered
            - Returns: A renderer
         */
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            return tileRenderer!
        }

        /**
         Creates the renderer for custom tiles
            (placed here because the delegate calls the tileRenderer, above method)
            - Parameters:
                - mapView: the map view
            - Returns: void
         */
        func addTileOverlay(mapView: MKMapView) {
            //Open Street Map tile Set
            let template = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
            // NPS Tile Set
            // For some reason these are scrambled
            /*
            let template = "https://api.mapbox.com/styles/v1/nps/cjt94v8pu23wh1fqug0cnviat/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibnBzIiwiYSI6IkdfeS1OY1UifQ.K8Qn5ojTw4RV1GwBlsci-Q" */
            let overlay = MKTileOverlay(urlTemplate: template)
            overlay.canReplaceMapContent = true
            tileRenderer = MKTileOverlayRenderer(tileOverlay: overlay)
            mapView.addOverlay(overlay, level: .aboveLabels)
        }
        
        /**
         MKMapViewDelegate method that fires upon selection
            tells the datamanager which annotation was selected
            - Parameters:
                - mapView: the map view
                - view: the view of the annotation
            - Returns: void
         */
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let anno = view.annotation as? CampgroundAnnotation {
                parent.dataManager.activeCampgroundId = anno.id
            }
        }
        
        /**
         MKMapViewDelegate method that fires upon deselection
            tells the datamanager which annotation was deselected
            - Parameters:
                - mapView: the map view
                - view: the view of the annotation
            - Returns: void
         */
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            parent.dataManager.activeCampgroundId = nil
        }
        
        /**
         Long press on the map
            Starts the process of adding a new Campground
            tells the datamanager this is a new campground and where it should be located
            - Parameters:
                - gestureRecognized: Container for location
            - Returns: void
         */
        @objc func longPressed(gestureRecognized: UIGestureRecognizer){
            if (gestureRecognized.state == .began){
                parent.dataManager.alert = true
                parent.dataManager.alertType = .newCamp

                let touchpoint = gestureRecognized.location(in: self.parent.map)
                let location = parent.map.convert(touchpoint, toCoordinateFrom: self.parent.map)
                parent.dataManager.dragCoordinates = location
              }
        }

        /**
         Action fired from a Campgrounds info flag
            Button is in an Open or Closed state
            this toggles the state
            - Parameters:
            - Returns: void
         */
        @objc func toggleCampgroundOpen(){
            // Updates the data store
            parent.dataManager.toggleOpen(id: parent.dataManager.activeCampgroundId!)
            // Finds the index of the annotation
            if let index = parent.map.annotations.firstIndex(where: {
                if let camp = $0 as? CampgroundAnnotation,
                    camp.id == parent.dataManager.activeCampgroundId {
                    return true
                }
                return false
            }) {
                // Remove the annotation, update it and add it back
                // This fires an update cycle which refreshes the icon
                let anno = parent.map.annotations[index] as! CampgroundAnnotation
                parent.map.removeAnnotation(anno)
                anno.open?.toggle()
                parent.map.addAnnotation(anno)
                parent.dataManager.saveCampgroundChanges()
            }
            
        }
        
        /// Prevents a long press on anything othe than the map from triggering a new campground
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            return touch.view == parent.map
        }

    }

    class CamperAnnotation: NSObject, MKAnnotation {
        @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        var title: String?
        var subtitle: String?
        var phone: String?
    }
    class GroupAnnotation: NSObject, MKAnnotation {
        @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        var title: String?
        var subtitle: String?
    }
}

class CampgroundAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var id: String?
    var title: String?
    var subtitle: String?
    var open: Bool?
}

#if DEBUG
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
#endif
