import Foundation
import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @State var isLoading: Bool = true
    @ObservedObject var network = NetworkMonitor()
    
    var body: some View {
        VStack {
            if(NetworkMonitor.shared.isNotConnected){
                GroupBox{
                    HStack{
                        Spacer()
                        Text("No internet connection")
                        Image(systemName: "wifi.exclamationmark").foregroundColor(.red)
                        Spacer()
                    }
                }
                .padding()
            }
            
            FilterOptions().environmentObject(viewModel)
            Divider()
            Spacer()
            CryptoList(isLoading: $isLoading).environmentObject(viewModel)
                .onAppear {
                    loadCoins()
                }
            Spacer()
        }
        .background(Color("BackgroundColor"))
        .navigationTitle("Market")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    loadCoins()
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
            }
        }
    }
    
    // MARK: - loadCoins

    func loadCoins() -> Void{
        if(!NetworkMonitor.shared.isNotConnected){
            Task {
                isLoading = true
                await viewModel.loadCoins()
                DispatchQueue.main.async {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - FilterOptions

struct FilterOptions: View {
    @EnvironmentObject var viewModel: MainViewModel
    
    var body: some View {
        HStack {
            FilterOptionItem(text: "Rank", filterOption: MainViewModel.FilterOption.marketCap, onTapGesture: {
                
                if viewModel.filterOption == .marketCap {
                    viewModel.filterOption = .marketCapReversed
                    viewModel.sortCoins(coinList: viewModel.coinList ,sort: .marketCapReversed)
                }else {
                    viewModel.filterOption = .marketCap
                    viewModel.sortCoins(coinList: viewModel.coinList, sort: .marketCap)
                }
            })
            
            Spacer()
            
            FilterOptionItem(text: "Name", filterOption: MainViewModel.FilterOption.name, onTapGesture: {
                
                if viewModel.filterOption == .name {
                    viewModel.filterOption = .namereversed
                    viewModel.sortCoins(coinList: viewModel.coinList, sort: .namereversed)
                }else {
                    viewModel.filterOption = .name
                    viewModel.sortCoins(coinList: viewModel.coinList, sort: .name)
                }
            })
            
            Spacer()
            
            FilterOptionItem(text: "Price", filterOption: MainViewModel.FilterOption.price, onTapGesture: {
                
                if viewModel.filterOption == .price {
                    viewModel.filterOption = .priceReversed
                    viewModel.sortCoins(coinList: viewModel.coinList, sort: .priceReversed)
                }else {
                    viewModel.filterOption = .price
                    viewModel.sortCoins(coinList: viewModel.coinList, sort: .price)
                }
            })
        }.padding()
    }
}

// MARK: - FilterOptionItem

struct FilterOptionItem: View {
    @EnvironmentObject var viewModel: MainViewModel
    
    var text: String
    var filterOption: MainViewModel.FilterOption
    var onTapGesture: () -> ()
    
    var body: some View {
        HStack {
            Text(text)
            Image(systemName: "chevron.down")
                .rotationEffect(Angle(degrees: viewModel.filterOption == filterOption ? 0 : 180))
        }.onTapGesture {
            onTapGesture()
        }
    }
}

// MARK: - Cryptolist

struct CryptoList: View {
    @EnvironmentObject var viewModel: MainViewModel
    @Binding var isLoading: Bool
    
    var body: some View {
        if isLoading {
            ProgressView()
        } else {
            List(viewModel.coinList){ coin in
                NavigationLink(destination: DetailView(coin: coin),
                               label: { CoinCard(coin: coin).frame(maxHeight: 50)}).listRowBackground(Color("BackgroundColor"))
            }
            .listStyle(.inset)
            .scrollContentBackground(.hidden)
        }
    }
}

// MARK: - CoinCard

struct CoinCard: View{
    let coin: Coin
    var isPositive: Bool {
        return coin.priceChangePercentage24H > 0
    }
    
    var body: some View{
        HStack{
            HStack {
                Text(String(format: "%.0f", coin.marketCapRank)).padding(.trailing)
                AsyncImage(url: URL(string: coin.image)){ image in
                    image.resizable().frame(width: 30, height: 30)
                }placeholder: {}
                VStack(alignment: .leading){
                    Text(coin.name)
                    Text(String(coin.symbol.uppercased())).font(.caption).foregroundColor(Color.gray)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing){
                Text(String(format: "%.2f",coin.currentPrice) + " $").bold()
                Text(String(format: "%.2f",coin.priceChangePercentage24H) + " %").foregroundColor(isPositive ? Color.green : Color.pink)
            }
        }
    }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
