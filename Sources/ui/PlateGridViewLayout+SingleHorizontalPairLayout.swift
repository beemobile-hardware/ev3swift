import UIKit

extension PlateGridViewLayout {
    func prepareSingleHorizontalPairLayout() {
        let plateSize = isPortrait ? self.plateSize(forRows: 1, columns: 2) : self.plateSize(forRows: 1, columns: 2).flipped()
        var frames = Array(repeatElement(BrickRect(origin: .zero, size: plateSize) , count: 2))
        
        var availableSize = isPortrait ? studdedViewSize : studdedViewSize.flipped()
        availableSize.width -= leftMargin + rightMargin
        availableSize.height -= topMargin + bottomMargin

        frames[0].origin.x = (availableSize.width / 2) - frames[0].size.width + leftMargin
        frames[1].origin.x = frames[0].origin.x + frames[0].size.width + 1
        frames[0].origin.y = max(0, (availableSize.height / 2) - (frames[0].size.height / 2) - 1) + topMargin
        frames[1].origin.y = frames[0].origin.y

        if !isPortrait {
            frames[0] = frames[0].flipped()
            frames[1] = frames[1].flipped()
        }

        let sortedConnections = connections.sorted { $0.port.inputValue < $1.port.inputValue }
        for (index, connection) in sortedConnections.enumerated() {
            let indexPath = self.indexPath(for: connection)!
            cellAttributes[indexPath] = UICollectionViewLayoutAttributes(forCellWith: indexPath,
                                                                         brickRect: frames[index],
                                                                         studDimensions: studDimensions,
                                                                         offset: layoutOffset)
            plateLocations[connection] = (column: index, row: 0)
        }
   }
}
