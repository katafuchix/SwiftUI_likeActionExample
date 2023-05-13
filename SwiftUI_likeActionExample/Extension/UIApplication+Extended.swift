//
//  UIApplication+Extended.swift
//  SwiftUI_likeActionExample
//
//  Created by cano on 2023/05/13.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
