import Foundation
import SwiftUI

class DetailViewModel: ObservableObject {
    
    let model = DetailModel()
    
    @Published var fetchedPrices = Price(prices: [])
    @Published var priceChartItems: [ChartPrice] = []
    @Published var errorText: String?
    
    // MARK: - loadPrices
    
    public func loadPrices(id: String, currency: String, days: Int) async throws -> Void {
        Task {
            do {
                let prices = try await model.fetchPrices(id: id, currency: currency, days: days)
                DispatchQueue.main.async {
                    self.fetchedPrices = prices
                    self.convertPricesToPriceChartItems(prices: prices)
                }
            } catch {
                DispatchQueue.main.async {
                    if let error = error as? NetworkError {
                        self.errorText = error.errDescription
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    self.errorText = nil
                }
            }
        }
    }
    
    // MARK: - convertPricesToPriceChartItems
    
    public func convertPricesToPriceChartItems(prices: Price) {
        priceChartItems = []
        for price in prices.prices {
            priceChartItems.append(ChartPrice(price: price[1], unixTime: price[0]))
        }
    }
}

// MARK: - TimeInterval

enum TimeInterval : Int, CaseIterable {
    case oneDay = 1
    case oneWeek = 7
    case oneMonth = 30
    case threeMonths = 90
    case oneYear = 365
    case twoYears = 730
    case fiveYears = 1825
    
    var label: String {
        switch self {
        case .oneDay:
            return "1D"
        case .oneWeek:
            return "7D"
        case .oneMonth:
            return "1M"
        case .threeMonths:
            return "3M"
        case .oneYear:
            return "1Y"
        case .twoYears:
            return "2Y"
        case .fiveYears:
            return "5Y"
        }
    }
}

// MARK: - ChartPrice

struct ChartPrice: Identifiable, Codable {
    var id = UUID()
    var price: Double
    var date: Date {
        return Date(timeIntervalSince1970: Double(unixTime) / 1000)
    }
    var unixTime: Double
}
