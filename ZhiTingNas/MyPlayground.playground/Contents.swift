import UIKit
import HandyJSON
import Combine
import Foundation






///// 垃圾回收
//var cancellables = [AnyCancellable]()
//
//
///// 发布者
//let publisher = PassthroughSubject<Int, Never>()
//
//
///// 订阅发布（订阅者 收到消息后的处理）
//publisher
//    .sink { value in
//        print("收到消息\(value)")
//    }
//    .store(in: &cancellables)
//
//
//DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//    /// 发布者发布消息
//    publisher.send(1)
//}
//
//DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//    /// 发布者发布消息
//    publisher.send(2)
//}
//
//DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
//    /// 发布者发布消息
//    publisher.send(3)
//}






//func getResult() -> Int {
//    var end = false
//    var result = 0
//
//    DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
//        end = true
//        result = 10
//    }
//
//    while (!end) {
//        RunLoop.current.run(mode: .default, before: .distantFuture)
//    }
//
//    return result
//
//}
//
//
//
//print(getResult())


