//
//  DashboardViewController.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 19/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {
  @IBOutlet weak var statusImageView: UIImageView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var btcUSDPriceLabel: UILabel!
  @IBOutlet weak var maxLabel: UILabel!
  @IBOutlet weak var minLabel: UILabel!
  @IBOutlet weak var lineChart: LineChart! {
    didSet {
      lineChart.area = false
      lineChart.x.grid.visible = false
      lineChart.x.labels.visible = false
      lineChart.y.grid.visible = false
      lineChart.y.axis.inset = 50 
      lineChart.y.labels.visible = false
      lineChart.dots.visible = false
    }
  }
  
  let viewModel = DashboardViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.barStyle = .blackTranslucent
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationItem.largeTitleDisplayMode = .always
    //
    viewModel.entries.bind { dataEntries in
      self.btcUSDPriceLabel.text = "$\(self.viewModel.btcUSD)"
      
      self.updateStatus(with: self.viewModel.change)
      self.maxLabel.text = String(format: "%.2fK", (self.viewModel.max / 1000))
      self.minLabel.text = String(format: "%.2fK", (self.viewModel.min / 1000))
      let yValues = dataEntries.map { CGFloat($0) }
      self.lineChart.clear()
      self.lineChart.addLine(yValues)
    }
  }
}

fileprivate extension DashboardViewController {
  func updateStatus(with value: Float) {
    let isPossitive = (value >= 0)
    if let cgImage = statusImageView.image?.cgImage {
      let image = UIImage(cgImage: cgImage, scale: CGFloat(1.0), orientation: isPossitive ? .up : .down)
      let color: UIColor = isPossitive ? .green : .red
      statusImageView.image = image
      statusImageView.image = statusImageView.image!.withRenderingMode(.alwaysTemplate)
      statusImageView.tintColor = color
      statusLabel.textColor = color
      statusLabel.text = String(format: "\(isPossitive ? "+" : "")%.2f", value)
    }
  }
}
