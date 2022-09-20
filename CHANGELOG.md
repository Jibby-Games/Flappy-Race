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
- Give the birds a rotation effect
- Player has a trail effect when going fast
- Wind particle effect
- Players emit particles when flapping
- Players have new and improved animations!

### Changed
- Reduced title screen birds from 32 to 16

## [0.4.0] - 2022-09-05

### Added

-   Spectator controls so you can control the camera
-   Race progress bar so you can see where all players are in the race
-   Particles:
    -   Players now emit coloured particles when they die
    -   Confetti for the start and end of the race
    -   Particles when a coin is taken
-   Improved level generation and chunking
-   More obstacles:
    -   Block fields
    -   Coin circles
    -   Tunnels
-   The controls are now shown at the start of the race to help new players
    -   Will automatically detect controllers and switch icons as needed

### Changed

-   The camera is now offset a bit so you can see obstacles ahead better

### Fixed

-   Improved the leaderboard alignment

## [0.3.1] - 2022-03-12

### Fixed

-   Stopped walls giving multiple points
-   Made crossing the finish line give a point again
-   Fixed menus breaking when using the back button

## [0.3.0] - 2022-03-11

### Added

-   Coins which give you a little speed boost!
-   Screen shake camera effect
-   Death animation
-   Smooth camera movement and switching
-   Expanded options menu with:
    -   Resolution
    -   Fullscreen
    -   Vsync
    -   High score reset
    -   Reset all options
-   Settings are now saved and loaded from a file
-   Command line options for starting the game or server:
    -   \--join \\&lt;ip:port> - join a game at an ip address and optional port
    -   \--host - host a game as a client
    -   \--server - start a headless server
    -   \--port - specify port for server/host
    -   \--upnp - to enable UPnP for server/host

### Changed

-   Leaderboard now shows a skull next to players that died
-   Setup menu will now show a message if the game cannot start

### Fixed

-   Stopped errors and crashes that could appear when stopping the server
-   Players will now be renamed if they have a name that is already in use
-   Stop audio breaking when setting volume &lt; 34%

## [0.2.0] - 2022-02-12

### Added

-   New game option to change the amount of lives
-   UI shows the amount of lives left if enabled
-   Players get knocked back on death
-   Death sound and respawn animation
-   You can now go back to the setup screen from the game
-   Racers are now timed with a stopwatch
-   Leaderboard displays race times

### Changed

-   Default to unlimited lives
-   Make UPnP usage optional

### Fixed

-   Made collision detection more responsive on the client
-   Walls can no longer give multiple points

## [0.1.0] - 2022-01-22

### Added

-   Wall sprites from kenney.nl
-   Menu and world now have a scrolling cloud background
-   Android support
-   UPnP support for automatic port forwarding on some routers
-   Countdown before each race starts

### Changed

-   You can now also left click to flap!

## [0.0.3] - 2021-11-30

Moved main GitHub repo to the Jibby-Games organization since the last release.

### Added

-   Enable HiDPI support for Macs

### Changed

-   All main menus have a nice animation between them now
-   Improved Godot export settings

### Fixed

-   Music now works in builds!
-   Remove music player from server
-   Replaced asserts to make non-debug builds work

## [0.0.2] - 2021-10-02

### Added

-   New music by Drozerix
-   Volume controls in options
-   Improved game logs
-   A finish line at a certain score
-   Game options to change the score to win
-   Show who the host is during setup
-   A leaderboard at the end of the race

### Changed

-   Default resolution is now 1080p
-   Players will now die if they go too far above or below the screen
-   Host only buttons will only appear to the host

### Fixed

-   Stopped players sometimes dying at the start of the game
-   Only update the score in the UI for the local player

## [0.0.1] - 2021-08-29

First proper release! :D

### Added

-   Singleplayer and multiplayer modes
-   Sound effects @wildjames
-   Menu styles and logo @sharkeyjames
-   Highscore saving @wildjames
-   Server side collisions
-   Player colour customisation
-   In-game pause menu
-   Animated title screen background
-   Spectator mode and death camera

[Unreleased]: https://github.com/Jibby-Games/Flappy-Race/compare/0.4.0...HEAD

[0.4.0]: https://github.com/Jibby-Games/Flappy-Race/compare/0.3.1...0.4.0

[0.3.1]: https://github.com/Jibby-Games/Flappy-Race/compare/0.3.0...0.3.1

[0.3.0]: https://github.com/Jibby-Games/Flappy-Race/compare/0.2.0...0.3.0

[0.2.0]: https://github.com/Jibby-Games/Flappy-Race/compare/v0.1.0...0.2.0

[0.1.0]: https://github.com/Jibby-Games/Flappy-Race/compare/v0.0.3...v0.1.0

[0.0.3]: https://github.com/Jibby-Games/Flappy-Race/compare/v0.0.2...v0.0.3

[0.0.2]: https://github.com/Jibby-Games/Flappy-Race/compare/v0.0.1...v0.0.2

[0.0.1]: https://github.com/Jibby-Games/Flappy-Race/releases/tag/v0.0.1
