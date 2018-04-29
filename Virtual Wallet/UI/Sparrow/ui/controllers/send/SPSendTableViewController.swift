// The MIT License (MIT)
// Copyright © 2017 Ivan Vorobei (hello@ivanvorobei.by)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

@available(iOS 9.0, *)
class SPSendTableViewController: UITableViewController {
  
  public struct SPSendContent {
    var navigationTitle: String = "Send"
    //
    var toAddressTitle: String = "To"
    var toAddressPlaceholder: String = "ELFk5lU9EUO0dJ1NmNW8JLBcgLQ2"
    var toAddressKeyboardType: UIKeyboardType = .asciiCapable
    //
    var quantityTitle: String = "BTC"
    var quantityPlaceholder: String = "0.0000001"
    var quantityKeyboardType: UIKeyboardType = .decimalPad
    //
    var feeTitle: String = "USD"
    var feeTitlePlaceholder: String = "0.0"
    var feeKeyboardType: UIKeyboardType = .decimalPad
    //
    var commentTitle: String = "Please enter a address key or quantity values"
    var buttonTitle: String = "Send"
    var errorOauthTitle: String = "Error"
    var errorOauthSubtitle: String = "Invalid address key or quantity"
    var errorOauthButtonTitle: String = "Ok"
    
    public init() {}
  }
  
  var content: SPSendContent!
  weak var delegate: SPSendViewControllerDelegate?
  
  private let textFieldTableViewCellIdentifier: String = "textFieldTableViewCellIdentifier"
  private let buttonTableViewCellIdentifier: String = "buttonTableViewCellIdentifier"
  private let bottomTextTableViewCellIdentificator: String = "bottomTextTableViewCellIdentificator"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = SPNativeStyleKit.Colors.customGray
    
    self.content = self.delegate?.sendContent
    
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationItem.largeTitleDisplayMode = .always
    
    
    self.navigationItem.title = self.content.navigationTitle
    
    self.tableView.backgroundColor = SPNativeStyleKit.Colors.customGray
    self.tableView.delaysContentTouches = false
    self.tableView.allowsSelection = false
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.tableFooterView = UIView.init()
    
    self.tableView.register(SPFormTextFiledTableViewCell.self, forCellReuseIdentifier: self.textFieldTableViewCellIdentifier)
    self.tableView.register(SPFormButtonTableViewCell.self, forCellReuseIdentifier: self.buttonTableViewCellIdentifier)
    self.tableView.register(SPFormBottomTextTableViewCell.self, forCellReuseIdentifier: self.bottomTextTableViewCellIdentificator)
    
    self.dismissKeyboardWhenTappedAround()
    
    self.updateLayout(with: self.view.frame.size)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if let cell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? SPFormTextFiledTableViewCell  {
      cell.textField.becomeFirstResponder()
    }
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: { (contex) in
      self.updateLayout(with: size)
    }, completion: nil)
  }
  
  private func updateLayout(with size: CGSize) {}
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 3
    case 1:
      return 1
    default:
      return 0
    }
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    var cell = tableView.dequeueReusableCell(withIdentifier: self.textFieldTableViewCellIdentifier, for: indexPath as IndexPath)
    
    var labelWidth: CGFloat = 0
    for text in [self.content.toAddressTitle, self.content.quantityTitle, self.content.feeTitle] {
      let font = UIFont.system(type: .Regular, size: 17)
      let fontAttributes = [NSAttributedStringKey.font: font]
      let calculatedSize = NSString.init(string: text).size(withAttributes: fontAttributes)
      labelWidth.setIfFewer(when: calculatedSize.width + 1)
    }
    
    switch indexPath {
    case IndexPath.init(row: 0, section: 0):
      if let cell = cell as? SPFormTextFiledTableViewCell {
        cell.label.text = self.content.toAddressTitle
        cell.textField.placeholder = self.content.toAddressPlaceholder
        cell.textField.keyboardType = self.content.toAddressKeyboardType
        cell.textField.delegate = self
        cell.textField.returnKeyType = .next
        cell.textField.autocapitalizationType = .none
        cell.textField.autocorrectionType = .no
        cell.fixWidthLabel = labelWidth
      }
      break
    case IndexPath.init(row: 1, section: 0):
      if let cell = cell as? SPFormTextFiledTableViewCell {
        cell.label.text = self.content.quantityTitle
        cell.textField.placeholder = self.content.quantityPlaceholder
        cell.textField.keyboardType = self.content.quantityKeyboardType
        cell.textField.delegate = self
        cell.textField.returnKeyType = .done
        cell.textField.autocapitalizationType = .none
        cell.textField.autocorrectionType = .no
        cell.textField.addTarget(self, action: #selector(quantityTextFieldDidChange), for: .editingChanged)
        cell.fixWidthLabel = labelWidth
      }
      break
    case IndexPath.init(row: 2, section: 0):
      if let cell = cell as? SPFormTextFiledTableViewCell {
        cell.label.text = self.content.feeTitle
        cell.textField.placeholder = self.content.feeTitlePlaceholder
        cell.textField.keyboardType = self.content.feeKeyboardType
        cell.textField.returnKeyType = .next
        cell.textField.autocapitalizationType = .none
        cell.textField.autocorrectionType = .no
        cell.textField.addTarget(self, action: #selector(feeTextFieldDidChange), for: .editingChanged)
        cell.fixWidthLabel = labelWidth
      }
      break
    case IndexPath.init(row: 2, section: 0):
      cell = tableView.dequeueReusableCell(withIdentifier: self.bottomTextTableViewCellIdentificator, for: indexPath as IndexPath)
      if let bottomTextCell = cell as? SPFormBottomTextTableViewCell {
        bottomTextCell.label.text = self.content.commentTitle
      }
    case IndexPath.init(row: 0, section: 1):
      cell = tableView.dequeueReusableCell(withIdentifier: self.buttonTableViewCellIdentifier, for: indexPath as IndexPath)
      if let enterButtonCell = cell as? SPFormButtonTableViewCell {
        enterButtonCell.button.setTitle(self.content.buttonTitle, for: .normal)
        enterButtonCell.separatorInset.left = 0
        enterButtonCell.button.addTarget(self, action: #selector(self.enterAction), for: .touchUpInside)
      }
      break
    default:
      break
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return UIView()
  }
  
  @objc func quantityTextFieldDidChange(_ textField: UITextField) {
    // update fee cell
    if let cell = self.tableView.cellForRow(at: IndexPath.init(row: 2, section: 0)) as? SPFormTextFiledTableViewCell  {
      let quantityValue = Float(textField.text ?? "") ?? 0.0
      cell.textField.text = "\((self.delegate?.btcUSD ?? 1) * quantityValue)"
    }
  }
  
  @objc func feeTextFieldDidChange(_ textField: UITextField) {
    // update fee cell
    if let cell = self.tableView.cellForRow(at: IndexPath.init(row: 1, section: 0)) as? SPFormTextFiledTableViewCell  {
      let usdValue = Float(textField.text ?? "") ?? 0.0
      cell.textField.text = "\( usdValue / (self.delegate?.btcUSD ?? 1))"
    }
  }
  
  @objc func enterAction() {
    var toAddressCell: SPFormTextFiledTableViewCell?
    var quantityCell: SPFormTextFiledTableViewCell?
    var feeCell: SPFormTextFiledTableViewCell?
    var buttonCell: SPFormButtonTableViewCell?
    
    if let cell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as? SPFormTextFiledTableViewCell  {
      toAddressCell = cell
    }
    if let cell = self.tableView.cellForRow(at: IndexPath.init(row: 1, section: 0)) as? SPFormTextFiledTableViewCell  {
      quantityCell = cell
    }
    if let cell = self.tableView.cellForRow(at: IndexPath.init(row: 2, section: 0)) as? SPFormTextFiledTableViewCell  {
      feeCell = cell
    }
    
    if let cell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 1)) as? SPFormButtonTableViewCell  {
      buttonCell = cell
    }
    
    if toAddressCell?.textField.isEmptyText ?? false {
      toAddressCell?.highlighted()
      return
    }
    
    if quantityCell?.textField.isEmptyText ?? false {
      quantityCell?.highlighted()
      return
    }
    
    
    buttonCell?.button.setLoadingMode()
    
    toAddressCell?.textField.isEnabled = false
    quantityCell?.textField.isEnabled = false
    feeCell?.textField.isEnabled = false
    
    
    self.delegate?.sendTransaction(to: toAddressCell?.textField.text ?? "", quantity: quantityCell?.textField.text ?? ""){ (oTransactionState) in

      buttonCell?.button.unsetLoadingMode()

      switch oTransactionState {
      case .success:
        toAddressCell?.textField.text = ""
        quantityCell?.textField.text = "0.0"
        break
      default:
        toAddressCell?.textField.isEnabled = true
        quantityCell?.textField.isEnabled = true
        feeCell?.textField.isEnabled = true
        toAddressCell?.textField.becomeFirstResponder()
        UIAlertController.show(
          title: self.content.errorOauthTitle,
          message: self.content.errorOauthSubtitle,
          buttonTitle: self.content.errorOauthButtonTitle,
          on: self
        )
        break
      }
    }
  }
}

@available(iOS 9.0, *)
extension SPSendTableViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField.superview == self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0))?.contentView {
      if let toAddressCell = self.tableView.cellForRow(at: IndexPath.init(row: 1, section: 0)) as? SPFormTextFiledTableViewCell  {
        toAddressCell.textField.becomeFirstResponder()
        return false
      }
    }
    if textField.superview == self.tableView.cellForRow(at: IndexPath.init(row: 1, section: 0))?.contentView {
      if let quantityCell = self.tableView.cellForRow(at: IndexPath.init(row: 2, section: 0)) as? SPFormTextFiledTableViewCell  {
        quantityCell.textField.becomeFirstResponder()
        return false
      }
    }
    
    
    if textField.superview == self.tableView.cellForRow(at: IndexPath.init(row: 3, section: 0))?.contentView  {
      textField.resignFirstResponder()
      self.enterAction()
      return true
    }
    
    return true
  }
}


@available(iOS 9.0, *)
protocol SPSendViewControllerDelegate: class {

  var btcUSD: Float {get}
  
  var sendContent: SPSendTableViewController.SPSendContent {get}
  
  func sendTransaction(to address: String, quantity: String, completion: @escaping (SPOtransactionState)->())
}


