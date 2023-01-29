import Foundation

class MainModel {
    
    func fetchCoins() async throws -> [Coin]{
        let coins = try await CryptoService.getCoins()
        return coins
    }
}
