import UIKit

extension PlatesViewController: PortModeSwitcherViewDelegate {
    func portModeSwitcherView(_ switcherView: PortModeSwitcherView, didSelect mode: PortMode) {
        guard let connection = switcherView.connection else { return }

        let modeValue = mode.EV3Value(for: connection.type)
        let operation = ReplyOperation.opInput_Device_Get_Ready_SI(layer: 0, port: connection.port.inputValue, type: 0, mode: modeValue)
        communicationLayer?.run(operations: [operation], isUserInitiated: false)
    }
}
