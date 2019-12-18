//
//  MKAnnotationView+Multiline.swift
//  GlacierNP
//
//  Created by Ken Torimaru on 12/13/19.
//  Copyright © 2019 Torimaru & Williamson, LLC. All rights reserved.
//

import MapKit

// Provides multi-line functionality to annotations
extension MKAnnotationView {

    func loadCustomLines(customLines: [String]) {
        let stackView = self.stackView()
        for line in customLines {
            let label = UILabel()
            label.text = line
            stackView.addArrangedSubview(label)
        }
        self.detailCalloutAccessoryView = stackView
    }

    private func stackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }
}
