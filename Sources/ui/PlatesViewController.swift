import UIKit
import PlaygroundSupport

@objc(PlatesViewController)
public class PlatesViewController: UIViewController, PlaygroundLiveViewSafeAreaContainer {
    struct LoggedData {
        var modes: [PlateConnection: PortMode] = [:]
        var data: [PlateConnection: ConnectionData] = [:]
        var startTime = Date()
    }
    
    var accumulatedErrors: [RobotError] = []

    // MARK: UI properties
    
    @IBOutlet weak var contentContainerView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var modeToggleButton: UIButton!
    @IBOutlet weak var actionsButton: UIButton!
    
    @IBOutlet weak var emptyPortsView: UIView!
    @IBOutlet var emptyPortsLabels: [UILabel]!

    @IBOutlet weak var gridLinesView: GridLinesView!

    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var headerContainerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerContainerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerContainerLeftContentWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerContainerLeftView: UIView!

    weak var currentOutputPortsView: PortsView?
    weak var currentInputPortsView: PortsView?
    
    let studDimensions = StudDimensions(totalSize: 10, inset: 2)
    var lastGraphScrollPosition: CGFloat?
    
    private(set) var isTransitioningLayout = false
    
    // MARK: Comms properties
    
    private(set) var connections: [PlateConnection] = []
    private(set) var liveData = LoggedData()
    private(set) var lastRunData: LoggedData?

    private(set) var communicationLayer: EV3CommunicationLayer?
    
    var userCodeState: UserCodeState = .ready {
        didSet {
            switch userCodeState {
            case .ready, .running:
                lastRunData = nil
                liveData = LoggedData()
                
            case .finished:
                lastRunData = liveData
            }
            
            // Update any visible `PlateTableViewCell` with the new state.
            for case let cell as PlateTableViewCell in collectionView.visibleCells {
                cell.userCodeState = userCodeState
            }
            
            // Don't scroll dequeued `PlateTableViewCell`s to an old offset.
            lastGraphScrollPosition = nil
        }
    }
    
    // MARK: UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        log(message: "Platesviewcontroller did load")

        for grayView in [view, contentContainerView, collectionView, emptyPortsView, headerContainerLeftView] {
            grayView?.backgroundColor = .legoLightGray
        }
        
        NSLayoutConstraint.activate([
            contentContainerView.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: studDimensions.totalSize),
            contentContainerView.bottomAnchor.constraint(equalTo: liveViewSafeAreaGuide.bottomAnchor, constant: studDimensions.totalSize)
        ])
        
        // Inset the content on left and right of the collection view.
        collectionView.contentInset.left += studDimensions.totalSize
        collectionView.contentInset.right += studDimensions.totalSize
        collectionView.isPrefetchingEnabled = false

        // Register the collection view's supplementary views.
        let nib = UINib(nibName: PortsView.nibName, bundle: nil)
        collectionView.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: PortsView.reuseIdentifier)
        collectionView.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: PortsView.reuseIdentifier)
        collectionView.register(PlateCollectionViewMask.self, forSupplementaryViewOfKind: PlateCollectionViewMask.collectionViewElementKind, withReuseIdentifier: PlateCollectionViewMask.reuseIdentifier)
        collectionView.register(StuddedView.self, forSupplementaryViewOfKind: StuddedView.collectionViewElementKind, withReuseIdentifier: StuddedView.reuseIdentifier)
        
        // Set the initial collection view layout.
        let layout = PlateGridViewLayout(studDimensions: studDimensions)
        layout.delegate = self
        collectionView.collectionViewLayout = layout
        updateToggleButton()
        
        // Startup communications with the EV3 brick.
        communicationLayer = EV3CommunicationLayer(commandManager: DefaultCommandManager(), delegate: self)
        communicationLayer?.setup()
        
        // Hide the collection view until a connection with the EV3 has been made.
        updateChildViewVisibility()
        
        // Give the actions button a localized accessibility label.
        actionsButton.accessibilityLabel = NSLocalizedString("EV3 actions", comment: "Voice Over summary description of live view actions button")
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        log(message: "Platesviewcontroller did appear")

        // Add an accessibility item to the empty ports view to allow Voice Over
        // to more easily read all the instructions.
        if let window = view.window, let firstLabel = emptyPortsLabels.first {
            let accessibilityElement = UIAccessibilityElement(accessibilityContainer: emptyPortsView)
            let labelsFrame = emptyPortsLabels.reduce(firstLabel.frame) { frame, label in
                return frame.union(label.frame)
            }
            accessibilityElement.accessibilityFrame = window.convert(labelsFrame, from: firstLabel.superview!)
            accessibilityElement.accessibilityLabel = emptyPortsLabels.map({ $0.text! }).joined(separator: ". ")
            emptyPortsView.accessibilityElements = [accessibilityElement]
        }

        // If there is no connection with the EV3, show the connection view controller
        if communicationLayer?.communicator?.accessory == nil && presentedViewController == nil {
            showConnectionView()
        }
    }
    
    func showConnectionView() {
        let connectionController: ConnectionViewController = ConnectionViewController.instantiateFromMainStoryboard()
        connectionController.communicationLayer = communicationLayer
        present(connectionController, animated: false, completion: nil)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        contentContainerView.layoutIfNeeded()
        collectionView.collectionViewLayout.invalidateLayout()

        if collectionView.collectionViewLayout is PlateGridViewLayout {
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        }
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let actionsController = segue.destination as? BrickActionsViewController {
            actionsController.popoverPresentationController?.delegate = self
            actionsController.delegate = self
            actionsController.communicationLayer = communicationLayer
        }
    }

    // MARK: IBActions
    
    @IBAction func toggleDisplayMode(_ sender: UIButton) {
        // Create the new layout.
        let newLayout: PlateCollectionViewLayout
        
        if collectionView.collectionViewLayout is PlateGridViewLayout {
            newLayout = PlateTableViewLayout(studDimensions: studDimensions)
            collectionView.alwaysBounceVertical = true
        }
        else {
            newLayout = PlateGridViewLayout(studDimensions: studDimensions)
            collectionView.alwaysBounceVertical = false
        }

        newLayout.delegate = self
        
        // Hide cell content during the transition.
        setVisibleCellContent(hidden: true)
        
        // Transition to the new layout.
        isTransitioningLayout = true
        collectionView.setCollectionViewLayout(newLayout, animated: true) { completed in
            if completed {
                // Reload the cells to update their cell class.
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                self.setVisibleCellContent(hidden: false)
            }
            
            self.setVisibleCellContent(hidden: false)
            self.isTransitioningLayout = false
            self.updateLines()
        }
        
        // Update the toggle button image and description
        updateToggleButton()
    }
    
    func setVisibleCellContent(hidden: Bool) {
        guard let layout = collectionView.collectionViewLayout as? PlateCollectionViewLayout else { return }
        var viewsToReveal: [UIView] = []
        
        for cell in collectionView.visibleCells {
            cell.contentView.isHidden = hidden
        }

        for kind in [UICollectionElementKindSectionHeader, UICollectionElementKindSectionFooter] {
            for supplementaryView in self.collectionView.visibleSupplementaryViews(ofKind: kind) {
                if hidden {
                    supplementaryView.isHidden = true
                }
                else {
                    supplementaryView.isHidden = !layout.includePortsAndLines
                    viewsToReveal.append(supplementaryView)
                }
            }
        }

        if hidden {
            gridLinesView.isHidden = true
        }
        else {
            gridLinesView.isHidden = !layout.includePortsAndLines
            viewsToReveal.append(gridLinesView)
        }
        
        if !viewsToReveal.isEmpty {
            for view in viewsToReveal {
                view.alpha = 0.0
            }
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                for view in viewsToReveal {
                    view.alpha = 1.0
                }
            }, completion: nil)
        }
    }
    
    private func updateChildViewVisibility() {
        collectionView.isHidden = connections.isEmpty
        gridLinesView.isHidden = connections.isEmpty
        modeToggleButton.isEnabled = !connections.isEmpty
        emptyPortsView.isHidden = !connections.isEmpty
    }
    
    // MARK: Connection and collection view helpers.
    
    func removeConnection(at index: Int) {
        // Remove the connection from the backing store before also removing it
        // from the collection view.
        connections.remove(at: index)
        if isViewLoaded {
            collectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
            collectionView.collectionViewLayout.invalidateLayout()

            updateChildViewVisibility()
        }
    }
    
    func removeAllConnections() {
        while !connections.isEmpty {
            removeConnection(at: 0)
        }
        
        updatePortViews()
    }
    
    func addConnection(_ connection: PlateConnection) {
        // Do nothing if the connection is already being shown.
        guard connections.index(of: connection) == nil else { return }
        
        // Add the connection and sort the array.
        connections.append(connection)
        connections = connections.sorted { lhs, rhs in
            if lhs.port is OutputPort && rhs.port is InputPort {
                return true
            }
            else if lhs.port is InputPort && rhs.port is OutputPort {
                return false
            }
            else {
                return lhs.port.inputValue < rhs.port.inputValue
            }
        }
        
        // Add the connection to the backing store before also adding it to the
        // collection view.
        if let insertedIndex = connections.index(of: connection), isViewLoaded {
            collectionView.insertItems(at: [IndexPath(item: insertedIndex, section: 0)])
            collectionView.collectionViewLayout.invalidateLayout()

            updateChildViewVisibility()
        }
    }
    
    func updatePortViews() {
        func update(portsView: PortsView, withConnectionsFor ports: [Port]) {
            for (index, port) in ports.enumerated() {
                portsView.portViews[index].configure(with: connection(for: port))
            }
        }
        
        if let portsView = currentOutputPortsView {
            update(portsView: portsView, withConnectionsFor: OutputPort.all)
        }
        if let portsView = currentInputPortsView {
            update(portsView: portsView, withConnectionsFor: InputPort.all)
        }
    }
    
    func updateToggleButton() {
        if collectionView.collectionViewLayout is PlateGridViewLayout {
            modeToggleButton.setImage(UIImage(named:"live_view_graph_mode")!, for: .normal)
            modeToggleButton.accessibilityLabel = NSLocalizedString("Switch to graph mode", comment: "Voice Over description of button that switches the live view to show graphs of data over time")
        }
        else {
            modeToggleButton.setImage(UIImage(named:"live_view_plates_mode")!, for: .normal)
            modeToggleButton.accessibilityLabel = NSLocalizedString("Switch to grid mode", comment: "Voice Over description of button that switches the live view to a grid of connected devices")
        }
    }
    
    func updateLines() {
        guard !isTransitioningLayout else { return }
        
        if let layout = collectionView.collectionViewLayout as? PlateGridViewLayout, layout.includePortsAndLines {
            let offset = CGSize(width: layout.layoutOffset.width + collectionView.contentInset.left,
                                height: layout.layoutOffset.height + collectionView.contentInset.top)
            gridLinesView.configure(with: layout.calculateGridLines(), studDimensions: studDimensions, offset: offset)
            
            if gridLinesView.isHidden {
                gridLinesView.isHidden = false
                gridLinesView.alpha = 0.0
                
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                    self.gridLinesView.alpha = 1.0
                }, completion: nil)
            }
        }
        else {
            gridLinesView.isHidden = true
        }
    }
    
    
    private func queryConnectionTypes() {
        let inputs:[Port] = InputPort.all
        let outputs:[Port] = OutputPort.all
        
        let ports: [Port] = inputs + outputs
        
        let getConnections: [ReplyOperation] = ports.map { ReplyOperation.opInput_Device_GET_CONNECTION(layer: 0, port: $0.inputValue) }
        communicationLayer?.run(operations: getConnections, isUserInitiated: false)
    }
    
    // MARK: Data recording
    
    func record(modes: [PlateConnection: PortMode], data: [PlateConnection: Float]) {
        let now = Date()
        
        
        // Check if the port configuration has changed (NOT THE MODES!)
        if !liveData.modes.keys.elementsEqual(modes.keys) {
            log(message: "Port configuration changed. Querying new configuration...")
            queryConnectionTypes()
        }
        
        // If the connection modes have changed, replace any existing data with
        // the current set.
        if liveData.modes != modes {
            // Clear the current live data.
            liveData = LoggedData(modes: modes, data: [:], startTime: now)
            
            // If we have data for a previous user code run, replace it with the
            // most recent data.
            if lastRunData != nil {
                lastRunData = liveData
                for (connection, value) in data {
                    lastRunData?.data[connection] = ConnectionData(startTime: now, initialValue: value, mode: modes[connection]!)
                }
                
                collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
            }
        }

        // Update the stored data with the new values.
        for (connection, value) in data {
            if var historicalData = liveData.data[connection] {
                historicalData.append(value, for: now)
                liveData.data[connection] = historicalData
            }
            else {
                liveData.data[connection] = ConnectionData(startTime: now, initialValue: value, mode: modes[connection]!)
            }
        }

        if collectionView.collectionViewLayout is PlateGridViewLayout || userCodeState != .finished {
            // Update the data logger for each connection.
            for (index, connection) in connections.enumerated() {
                // Get the mode, data and associated logger for the connection.
                guard let mode = liveData.modes[connection],
                    let data = liveData.data[connection],
                    let logger = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ConnectionDataLogger
                else {
                    continue
                }
                // Send the data to the logger.
                logger.logConnectionData(data, for: mode)
            }
        }
    }
    
    private func connection(for port: Port) -> PlateConnection? {
        return connections.first(where: { $0.port.isEqual(to: port) })
    }
}

extension PlatesViewController: PlateCollectionViewLayoutDelegate {
    func plateCollectionViewLayoutDidInvalidate(_ layout: PlateCollectionViewLayout) {
        gridLinesView.isHidden = true
    }
    
    func plateCollectionViewLayoutDidChange(_ layout: PlateCollectionViewLayout) {
        headerContainerTopConstraint.constant = collectionView.contentInset.top + layout.layoutOffset.height
        headerContainerLeadingConstraint.constant = collectionView.contentInset.left + layout.layoutOffset.width
        headerContainerTrailingConstraint.constant = (collectionView.contentInset.right + layout.layoutOffset.width) * -1
        headerContainerHeightConstraint.constant = 4 * studDimensions.totalSize
        headerContainerLeftContentWidthConstraint.constant = 8 * studDimensions.totalSize
        
        updateLines()
    }
}

extension PlatesViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if controller.presentedViewController is BrickActionsViewController {
            return .none
        }
        else {
            return controller.presentedViewController.modalPresentationStyle
        }
    }
}
