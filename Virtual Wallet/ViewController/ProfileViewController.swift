//
//  ProfileViewController.swift
//  Virtual Wallet
//
//  Created by Hasan Sa on 19/04/2018.
//  Copyright © 2018 Hasan Sa. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
  
  @IBOutlet weak var avatarImageView: UIImageView!
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var balanceLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  
  private var viewModel = ProfileViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.barStyle = .blackTranslucent
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationItem.largeTitleDisplayMode = .always
    
    viewModel.load()
    
    viewModel.user.bind { user in
      self.usernameLabel.text = user.username
      self.balanceLabel.text = String.init(format: "%.2f", self.viewModel.user.value?.totalBalance ?? 0)
      self.tableView.reloadData()
    }
    viewModel.balances.bind { _ in
      self.balanceLabel.text = String.init(format: "%.2f", self.viewModel.user.value?.totalBalance ?? 0)
      self.tableView.reloadData()
    }
  }
  
  @IBAction func importKeys() {
    let alertMessage = UIAlertController(title: "Address",
                                         message: "", preferredStyle: .alert)
    alertMessage.addAction(UIAlertAction(title: "Import", style: .default) { (alertAction) in
      if let textFields = alertMessage.textFields, !textFields.isEmpty {
         if let text = textFields[0].text, !text.isEmpty {
          self.viewModel.add(address: text) { success in
            if !success {
              let alertMessage = UIAlertController(title: "Error",
                                                   message: "Invalid address, Please try again", preferredStyle: .alert)
              alertMessage.addAction(UIAlertAction(title: "Ok", style: .cancel))
              self.present(alertMessage, animated: true, completion: nil)
            }
          }
        }
      }}
    )
    alertMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alertMessage.addTextField { (textField) in
      textField.placeholder = "Enter address key"
    }
    self.present(alertMessage, animated: true, completion: nil)
  }
  
  @IBAction func signOut() {
    let alertMessage = UIAlertController(title: "Please confirm sign out",
                                         message: "", preferredStyle: .actionSheet)
    alertMessage.addAction(
      UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
        self.viewModel.logout()
        (self.tabBarController as! MainTabBarController).coordinatorDelegate?.previous()
    })
    alertMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    self.present(alertMessage, animated: true, completion: nil)
  }
  
  fileprivate func copyToClipboard(_ text: String?) {
    if let text = text {
      UIPasteboard.general.string = text
    }
  }
}

extension ProfileViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    }
    return viewModel.user.value?.addresses.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    var text = ""
    var detailText = ""
    
    switch indexPath.section {
    case 0:
      if let address = viewModel.user.value?.address {
        text = address
      }
    case 1:
      if let addresses = viewModel.user.value?.addresses {
        text = Array(addresses.keys)[indexPath.row]
      }
    default: break
    }
    if let balances = viewModel.balances.value {
      detailText = String.init(format: "%.2f", balances[text] ?? 0)
    }
    cell.textLabel?.text = text
    cell.detailTextLabel?.text = detailText
    return cell
  }
}

extension ProfileViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0: return "Main Address"
    default: return "Addresses"
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    switch indexPath.section {
    case 0:
      if let key = viewModel.user.value?.address {
        copyToClipboard(key)
      }
    case 1:
      if let addresses = viewModel.user.value?.addresses {
        let key = Array(addresses.keys)[indexPath.row]
        copyToClipboard(key)
      }
    default: break
    }

  }
}
