import Foundation

func ^ (lhs: Data, rhs: Data) -> Data? {
    guard lhs.count == rhs.count else { return nil }
    var result = Data(count: lhs.count)
    for index in lhs.indices {
        result[index] = lhs[index] ^ rhs[index]
    }
    return result
}

// Removed in Xcode 8 beta 3
func + (lhs: Data, rhs: Data) -> Data {
    var result = lhs
    result.append(rhs)
    return result
}

extension Data {
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }
            .joined()
    }
}

