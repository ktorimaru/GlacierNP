//
//  API.swift
//  GlacierNP
//
//  Created by Ken Torimaru on 12/12/19.
//  Copyright © 2019 Torimaru & Williamson, LLC. All rights reserved.
//

import Foundation


class API: NSObject {
    
    /**
     Basic method for opening a json file from the bundle and creating dictionary
        This is easier to use for hand created json
        - Parameters:
            - fileName: name of the file
        - returns: a dictionary
     */
    func open (fileName: String) -> [String: Any]? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                let datafile = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                if let json = try? JSONSerialization.jsonObject(with: datafile, options: []) as? [String: Any] {
                    return json
                }
            } catch {
                print("error")
                return nil
            }
        }
        return nil
    }
    
}
