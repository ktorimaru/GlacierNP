//
//  Errors.swift
//  GlacierNP
//
//  Created by Ken Torimaru on 12/12/19.
//  Copyright © 2019 Torimaru & Williamson, LLC. All rights reserved.
//

import Foundation

enum DataError: Error {
    case missingData
    case missingRequiredField(name: String)
    case invalidExpirationDate
}
