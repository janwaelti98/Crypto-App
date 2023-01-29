import Foundation

class DetailModel {

    func fetchPrices(id: String, currency: String, days: Int) async throws -> Price {
        let prices = try await CryptoService.getPrices(id: id, currency: currency, days: days)
        return prices
    }
}
