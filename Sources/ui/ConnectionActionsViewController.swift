import Foundation
import ExternalAccessory
import UIKit
import PlaygroundSupport

@objc(ConnectionActionsViewController)
class ConnectionActionsViewController: UITableViewController {
    
    private var observerContext = 1
    
    var accessories: [EAAccessory]?
    var accessoryNames: [Int: String]?
    
    var communicationLayer: EV3CommunicationLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addObserver(self, forKeyPath: #keyPath(UITableView.contentSize), options: [.new], context: &observerContext)
        
        accessories = EAAccessoryManager.shared().connectedAccessories.filter { $0.isEV3Accessory() }
        accessoryNames = PlaygroundKeyValueStore.current.connectedBricks
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        tableView.removeObserver(self, forKeyPath: "contentSize")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let accessoryCount = accessories?.count ?? 0
        let cellIndex = indexPath.row
        
        if cellIndex == accessoryCount {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BrickCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("Add new brick", comment: "text that indicates the action of adding a new brick")
            return cell
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = NSLocalizedString("EV3 Brick", comment: "the default name for unknown ev3 bricks")
            if
                let accessories = accessories,
                let accessoryNames = accessoryNames,
                case let connectionID = accessories[cellIndex].connectionID,
                let brickName = accessoryNames[connectionID] {
                cell.textLabel?.text = brickName
            }
            return cell
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (accessories?.count ?? 0) + 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Available Bricks", comment: "the header for the overview of known or previously connected ev3 bricks")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let accessoryCount = accessories?.count ?? 0
        let cellIndex = indexPath.row
        
        if cellIndex < accessoryCount,
            let accessories = accessories {
            let accessory = accessories[cellIndex]
            communicationLayer?.set(accessory: accessory)
            self.dismiss(animated: true, completion: nil)
        } else if cellIndex == accessoryCount {
            self.dismiss(animated: true, completion: nil)
            EAAccessoryManager.shared().showBluetoothAccessoryPicker(withNameFilter: nil, completion: nil)
        }
    }
    
    // MARK: - Table view observer
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let observedObject = object, context == &observerContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if observedObject as? UITableView == tableView && keyPath == #keyPath(UITableView.contentSize) {
            preferredContentSize = CGSize(width: tableView.contentSize.width, height: tableView.contentSize.height)
        }
    }
}
