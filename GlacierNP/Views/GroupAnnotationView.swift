//
//  GroupAnnotationView.swift
//  GlacierNP
//
//  Created by Ken Torimaru on 12/13/19.
//  Copyright © 2019 Torimaru & Williamson, LLC. All rights reserved.
//

import MapKit

/// - Tag: ClusterAnnotationView
class GroupAnnotationView: MKAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
    }
    
    // Required never used
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()
        if let cluster = annotation as? MKClusterAnnotation {
            let count = cluster.memberAnnotations.count
            image = drawCount(count)
        } else {
            // We should never get here but just in case.
            image = UIImage(named: "Group")
        }
    }
    
    /**
     Creates the icon used when clustering campers
        - Parameters:
            - count: The number of campers in the cluster
        - Returns: UIImage Icon
     */
    private func drawCount(_ count: Int) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 30))
        return renderer.image { _ in
            UIColor.black.setStroke()
            let headPath = UIBezierPath()
            headPath.lineWidth = 2
            headPath.addArc(withCenter: CGPoint(x: 15, y: 9),
                            radius: 6,
                            startAngle: 0,
                            endAngle: 10,
                            clockwise: true)
            headPath.stroke()
            let bodyPath = UIBezierPath()
            bodyPath.lineWidth = 2
            bodyPath.addArc(withCenter: CGPoint(x: 15, y: 25), radius: 10,
                           startAngle: 0, endAngle: 3.15,
                           clockwise: false)
            bodyPath.stroke()
            // Draw count text vertically and horizontally centered
            let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                               NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
            let text = "\(count)"
            let size = text.size(withAttributes: attributes)
            let rect = CGRect(x: 15 - size.width / 2, y: (15 - size.height / 2) + 9, width: size.width, height: size.height)
            text.draw(in: rect, withAttributes: attributes)
        }
    }

}
