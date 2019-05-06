import UIKit

@objc(BrickActionsViewController)
class BrickActionsViewController: UITableViewController {
    
    weak var delegate: BrickActionsViewControllerDelegate?
    
    private enum CellIndex: Int {
        case rename, reset, disconnect
        
        var localizedName: String {
            switch self {
            case .rename:
                return NSLocalizedString("Rename", comment: "Brick action button to show the rename brick view")
                
            case .reset:
                return NSLocalizedString("Reset", comment: "Brick action button to reset the brick state")
                
            case .disconnect:
                return NSLocalizedString("Disconnect", comment: "Brick action button to disconnect the currently connected brick")
            }
        }
        
        static let all: [CellIndex] = [.rename, .reset, .disconnect]
    }
    
    private var observerContext = 1

    var communicationLayer: EV3CommunicationLayer?

    deinit {
        tableView.removeObserver(self, forKeyPath: #keyPath(UITableView.contentSize), context: &observerContext)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addObserver(self, forKeyPath: #keyPath(UITableView.contentSize), options: [.new], context: &observerContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let observedObject = object, context == &observerContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if observedObject as? UITableView == tableView && keyPath == #keyPath(UITableView.contentSize) {
            preferredContentSize = CGSize(width: 220, height: tableView.contentSize.height)
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CellIndex.all.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BrickActionsCell.reuseIdentifier, for: indexPath) as? BrickActionsCell else {
            fatalError("Unable to dequeue a BrickActionsCell")
        }
        
        guard let cellIndex = CellIndex(rawValue: indexPath.row) else {
            fatalError("Unexpected index path \(indexPath.row)")
        }
        
        cell.actionLabel.text = cellIndex.localizedName
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cellIndex = CellIndex(rawValue: indexPath.row) else { return }
        
        switch cellIndex {
        case .rename:
            presentRenameBrickAlert()
            
        case .reset:
            resetBrick()
            
        case .disconnect:
            disconnectBrick()
        }
    }
    
    // MARK: Convenience
    
    private func presentRenameBrickAlert() {
        var title = NSLocalizedString("Rename EV3", comment: "Title for the Rename EV3 alert")
        let message = NSLocalizedString("Enter a new name for your EV3 Brick", comment: "Message shown in the Rename EV3 alert")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let brickName = communicationLayer?.readBrickName()
        
        var nameTextField: UITextField? = nil
        alert.addTextField { textField in
            textField.text = brickName
            nameTextField = textField
        }
        
        title = NSLocalizedString("OK", comment: "OK")
        alert.addAction(UIAlertAction(title: title, style: .default, handler: { _ in
            if let name = nameTextField?.text {
                log(message: "Setting brick name to \(name)")
                self.communicationLayer?.writeBrickName(name: name)
            }
            self.dismiss(animated: true, completion: nil)
        }))
        
        title = NSLocalizedString("Cancel", comment: "Cancel")
        alert.addAction(UIAlertAction(title: title, style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))

        let presentingController = presentingViewController
        dismiss(animated: true, completion: nil)
        presentingController?.present(alert, animated: true, completion: nil)
    }
    
    private func resetBrick() {
        communicationLayer?.run(operations: Robot.resetSensorOperations, condition: BlockCondition.time(milliseconds: 0))
        dismiss(animated: true, completion: nil)

    }
    
    private func disconnectBrick() {
        communicationLayer?.disconnect()
        dismiss(animated: true, completion: nil)
        delegate?.brickActionsViewDidTapDisconnect(self)
    }
}

protocol BrickActionsViewControllerDelegate: class {
    func brickActionsViewDidTapDisconnect(_ controller: BrickActionsViewController)
}
