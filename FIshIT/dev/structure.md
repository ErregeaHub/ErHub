# ErHub V2 - Project Structure

## 📁 Directory Layout
- `main.lua`: The primary entry point containing UI initialization, global functions, optimization logic, and automation systems.

## 🛠️ Core Components

### 1. Initialization & UI Framework
- **WindUI**: Used for the graphical interface.
- **Remote Loading**: Asynchronous loading of game Remotes (RF/RE) to prevent UI blocking.
- **Module Initialization**: Dynamically requires `Replion` and `ItemUtility` for inventory management.

### 2. Automation Systems
- **Auto-Trade**: Iterates through inventory by Tier and automates the trade process.
- **Auto-Reconnect**: Ensures the script persists through disconnections or teleport failures.

### 3. Optimization (FPS Boost)
- Aggressive material and mesh stripping to maximize performance on low-end devices.

### 4. Utilities
- **Teleportation**: Support for player-to-player and static island teleportation.

## 🚀 Upcoming Features (Blatant)
- **Instant Fishing**: Bypasses casting delay and minigame mechanics to catch fish instantly.
- **Auto-Cast**: Automatically restarts the fishing cycle.
- **Minigame Bypass**: Sends immediate success signals to the server upon minigame start.
