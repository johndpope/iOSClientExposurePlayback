//
//  ProgramSource+StartTime.swift
//  ExposureTests
//
//  Created by Fredrik Sjöberg on 2018-01-29.
//  Copyright © 2018 emp. All rights reserved.
//

import Quick
import Nimble
import Player
import Exposure

@testable import Player
@testable import ExposurePlayback

class ProgramSourceStartTimeSpec: QuickSpec {
    override func spec() {
        super.spec()
        describe("ProgramSource") {
            let segmentLength: Int64 = 6000
            let currentDate = Date().unixEpoch
            let hour: Int64 = 60 * 60 * 1000
            let environment = Environment(baseUrl: "url", customer: "customer", businessUnit: "businessUnit")
            let sessionToken = SessionToken(value: "token")
            
            func generateEnv() -> TestEnv {
                let env = TestEnv(environment: environment, sessionToken: sessionToken)
                env.player.context.isDynamicManifest = { _,_ in return false }
                env.mockAsset(callback: env.defaultAssetMock(currentDate: currentDate, bufferDuration: hour/2))
                return env
            }
            
            func generatePlayable(pipe: String = "file://play/.isml", lastViewedOffset: Int? = nil, lastViewedTime: Int64? = nil, live: Bool = false) -> ProgramPlayable {
                // Configure the playable
                let provider = MockedProgramEntitlementProvider()
                provider.mockedRequestEntitlement = { _,_,_,_, callback in
                    var json = PlaybackEntitlement.requiedJson
                    json["mediaLocator"] = pipe
                    if let offset = lastViewedOffset {
                        json["lastViewedOffset"] = offset
                    }
                    if let offset = lastViewedTime {
                        json["lastViewedTime"] = offset
                    }
                    json["live"] = live
                    callback(json.decode(PlaybackEntitlement.self), nil)
                }
                return ProgramPlayable(assetId: "assetId", channelId: "channelId", entitlementProvider: provider)
            }
            
            context(".defaultBehaviour") {
                let properties = PlaybackProperties(playFrom: .defaultBehaviour)
                context("USP") {
                    context("live program") {
                        it("should use default behavior with lastViewedOffset specified") {
                            let env = generateEnv()
                            let playable = generatePlayable(lastViewedOffset: 100, live: true)
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(beNil())
                        }
                        
                        it("should use default behavior with lastViewedTime specified") {
                            let env = generateEnv()
                            let playable = generatePlayable(lastViewedTime: 100, live: true)
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(beNil())
                        }
                        
                        it("should use default behavior with no bookmarks specified") {
                            let env = generateEnv()
                            let playable = generatePlayable(live: true)
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(beNil())
                        }
                    }
                    
                    context("catchup program") {
                        it("should use default behavior with lastViewedOffset specified") {
                            let env = generateEnv()
                            let playable = generatePlayable(lastViewedOffset: 100)
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(equal(segmentLength))
                        }
                        
                        it("should use default behavior with lastViewedTime specified") {
                            let env = generateEnv()
                            let playable = generatePlayable(lastViewedTime: 100)
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(equal(segmentLength))
                        }
                        
                        it("should use default behavior with no bookmarks specified") {
                            let env = generateEnv()
                            let playable = generatePlayable()
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(equal(segmentLength))
                        }
                    }
                }
                
                context("old pipe") {
                    it("should use default behavior with lastViewedOffset specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(pipe: "file://old/pipe", lastViewedOffset: 100)
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(beNil())
                    }
                    
                    it("should use default behavior with lastViewedTime specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(pipe: "file://old/pipe", lastViewedTime: 100)
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(beNil())
                    }
                    
                    it("should use default behavior with no bookmarks specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(pipe: "file://old/pipe")
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(beNil())
                    }
                }
            }
            
            context(".beginning") {
                let properties = PlaybackProperties(playFrom: .beginning)
                context("USP") {
                    context("live program") {
                        it("should start from zero with lastViewedOffset specified") {
                            let env = generateEnv()
                            let playable = generatePlayable(lastViewedOffset: 100, live: true)
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(equal(segmentLength))
                        }
                        
                        it("should start from zero with lastViewedTime specified") {
                            let env = generateEnv()
                            let playable = generatePlayable(lastViewedTime: 100, live: true)
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(equal(segmentLength))
                        }
                        
                        it("should start from zero with no bookmarks specified") {
                            let env = generateEnv()
                            let playable = generatePlayable(live: true)
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(equal(segmentLength))
                        }
                    }
                    
                    context("catchup program") {
                        it("should use default behavior with lastViewedOffset specified") {
                            let env = generateEnv()
                            let playable = generatePlayable(lastViewedOffset: 100)
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(equal(segmentLength))
                        }
                        
                        it("should use default behavior with lastViewedTime specified") {
                            let env = generateEnv()
                            let playable = generatePlayable(lastViewedTime: 100)
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(equal(segmentLength))
                        }
                        
                        it("should use default behavior with no bookmarks specified") {
                            let env = generateEnv()
                            let playable = generatePlayable()
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(equal(segmentLength))
                        }
                    }
                }

                context("old pipe") {
                    it("should rely on vod manifest to start from 0 with lastViewedOffset specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(pipe: "file://old/pipe", lastViewedOffset: 100)
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(beNil())
                    }

                    it("should rely on vod manifest to start from 0 with lastViewedTime specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(pipe: "file://old/pipe", lastViewedTime: 100)
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(beNil())
                    }

                    it("should rely on vod manifest to start from 0 with no bookmarks specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(pipe: "file://old/pipe")
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(beNil())
                    }
                }
            }

            context(".bookmark") {
                let properties = PlaybackProperties(playFrom: .bookmark)
                context("USP") {
                    it("should pick up lastViewedOffset if specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(lastViewedOffset: 100)
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(equal(100))
                    }


                    context("live program") {
                        it("should use default behavior with lastViewedTime specified") {
                            let env = generateEnv()
                            let playable = generatePlayable(lastViewedTime: 100, live: true)
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(beNil())
                        }
                        
                        it("should use default behavior with no bookmarks specified") {
                            let env = generateEnv()
                            let playable = generatePlayable(live: true)
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(beNil())
                        }
                    }

                    context("catchup program") {
                        it("should use default behavior with lastViewedTime specified") {
                            let env = generateEnv()
                            let playable = generatePlayable(lastViewedTime: 100)
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(equal(segmentLength))
                        }
                        
                        it("should use default behavior with no bookmarks specified") {
                            let env = generateEnv()
                            let playable = generatePlayable()
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(equal(segmentLength))
                        }
                    }
                }

                context("old pipe") {
                    it("should pick up lastViewedOffset if specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(pipe: "file://old/pipe", lastViewedOffset: 100)
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(equal(100))
                    }

                    it("should use default behavior with lastViewedTime specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(pipe: "file://old/pipe", lastViewedTime: 100)
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(beNil())
                    }

                    it("should use default behavior with no bookmarks specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(pipe: "file://old/pipe")
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(beNil())
                    }
                }
            }

            context(".customTime") {
                let lastViewedTime = currentDate + 1000
                let customOffset = currentDate + 300
                let illegalOffset = currentDate - 1000
                let properties = PlaybackProperties(playFrom: .customTime(timestamp: customOffset))
                context("USP") {
                    it("should use custom value if lastViewedOffset if specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(lastViewedOffset: 100)
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(equal(customOffset))
                        expect(env.player.startPosition).to(beNil())
                    }

                    it("should use custom value if lastViewedTime specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(lastViewedTime: lastViewedTime)
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(equal(customOffset))
                        expect(env.player.startPosition).to(beNil())
                    }

                    it("should use custom value if no bookmarks specified") {
                        let env = generateEnv()
                        let playable = generatePlayable()
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(equal(customOffset))
                        expect(env.player.startPosition).to(beNil())
                    }
                    
                    context("live program") {
                        it("should use default behavior with illegal startTime") {
                            let properties = PlaybackProperties(playFrom: .customTime(timestamp: illegalOffset))
                            let env = generateEnv()
                            let playable = generatePlayable(lastViewedTime: lastViewedTime, live: true)
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(beNil())
                        }
                    }
                    
                    context("catchup program") {
                        it("should use default behavior with illegal startTime") {
                            let properties = PlaybackProperties(playFrom: .customTime(timestamp: illegalOffset))
                            let env = generateEnv()
                            let playable = generatePlayable(lastViewedTime: lastViewedTime)
                            
                            env.player.startPlayback(playable: playable, properties: properties)
                            
                            expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                            expect(env.player.startTime).to(beNil())
                            expect(env.player.startPosition).to(equal(segmentLength))
                        }
                    }
                }

                context("old pipe") {
                    it("should use custom value if lastViewedOffset if specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(pipe: "file://old/pipe", lastViewedOffset: 100)
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(equal(customOffset))
                        expect(env.player.startPosition).to(beNil())
                    }

                    it("should use custom value if lastViewedTime specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(pipe: "file://old/pipe", lastViewedTime: lastViewedTime)
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(equal(customOffset))
                        expect(env.player.startPosition).to(beNil())
                    }

                    it("should use custom value if no bookmarks specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(pipe: "file://old/pipe")
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(equal(customOffset))
                        expect(env.player.startPosition).to(beNil())
                    }
                    
                    it("should use default behavior with illegal startTime") {
                        let properties = PlaybackProperties(playFrom: .customTime(timestamp: illegalOffset))
                        let env = generateEnv()
                        let playable = generatePlayable(pipe: "file://old/pipe", lastViewedTime: lastViewedTime)
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(beNil())
                    }
                }
            }
            
            context(".customPosition") {
                let properties = PlaybackProperties(playFrom: .customPosition(position: 300))
                context("USP") {
                    it("should use custom value if lastViewedOffset if specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(lastViewedOffset: 100)
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(equal(300))
                    }

                    it("should use custom value if lastViewedTime specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(lastViewedTime: 100)
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(equal(300))
                    }

                    it("should use custom value if no bookmarks specified") {
                        let env = generateEnv()
                        let playable = generatePlayable()
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(equal(300))
                    }
                }

                context("old pipe") {
                    it("should use custom value if lastViewedOffset if specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(pipe: "file://old/pipe", lastViewedOffset: 100)
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(equal(300))
                    }

                    it("should use custom value if lastViewedTime specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(pipe: "file://old/pipe", lastViewedTime: 100)
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(equal(300))
                    }

                    it("should use custom value if no bookmarks specified") {
                        let env = generateEnv()
                        let playable = generatePlayable(pipe: "file://old/pipe")
                        
                        env.player.startPlayback(playable: playable, properties: properties)
                        
                        expect(env.player.tech.currentAsset).toEventuallyNot(beNil())
                        expect(env.player.startTime).to(beNil())
                        expect(env.player.startPosition).to(equal(300))
                    }
                }
            }
        }
    }
}
