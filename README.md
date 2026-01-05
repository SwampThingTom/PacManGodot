# Pac-Man Clone

A Pac-Man clone written in [Godot](https://godotengine.org/).
The goal is to remain as authentic to Namco's original gameplay as possible, including bugs.

## Supported Platforms
Intended to be cross-platform.
Should work without trouble on MacOS and Windows (all of my testing has been on MacOS).
Eventually hope to support Apple TV and iOS devices.

## Architecture

### Scenes

- Title: Shows a static title screen and waits for any key to start the game.
- Game: Starts the `GameController` class to play the game.

### Classes

`GameController` is the top-level state machine responsible for maintaining the current player, level, round, scores, and detecting collisions.

`MazeMap` is the tilemap for the maze and source of truth for which cells are open.

`PelletsMap` is the tilemap for the pellets and source of truth for which cells have which kind of pellet.

`PacManActor` takes input from the user and moves the Pac-Man sprite accordingly.

`GhostActor` moves the ghost through the maze based on current state, mode, and frightened status.

`GhostCoordinator` coordinates the group of ghosts and determines when they are released from the house. Also responsible for managing when Elroy mode begins.

`GhostModeController` is a timing controller for scattered vs chase modes, as well as frightened status. Emits signals when mode or frightened status changes.

`GhostTargetingService` provides ghost-specific chase target calculations.

`BonusFruitActor` spawns a fruit at pellets-eaten thresholds and awards points if collected.

`LevelData` provides per-level configuration data, such as actor speeds, bonus fruit, bonus fruit points, and frightened mode configuration, etc.

### States

- `START_GAME`: initialize a new game, spawn actors, reset scores.

- `START_LEVEL`: reset pellets, reset per-level controllers (ghost mode, ghosts, fruit), update HUD.

- `START_PLAYER`: show “PLAYER ONE / READY” intro (first time only).

- `START_ROUND`: place actors at their start positions, show “READY!”, then begin play.

- `PLAYING`: main gameplay; collision checks happen here.

- `PLAYER_DIED`: run death sequence, decrement lives, either restart round or go to game over.

- `LEVEL_COMPLETE`: run level-clear sequence, advance level number, start next level.

- `GAME_OVER`: show game over text, return to title.

## Resources

- The [Pac-Man Dossier](https://pacman.holenet.info/) is an amazing resource for details about how the original arcade game worked internally.

- Graphic assets were thanks to [The Spriter's Resource](https://www.spriters-resource.com/arcade/pacman/).

- Audio assets were thanks to [Sound Effects Wiki](https://soundeffects.fandom.com/wiki/Pac-Man).

## Feature Backlog

- Persist high score
- Intermission animations
- Attract mode on title screen
- Second player

## Known Bugs

- Ghost collisions are sometimes not detected
- Annoying click when looping final siren wav
- Timing doesn't quite match arcade game
