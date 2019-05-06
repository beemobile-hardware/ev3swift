import UIKit

private let reuseIdentifier = "Cell"

public class DebugUIHardwareCollectionView: UICollectionView {

    var ports = (0...7).map { _ in DebugUIPort() }

    public init() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        layout.minimumLineSpacing = 20.0
        layout.minimumInteritemSpacing = 20.0
        
        super.init(frame: CGRect.zero, collectionViewLayout: layout)
        
        register(DebugUIHardwareViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.white
        dataSource = self
        layout.itemSize = itemSize(for: CGSize(width: 512, height: 0))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updatedPorts(data: [PortData]) {
        for portData in data {
            let port = ports[portData.portIndex]
            port.setPart(data: portData)
        }
    }
    
    func itemSize(for size: CGSize) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let width = (size.width - layout.minimumInteritemSpacing * 4 - layout.sectionInset.left * 2) / 4.0
        return CGSize(width: width, height: width)
    }
}

extension DebugUIHardwareCollectionView: UICollectionViewDataSource {
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return ports.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DebugUIHardwareViewCell
        cell.port = ports[indexPath.row]
        return cell
    }
}
