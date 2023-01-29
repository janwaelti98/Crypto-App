import Foundation
import Network

class NetworkMonitor: ObservableObject{
    
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor ()
    private let queue = DispatchQueue.global(qos: .background)
    @Published public var isNotConnected = false
    
    init(){
        monitor.pathUpdateHandler = {path in
            DispatchQueue.main.async{
                self.isNotConnected = path.status == .unsatisfied
            }
        }
        monitor.start(queue: queue)
    }
}

