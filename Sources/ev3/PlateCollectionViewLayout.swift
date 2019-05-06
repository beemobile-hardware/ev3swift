import UIKit

protocol PlateConnectionDataSource {
    var connections: [PlateConnection] { get }
}

class PlateCollectionViewLayout: UICollectionViewFlowLayout {
    
    let studDimensions: StudDimensions
    
    let studOverflowCount = 10
    
    weak var delegate: PlateCollectionViewLayoutDelegate?

    /// An array of all current `PlateConnection`s.
    var connections: [PlateConnection] {
        guard let collectionView = collectionView else { return [] }
        guard let dataSource = collectionView.dataSource as? PlateConnectionDataSource else {
            fatalError("PlateCollectionViewLayout requires a PlateConnectionDataSource")
        }
        
        return dataSource.connections
    }

    /// The size of the background studded view.
    var studdedViewSize: BrickSize {
        guard let collectionView = collectionView else { return .zero }
        
        var visibleSize = collectionView.bounds.size
        visibleSize.width -= collectionView.contentInset.left + collectionView.contentInset.right
        visibleSize.height -= collectionView.contentInset.top + collectionView.contentInset.bottom
        
        var size = BrickSize(visibleSize, with: studDimensions)
        if size.width.isEven == isPortrait {
            size.width -= 1
        }
        if !size.height.isEven == isPortrait {
            size.height -= 1
        }
        
        return size
    }
    
    /// The offset to apply to the backround studded view and its content for content to appear centered in the collection view.
    var layoutOffset: CGSize {
        guard let collectionView = collectionView else { return .zero }
        
        var visibleBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
        visibleBounds.size.width -= collectionView.contentInset.left + collectionView.contentInset.right
        visibleBounds.size.height -= collectionView.contentInset.top + collectionView.contentInset.bottom
        
        let contentSize = studdedViewSize.cgSize(with: studDimensions)
        visibleBounds = visibleBounds.insetBy(dx: (visibleBounds.size.width - contentSize.width) / 2.0, dy: (visibleBounds.size.height - contentSize.height) / 2.0)
        
        return CGSize(width: visibleBounds.origin.x, height: visibleBounds.origin.y)
    }
    
    /// Returns `true` if the collection view's height is greater than its width.
    var isPortrait: Bool {
        guard let collectionView = collectionView else { return true }
        return collectionView.bounds.size.height > collectionView.bounds.size.width
    }

    /// Returns `true` if ports and lines should be shown when appropriate.
    var includePortsAndLines: Bool {
        let availablePortArea = studdedViewSize.height * studdedViewSize.width
        return availablePortArea > 1600
    }
    
    /// Top margin when viewing connections as a grid.
    var topMargin: Int {
        if isPortrait {
            return includePortsAndLines ? 8 : 5
        }
        else {
            return includePortsAndLines ? 7 : 0
        }
    }
    
    /// Bottom margin when viewing connections as a grid.
    var bottomMargin: Int { return includePortsAndLines ? 7 : 0 }
    
    /// Left margin when viewing connections as a grid.
    var leftMargin: Int {
        if isPortrait {
            return includePortsAndLines ? 3 : 0
        }
        else {
            return includePortsAndLines ? 7 : 5
        }
    }
    
    /// Right margin when viewing connections as a grid.
    var rightMargin: Int { return includePortsAndLines ? 3 : 0 }
    
    // MARK: Initialization
    
    required init(studDimensions: StudDimensions) {
        self.studDimensions = studDimensions
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UICollectionViewLayout
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return .zero }
        let visibleSize = CGSize(width: collectionView.bounds.size.width - collectionView.contentInset.left - collectionView.contentInset.right,
                                 height: collectionView.bounds.size.height - collectionView.contentInset.top - collectionView.contentInset.bottom)
        let superSize = super.collectionViewContentSize
        
        return CGSize(width: max(superSize.width, visibleSize.width), height: max(superSize.height, visibleSize.height))
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        delegate?.plateCollectionViewLayoutDidInvalidate(self)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch elementKind {
        case UICollectionElementKindSectionHeader:
            return layoutAttributesForPortsView(isOutput: true)
            
        case UICollectionElementKindSectionFooter:
            return layoutAttributesForPortsView(isOutput: false)
            
        case StuddedView.collectionViewElementKind:
            return layoutAttributesForStuddedView()
            
        case PlateCollectionViewMask.collectionViewElementKind:
            if indexPath.item == 0 {
                return layoutAttributesForMask(isOutput: true)
            }
            else {
                return layoutAttributesForMask(isOutput: false)
            }
            
        default:
            return nil
        }
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return proposedContentOffset }
        return CGPoint(x: -collectionView.contentInset.left, y: -collectionView.contentInset.top)
    }
    
    // MARK: Convenience methods for `PlateConnection`s.
    
    /// Returns the `IndexPath` for a given `PlateConnection`.
    func indexPath(for connection: PlateConnection) -> IndexPath? {
        guard let index = connections.index(of: connection) else { return nil }
        return IndexPath(item: index, section: 0)
    }
    
    // MARK: Convenience methods to return attributes for supplementary views.
    
    /// Returns a `UICollectionViewLayoutAttributes` for the background `StuddedView`.
    func layoutAttributesForStuddedView() -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: StuddedView.collectionViewElementKind,
                                                          with: IndexPath(item: 0, section: 0),
                                                          brickRect: BrickRect(origin: .zero, size: studdedViewSize).insetBy(dx: -studOverflowCount, dy: -studOverflowCount),
                                                          studDimensions: studDimensions,
                                                          offset: layoutOffset)
        
        offsetAttribtuesForContentOffset(attributes)
        return attributes
    }
    
    /// Returns the `UICollectionViewLayoutAttributes` for the input or output `PortsView`.
    func layoutAttributesForPortsView(isOutput: Bool) -> UICollectionViewLayoutAttributes {
        var sizeToFit = isPortrait ? studdedViewSize : studdedViewSize.flipped()
        sizeToFit.width -= leftMargin + rightMargin
        
        var frame = BrickRect.zero
        frame.size.width = (4 * 6) - 1
        frame.size.height = 2
        frame.origin.x = (sizeToFit.width / 2) - (frame.size.width / 2) + leftMargin
        
        if isOutput {
            frame.origin.y = 1
        }
        else {
            frame.origin.y = sizeToFit.height - frame.size.height - 1
        }
        
        if !isPortrait {
            frame.origin = frame.origin.flipped()
            frame.size = frame.size.flipped()
        }
        
        let supplementaryViewKind = isOutput ? UICollectionElementKindSectionHeader : UICollectionElementKindSectionFooter
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: supplementaryViewKind,
                                                          with: IndexPath(item: 0, section: 0),
                                                          brickRect: frame,
                                                          studDimensions: studDimensions,
                                                          offset: layoutOffset)
        
        if self is PlateGridViewLayout {
            attributes.isHidden = !includePortsAndLines
        }
        else {
            attributes.isHidden = true
        }
        
        return attributes
    }
    
    /// Returns the `UICollectionViewLayoutAttributes` for a `PlateCollectionViewMask`
    /// that masks either the top or bottom of the content.
    func layoutAttributesForMask(isOutput: Bool) -> UICollectionViewLayoutAttributes {
        guard let collectionView = collectionView else { fatalError("Expected a collection view to have been set.") }
        let indexPath = isOutput ? IndexPath(item: 0, section: 0) : IndexPath(item: 1, section: 0)
        let nativeStuddedViewSize = studdedViewSize.cgSize(with: studDimensions)
        
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: PlateCollectionViewMask.collectionViewElementKind, with: indexPath)
        attributes.zIndex = UICollectionViewLayoutAttributes.ZIndex.mask
        
        if isOutput {
            let height = studDimensions.totalSize * 5 + layoutOffset.height
            attributes.frame = CGRect(x: layoutOffset.width,
                                      y: 0,
                                      width: nativeStuddedViewSize.width,
                                      height: height)
            
            // Adjust the frame so the view masks content outside the top bounds
            // of the collection view.
            attributes.frame.origin.y -= studDimensions.totalSize * CGFloat(studOverflowCount)
            attributes.frame.size.height += studDimensions.totalSize * CGFloat(studOverflowCount)
            attributes.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
        else {
            let height = collectionView.bounds.size.height - nativeStuddedViewSize.height - layoutOffset.height + studDimensions.totalSize
            attributes.frame = CGRect(x: layoutOffset.width,
                                      y: collectionView.bounds.size.height - height,
                                      width: nativeStuddedViewSize.width,
                                      height: height)
            
            // Adjust the frame so the view masks content outside the bottom bounds
            // of the collection view.
            attributes.frame.size.height += studDimensions.totalSize * CGFloat(studOverflowCount)
        }
        
        // Adjust the frame so it masks outside the horizontal edges of the bounds
        attributes.frame.origin.x -= studDimensions.totalSize * CGFloat(studOverflowCount)
        attributes.frame.size.width += studDimensions.totalSize * CGFloat(studOverflowCount) * 2.0

        offsetAttribtuesForContentOffset(attributes)
        return attributes
    }

    /// Updates `UICollectionViewLayoutAttributes`'s geometry so it appears
    /// stationary in a scrolling `UICollectionView`.
    private func offsetAttribtuesForContentOffset(_ attributes: UICollectionViewLayoutAttributes) {
        guard let collectionView = collectionView else { return }
        attributes.center.y += collectionView.contentOffset.y + collectionView.contentInset.top
    }
}


protocol PlateCollectionViewLayoutDelegate: class {
    func plateCollectionViewLayoutDidInvalidate(_ layout: PlateCollectionViewLayout)
    func plateCollectionViewLayoutDidChange(_ layout: PlateCollectionViewLayout)
}
