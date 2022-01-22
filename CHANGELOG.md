# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!--
Types of changes:
  Added - for new features.
  Changed - for changes in existing functionality.
  Deprecated - for soon-to-be removed features.
  Removed - for now removed features.
  Fixed - for any bug fixes.
  Security - in case of vulnerabilities.
-->

## [Unreleased]
### Added
- Wall sprites from kenney.nl
- Menu and world now have a scrolling cloud background
- Android support
- UPnP support for automatic port forwarding on some routers
- Countdown before each race starts

### Changed
- You can now also left click to flap!

## [0.0.3] - 2021-11-30

Moved main GitHub repo to the Jibby-Games organization since the last release.

### Added
- Enable HiDPI support for Macs
### Changed
- All main menus have a nice animation between them now
- Improved Godot export settings
### Fixed
- Music now works in builds!
- Remove music player from server
- Replaced asserts to make non-debug builds work

## [0.0.2] - 2021-10-02

### Added
- New music by Drozerix
- Volume controls in options
- Improved game logs
- A finish line at a certain score
- Game options to change the score to win
- Show who the host is during setup
- A leaderboard at the end of the race

### Changed
- Default resolution is now 1080p
- Players will now die if they go too far above or below the screen
- Host only buttons will only appear to the host

### Fixed
- Stopped players sometimes dying at the start of the game
- Only update the score in the UI for the local player

## [0.0.1] - 2021-08-29
First proper release! :D
### Added
- Singleplayer and multiplayer modes
- Sound effects @wildjames
- Menu styles and logo @sharkeyjames
- Highscore saving @wildjames
- Server side collisions
- Player colour customisation
- In-game pause menu
- Animated title screen background
- Spectator mode and death camera

[Unreleased]: https://github.com/Jibby-Games/Flappy-Race/compare/v0.0.3...HEAD
[0.0.3]: https://github.com/Jibby-Games/Flappy-Race/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/Jibby-Games/Flappy-Race/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/Jibby-Games/Flappy-Race/releases/tag/v0.0.1