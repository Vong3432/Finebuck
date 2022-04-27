//
//  UIApplication.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 27/04/2022.
//

import Foundation
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
