//
//  ClientInfo.swift
//  PAYJP
//
//  Created by Tatsuya Kitagawa on 2020/02/05.
//  Copyright © 2020 PAY, Inc. All rights reserved.
//

import Foundation
import UIKit

/// リクエストに付与するクライアント情報を表す
/// `ClientInfo:makeInfo:plugin:publisher` で作成する
@objc(PAYClientInfo) @objcMembers
public final class ClientInfo: NSObject, Encodable {
    public let bindingsName: String
    public let bindingsVersion: String
    public let bindingsPlugin: String?
    public let unameString: String
    public let platform: String
    public let publisher: String
    public var cardFormType: String?

    lazy var bindingInfo: String = buildBindingInfo()
    lazy var userAgent: String = buildUserAgent()
    var json: String? {
        return buildJson()
    }

    public static let `default` = ClientInfo.makeInfo()

    public static func makeInfo(
        plugin: String? = nil,
        publisher: String? = nil
    ) -> ClientInfo {
        return ClientInfo(
            bindingsName: "jp.pay.ios",
            bindingsVersion: PAYJPSDK.sdkVersion,
            bindingsPlugin: plugin,
            unameString: "iOS/\(ClientInfo.osVersion); apple; \(ClientInfo.device)",
            platform: "ios",
            publisher: publisher ?? "payjp")
    }

    init(bindingsName: String,
         bindingsVersion: String,
         bindingsPlugin: String?,
         unameString: String,
         platform: String,
         publisher: String) {
        self.bindingsName = bindingsName
        self.bindingsVersion = bindingsVersion
        self.bindingsPlugin = bindingsPlugin
        self.unameString = unameString
        self.platform = platform
        self.publisher = publisher
    }

    // MARK: - Encodable

    private enum CodingKeys: String, CodingKey {
        case bindingsName = "bindings_name"
        case bindingsVersion = "bindings_version"
        case bindingsPlugin = "bindings_plugin"
        case unameString = "uname"
        case platform
        case publisher
        case cardFormType = "card_form_type"
    }

    func buildBindingInfo() -> String {
        var info = "\(bindingsName)/\(bindingsVersion)"
        if let bindingsPlugin = bindingsPlugin {
            info += "@\(bindingsPlugin)"
        }
        return info
    }

    func buildUserAgent() -> String {
        return "\(bindingInfo); \(unameString)"
    }

    func buildJson() -> String? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - Platform

extension ClientInfo {

    private static var osVersion: String {
        return UIDevice.current.systemVersion
    }

    private static var device: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
