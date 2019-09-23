import Foundation
import UIKit

extension LiveViewController {
    
    func createUI() {
        
        firstShapeLayer.strokeColor = UIColor.blue.cgColor
        firstShapeLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(firstShapeLayer)
        
        secondShapeLayer.strokeColor = UIColor.red.cgColor
        secondShapeLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(secondShapeLayer)
        
        hardwareCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hardwareCollectionView)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 1
        slider.value = 1
        slider.maximumValue = 1
        slider.addTarget(self, action: #selector(updatedSlider), for: .valueChanged)
        view.addSubview(slider)
        
        let constraints = [
            hardwareCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            hardwareCollectionView.bottomAnchor.constraint(equalTo: liveViewSafeAreaGuide.bottomAnchor),
            hardwareCollectionView.widthAnchor.constraint(equalToConstant: 512),
            hardwareCollectionView.heightAnchor.constraint(equalToConstant: 240),
            
            slider.leftAnchor.constraint(equalTo: liveViewSafeAreaGuide.leftAnchor, constant: 20),
            slider.topAnchor.constraint(equalTo: liveViewSafeAreaGuide.topAnchor, constant: 20),
            slider.rightAnchor.constraint(equalTo: liveViewSafeAreaGuide.rightAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func updatedSlider() {
        currentIndex = Int(slider.value)
        drawShapes()
        hardwareCollectionView.updatedPorts(data: allPortData[currentIndex - 1])
    }
    
    func drawShapes() {
        
        var dataToDraw = allPortData
        
        dataToDraw.removeLast(dataToDraw.count - currentIndex)
        if dataToDraw.count > 100 {
            dataToDraw.removeFirst(dataToDraw.count - 100)
        }
        
        let interval = 512.0 / Float(dataToDraw.count)
        
        let firstBezierPath = UIBezierPath()
        let secondBezierPath = UIBezierPath()
        firstBezierPath.move(to: CGPoint(x: 0, y: Int(view.frame.height / 2.0)))
        secondBezierPath.move(to: CGPoint(x: 0, y: Int(view.frame.height / 2.0)))
        
        for (index, data) in dataToDraw.enumerated() {
            let x: Double = Double(interval * Float(index))
            let firstY = Double(Float(view.frame.height) / 2.0 - data[2].value)
            let secondY = Double(Float(view.frame.height) / 2.0 - data[0].value)

            firstBezierPath.addLine(to: CGPoint(x: x, y: firstY))
            secondBezierPath.addLine(to: CGPoint(x: x, y: secondY))
        }
        
        firstShapeLayer.path = firstBezierPath.cgPath
        secondShapeLayer.path = secondBezierPath.cgPath
    }
    
    func gotNewPortData() {
        dates.append(Date())
        currentIndex += (currentIndex + 1 == dates.count ? 1 : 0)
        slider.maximumValue = Float(dates.count)
        slider.value = Float(currentIndex)
    }
}
