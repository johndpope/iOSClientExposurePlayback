//
//  StartCasting.swift
//  Analytics
//
//  Created by Fredrik Sjöberg on 2017-12-12.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Exposure

extension Playback {
    /// Player started ChromeCasting.
    internal struct StartCasting: AnalyticsEvent {
        internal let eventType: String = "Playback.StartCasting"
        internal let bufferLimit: Int64 = 3000
        internal let timestamp: Int64
        
        /// Offset in the video sequence where the playback was started at in milliseconds.
        internal let offsetTime: Int64
        
        internal init(timestamp: Int64, offsetTime: Int64) {
            self.timestamp = timestamp
            self.offsetTime = offsetTime
        }
    }
}

extension Playback.StartCasting: PlaybackOffset { }
extension Playback.StartCasting {
    internal var jsonPayload: [String : Any] {
        return [
            JSONKeys.eventType.rawValue: eventType,
            JSONKeys.timestamp.rawValue: timestamp,
            JSONKeys.offsetTime.rawValue: offsetTime
        ]
    }
    
    internal enum JSONKeys: String {
        case eventType = "EventType"
        case timestamp = "Timestamp"
        case offsetTime = "OffsetTime"
    }
}
