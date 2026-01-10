# v2.lua Structure

This document outlines the structure and key components of the `v2.lua` script, which is part of the development branch.

## 1. Initialization & Optimization
- **Localized Globals**: All game services and global functions are localized for faster registry lookups and reduced CPU overhead.
- **Immediate Mobilization**: Upon execution, the player is instantly teleported to the **Treasure Room**.
- **Asset Engagement**: Automatically equips the fishing rod from **Hotbar Slot [1]** 1 second after mobilization.
- **Framework**: `WindUI` initialization with a low-latency floating toggle button.

## 2. Global Functions & Modules
- **Data Initialization**: `initializeDataModules()` loads `Replion` and `ItemUtility` with error-handled `SafeGet` retrieval.
- **Teleportation**:
  - `TeleportToTreasureRoom`: Primary location for farming.
  - `TeleportToPlayer`: Dynamic player-to-player movement for trading sequences.
- **Session Security**: `AutoReconnect` loop and `Anti-AFK` via `VirtualUser` simulation.

## 3. Core Logic & Features
### A. High-Performance Environment (FPS Boost)
- **Scoped Scanning**: Optimization is limited to `Workspace` and `Lighting` to minimize traversal costs.
- **Hash-Map Processing**: `OptimizeObject` uses a lookup table (`OPTIMIZE_TYPES`) for instantaneous object processing.
- **CPU Conservation**: Environment cleanup runs on a **10-second interval** instead of every frame, drastically reducing CPU usage.
- **Non-Destructive Water**: Water is made invisible via property adjustment rather than destructive clearing, saving memory.

### B. Automated Production (Fishing)
- **AutoFishingLoop**: A background task executing the (Charge -> Start -> Complete) sequence.
- **Direct Remote Calls**: Remote invocations are optimized to avoid anonymous function overhead.

### C. Logic & State Machine (Full Auto)
- **Efficient Monitor**: Inventory is polled every **5 seconds** to balance detection speed with CPU usage.
- **Secret Fish Sequence**:
  1. Detects **Tier 7 (Secret)** item via real-time Replion monitoring.
  2. Halts all fishing operations immediately.
  3. Teleports to player **"ruptor02"**.
  4. Initiates secure trade for the specific item UUID.
  5. After trade, returns to **Treasure Room**, re-equips, and resumes automation.

## 4. UI Layout
- **Tab: Utility**:
  - **Full Auto Section**: End-to-end automation toggle for the Secret fish workflow.
  - **Teleport Section**: Instant access to the **Treasure Room**.

---
*Note: This version is focused on high-level automation and aggressive performance optimization for specific trading workflows.*
