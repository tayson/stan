//
//  StanApp.swift
//  Stan
//
//  Created by Tayson Nguyen on 2023-12-13.
//

import SwiftUI

@main
struct StanApp: App {    
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environmentObject(ModelStore())
        }
    }
}
