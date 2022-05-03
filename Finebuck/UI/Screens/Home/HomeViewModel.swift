//
//  HomeViewModel.swift
//  Finebuck
//
//  Created by Vong Nyuksoon on 03/05/2022.
//

import Foundation

extension HomeView {
    class HomeViewModel: ObservableObject {
        let dataService: BudgetsDataServiceProtocol
        
        init(dataService: BudgetsDataServiceProtocol) {
            self.dataService = dataService
        }
    }
}