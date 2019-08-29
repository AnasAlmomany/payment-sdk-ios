//
//  StoreFrontViewController.swift
//  Simple Integration
//
//  Created by Johnny Peter on 22/08/19.
//  Copyright © 2019 Network International. All rights reserved.
//

import Foundation
import UIKit
import NISdk
import PassKit

class StoreFrontViewController:
    UIViewController,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDelegate,
    CardPaymentDelegate,
    ApplePayDelegate {
    
    var collectionView: UICollectionView?
    let payButton = UIButton()
    lazy var applePayButton = PKPaymentButton(paymentButtonType: .buy , paymentButtonStyle: .black)
    let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 20
        return stack
    }()
    let pets = ["🐊", "🐅", "🐆", "🦓", "🦏", "🦠", "🐙", "🐡", "🐋", "🐳"]
    var total: Int = 0 {
        didSet { showHidePayButtonStack() }
    }
    var selectedItems: [Product] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPaymentButtons()
        
        title = "Zoomoji Store"
//        let indexPath = IndexPath(item: pets.count, section: 0)
        self.collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
//        self.collectionView?.insertItems(at: [indexPath])
        collectionView?.register(ProductViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        collectionView?.delegate = self
        collectionView?.allowsSelection = true
        collectionView?.allowsMultipleSelection = true
        collectionView?.dataSource = self
        collectionView?.backgroundColor = UIColor.white
        view.addSubview(collectionView!)
    }
    
    func resetSelection() {
        total = 0
        selectedItems = []
        collectionView?.deselectAllItems(animated: true, resetHandler: {
            cell in
            if let cell = cell as! ProductViewCell? {
                cell.updateBorder(selected: false)
            }
        })
    }
    
    func showAlertWith(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func paymentDidComplete(with status: PaymentStatus) {
        if(status == .PaymentSuccess) {
            resetSelection()
            showAlertWith(title: "Payment Successfull", message: "Your Payment was successfull.")
            return
        }
        showAlertWith(title: "Payment Failed", message: "Your Payment could not be completed.")
    }
    
    @objc func authorizationDidComplete(with status: AuthorizationStatus) {
        if(status == .AuthFailed) {
            print("Auth Failed :(")
            return
        }
         print("Auth Passed :)")
    }
    
    @objc func payButtonTapped() {
        let orderCreationViewController = OrderCreationViewController(paymentAmount: total, and: self, using: .Card, with: selectedItems)
        self.present(orderCreationViewController, animated: true, completion: nil)
    }
    
    @objc func applePayButtonTapped(applePayPaymentRequest: PKPaymentRequest) {
        let orderCreationViewController = OrderCreationViewController(paymentAmount: total, and: self, using: .ApplePay, with: selectedItems)
        self.present(orderCreationViewController, animated: true, completion: nil)
    }
    
    func setupPaymentButtons() {
        navigationController?.view.addSubview(buttonStack)
        configureButtonStack()
        if let parentView = navigationController?.view {
            buttonStack.translatesAutoresizingMaskIntoConstraints = false
            buttonStack.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 20).isActive = true
            buttonStack.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20).isActive = true
            buttonStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
            buttonStack.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -50).isActive = true
            buttonStack.isHidden = true
        }
        
        // Pay button for card
        payButton.backgroundColor = .black
        payButton.setTitleColor(.white, for: .normal)
        payButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        payButton.setTitleColor(UIColor(red: 255, green: 255, blue: 255, alpha: 0.6), for: .highlighted)
        payButton.setTitle("Pay", for: .normal)
        payButton.layer.cornerRadius = 5
        payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        buttonStack.addArrangedSubview(payButton)
        
        // Pay button for Apple Pay
        if(NISdk.sharedInstance.deviceSupportsApplePay()) {
            applePayButton.addTarget(self, action: #selector(applePayButtonTapped), for: .touchUpInside)
            buttonStack.addArrangedSubview(applePayButton)
        }
    }
    func configureButtonStack() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.pinAsBackground(to: buttonStack)
    }
    
    func showHidePayButtonStack() {
        if(total > 0) {
            buttonStack.isHidden = false
            payButton.setTitle("Pay Aed \(total)", for: .normal)
        } else {
            buttonStack.isHidden = true
        }
    }
    
    func add(amount: Int, emoji: String) {
        total += amount
        selectedItems.append(Product(name: emoji, amount: amount))
    }
    
    func remove(amount: Int, emoji: String) {
        total -= amount
        selectedItems = selectedItems.filter { $0.name != emoji}
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! ProductViewCell
        if cell.isSelected {
            cell.updateBorder(selected: true)
        } else {
            cell.updateBorder(selected: false)
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ProductViewCell
        cell.isSelected = true
        cell.updateBorder(selected: true)
        add(amount: cell.price, emoji: cell.productLabel.text!)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ProductViewCell
        cell.isSelected = false
        cell.updateBorder(selected: false)
        remove(amount: cell.price, emoji: cell.productLabel.text!)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath as IndexPath) as! ProductViewCell
        
        cell.productLabel.text = pets[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let length = (screenWidth / 2) - 20
        return CGSize(width: length, height: length)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 80, right: 15)
    }
}
