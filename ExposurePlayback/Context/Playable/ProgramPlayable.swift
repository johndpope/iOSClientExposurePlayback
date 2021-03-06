//
//  ProgramPlayable.swift
//  Exposure
//
//  Created by Fredrik Sjöberg on 2018-01-26.
//  Copyright © 2018 emp. All rights reserved.
//

import Foundation
import Exposure

internal protocol ProgramEntitlementProvider {
    func requestEntitlement(programId: String, channelId: String, using sessionToken: SessionToken, in environment: Environment, callback: @escaping (PlaybackEntitlement?, ExposureError?) -> Void)
}

public struct ProgramPlayable: Playable {
    public let assetId: String
    public let channelId: String
    
    internal var entitlementProvider: ProgramEntitlementProvider = AlamofireEntitlementProvider()
    
    internal struct AlamofireEntitlementProvider: ProgramEntitlementProvider {
        func requestEntitlement(programId: String, channelId: String, using sessionToken: SessionToken, in environment: Environment, callback: @escaping (PlaybackEntitlement?, ExposureError?) -> Void) {
            let entitlement = Entitlement(environment: environment,
                                          sessionToken: sessionToken)
                .program(programId: programId,
                         channelId: channelId)
            
            entitlement
                .request()
                .validate()
                .response{
                    if let error = $0.error {
                        // Workaround until EMP-10023 is fixed
                        if case let .exposureResponse(reason: reason) = error, (reason.httpCode == 403 && reason.message == "NO_MEDIA_FOR_PROGRAM") {
                            entitlement
                                .use(drm: "UNENCRYPTED")
                                .request()
                                .validate()
                                .response{ callback($0.value, $0.error) }
                        }
                        else {
                            callback(nil,error)
                        }
                    }
                    else if let entitlement = $0.value {
                        callback(entitlement, nil)
                    }
            }
        }
    }
}

extension ProgramPlayable {
    public init(assetId: String, channelId: String) {
        self.assetId = assetId
        self.channelId = channelId
    }
}

extension ProgramPlayable {
    /// Helper method producing an `ProgramSource` for *program* playback using the supplied `environment` and `sessionToken`
    ///
    /// - parameter environment: `Environment` to request the Source from
    /// - parameter sessionToken: `SessionToken` validating the user
    /// - parameter callback: Closure called on request completion
    public func prepareSource(environment: Environment, sessionToken: SessionToken, callback: @escaping (ExposureSource?, ExposureError?) -> Void) {
        entitlementProvider.requestEntitlement(programId: assetId, channelId: channelId, using: sessionToken, in: environment) { entitlement, error in
            if let entitlement = entitlement {
                callback(ProgramSource(entitlement: entitlement, assetId: self.assetId, channelId: self.channelId), nil)
            }
            else {
                callback(nil,error!)
            }
        }
    }
}
