import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    
    // PERFORMANCE FIX: Initialize the MethodChannel once at startup.
    // This allows the Flutter side to communicate with iOS hardware APIs.
    let batteryChannel = FlutterMethodChannel(name: "com.speedcharge/hardware",
                                              binaryMessenger: controller.binaryMessenger)
    
    batteryChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      if call.method == "getBatteryHardware" {
          // BUG FIX: Ensure battery monitoring is enabled, otherwise iOS returns 
          // 'unknown' or -1 for standard battery queries.
          UIDevice.current.isBatteryMonitoringEnabled = true
          
          // iOS PRIVACY NOTE: raw voltage, current, and temperature are restricted 
          // by Apple. We return 0s to prevent a crash on the Flutter side.
          let batteryData: [String: Any] = [
              "voltage": 0,
              "temperature": 0,
              "current": 0,
              "capacity": 0
          ]
          
          result(batteryData)
      } else {
          result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}