//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Sergei on 29/01/16.
//  Copyright © 2016 Sergei. All rights reserved.
//

import UIKit

extension UIViewController {
	func showAlert(message: String, title: String = "") {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		let OKAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
		alertController.addAction(OKAction)
		Queue.Main.execute { self.presentViewController(alertController, animated: true, completion: nil) }
	}
}

class LoginViewController: UIViewController, UITextFieldDelegate, LoginProviderDelegate {
	
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var signUpButton: UIButton!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	// variable to keep track of active text fields
	weak var activeField = UITextField()

	override func viewDidLoad() {
		super.viewDidLoad()
		loginButton.layer.cornerRadius = 5
		emailTextField.text = "sjepifanov@hotmail.com"
		passwordTextField.text = "Mong2005!"
	}
	
	override func viewDidLayoutSubviews() {
		// If any of text fields is active do not center scroll view
		if let _ = activeField { return }
		centerContentView()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		subscribeToKeyboardNotifications()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		unsubscribeFromKeyboardNotifications()
		LoginProvider.Connect.delegate = nil
		LoginProvider.Connect.client = nil
	}

	// MARK: - Actions
	@IBAction func loginButtonAction(sender: AnyObject) {
		activityIndicator.startAnimating()
		LoginProvider.Connect.client = HTTPClient()
		LoginProvider.Connect.delegate = self
		let loginUser = LoginUser(email: emailTextField.text, password: passwordTextField.text)
		let provider = LoginProvider.Email(loginUser)
		provider.login()
	}

	@IBAction func signUpButtonAction(sender: AnyObject) {
		openUdacitySignUpPage()
	}

	// MARK: - Login Provider Delegate
	func loginProvider(loginProvider: LoginProvider, didSucceed: UserInformation) {
		activityIndicator.stopAnimating()
		showMapViewController(didSucceed)
	}
	
	func loginProvider(loginProvider: LoginProvider, didError error: NSError) {
		activityIndicator.stopAnimating()
		self.showAlert(error.localizedDescription, title: "Error")
	}
	
	// MARK: View Helpers
	func showMapViewController(currentUser: UserInformation) {
		let controller = storyboard!.instantiateViewControllerWithIdentifier(String(MapViewController)) as! MapViewController
		controller.currentUser = currentUser
		//let myNavController = storyboard!.instantiateViewControllerWithIdentifier("MapViewNavigationController") as! UINavigationController
		//showViewController(myNavController, sender: controller)
		//MapViewNavigationController
		let navController = UINavigationController(rootViewController: controller)
		//navController.setToolbarHidden(false, animated: true)
		showViewController(navController, sender: self)
	}
	
	func openUdacitySignUpPage() {
		UIApplication.sharedApplication().openURL(NSURL(string: Constants.URL.UdacitySignUpURL)!)
	}
	
	// MARK: - Keyboard Helpers
	func subscribeToKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().addObserver(self,
			selector: "keyboardWillShow:",
			name: UIKeyboardWillShowNotification,
			object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self,
			selector: "keyboardWillHide:",
			name: UIKeyboardWillHideNotification,
			object: nil)
	}
	
	func unsubscribeFromKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().removeObserver(self,
			name: UIKeyboardWillShowNotification,
			object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self,
			name: UIKeyboardWillHideNotification,
			object: nil)
	}
	
	func keyboardWillShow(notification: NSNotification) {
		let kbHeight = getKeyboardHeight(notification)
		let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, kbHeight, 0.0)
		scrollView.contentInset = contentInsets
		
		var aRect: CGRect = contentView.frame
		aRect.size.height -= kbHeight
		if let activeField = activeField {
			if CGRectContainsPoint(aRect, activeField.frame.origin) {
				scrollView.scrollRectToVisible(activeField.frame, animated: true)
			}
		}
	}
	
	func keyboardWillHide(notification: NSNotification) {
		centerContentView()
	}
	
	func getKeyboardHeight(notification: NSNotification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
		return keyboardSize.CGRectValue().height
	}

	// MARK: - Configure Login Screen
	func centerContentView() {
		let scrollViewBounds = scrollView.bounds
		let contentViewBounds = contentView.bounds
		
		var scrollViewInsets = UIEdgeInsetsZero
		scrollViewInsets.top = scrollViewBounds.size.height/2.0;
		scrollViewInsets.top -= contentViewBounds.size.height/2.0;
		
		scrollViewInsets.bottom = scrollViewBounds.size.height/2.0
		scrollViewInsets.bottom -= contentViewBounds.size.height/2.0;
		scrollViewInsets.bottom += 1
		
		scrollView.contentInset = scrollViewInsets
	}
	
	// MARK: - Text Field Delegate
	func textFieldDidBeginEditing(textField: UITextField) {
		activeField = textField
	}
	
	func textFieldDidEndEditing(textField: UITextField) {
		activeField = nil
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}
