//
//  SendViewController.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 19/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import UIKit

class SendViewController: UIViewController, SPSendViewControllerDelegate {
  
  private let viewModel = SendViewModel()
  private var sendTableViewController = SPSendTableViewController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.barStyle = .blackTranslucent
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationItem.largeTitleDisplayMode = .always
    sendTableViewController.delegate = self
    sendTableViewController.willMove(toParentViewController: self)
    sendTableViewController.view.frame = view.bounds
    self.view.addSubview(sendTableViewController.view)
    self.addChildViewController(sendTableViewController)
    sendTableViewController.didMove(toParentViewController: self)
  }
  
  var btcUSD: Float {
    return BlockChainService.shared.btcUSD
  }
  
  var sendContent: SPSendTableViewController.SPSendContent {
    return SPSendTableViewController.SPSendContent()
  }
  
  func sendTransaction(to address: String, quantity: String, completion: @escaping (SPOtransactionState) -> ()) {
    guard let amount = Float(quantity)  else {
      completion(.invalidAddres)
      return
    }
    viewModel.sendTransaction(to: address, quantity: amount) { (success) in
      DispatchQueue.main.async {
        guard success else {
          completion(.error)
          return
        }
        completion(.success)
      }

    }
  }
  
}
