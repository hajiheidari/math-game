import Flutter
import GameKit
import UIKit

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
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "AdadiNative") {
      AdadiNative.register(messenger: registrar.messenger())
    }
  }
}

/// iCloud key-value storage (the progress backup, lib/backup/cloud_save.dart)
/// and Game Center (lib/services/game_center.dart). Both answer quietly when
/// they are not available (not signed in to iCloud / Game Center).
enum AdadiNative {
  static func register(messenger: FlutterBinaryMessenger) {
    let cloud = FlutterMethodChannel(name: "adadi/cloud", binaryMessenger: messenger)
    cloud.setMethodCallHandler { call, result in
      let store = NSUbiquitousKeyValueStore.default
      let args = call.arguments as? [String: Any]
      switch call.method {
      case "get":
        store.synchronize()
        result(store.string(forKey: args?["key"] as? String ?? ""))
      case "set":
        if let key = args?["key"] as? String, let value = args?["value"] as? String {
          store.set(value, forKey: key)
          store.synchronize()
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    let games = FlutterMethodChannel(name: "adadi/game_center", binaryMessenger: messenger)
    games.setMethodCallHandler { call, result in
      let args = call.arguments as? [String: Any]
      switch call.method {
      case "signIn":
        let player = GKLocalPlayer.local
        if player.isAuthenticated {
          result(true)
          return
        }
        var answered = false
        player.authenticateHandler = { viewController, _ in
          if let viewController = viewController {
            topViewController()?.present(viewController, animated: true)
            return
          }
          if !answered {
            answered = true
            result(GKLocalPlayer.local.isAuthenticated)
          }
        }
      case "submit":
        guard GKLocalPlayer.local.isAuthenticated,
          let scores = args?["scores"] as? [String: Int]
        else {
          result(false)
          return
        }
        let group = DispatchGroup()
        for (board, score) in scores {
          group.enter()
          GKLeaderboard.submitScore(
            score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [board]
          ) { _ in group.leave() }
        }
        group.notify(queue: .main) { result(true) }
      case "show":
        guard GKLocalPlayer.local.isAuthenticated, let top = topViewController() else {
          result(false)
          return
        }
        let view = GKGameCenterViewController(state: .leaderboards)
        view.gameCenterDelegate = GameCenterDismiss.shared
        top.present(view, animated: true)
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  static func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    var top = scenes.flatMap { $0.windows }.first { $0.isKeyWindow }?.rootViewController
    while let presented = top?.presentedViewController { top = presented }
    return top
  }
}

final class GameCenterDismiss: NSObject, GKGameCenterControllerDelegate {
  static let shared = GameCenterDismiss()

  func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
    gameCenterViewController.dismiss(animated: true)
  }
}
