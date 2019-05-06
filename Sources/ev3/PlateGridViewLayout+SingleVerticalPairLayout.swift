import UIKit

extension PlateGridViewLayout {
    func prepareSingleVerticalPairLayout() {
        let plateSize = isPortrait ? self.plateSize(forRows: 2, columns: 1) : self.plateSize(forRows: 2, columns: 1).flipped()
        var frames = Array(repeatElement(BrickRect(origin: .zero, size: plateSize) , count: 2))
        
        // Fiddle the sizes so the pair look best.
        frames[0].size.width -= frames[0].size.width.isEven ? 1 : 0
        frames[1].size.width -= frames[1].size.width.isEven ? 1 : 0
        frames[0].size.height += isPortrait ? 0 : 1
        
        var availableSize = isPortrait ? studdedViewSize : studdedViewSize.flipped()
        availableSize.width -= leftMargin + rightMargin
        availableSize.height -= topMargin + bottomMargin
        
        frames[0].origin.y = (availableSize.height / 2) - frames[0].size.height + topMargin
        frames[1].origin.y = frames[0].origin.y + frames[0].size.height + 1
        frames[0].origin.x = (availableSize.width / 2) - (frames[0].size.width / 2) + leftMargin
        frames[1].origin.x = frames[0].origin.x
        
        if !isPortrait {
            frames[0] = frames[0].flipped()
            frames[1] = frames[1].flipped()
        }
        
        let sortedConnections = connections.sorted { $0.port.inputValue > $1.port.inputValue }
        for (index, connection) in sortedConnections.enumerated() {
            let indexPath = self.indexPath(for: connection)!
            cellAttributes[indexPath] = UICollectionViewLayoutAttributes(forCellWith: indexPath,
                                                                         brickRect: frames[index],
                                                                         studDimensions: studDimensions,
                                                                         offset: layoutOffset)
            plateLocations[connection] = (column: 0, row: index
)
        }
    }
}
