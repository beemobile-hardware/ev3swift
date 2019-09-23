import UIKit
import PlaygroundSupport
import ExternalAccessory

@objc(ConnectionViewController)
public class ConnectionViewController: UIViewController, ConnectionOverviewViewControllerDelegate, ConnectionInstructionsViewControllerDelegate {
    
    @IBOutlet weak var contentContainer: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentContainerTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentContainerBottomConstraint: NSLayoutConstraint!
    
    var communicationLayer: EV3CommunicationLayer?
    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .legoLightGray
        contentContainer.backgroundColor = .legoLightGray
        scrollView.backgroundColor = .legoLightGray
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if childViewControllers.isEmpty {
            let overviewController: ConnectionOverviewViewController = ConnectionOverviewViewController.instantiateFromMainStoryboard()
            overviewController.delegate = self
            embed(overviewController)
        }
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateScrollViewInsets()
    }
    
    // MARK: Convenience
    
    private func embed(_ childController: UIViewController) {
        // Remove any existing child controller.
        if let child = childViewControllers.first {
            child.willMove(toParentViewController: nil)
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        }
        
        // Add the new child controller, constrained to `containerView`.
        addChildViewController(childController)
        childController.view.translatesAutoresizingMaskIntoConstraints = false
        childController.view.backgroundColor = .legoLightGray
        scrollView.insertSubview(childController.view, at: 0)
        
        NSLayoutConstraint.activate([
            childController.view.topAnchor.constraint(greaterThanOrEqualTo: scrollView.topAnchor),
            childController.view.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor),
            childController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            childController.view.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            childController.view.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            ])
        childController.didMove(toParentViewController: self)
        
        updateScrollViewInsets()
    }
    
    private func updateScrollViewInsets() {
        guard let childController = childViewControllers.first else { return }

        // Find the parent controller that has a valid `liveViewSafeAreaGuide`.
        var controller: UIViewController? = self
        var safeViewInsets = UIEdgeInsets.zero

        while controller != nil {
            guard let layoutFrame = (controller as? PlaygroundLiveViewSafeAreaContainer)?.liveViewSafeAreaGuide.layoutFrame, layoutFrame.size.height > 0, layoutFrame.size.width > 0 else {
                controller = controller?.parent
                continue
            }

            safeViewInsets.top = layoutFrame.origin.y
            safeViewInsets.bottom = controller!.view.bounds.size.height - layoutFrame.maxY
            break
        }
        
        // Update the conainer view insets so it fits within the safe area.
        contentContainerTopConstraint.constant = safeViewInsets.top
        contentContainerBottomConstraint.constant = safeViewInsets.bottom
        view.layoutIfNeeded()
        
        scrollView.contentInset.top = max(0, (scrollView.bounds.size.height - childController.view.bounds.size.height) / 2.0)
    }
    
    func showConnectDialog() {
        let isConnected = EAAccessoryManager.shared().connectedAccessories.contains(where: {$0.isEV3Accessory()})
        if isConnected {
            performSegue(withIdentifier: "showConnectedBricks", sender: self)
        } else {
            EAAccessoryManager.shared().showBluetoothAccessoryPicker(withNameFilter: nil, completion: nil)
        }
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let actionsController = segue.destination as? ConnectionActionsViewController {
            actionsController.popoverPresentationController?.delegate = self
            actionsController.popoverPresentationController?.sourceView = view
            actionsController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            actionsController.communicationLayer = communicationLayer
        }
    }
    
    // MARK: ConnectionOverviewViewControllerDelegate
    
    func overviewControllerDidTapShowInstructions(_ controller: ConnectionOverviewViewController) {
        let instructionsController: ConnectionInstructionsViewController = ConnectionInstructionsViewController.instantiateFromMainStoryboard()
        instructionsController.delegate = self
        embed(instructionsController)
    }
    
    func overviewControllerDidTapConnect(_ controller: ConnectionOverviewViewController) {
        showConnectDialog()
    }
    
    // MARK: ConnectionInstructionsViewControllerDelegate
    
    func instructionsControllerDidTapConnect(_ controller: ConnectionInstructionsViewController) {
        showConnectDialog()
    }

}

extension ConnectionViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if controller.presentedViewController is ConnectionActionsViewController {
            return .none
        }
        else {
            return controller.presentedViewController.modalPresentationStyle
        }
    }
}
