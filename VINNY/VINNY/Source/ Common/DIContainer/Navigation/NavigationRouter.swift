//
//  NavigationRouter.swift
//  VINNY
//
//  Created by 홍지우 on 6/25/25.
//

import Foundation

protocol NavigationRoutable {
    var destinations: [NavigationDestination] { get set }

    func push(to: NavigationDestination)
    func pop()
    func popToRoot()
    func hardReset(to: NavigationDestination) // hard reset + single destination
}

@Observable
class NavigationRouter: NavigationRoutable {
    var destinations: [NavigationDestination] = []
    
    func push(to destination : NavigationDestination) {
        destinations.append(destination)
    }
    
    func pop() {
        if !destinations.isEmpty { destinations.removeLast() }
    }
    
    func popToRoot() {
        destinations = [.VinnyTabView]
    }
    
    /// Backward-compatible API: respects allowGlobalReset gate
    func hardReset(to destination: NavigationDestination) {
        destinations.removeAll()
        destinations = [destination]
    }
}
