import Flutter
import UIKit
import PDFKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "LumaPdfViewer") {
      registrar.register(LumaPdfViewFactory(), withId: "com.cehalo.luma/pdf-view")
    }
  }
}

// System PDFKit replaces the third-party PDFium framework on iOS. Documents
// arrive as already-authorized bytes; no URLs, persistent files or credentials
// are passed to this view.
private final class LumaPdfViewFactory: NSObject, FlutterPlatformViewFactory {
  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    return FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    return LumaPdfPlatformView(frame: frame, arguments: args)
  }
}

private final class LumaPdfPlatformView: NSObject, FlutterPlatformView {
  private let content: UIView

  init(frame: CGRect, arguments: Any?) {
    let args = arguments as? [String: Any]
    if let bytes = args?["bytes"] as? FlutterStandardTypedData,
       let document = PDFDocument(data: bytes.data),
       document.pageCount > 0 {
      let pdfView = PDFView(frame: frame)
      pdfView.document = document
      pdfView.autoScales = true
      pdfView.displayMode = .singlePageContinuous
      pdfView.displayDirection = .vertical
      pdfView.displaysPageBreaks = true
      pdfView.backgroundColor = UIColor(white: 0.96, alpha: 1)
      pdfView.accessibilityLabel = args?["title"] as? String ?? "CE document"
      content = pdfView
    } else {
      let message = UILabel(frame: frame)
      message.text = "Unable to display this PDF. Return to the course and try again."
      message.numberOfLines = 0
      message.textAlignment = .center
      message.adjustsFontForContentSizeCategory = true
      message.font = UIFont.preferredFont(forTextStyle: .body)
      content = message
    }
    super.init()
  }

  func view() -> UIView { content }
}
