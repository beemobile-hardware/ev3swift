import UIKit

class PlateGridViewLayout: PlateCollectionViewLayout {
    typealias GridLayoutLocation = (column: Int, row: Int)
    
    /// A local cache of `UICollectionViewLayoutAttributes` for each connection's `IndexPath`.
    var cellAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    
    var plateLocations: [PlateConnection: GridLayoutLocation] = [:]
    
    let portContainerViewWidth = (6 * 4) - 1
    
    private(set) var plateStyle: GridPlateStyle?
    
    // MARK: UICollectionViewLayout

    override func prepare() {
        super.prepare()
        
        // Clear any current attributes.
        cellAttributes = [:]
        plateLocations = [:]
        
        switch connections.portCounts {
        case (input: 0, output: 0):
            prepareEmptyLayout()
            
        case (input: 1, output: 0), (input: 0, output: 1):
            prepareSingleLayout()

        case (input: 2, output: 0), (input: 0, output: 2):
            prepareSingleHorizontalPairLayout()

        case (input: 1, output: 1):
            prepareSingleVerticalPairLayout()
            
        default:
            prepareDefaultLayout()
        }

        // Determine the plate style.
        if let connection = connections.first {
            let plateSize = plateFrame(for: connection).size
            plateStyle = GridPlateStyle(plateSize: plateSize)
        }

        delegate?.plateCollectionViewLayoutDidChange(self)
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Return layout attributes for all supplementary views and all cells.
        var allAttributes = Array(cellAttributes.values)
        allAttributes.append(layoutAttributesForStuddedView())
        
        var attributes = layoutAttributesForMask(isOutput: true)
        allAttributes.append(attributes)
        
        attributes = layoutAttributesForMask(isOutput: false)
        allAttributes.append(attributes)
        
        attributes = layoutAttributesForPortsView(isOutput: true)
        attributes.isHidden = !includePortsAndLines
        allAttributes.append(attributes)
        
        attributes = layoutAttributesForPortsView(isOutput: false)
        attributes.isHidden = !includePortsAndLines
        allAttributes.append(attributes)
        
        return allAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cellAttributes[indexPath]
    }

    // MARK: Convenience
    
    func plateSize(forRows rows: Int, columns: Int) -> BrickSize {
        var availableSize = isPortrait ? studdedViewSize : studdedViewSize.flipped()
        availableSize.height -= topMargin + bottomMargin
        availableSize.width -= leftMargin + rightMargin

        var rowCount = max(2, rows)
        var columnCount = max(2, columns)
        
        let aspectRatio = CGFloat(availableSize.width) / CGFloat(availableSize.height)
        if aspectRatio < 0.6 {
            columnCount = max(1, columns)
        }
        else if min(availableSize.width, availableSize.height) < 30 {
            rowCount = max(1, rows)
            columnCount = max(1, columns)
        }

        // Subtract space for as ingle stud gap between plates from the available space.
        availableSize.height -= rowCount - 1
        availableSize.width -= columnCount - 1
        
        var plateSize = BrickSize( width: availableSize.width / columnCount, height: availableSize.height / rowCount)
        
        // If ports are visible and there's only one plate, make sure it is as wide 
        // as the port views.
        if rows == 1 && columns == 1 && includePortsAndLines {
            plateSize.width = max(plateSize.width, portContainerViewWidth)
        }
        
        return isPortrait ? plateSize : plateSize.flipped()
    }

    func plateFrame(for connection: PlateConnection) -> BrickRect {
        guard let indexPath = self.indexPath(for: connection), let attributes = layoutAttributesForItem(at: indexPath) else { return .zero }
        
        var frame = BrickRect.zero
        frame.origin.x = Int((attributes.frame.origin.x - layoutOffset.width) / studDimensions.totalSize)
        frame.origin.y = Int((attributes.frame.origin.y - layoutOffset.height) / studDimensions.totalSize)
        frame.size.width = Int(attributes.size.width / studDimensions.totalSize)
        frame.size.height = Int(attributes.size.height / studDimensions.totalSize)
        
        return frame
    }
}

enum GridPlateStyle {
    case large, medium, small
    
    init(plateSize: BrickSize) {
        if plateSize.height >= 24 && plateSize.width >= 20 {
            self = .large
        }
        else if plateSize.height >= 12 && plateSize.width >= 18 {
            self = .medium
        }
        else {
            self = .small
        }
    }
}
