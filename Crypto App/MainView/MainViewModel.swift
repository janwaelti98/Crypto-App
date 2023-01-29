import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    
    let model = MainModel()
    
    @Published var coinList: [Coin] = []
    @Published var filterOption: FilterOption = .name
    
    // MARK: - FilterOption
    
    enum FilterOption{
        case name, namereversed, marketCap, marketCapReversed, price, priceReversed
    }
    
    // MARK: - loadCoins
    
    func loadCoins() async {
        Task{
            do{
                let coins = try await model.fetchCoins()
                DispatchQueue.main.async {
                    self.coinList = coins
                }
            }
        }
    }
    
    // MARK: - sortCoins
    
    func sortCoins(coinList:[Coin], sort: FilterOption){
        switch sort{
        case .name:
            self.coinList.sort(by: {$0.name.lowercased() < $1.name.lowercased()})
        case .namereversed:
            self.coinList.sort(by: {$0.name.lowercased() > $1.name.lowercased()})
        case .marketCap:
            self.coinList.sort(by: {$0.marketCap < $1.marketCap})
        case .marketCapReversed:
            self.coinList.sort(by: {$0.marketCap > $1.marketCap})
        case .price:
            self.coinList.sort(by: {$0.currentPrice < $1.currentPrice})
        case .priceReversed:
            self.coinList.sort (by: {$0.currentPrice > $1.currentPrice})
        }
    }
}
