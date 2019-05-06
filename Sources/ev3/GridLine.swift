import UIKit

struct GridLine {
    var connection: PlateConnection
    var path: [BrickPoint]
}

extension GridLine: Equatable {
    static func ==(lhs: GridLine, rhs: GridLine) -> Bool {
        return lhs.connection == rhs.connection && lhs.path == rhs.path
    }
}
