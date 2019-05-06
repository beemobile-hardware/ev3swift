import Foundation

enum GridLineType {
    case longLeft
    case shortLeft
    case vertical
    case shortRight
    case longRight
}

extension GridLineType {

    private enum Direction {
        case left, right
    }
    
    static func lineType(for connection: PlateConnection, in plateLocations: [PlateConnection: (column: Int, row: Int)]) -> GridLineType {
        guard let location = plateLocations[connection] else { fatalError("Expect plateLocations to contain a location for all connections") }
        
        // Calculate information needed to determine the `GridLineType`.
        let connectionsInRow = plateLocations.values.filter { $0.row == location.row }
        
        let verticalPositionFromPort: Int
        if connection.port is OutputPort {
            verticalPositionFromPort = location.row
        }
        else {
            let rowCount = (plateLocations.values.max(by: { $0.row < $1.row })?.row ?? 0)
            verticalPositionFromPort = rowCount - location.row
        }
        
        // Use the information to determine the `GridLineType`.
        switch (location.column, verticalPositionFromPort, connection.port.index, connectionsInRow.count) {
        case (_, 0, 0, 1):
            return .shortRight
            
        case (_, 0, 3, 1):
            return .shortLeft
            
        case (1, 0, 1, 2), (1, 0, 0, 2):
            return .shortRight
            
        case (0, 0, 2, 2), (0, 0, 3, 2):
            return .shortLeft
            
        case (0, 1, 0, _):
            return .longLeft
            
        case (0, 1, 1, _):
            return .longLeft
            
        case (1, 1, 3, _):
            return .longRight
            
        case (1, 1, 2, _):
            return .longRight
            
        default:
            return .vertical
        }
    }

    func path(from start: BrickPoint, to end: BrickRect, in boundingSize: BrickSize, extraStubLength: Int) -> [BrickPoint] {
        var path = stubPath(from: start, towards: end, extraStubLength: extraStubLength)
        
        switch self {
        case .vertical:
            path += verticalPath(from: path.last!, to: end, in: boundingSize)
            
        case .shortLeft:
            path += shortPath(from: path.last!, to: end, withDirection: .left, in: boundingSize)
            
        case .shortRight:
            path += shortPath(from: path.last!, to: end, withDirection: .right, in: boundingSize)
            
        case .longLeft:
            path += longPath(from: path.last!, to: end, withDirection: .left, in: boundingSize)
            
        case .longRight:
            path += longPath(from: path.last!, to: end, withDirection: .right, in: boundingSize)
        }
        
        return path
    }
    
    private func verticalPath(from start: BrickPoint, to end: BrickRect, in boundingSize: BrickSize) -> [BrickPoint] {
        let yDelta = start.y < end.origin.y ? 1 : -1
        
        var path: [BrickPoint] = [start]
        var nextPoint = start
        
        while !end.contains(nextPoint) {
            nextPoint.y += yDelta
            path.append(nextPoint)
        }
        
        return path
    }
    
    private func shortPath(from start: BrickPoint, to end: BrickRect, withDirection direction: Direction, in boundingSize: BrickSize) -> [BrickPoint] {
        let yDelta = start.y < end.origin.y ? 1 : -1
        let xDelta = direction == .right ? 1 : -1
        
        var path: [BrickPoint] = [start]
        var nextPoint = start
        
        while nextPoint.x < end.origin.x + 2 || nextPoint.x > end.origin.x + end.size.width - 2 {
            nextPoint.x += xDelta
            path.append(nextPoint)
        }

        while !end.contains(nextPoint) {
            nextPoint.y += yDelta
            path.append(nextPoint)
        }

        return path
    }
    
    private func longPath(from start: BrickPoint, to end: BrickRect, withDirection direction: Direction, in boundingSize: BrickSize) -> [BrickPoint] {
        let yDelta = start.y < end.origin.y ? 1 : -1
        let xDelta = direction == .right ? 1 : -1
        let xTarget = direction == .right ? end.origin.x + end.size.width + 1 : end.origin.x - 2
        
        var path: [BrickPoint] = [start]
        var nextPoint = start
        
        while nextPoint.x != xTarget {
            nextPoint.x += xDelta
            path.append(nextPoint)
        }

        while nextPoint.y < end.origin.y + 2 || nextPoint.y > end.origin.y + end.size.height - 2 {
            nextPoint.y += yDelta
            path.append(nextPoint)
        }

        while !end.contains(nextPoint) {
            nextPoint.x -= xDelta
            path.append(nextPoint)
        }
        
        return path
    }

    private func stubPath(from start: BrickPoint, towards end: BrickRect, extraStubLength: Int) -> [BrickPoint] {
        let isDown = start.y < end.origin.y
        let yDelta = isDown ? 1 : -1
        let count: Int
        
        switch (self, isDown) {
        case (.shortLeft, true), (.shortRight, true):
            count = 3 + extraStubLength

        case (.shortLeft, false), (.shortRight, false):
            count = 3

        default:
            count = 2
        }
        
        return (0..<count).map { BrickPoint(x: start.x, y: start.y + (yDelta * $0)) }
    }
}
