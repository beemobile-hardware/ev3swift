import UIKit

extension PlateGridViewLayout {
    func prepareSingleLayout() {
        var frame = BrickRect.zero
        frame.size = isPortrait ? plateSize(forRows: 1, columns: 1) : plateSize(forRows: 1, columns: 1).flipped()
        if frame.size.width.isEven {
            frame.size.width += 1
        }

        var availableSize = isPortrait ? studdedViewSize : studdedViewSize.flipped()
        availableSize.height -= topMargin + bottomMargin
        availableSize.width -= leftMargin + rightMargin

        frame.origin.x = (availableSize.width / 2) - (frame.size.width / 2) + leftMargin
        frame.origin.y = (availableSize.height / 2) - (frame.size.height / 2) + topMargin
        
        let indexPath = IndexPath(item: 0, section: 0)
        cellAttributes[indexPath] = UICollectionViewLayoutAttributes(forCellWith: indexPath,
                                                                     brickRect: isPortrait ? frame : frame.flipped(),
                                                                     studDimensions: studDimensions,
                                                                     offset: layoutOffset)
        plateLocations[connections[0]] = (column: 0, row: 0)
    }
}
