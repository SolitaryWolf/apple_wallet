import Flutter
import UIKit
import PassKit

public class AppleWalletPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var passLibrary: PKPassLibrary?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "apple_wallet", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "apple_wallet/events", binaryMessenger: registrar.messenger())
        
        let instance = AppleWalletPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
        
        instance.passLibrary = PKPassLibrary()
        instance.setupPassLibraryNotifications()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "canAddPasses":
            result(PKPassLibrary.isPassLibraryAvailable() && PKAddPassesViewController.canAddPasses())

        case "isPassKitAvailable":
            result(PKPassLibrary.isPassLibraryAvailable())

        case "addPaymentPass":
            handleAddPaymentPass(call: call, result: result)
            
        case "getPaymentPasses":
            handleGetPaymentPasses(result: result)
            
        case "removePaymentPass":
            handleRemovePaymentPass(call: call, result: result)
            
        case "isPaymentPassActivated":
            handleIsPaymentPassActivated(call: call, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleAddPaymentPass(call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("DEBUG: handleAddPaymentPass called")
        guard let args = call.arguments as? [String: Any] else {
            print("DEBUG: handleAddPaymentPass - Invalid arguments")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }

        print("DEBUG: handleAddPaymentPass - args: \(args)")

        // Debug print each parameter before guard check
        print("DEBUG: handleAddPaymentPass - cardholderName: \(args["cardholderName"] ?? "nil")")
        print("DEBUG: handleAddPaymentPass - primaryAccountIdentifier: \(args["primaryAccountIdentifier"] ?? "nil")")
        print("DEBUG: handleAddPaymentPass - primaryAccountSuffix: \(args["primaryAccountSuffix"] ?? "nil")")
        print("DEBUG: handleAddPaymentPass - localizedDescription: \(args["localizedDescription"] ?? "nil")")
        print("DEBUG: handleAddPaymentPass - paymentNetwork: \(args["paymentNetwork"] ?? "nil")")
        print("DEBUG: handleAddPaymentPass - encryptedPassData: \(args["encryptedPassData"] ?? "nil")")

        let primaryAccountIdentifier = args["primaryAccountIdentifier"] as? String
        guard let cardholderName = args["cardholderName"] as? String,
              let primaryAccountSuffix = args["primaryAccountSuffix"] as? String,
              let localizedDescription = args["localizedDescription"] as? String,
              let paymentNetworkString = args["paymentNetwork"] as? String,
              let encryptedPassData = args["encryptedPassData"] as? [String: String] else {
            print("DEBUG: handleAddPaymentPass - Missing required parameters or type mismatch")
            result(FlutterError(code: "MISSING_PARAMETERS", message: "Missing required parameters", details: nil))
            return
        }

        print("DEBUG: handleAddPaymentPass - All parameters successfully extracted")
        
        guard PKPassLibrary.isPassLibraryAvailable() else {
            print("DEBUG: handleAddPaymentPass - PassKit library not available")
            result(FlutterError(code: "CANNOT_ADD_PAYMENT_PASSES", message: "Cannot add payment passes", details: nil))
            return
        }

        print("DEBUG: handleAddPaymentPass - PassKit library available")

        let paymentNetwork = mapPaymentNetwork(from: paymentNetworkString)
        print("DEBUG: handleAddPaymentPass - paymentNetwork: \(paymentNetwork?.rawValue ?? "nil")")

        let configuration = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2)
        configuration?.cardholderName = cardholderName
        configuration?.primaryAccountSuffix = primaryAccountSuffix
        configuration?.localizedDescription = localizedDescription
        configuration?.primaryAccountIdentifier = primaryAccountIdentifier
        
        if let paymentNetwork = paymentNetwork {
            configuration?.paymentNetwork = paymentNetwork
            print("DEBUG: handleAddPaymentPass - Set payment network: \(paymentNetwork.rawValue)")
        } else {
            print("DEBUG: handleAddPaymentPass - No payment network set")
        }

        guard let config = configuration else {
            print("DEBUG: handleAddPaymentPass - Failed to create configuration")
            result(FlutterError(code: "CONFIGURATION_ERROR", message: "Failed to create configuration", details: nil))
            return
        }

        print("DEBUG: handleAddPaymentPass - Configuration created successfully")
        print("DEBUG: handleAddPaymentPass - Attempting to create PKAddPaymentPassViewController")

        guard let addPaymentPassVC = PKAddPaymentPassViewController(requestConfiguration: config, delegate: self) else {
            print("DEBUG: handleAddPaymentPass - Failed to create PKAddPaymentPassViewController")
            result(FlutterError(code: "VIEW_CONTROLLER_ERROR", message: "Failed to create view controller", details: nil))
            return
        }

        print("DEBUG: handleAddPaymentPass - PKAddPaymentPassViewController created successfully")

        DispatchQueue.main.async {
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                print("DEBUG: handleAddPaymentPass - Presenting view controller")
                rootViewController.present(addPaymentPassVC, animated: true)
                result("SUCCESS")
            } else {
                print("DEBUG: handleAddPaymentPass - No root view controller found")
                result(FlutterError(code: "NO_ROOT_VC", message: "No root view controller found", details: nil))
            }
        }
    }
    
    private func handleGetPaymentPasses(result: @escaping FlutterResult) {
        guard let passLibrary = self.passLibrary else {
            result([])
            return
        }
        
        let passes = passLibrary.passes(of: .payment)
        let passesData = passes.map { pass -> [String: Any] in
            return [
                "passTypeIdentifier": pass.passTypeIdentifier,
                "serialNumber": pass.serialNumber,
                "localizedDescription": pass.localizedDescription,
                "organizationName": pass.organizationName,
                "isActivated": pass.isRemotePass,
                "metadata": [:]
            ]
        }
        
        result(passesData)
    }
    
    private func handleRemovePaymentPass(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let passTypeIdentifier = args["passTypeIdentifier"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let passLibrary = self.passLibrary else {
            result(false)
            return
        }
        
        if let pass = passLibrary.pass(withPassTypeIdentifier: passTypeIdentifier, serialNumber: "") {
            passLibrary.removePass(pass)
            result(true)
        } else {
            result(false)
        }
    }
    
    private func handleIsPaymentPassActivated(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let passTypeIdentifier = args["passTypeIdentifier"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
            return
        }
        
        guard let passLibrary = self.passLibrary else {
            result(false)
            return
        }
        
        if let pass = passLibrary.pass(withPassTypeIdentifier: passTypeIdentifier, serialNumber: "") {
            result(pass.isRemotePass)
        } else {
            result(false)
        }
    }
    
    private func mapPaymentNetwork(from string: String) -> PKPaymentNetwork? {
        switch string.lowercased() {
        case "visa":
            return .visa
        case "mastercard":
            return .masterCard
        case "amex":
            return .amex
        case "discover":
            return .discover
        case "jcb":
            return .JCB
        case "unionpay":
            return .chinaUnionPay
        case "maestro":
            return .maestro
        case "girocard":
            return .girocard
        case "interac":
            return .interac
        case "eftpos":
            return .eftpos
        default:
            return nil
        }
    }
    
    private func setupPassLibraryNotifications() {
        let didChangeNotificationName = NSNotification.Name(rawValue: PKPassLibraryNotificationName.PKPassLibraryDidChange.rawValue)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(passLibraryDidChange),
            name: didChangeNotificationName,
            object: passLibrary
        )
        
        let remotePaymentpassesDidChangeNotificationName = NSNotification.Name(rawValue: PKPassLibraryNotificationName.PKPassLibraryRemotePaymentPassesDidChange.rawValue)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(remotePaymentPassesDidChange),
            name: remotePaymentpassesDidChangeNotificationName,
            object: passLibrary
        )
    }
    
    @objc private func passLibraryDidChange(_ notification: Notification) {
        sendPassLibraryChangeEvent(type: "added")
    }
    
    @objc private func remotePaymentPassesDidChange(_ notification: Notification) {
        sendPassLibraryChangeEvent(type: "replaced")
    }
    
    private func sendPassLibraryChangeEvent(type: String) {
        let event: [String: Any] = [
            "type": type,
            "passTypeIdentifier": "",
            "serialNumber": "",
            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
        ]
        
        eventSink?(event)
    }
    
    // MARK: - FlutterStreamHandler
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - PKAddPaymentPassViewControllerDelegate

extension AppleWalletPlugin: PKAddPaymentPassViewControllerDelegate {
    public func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController, generateRequestWithCertificateChain certificates: [Data], nonce: Data, nonceSignature: Data, completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void) {
        
        // This is where you would typically make a request to your server
        // to generate the encrypted pass data using the certificates, nonce, and nonceSignature
        
        // For now, we'll create a basic request
        let request = PKAddPaymentPassRequest()
        // You would populate this with encrypted pass data from your server
        handler(request)
    }
    
    public func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController, didFinishAdding pass: PKPaymentPass?, error: Error?) {
        DispatchQueue.main.async {
            controller.dismiss(animated: true)
            
            if let error = error {
                print("Error adding payment pass: \(error.localizedDescription)")
            } else if let pass = pass {
                print("Successfully added payment pass: \(pass.localizedDescription)")
            }
        }
    }
}
