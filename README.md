[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Exposure Playback

* [Features](#features)
* [License](https://github.com/EricssonBroadcastServices/iOSClientExposurePlayback/blob/master/LICENSE)
* [Requirements](#requirements)
* [Installation](#installation)
* Documentation
    - [Simple Player](https://github.com/EricssonBroadcastServices/iOSClientExposurePlayback/blob/master/Documentation/simple-player.md)
    - [Live and Catchup](https://github.com/EricssonBroadcastServices/iOSClientExposurePlayback/blob/master/Documentation/live-and-catchup-playback.md)
    - [Error Handling and Warning Messages](https://github.com/EricssonBroadcastServices/iOSClientExposurePlayback/blob/master/Documentation/error-handling-and-warning-messages.md)
    - [Migrating from MRR](https://github.com/EricssonBroadcastServices/iOSClientExposurePlayback/blob/master/Documentation/migrating-from-mrr.md)
* [Release Notes](#release-notes)
* [Upgrade Guides](#upgrade-guides)
* [Roadmap](#roadmap)
* [Contributing](#contributing)

## Features

- [x] Catchup as Live
- [x] Playback through *ExposureContext*
- [x] Program Based Stream Navigation
- [x] Program Service
- [x] Advanced Contract Restrictions
- [x] Analytics Provider

## Requirements

* `iOS` 9.0+
* `Swift` 4.0+
* `Xcode` 9.0+

* Framework dependencies
    - [`Player`](https://github.com/EricssonBroadcastServices/iOSClientPlayer)
    - [`Exposure`](https://github.com/EricssonBroadcastServices/iOSClientExposure)
    - Exact versions described in [Cartfile](https://github.com/EricssonBroadcastServices/iOSClientExposurePlayback/blob/master/Cartfile)

## Installation

### Carthage
[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependency graph without interfering with your `Xcode` project setup. `CI` integration through [fastlane](https://github.com/fastlane/fastlane) is also available.

Install *Carthage* through [Homebrew](https://brew.sh) by performing the following commands:

```sh
$ brew update
$ brew install carthage
```

Once *Carthage* has been installed, you need to create a `Cartfile` which specifies your dependencies. Please consult the [artifacts](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md) documentation for in-depth information about `Cartfile`s and the other artifacts created by *Carthage*.

```sh
github "EricssonBroadcastServices/iOSClientExposurePlayback"
```

Running `carthage update` will fetch your dependencies and place them in `/Carthage/Checkouts`. You either build the `.framework`s and drag them in your `Xcode` or attach the fetched projects to your `Xcode workspace`.

Finally, make sure you add the `.framework`s to your targets *General -> Embedded Binaries* section.

## Release Notes
Release specific changes can be found in the [CHANGELOG](https://github.com/EricssonBroadcastServices/iOSClientExposurePlayback/blob/master/CHANGELOG.md).

## Upgrade Guides
The procedure to apply when upgrading from one version to another depends on what solution your client application has chosen to integrate `ExposurePlayback`.

Major changes between releases will be documented with special [Upgrade Guides](https://github.com/EricssonBroadcastServices/iOSClientExposurePlayback/blob/master/UPGRADE_GUIDE.md).

### Carthage
Updating your dependencies is done by running  `carthage update` with the relevant *options*, such as `--use-submodules`, depending on your project setup. For more information regarding dependency management with `Carthage` please consult their [documentation](https://github.com/Carthage/Carthage/blob/master/README.md) or run `carthage help`.

## Roadmap
No formalised roadmap has yet been established but an extensive backlog of possible items exist. The following represent an unordered *wish list* and is subject to change.


## Contributing
