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
    
    @Binding var text: String
    @Binding var value: Double?
    
    // swiftUI modifiers
    var textColor: Color? = .none
    var keyboardType: UIKeyboardType? = .default
    
    // formater
    var formatter: Formatter? = nil
    
    /// Store the formatted "value" as string
    private var realText = ""
    private var isValue: Bool = false
    
    let onCancel: (() -> Void)? = nil
    let onDone: (() -> Void)? = nil
    
    init(text: Binding<String>, textColor: Color? = .secondary, formatter: Formatter? = nil, keyboardType: UIKeyboardType? = .default) {
        self._text = text
        self._value = .constant(nil)
        self.textColor = textColor
        self.keyboardType = keyboardType
        self.formatter = formatter
    }
    
    init(value: Binding<Double?>, format: NumberFormatter.Style, formatter: Formatter? = nil, textColor: Color? = .secondary, keyboardType: UIKeyboardType? = .decimalPad) {
        self._value = value
        self._text = .constant("")
        self.textColor = textColor
        self.keyboardType = keyboardType
        
        self.formatter = formatter ?? NumberFormatter()
        
        // default configuration if no formatter is provided
        if formatter == nil {
            let numFormatter = self.formatter as! NumberFormatter
            numFormatter.numberStyle = format
        }
        
        self.isValue = true
    }
    
    func makeUIView(context: Context) -> UITextField {
        
        let textField = UITextField()
        
        // textfield
        textField.textColor = UIColor(textColor!)
        textField.keyboardType = keyboardType!
        
        textField.delegate = context.coordinator
        
        // toolbars
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        
        toolbar.items = [
            UIBarButtonItem(title: "Cancel", style: .plain, target: context.coordinator, action: #selector(context.coordinator.onCancel(_:))),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: context.coordinator, action: #selector(context.coordinator.onDone(_:)))
        ]
        toolbar.sizeToFit()
        
        // add toolbar above textField
        textField.inputAccessoryView = toolbar
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField
        
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
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            //            resetTextField(textField)
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            // The delete key being pressed always has an NSRange length of one. [View source](https://gist.github.com/justin/2288837)
            let isDeleteKey = (range.length == 1)
            let isDeletingTheFirstCharacter = (range.location == 0) && (range.length == 1) && (isDeleteKey == true)
            
            // If delete is pressed
            if isDeleteKey {
                
                if parent.isValue { parent.realText.removeLast() }
                else { parent.text.removeLast() }
                
                if isDeletingTheFirstCharacter {
                    let fieldHasOnlyEmptyLine = textField.text?.isEmpty ?? true
                    if fieldHasOnlyEmptyLine {
                        textField.resignFirstResponder()
                        return false
                    }
                    else
                    {
                        textField.text = .none;
                        return false
                    }
                }
            }
            
            // Check whether the string is parseable to NSNumber for value
            if parent.isValue && isDeleteKey == false {
                parent.realText = (parent.realText) + string
                
                // do format and validate.
                // if fail to format, clear the textfield.
                if Double(parent.realText) == nil {
                    parent.realText = ""
                    return false
                }
                
                // convert to double
                parent.value = Double(parent.realText) ?? 0.0
            }
            
            // Else, just append string to "text"
            parent.text = parent.text + string
            
            return true
        }
        
        func textFieldShouldClear(_ textField: UITextField) -> Bool {
            resetTextField(textField)
            return true
        }
        
        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            
            // To handle "CUT"
            if textField.text?.isEmpty == true {
                parent.text = ""
            }
            
            if let formatter = parent.formatter as? NumberFormatter {
                
                // make sure "value" is provided to continue
                guard let value = parent.value else { return true }
                
                // format "value"
                let formattedNumber = formatter.string(from: NSNumber(value: value)) ?? ""
                print("VAL: \(value)")
                print("formattedNumber: \(formattedNumber)")
                parent.realText = formattedNumber
                textField.text = formattedNumber
                textField.resignFirstResponder()
                
                return true
            }
            
            return true
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        private func resetTextField(_ textField: UITextField) {
            parent.realText = ""
            parent.text = ""
            parent.value = nil
            
            textField.text = ""
        }
    }
    
}
