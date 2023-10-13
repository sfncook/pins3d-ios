//
//  AnnotatingMachineViewViewModel.swift
//  Pins3D
//
//  Created by Shawn Cook on 10/12/23.
//

import SwiftUI
import ARKit

class AnnotatingMachineViewViewModel: ObservableObject {
    var machine: Machine
    
    init(machine: Machine) {
        self.machine = machine
    }
}
