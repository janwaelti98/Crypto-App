import SwiftUI
import Charts
import Foundation

struct DetailView: View {
    @State var isLoading: Bool = true
    @State var coin: Coin
    @State var timeInterval: Int = TimeInterval.oneMonth.rawValue
    
    @ObservedObject var detailVM: DetailViewModel = DetailViewModel()
        
    var body: some View {
        ScrollView {
            VStack {
                GraphView(coin: $coin, chartItems: $detailVM.priceChartItems, isLoading: $isLoading)
                PickerView(coin: $coin, isLoading: $isLoading, timeInterval: $timeInterval).environmentObject(detailVM)
                TableView(coin: $coin)
            }
        }.onAppear {
            updateChart()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(coin.name).bold().font(.title)
                    AsyncImage(url: URL(string: coin.image)){ image in
                        image.resizable().frame(width: 30, height: 30)
                    } placeholder: {}
                }
            }
        }
        .background(Color("BackgroundColor"))
    }
    
    // MARK: - updateChart

    func updateChart(){
        Task {
            isLoading = true
            try await detailVM.loadPrices(id: coin.id, currency: "usd", days: timeInterval)
            DispatchQueue.main.async {
                isLoading = false
            }
        }
    }
}

// MARK: - GraphView

struct GraphView : View {
    @Binding var coin: Coin
    @Binding var chartItems: [ChartPrice]
    @Binding var isLoading: Bool
    var isPositive: Bool {
        guard let firstPrice = $chartItems.first?.price.wrappedValue,
              let lastPrice = $chartItems.last?.price.wrappedValue else {
            return false
        }
        return firstPrice < lastPrice
    }
    
    var positiveGradient = LinearGradient(gradient: Gradient(colors: [.green, .clear]), startPoint: .top, endPoint: .bottom)
    var negativGradient = LinearGradient(gradient: Gradient(colors: [.pink, .clear]), startPoint: .top, endPoint: .bottom)
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                Chart(chartItems) { item in
                    AreaMark(
                        x: .value("X Achse", item.date),
                        y: .value("Y Achse", item.price)
                    )
                    .foregroundStyle(isPositive ? positiveGradient : negativGradient)
                    LineMark(
                        x: .value("X Achse", item.date),
                        y: .value("Y Achse", item.price)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    .foregroundStyle(isPositive ? Color.green : Color.pink)
                }
            }
        }.frame(height: 300).padding()
    }
}

// MARK: - PickerView

struct PickerView: View {
    @Binding var coin: Coin
    @State var chosenTimeInterval: TimeInterval = .oneMonth
    @Binding var isLoading: Bool
    @Binding var timeInterval: Int
    @EnvironmentObject var detailVM: DetailViewModel
    
    var body: some View {
        Picker("", selection: $chosenTimeInterval) {
            ForEach(TimeInterval.allCases, id: \.self) { chosenInterval in
                Text(chosenInterval.label)
            }
        }
        .onChange(of: chosenTimeInterval, perform: { chosenInterval in
            timeInterval = chosenInterval.rawValue
            
            Task {
                isLoading = true
                try await detailVM.loadPrices(id: coin.id, currency: "usd", days: timeInterval)
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        })
        .pickerStyle(SegmentedPickerStyle()).padding()
    }
}

// MARK: - TableView

struct TableView: View {
    @Binding var coin: Coin
    
    private let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    private let spacing: CGFloat = 30
    
    var body: some View {
        VStack(spacing: 20) {
            overviewTitle
            Divider()
            overviewGrid
            detailsTitle
            Divider()
            detailsGrid
        }.padding()
    }
}

// MARK: - DetailsItem

struct DetailsItem: View {
    var text: String
    var value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(text).font(.caption).foregroundColor(Color.gray)
            Spacer()
            Text(value).bold()
        }
    }
}

// MARK: - TableView Extensions

extension TableView {
    var isPositive: Bool {
        return coin.priceChangePercentage24H > 0
    }
    
    private var overviewTitle: some View {
        Text("Overview")
            .font(.title)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var detailsTitle: some View {
        Text("Details ")
            .font(.title)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var overviewGrid: some View {
        LazyVGrid(columns: columns,
                  alignment: .leading,
                  spacing: spacing,
                  content: {
            DetailsItem(text: "Price", value: String(coin.currentPrice) + " $")
            DetailsItem(text: "Market Cap", value: String(Int(coin.marketCap)) + " $")
            DetailsItem(text: "Rank", value: String(Int(coin.marketCapRank)))
            DetailsItem(text: "Volume", value: String(Int(coin.totalVolume)))
        })
    }
    
    private var detailsGrid: some View {
        LazyVGrid(columns: columns,
                  alignment: .leading,
                  spacing: spacing,
                  content: {
            DetailsItem(text: "24h High", value: String(coin.high24H) + " $")
            DetailsItem(text: "24h Low", value: String(coin.low24H) + " $")
            DetailsItem(text: "24h Change", value: String(format:"%.2f", coin.priceChangePercentage24H) + " %").foregroundColor(isPositive ? Color.green : Color.pink)
            DetailsItem(text: "24h Change", value: String(format:"%.2f", coin.priceChange24H) + " $").foregroundColor(isPositive ? Color.green : Color.pink)
        })
    }
}
