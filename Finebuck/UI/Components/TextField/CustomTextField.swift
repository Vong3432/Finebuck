//
//  CustomTextField.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 27/04/2022.
//

import Foundation
import SwiftUI


struct CustomTextField: UIViewRepresentable{
    typealias UIViewType = UITextField
    
    var text: Binding<String>? = nil
    var value: Binding<Double?>? = nil
    
    let onCancel: (() -> Void)? = nil
    let onDone: (() -> Void)? = nil
    
    var formatter: Formatter? = nil
    
    init(text: Binding<String>) {
        self.text = text
    }
    
    init<F>(value: Binding<Double?>, format: F) where F : ParseableFormatStyle, F.FormatOutput == String {
        self.value = value
        
        formatter = NumberFormatter()
        
        if let formatter = formatter as? NumberFormatter {
            if let numberStyle = format as? NumberFormatter.Style {
                formatter.numberStyle = numberStyle
            }
            
        }
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: context.coordinator, action: #selector(context.coordinator.onCancel(_:))),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: context.coordinator, action: #selector(context.coordinator.onDone(_:)))
        ]
        toolbar.sizeToFit()
        
        textField.inputAccessoryView = toolbar
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if let text = text {
            uiView.text = text.wrappedValue
        } else if let value = value {
            uiView.text = formatter?.string(for: value)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        let parent: CustomTextField
        
        init(_ parent: CustomTextField) {
            self.parent = parent
        }
        
        @objc func onDone(_ sender : UIButton) {
            UIApplication.shared.endEditing()
            if let onDone = parent.onDone {
                onDone()
            }
        }
        
        @objc func onCancel(_ sender : UIButton) {
            UIApplication.shared.endEditing()
            if let onCancel = parent.onCancel {
                onCancel()
            }
        }
    }
    
}
