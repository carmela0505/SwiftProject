//
//  TESTINGApp.swift
//  TESTING
//
//  Created by apprenant130 on 13/09/2025.
//

import SwiftUI

@main
struct TESTINGApp: App {
    init() {
        let d = UserDefaults.standard
        if let old = d.string(forKey: "childName"),
           d.string(forKey: "prenomEnfant")?.isEmpty ?? true {
            d.set(old, forKey: "prenomEnfant")
            d.removeObject(forKey: "childName")
        }
    }

    var body: some Scene {
        WindowGroup {
            ThemesTabContainer()
        }
    }
}
