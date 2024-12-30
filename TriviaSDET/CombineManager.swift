

import Foundation
import Combine

final class CombineManager: ObservableObject {
    var cancellables = Set<AnyCancellable>()
}

