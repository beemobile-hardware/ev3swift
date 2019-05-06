import Foundation

extension PlatesViewController : BrickActionsViewControllerDelegate {
    func brickActionsViewDidTapDisconnect(_ controller: BrickActionsViewController) {
        showConnectionView()
    }
}
