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

### Fixed
- Actually apply bot difficulty setting to bots and tweak difficulty
- Stop level generation breaking with 1 obstacle
- Stop respawning clearing item effects

## [0.9.1] - 2023-05-29

### Fixed

-   Use the correct SSL certificate for official dedicated servers so non-HTML builds can join again

## [0.9.0] - 2023-05-27

### Added

-   Bot difficulty!
    -   The bot difficult can now be changed to one of five options: very easy, easy, medium, hard or very hard

## [0.8.1] - 2023-05-27

### Fixed

-   Limit bots to the total amount of player slots
-   Improve nav polygons to improve bot navigation
-   Stop obstacles sometimes unloading when players were nearby

## [0.8.0] - 2023-05-21

### Added

-   Bots!
    -   New AI bot players to spice up singleplayer and multiplayer games

## [0.7.1] - 2023-04-25

### Security

-   Add HTTPS support for official servers

## [0.7.0] - 2023-04-10

### Added

-   Item boxes can now spawn in the world which contain items such as:
    -   Gems - Gives the player 10 coins instantly
    -   Picoberries - Shrinks the player for 10 seconds
    -   Invisiberries - Makes the player invisible for 10 seconds
-   New animations for the coin counter
-   HTML support to allow playing from your browser!
    -   All network connections now use WebSocket
    -   Note: Server hosting is not supported through the browser, but official servers can be used to play instead

### Fixed

-   Stopped player going through walls when going too fast

## [0.6.2] - 2023-03-25

### Fixed

-   Spectators not being able to see obstacles
-   Clients getting out of sync with the server
-   Reduced checkpoint log messages

## [0.6.1] - 2023-03-19

### Fixed

-   Stopped level generation getting stuck if it runs too fast
-   Only disconnect from server list if connected
-   Auto shutdown official servers if no one joins
-   Fixed command line joining

## [0.6.0] - 2023-03-13

### Added

-   Players can now join mid race as spectators!
-   Overhauled the multiplayer lobby which now has:
    -   Server browser to show public servers
    -   Button to host an official server (no need for port forwarding!)
    -   More self hosting options (server name, public/private server)

### Changed

-   Add a limit to the obstacle spacing increase and reduced the rate of increase
-   Updated Godot to v3.5.2
-   Can now specify URLs and ports when connecting to servers with an IP

### Fixed

-   Various dedicated server fixes
-   Hide IP finder for non-hosts
-   Increase max output messages to stop logs getting cut off
-   Optimized docker build caching and image sizes

## [0.5.0] - 2022-10-19

### Added

-   Give the birds a rotation effect
-   Player has a trail effect when going fast
-   Wind particle effect
-   Players emit particles when flapping
-   Players have new and improved animations!
-   Camera animations for the start and end of the race
-   Added a loading bar for level generation
-   New player sprite, animations and game icon!

### Changed

-   Reduced title screen birds from 32 to 16
-   Always show game options by default
-   Decrease default race goal to 50
-   Made screen shake more subtle
-   Added more clouds and mountains to the background
-   Force the game aspect ratio to be consistent
-   Reduced chance of some obstacles appearing too often
-   Update to Godot 3.5.1
-   Limit lives and obstacles to 1000

### Removed

-   Highscore is no longer shown in UI

### Fixed

-   The height difference between obstacles should now always be reachable
-   All players will wait for everyone to finish generating the level before starting
-   Sounds are now heard from the player instead of the centre of the screen
-   Clear up leftover obstacles to stop memory leaks
-   Reset the server world correctly

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

[Unreleased]: https://github.com/Jibby-Games/Flappy-Race/compare/0.9.1...HEAD

[0.9.1]: https://github.com/Jibby-Games/Flappy-Race/compare/0.9.0...0.9.1

[0.9.0]: https://github.com/Jibby-Games/Flappy-Race/compare/0.8.1...0.9.0

[0.8.1]: https://github.com/Jibby-Games/Flappy-Race/compare/0.8.0...0.8.1

[0.8.0]: https://github.com/Jibby-Games/Flappy-Race/compare/0.7.1...0.8.0

[0.7.1]: https://github.com/Jibby-Games/Flappy-Race/compare/0.7.0...0.7.1

[0.7.0]: https://github.com/Jibby-Games/Flappy-Race/compare/0.6.2...0.7.0

[0.6.2]: https://github.com/Jibby-Games/Flappy-Race/compare/0.6.1...0.6.2

[0.6.1]: https://github.com/Jibby-Games/Flappy-Race/compare/0.6.0...0.6.1

[0.6.0]: https://github.com/Jibby-Games/Flappy-Race/compare/0.5.0...0.6.0

[0.5.0]: https://github.com/Jibby-Games/Flappy-Race/compare/0.4.0...0.5.0

[0.4.0]: https://github.com/Jibby-Games/Flappy-Race/compare/0.3.1...0.4.0

[0.3.1]: https://github.com/Jibby-Games/Flappy-Race/compare/0.3.0...0.3.1

[0.3.0]: https://github.com/Jibby-Games/Flappy-Race/compare/0.2.0...0.3.0

[0.2.0]: https://github.com/Jibby-Games/Flappy-Race/compare/v0.1.0...0.2.0

[0.1.0]: https://github.com/Jibby-Games/Flappy-Race/compare/v0.0.3...v0.1.0

[0.0.3]: https://github.com/Jibby-Games/Flappy-Race/compare/v0.0.2...v0.0.3

[0.0.2]: https://github.com/Jibby-Games/Flappy-Race/compare/v0.0.1...v0.0.2

[0.0.1]: https://github.com/Jibby-Games/Flappy-Race/releases/tag/v0.0.1
