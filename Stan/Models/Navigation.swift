//
//  Navigation.swift
//  Stan
//
//  Created by Tayson Nguyen on 2023-12-14.
//

import Foundation

class Navigation<Path, Modal>: ObservableObject {
    @Published var path: [Path] = []
    @Published var modal: Modal?
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeAll()
    }
    
    func dismissModal() {
        modal = nil
    }
}
