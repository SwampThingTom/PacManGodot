# Pac-Man Clone

A Pac-Man clone written in Godot.
The goal is to try to remain as authentic to the original arcade game as possible,
including the splash screen and between-level intermissions.
Will ultimately provide options to run with the original bugs (especially Pinky and Inky pathfinding).

Intended to be cross-platform.
Hope to support Apple TV and iOS devices in addition to Mac and Windows.

## Classes

**Title**
Title scene that simply waits for the user to start a new game.

**Game**
Main game controller responsible for tracking level, lives, score, and game state.
Also responsible for detecting collisions and managing ghost and player death and respawning.

**ScoresText**
Renders the player and high scores as tiles from the Font tilesheet.

**ReadyText**
Renders the word "READY!" when play is about to start.

**Maze**
TileMapLayer that renders the maze and is the source of truth for everything map-related,
including walls, tunnel, spawn locations, etc.

**Pellets**
TileMapLayer that renders the pellets (dots) and power pellets.
Signals events when a pellet is eaten and when all of the pellets have been eated.

**GhostPoints**
A sprite that renders the number of points scored for eating a ghost.

**FreezeTimer**
A timer used to freeze everything while GhostPoints is shown.

**GhostMode**
Maintains the current ghost mode (scatter, chase, or frightened) and signals an event when it changes.

**Ghosts**
Coordinates game state for all 4 ghosts and releases them from the ghost house.

**Ghost**
Responsible for moving a Ghost around the maze depending on the current mode.
Also responsible for Ghost animations.

**GhostTargeting**
Provides targets for ghosts in chase mode.

**PacMan**
Responsible for moving Pac-Man around the maze based on user input.
Also responsible for PacMan animations.

**ActorFactory**
Responsible for creating Pac-Man and Ghost sprites.

**LevelData**
Maintains configuration data for all game levels and provides convenience functions to
get specific data items for a given level.

## Features To-Do

- Ghost release timer
- Extra life
- Additional levels past the first
- Game over
- Intermission animations
- Attract mode on title screen
- Second player
