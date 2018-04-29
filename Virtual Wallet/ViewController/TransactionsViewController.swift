//
//  TransactionsTableViewController.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 19/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import UIKit
import CenteredCollectionView

class TransactionsViewController: UIViewController {

  let cellPercentWidth: CGFloat = 0.8
  var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!
  
  fileprivate var viewModel = TransactionsViewModel()
  @IBOutlet weak var collectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.barStyle = .blackTranslucent
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationItem.largeTitleDisplayMode = .always
    viewModel.load()
    viewModel.content.bind { _ in
      self.collectionView.reloadData()
    }
    // Get the reference to the CenteredCollectionViewFlowLayout (REQURED)
    centeredCollectionViewFlowLayout = collectionView.collectionViewLayout as! CenteredCollectionViewFlowLayout
    
    // Modify the collectionView's decelerationRate (REQURED)
    collectionView.decelerationRate = UIScrollViewDecelerationRateFast
    
    // Assign delegate and data source
    collectionView.delegate = self
    collectionView.dataSource = self
    
    // Configure the required item size (REQURED)
    centeredCollectionViewFlowLayout.itemSize = CGSize(
      width: view.bounds.width * cellPercentWidth,
      height: view.bounds.height * cellPercentWidth * cellPercentWidth
    )
    
    // Configure the optional inter item spacing (OPTIONAL)
    centeredCollectionViewFlowLayout.minimumLineSpacing = 20
  }
  
}

extension TransactionsViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("Selected Cell #\(indexPath.row)")
  }
}

extension TransactionsViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.content.value?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: "CollectionViewCell"), for: indexPath) as! TransactionCollectionViewCell
        let model = viewModel.content.value![indexPath.row]
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        cell.dateCell.detailTextLabel?.text = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(model.date)))
        cell.quantityCell.detailTextLabel?.text = String(format: "%.6f", model.quantity)
        cell.toCell.detailTextLabel?.text = "\(model.to ?? "")"
        cell.fromCell.detailTextLabel?.text = "\(model.from ?? "")"
    return cell
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    // print("Current centered index: \(String(describing: centeredCollectionViewFlowLayout.currentCenteredPage ?? nil))")
  }
  
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    // print("Current centered index: \(String(describing: centeredCollectionViewFlowLayout.currentCenteredPage ?? nil))")
  }
}

