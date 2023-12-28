//
//  PhoneNumberViewController.swift
//  JioMeetSDKDemo
//
//  Created by Shivam Tripathi on 21/12/23.
//

import Foundation
import UIKit
import CommonCrypto
import CryptoKit
import JioMatrixTranslationSDK

class PhoneNumberViewController: UIViewController, UITextFieldDelegate {
    var dummyToken = "eyJhbGciOiJIUzI1NiJ9.eyJwbGF0Zm9ybSI6Imppb21lZXQiLCJwaG9uZU5vIjoiNzg4OTc2NDcyMiIsInNvdXJjZSI6Im15amlvIiwic3Vic2NyaWJlcklkIjoiNzg4OTc2NDcyMiIsImlhdCI6MTUxNjIzOTAyMiwiZXhwIjoxOTIwMjY5MDIyfQ.DvdRIzVtrnZo0-QwIBFbODkp-rM7eLQNKK3uUTThceE"
    private var translationView = JMTranslationView()

    // Create a text field to input the phone number
    private let phoneNumberTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter Phone Number",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray]
        )
        textField.textColor = UIColor.black // Set a color contrasting with the background
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.keyboardType = .phonePad
        textField.borderStyle = .bezel
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let telephoneImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "phone")
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor.blue
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = UIColor.blue
        self.title = "JioTranslate"
        navigationController?.navigationBar.isTranslucent = false
        view.addSubview(telephoneImageView)
        view.addSubview(phoneNumberTextField)
        view.addSubview(continueButton)
        // Add left padding or an icon (adjust width as needed)
        let leftPaddingView = UIView(frame: CGRect(x: 20, y: 0, width: 10, height: 1))
        phoneNumberTextField.leftView = leftPaddingView
        phoneNumberTextField.leftViewMode = .always
        phoneNumberTextField.delegate = self
        phoneNumberTextField.text = "9898656387"
        continueButton.addTarget(self, action: #selector(continueWithoutToken), for: .touchUpInside)
        
        // view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            telephoneImageView.centerXAnchor.constraint(equalTo: phoneNumberTextField.centerXAnchor),
            telephoneImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            telephoneImageView.widthAnchor.constraint(equalToConstant: 80),
            telephoneImageView.heightAnchor.constraint(equalToConstant: 80),
            phoneNumberTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            phoneNumberTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            phoneNumberTextField.topAnchor.constraint(equalTo: telephoneImageView.bottomAnchor, constant: 30),
            phoneNumberTextField.heightAnchor.constraint(equalToConstant: 70),
            continueButton.centerXAnchor.constraint(equalTo: phoneNumberTextField.centerXAnchor),
            continueButton.topAnchor.constraint(equalTo: phoneNumberTextField.bottomAnchor, constant: 30),
            continueButton.widthAnchor.constraint(equalToConstant: 200),
            continueButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    @objc private func continueWithoutToken() {
        // Handle the action when "Continue without token" button is tapped
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.phoneNumberTextField.resignFirstResponder()
        let token = self.getToken()
        translationView.translatesAutoresizingMaskIntoConstraints = false
        translationView.frame = self.view.frame
        view.addSubview(translationView)
        translationView.pinViewToSuperView(superView: view)
        let config = JMTranslationConfig(speechKey: "3b0d9f07d9ef41c099dc9243e3012051", speechRegion: "centralindia", textTranslationKey: "9c47c5bdb4504cd48422ee2b8683d3c5")
        translationView.setUpTranslationScreen(webToken: token, config: config)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard when "Return" is pressed
        return true
    }
    
    
    func getToken() -> String {
        if phoneNumberTextField.text == "" {
            return dummyToken
        }
        let header = [
            "alg": "HS256"
        ]
        
        let payloadDict: [String: Any] = [
            "platform": "jiomeet",
            "phoneNo": phoneNumberTextField.text ?? "",
            "source": "myjio",
            "subscriberId": phoneNumberTextField.text ?? "",
            "iat": 1516239022,
            "exp": 1920269022
        ]
        
        var jwtB64Header = ""
        var jwtB64Payload = ""
        var signature = ""
        
        do {
            let headerData = try JSONSerialization.data(withJSONObject: header)
            let payloadData = try JSONSerialization.data(withJSONObject: payloadDict)
            jwtB64Header = headerData.base64EncodedString().replacingOccurrences(of: "=", with: "")
            jwtB64Payload = payloadData.base64EncodedString().replacingOccurrences(of: "=", with: "")
            let secret = "076602d3-a4db-4347-87e9-31360296af6b"
            signature = createSignature(jwtB64Header, jwtB64Payload, secret)
        } catch {
            print("Error encoding JSON: \(error)")
        }
        let jsonWebToken = "\(jwtB64Header).\(jwtB64Payload).\(signature)"
        print("the JWT is: \(jsonWebToken)")
        return jsonWebToken
    }
    
    func createSignature(_ jwtB64Header: String, _ jwtB64Payload: String, _ secret: String) -> String {
        guard let secretData = secret.data(using: .utf8),
              let data = "\(jwtB64Header).\(jwtB64Payload)".data(using: .utf8) else {
            return ""
        }
        var hmac = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        secretData.withUnsafeBytes { keyPtr in
            data.withUnsafeBytes { dataPtr in
                CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyPtr.baseAddress, secretData.count, dataPtr.baseAddress, data.count, &hmac)
            }
        }
        let signatureData = Data(hmac)
        let signature = signatureData.base64EncodedString()
        let cleanedSignature = replaceSpecialChars(signature)
        return cleanedSignature
    }
    
    func replaceSpecialChars(_ b64String: String) -> String {
        var replacedString = b64String
        replacedString = replacedString.replacingOccurrences(of: "=", with: "")
        replacedString = replacedString.replacingOccurrences(of: "+", with: "-")
        replacedString = replacedString.replacingOccurrences(of: "/", with: "_")
        return replacedString
    }
    
}




extension UIView {
    func pinViewToSuperView(superView: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: superView.leadingAnchor),
            trailingAnchor.constraint(equalTo: superView.trailingAnchor),
            topAnchor.constraint(equalTo: superView.topAnchor),
            bottomAnchor.constraint(equalTo: superView.bottomAnchor),
        ])
    }
}
