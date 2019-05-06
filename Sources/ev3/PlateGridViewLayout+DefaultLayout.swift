import UIKit

extension PlateGridViewLayout {
    func prepareDefaultLayout() {
        let pairedConnections = pairConnections()

        var plateSize = self.plateSize(forRows: pairedConnections.count, columns: 2)
        plateSize = isPortrait ? plateSize : plateSize.flipped()

        // Layout the plates in each row.
        var frames: [IndexPath: BrickRect] = [:]
        var top = topMargin
        for (rowIndex, row) in pairedConnections.enumerated() {
            for (columnIndex, connection) in row.enumerated() {
                guard let connection = connection else { continue }
                
                let frame = calculateFrame(forRow: rowIndex, column: columnIndex, plateSize: plateSize, top: top, left: leftMargin)
                frames[indexPath(for: connection)!] = frame
                plateLocations[connection] = (column: columnIndex, row: rowIndex)
            }

            top += plateSize.height + 1
        }

        // Flip the geometry if the collection view is in landscape.
        if !isPortrait {
            for indexPath in frames.keys {
                frames[indexPath] = frames[indexPath]!.flipped()
            }
        }

        // Map the frames to layout attributes.
        for (indexPath, frame) in frames {
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath, brickRect: frame, studDimensions: studDimensions, offset: layoutOffset)
            cellAttributes[indexPath] = attributes
        }
    }
    
    private func pairConnections() -> [[PlateConnection?]] {
        let sortedOutputConnections = connections.filter({ $0.port is OutputPort }).sorted(by: { $0.port.inputValue < $1.port.inputValue })
        let sortedInputConnections = connections.filter({ $0.port is InputPort }).sorted(by: { $0.port.inputValue < $1.port.inputValue })
        var locations = Array(repeating:Array<PlateConnection?>(repeating: nil, count: 2), count: 4)
        
        if let connection = sortedOutputConnections.first, sortedOutputConnections.count == 1 {
            // Simple case of a single output connection.
            switch connection.port as! OutputPort {
            case .a, .b:
                locations[0][0] = connection

            case .c, .d:
                locations[0][1] = connection
            }
        }
        else if sortedOutputConnections.count == 2 {
            // Position the two output connections in the sorted order on the first row
            for (index, connection) in sortedOutputConnections.enumerated() {
                locations[0][index] = connection
            }
        }
        else  {
            for connection in sortedOutputConnections {
                switch connection.port as! OutputPort {
                case .a:
                    if sortedOutputConnections.first(where: { ($0.port as? OutputPort) == .b }) != nil {
                        locations[1][0] = connection
                    }
                    else {
                        locations[0][0] = connection
                    }
                
                case .b:
                        locations[0][0] = connection
                
                case .c:
                    if locations[0][0] == nil {
                        locations[0][0] = connection
                    }
                    else {
                        locations[0][1] = connection
                    }
                
                case .d:
                    if locations[0][1] == nil {
                        locations[0][1] = connection
                    }
                    else {
                        locations[1][1] = connection
                    }
                }
            }
        }

        // Determine the row and column index to position the first input connection
        var rowIndex = 0
        var columnIndex = 0
        for (index, row) in locations.enumerated() {
            let emptyLocationCount = row.filter({ $0 == nil }).count
            guard emptyLocationCount > 0 else { continue }

            if (sortedInputConnections.count % 2 == 0 && emptyLocationCount == 2) {
                rowIndex = index
                columnIndex = 0
                break
            }
            else if sortedInputConnections.count % 2 == 1 {
                rowIndex = index
                columnIndex = locations[index][0] == nil ? 0 : 1
                break
            }
        }
        
        // Check if the first location we use to place a connection should be to the right.
        if sortedInputConnections.count % 2 == 1 && columnIndex == 0 && locations[rowIndex][1] == nil {
            if sortedInputConnections.count == 3 && sortedInputConnections.first(where: { ($0.port as? InputPort) == .three }) != nil && sortedInputConnections.first(where: { ($0.port as? InputPort) == .four }) != nil {
                columnIndex = 1
            }
            else if let port = sortedInputConnections.first?.port as? InputPort, sortedInputConnections.count == 1 && (port == .three || port == .four) {
                columnIndex = 1
            }
        }

        // Loop through all the input connections until they're all been positioned
        var connectionsToPosition = sortedInputConnections
        while !connectionsToPosition.isEmpty {
            let portOrder: [InputPort]
            if columnIndex == 0 {
                portOrder = [.one, .two, .three, .four]
            }
            else {
                portOrder = [.four, .three, .two, .one]
            }
            
            // Loop through the preferred ports and find the first match in the remaining connections.
            for port in portOrder {
                guard let connectionIndex = connectionsToPosition.index(where: { port.isEqual(to: $0.port) }) else { continue }
                locations[rowIndex][columnIndex] = connectionsToPosition[connectionIndex]
                connectionsToPosition.remove(at: connectionIndex)
                break
            }
            
            columnIndex += 1
            if columnIndex > 1 || // The column index is out of bounds
                (connectionsToPosition.count == 2 && columnIndex > 0) || // There are only two connections remaining and the column index is on the right
                (columnIndex == 1 && locations[rowIndex][columnIndex] != nil) // There is already a positioned connection at the column index
            {
                columnIndex = 0
                rowIndex += 1
            }
        }
        
        return locations.filter { $0[0] != nil || $0[1] != nil }
    }
    
    private func calculateFrame(forRow row: Int, column: Int, plateSize: BrickSize, top: Int, left: Int) -> BrickRect {
        return BrickRect(x: left + column * (plateSize.width + 1),
                         y: top,
                         width: plateSize.width,
                         height: plateSize.height)
    }
}
