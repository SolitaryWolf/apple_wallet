import Flutter
import UIKit
import PassKit

class PKAddPassButtonView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var button: PKAddPassButton
    private var channel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()

        // Parse arguments
        let arguments = args as? [String: Any] ?? [:]
        let style = arguments["style"] as? Int ?? 0
        let width = arguments["width"] as? Double ?? 140
        let height = arguments["height"] as? Double ?? 44

        // Create PKAddPassButton with the specified style
        let buttonStyle = PKAddPassButtonStyle(rawValue: style) ?? .black
        button = PKAddPassButton(addPassButtonStyle: buttonStyle)

        // Setup method channel for communication with Flutter
        channel = FlutterMethodChannel(
            name: "PKAddPassButton_\(viewId)",
            binaryMessenger: messenger!
        )

        super.init()

        // Configure button
        button.frame = CGRect(x: 0, y: 0, width: width, height: height)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

        // Add button to view
        _view.addSubview(button)
        _view.frame = button.frame

        // Set up constraints to center the button
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: _view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: _view.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: width),
            button.heightAnchor.constraint(equalToConstant: height)
        ])
    }

    @objc private func buttonTapped() {
        // Notify Flutter when button is tapped
        channel.invokeMethod("onPressed", arguments: nil)
    }

    func view() -> UIView {
        return _view
    }
}

class PKAddPassButtonViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return PKAddPassButtonView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}