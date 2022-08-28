//
//  MyDropDelegate.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 08/08/2022.
//

import Foundation
import SwiftUI

struct MyDropDelegate<T>: DropDelegate where T: Equatable {
    let item : T
    @Binding var items : [T]
    @Binding var draggedItem : T?
    let completion: ((Int, Int) -> Void)?
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else {
            return
        }
        if draggedItem != item {
            let from = items.firstIndex(of: draggedItem)!
            let to = items.firstIndex(of: item)!
            withAnimation(.default) {
                self.items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
                completion?(from, to)
            }
        }
    }
}
