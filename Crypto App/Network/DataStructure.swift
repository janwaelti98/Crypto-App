import Foundation

// MARK: - Coin

struct Coin: Identifiable, Codable, Equatable{
    let id, symbol, name: String
    let image: String
    let currentPrice: Double
    let marketCap, marketCapRank: Double
    let totalVolume: Double
    let high24H, low24H: Double
    let priceChange24H, priceChangePercentage24H: Double
    
    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case totalVolume = "total_volume"
        case high24H = "high_24h"
        case low24H = "low_24h"
        case priceChange24H = "price_change_24h"
        case priceChangePercentage24H = "price_change_percentage_24h"
    }
}

// MARK: - Price

struct Price: Codable, Equatable {
    let prices: [[Double]]
}
