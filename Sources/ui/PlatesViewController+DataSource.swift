import UIKit

/**
 Extend `PlatesViewController` to conform to the `UICollectionViewDataSource`
 and `PlateConnectionDataSource` protocols.
 */
extension PlatesViewController: UICollectionViewDataSource, PlateConnectionDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return connections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        if collectionView.collectionViewLayout is PlateGridViewLayout {
            cell = dequeueGridCell(for: indexPath)
        }
        else if collectionView.collectionViewLayout is PlateTableViewLayout {
            cell = dequeueTableCell(for: indexPath)
        }
        else {
            fatalError("Unsuppoert layout type - \(String(describing: collectionView.collectionViewLayout))")
        }
        
        cell.contentView.isHidden = isTransitioningLayout
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader, UICollectionElementKindSectionFooter:
            return portsView(ofKind: kind, for: indexPath)
            
        case StuddedView.collectionViewElementKind:
            return studdedView(for: indexPath)
            
        case PlateCollectionViewMask.collectionViewElementKind:
            return mask(for: indexPath)
            
        default:
            fatalError("Unsupported supplementary element kind - \(kind)")
        }
    }

    // MARK: Convenience cell methods.

    private func dequeueGridCell(for indexPath: IndexPath) -> UICollectionViewCell {
        guard let gridLayout = collectionView.collectionViewLayout as? PlateGridViewLayout, let plateStyle = gridLayout.plateStyle else {
            fatalError("Expected the collection view to be displaying a grid layout with a plate style set.")
        }
        
        let reuseIdentifier = PlateGridViewCell.reuseIdentifier(for: plateStyle)
        guard let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PlateGridViewCell else {
            fatalError("Unable to dequeue a PlateGridViewCell")
        }
        
        cell.configure(with: connections[indexPath.row], style: plateStyle)
        cell.modesView?.delegate = self
        return cell
    }
    
    private func dequeueTableCell(for indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = PlateTableViewCell.reuseIdentifier
        guard let cell = collectionView!.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PlateTableViewCell else {
            fatalError("Unable to dequeue a PlateTableViewCell")
        }
        
        // Configure the cell labels and colors.
        let connection = connections[indexPath.row]
        cell.delegate = self
        cell.userCodeState = userCodeState
        
        // Send the current data set to the cell.
        let loggedData = lastRunData ?? liveData
        if let data = loggedData.data[connection], let mode = loggedData.modes[connection] {
            cell.configure(with: connection, data: data, mode: mode)
            
            if let xOffset = lastGraphScrollPosition {
                cell.scrollGraph(to: xOffset)
            }
            else {
                cell.scrollGraph(to: cell.maximumGraphOffset)
            }
        }

        return cell
    }
    
    // MARK: Convenience supplimentary view methods.
    
    private func portsView(ofKind kind: String, for indexPath: IndexPath) -> PortsView {
        // Dequeue the view.
        let reuseIdentifier = PortsView.reuseIdentifier
        guard let portsView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                              withReuseIdentifier: reuseIdentifier,
                                                                              for: indexPath) as? PortsView
            else {
                fatalError("Unable to dequeue a PortsView")
        }
        
        // Setup the view before returning it.
        portsView.studDimensions = studDimensions
        switch kind {
        case UICollectionElementKindSectionHeader:
            portsView.ports = OutputPort.all
            currentOutputPortsView = portsView
            
        case UICollectionElementKindSectionFooter:
            portsView.ports = InputPort.all
            currentInputPortsView = portsView
            
        default:
            fatalError("Unsupported element kind - \(kind)")
        }
        
        return portsView
    }
    
    private func studdedView(for indexPath: IndexPath) -> StuddedView {
        // Dequeue the view.
        let reuseIdentifier = StuddedView.reuseIdentifier
        guard let studdedView = collectionView.dequeueReusableSupplementaryView(ofKind: StuddedView.collectionViewElementKind,
                                                                                withReuseIdentifier: reuseIdentifier,
                                                                                for: indexPath) as? StuddedView
            else {
                fatalError("Unable to dequeue a StuddedView")
        }
        
        // Setup the view before returning it.
        studdedView.studDimensions = studDimensions
        return studdedView
    }

    
    private func mask(for indexPath: IndexPath) -> PlateCollectionViewMask {
        // Dequeue the view.
        let reuseIdentifier = PlateCollectionViewMask.reuseIdentifier
        guard let mask = collectionView.dequeueReusableSupplementaryView(ofKind: PlateCollectionViewMask.collectionViewElementKind,
                                                                                withReuseIdentifier: reuseIdentifier,
                                                                                for: indexPath) as? PlateCollectionViewMask
            else {
                fatalError("Unable to dequeue a PlateCollectionViewMask")
        }
        
        // Setup the view before returning it.
        mask.studdedView.studDimensions = studDimensions
        
        return mask
    }
}


extension PlatesViewController: PlateTableViewCellDelegate {
    func plateTableViewCell(_ sender: PlateTableViewCell, didScrollTo xOffset: CGFloat) {
        lastGraphScrollPosition = xOffset
        
        for case let cell as PlateTableViewCell in collectionView.visibleCells where cell != sender {
            cell.scrollGraph(to: xOffset)
        }
    }
}
