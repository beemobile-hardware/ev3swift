import UIKit

extension PlateGridViewLayout {
    func calculateGridLines() -> [GridLine] {
        guard includePortsAndLines else { return [] }
        
        let bounds = isPortrait ? studdedViewSize : studdedViewSize.flipped()
        var lines: [GridLine] = []
        
        for connection in connections {
            let start = isPortrait ? startPoint(for: connection.port) : startPoint(for: connection.port).flipped()
            let end = isPortrait ? plateFrame(for: connection) : plateFrame(for: connection).flipped()
            let lineType = GridLineType.lineType(for: connection, in: plateLocations)
            
            var path = lineType.path(from: start, to: end, in: bounds, extraStubLength: topMargin - 7)
            if !isPortrait {
                path = path.map { $0.flipped() }
            }
            
            lines.append(GridLine(connection: connection, path: path))
        }
        
        return lines
    }
    
    private func startPoint(for port: Port) -> BrickPoint {
        var bounds = isPortrait ? studdedViewSize : studdedViewSize.flipped()
        
        var point = BrickPoint.zero
        if port is OutputPort {
            point.y = 3
        }
        else {
            point.y = bounds.height - 4
        }
        
        bounds.width -= leftMargin + rightMargin
        
        point.x = (bounds.width / 2) - (portContainerViewWidth / 2) + leftMargin + 2 + (port.index * 6)
        
        return isPortrait ? point : point.flipped()
    }
}
