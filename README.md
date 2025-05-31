# Maze Runner

Maze Runner is an extended reality (XR) maze game developed in Godot as part of the IDATT2505 course at NTNU. The game challenges players to navigate through a randomly generated labyrinth, while avoiding traps and a monster and collecting coins. The goal is to finish as quickly as possible.

## Features
* Randomly generated mazes
* Switch between 2D and 3D views
* Patrolling monster with AI navigation
* Coins, traps, moving walls, and health pickups
* Visuals and sound effects
* Difficulty selection and performance indicators

## System Implementation
* Maze Generation: Uses a modified depth-first search (DFS) algorithm to create random mazes with multiple paths. Additional random walls are removed to ensure variability.
* Monster AI: Utilizes Godot's NavigationMesh for pathfinding and switches between idle, chasing, and searching modes based on player proximity.
* Object Placement: Coins, hearts, traps, and moving walls are placed randomly in the maze while ensuring proper space and logic constraints.
* UI and UX: A clean interface includes a start menu, performance indicators, and allows difficulty selection affecting maze size and damage taken.

## Requirements
* Godot Engine

## How to Run
1. Install Godot on your computer.
2. Clone the project.
3. Open the project in Godot.
4. Run the game using the play button.

## Demo
Watch a short gameplay demo here: https://www.youtube.com/watch?v=Y1VwsJZUvbI
