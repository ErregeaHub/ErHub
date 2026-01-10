# FishIT - main.lua Structure and Flow

This document outlines the architecture and operational flow of the core script for the FishIT hub.

## 1. File Structure

The script is organized into several distinct layers, moving from environment setup to core logic and finally the user interface.

### **Environment & Service Initialization**
- **Services**: Retrieves core Roblox services (`Players`, `HttpService`, `ReplicatedStorage`, `RunService`, `UserInputService`, `VirtualInputManager`).
- **Data Modules**: Connects to the game's data replication system (`DataReplion`) to monitor inventory and player stats safely.
- **Utility Functions**:
    - `SafeGet`: A wrapper for safe data retrieval from the replication system.
    - `deepCopy`: Ensures inventory data is cloned rather than referenced destructively, preventing the "empty inventory" bug.
    - `NotifyInfo/NotifySuccess/NotifyError`: Standardized UI notification wrappers.

### **State Management & Configuration**
- **`state` Table**: Centralized storage for feature toggles (e.g., `state.AutoFish`, `state.WebhookEnabled`).
- **`tierNames`**: Mapping of tier IDs (1-7) to descriptive names (Common to Secret).
- **`tierColors`**: Color hex codes for Discord webhook embeds based on fish rarity.

### **Remote Hooking (Logic Interception)**
- Hooks into `FishingRemote` and `NotificationRemote` to:
    - Detect when a fish is caught.
    - Disable in-game "obtained" UI effects if requested.
    - Capture fish data (Name, Tier, Weight) for the webhook system.

### **UI Construction (WindUI)**
The script uses the WindUI library to create a tabbed interface:
- **Teleport Tab**: Island selection and player-to-player teleports.
- **Fishing Tab**: Controls for Auto-Fishing, Auto-Sell, and rod equipment.
- **Utility Tab**: Movement modifications (WalkSpeed/JumpPower) and "Walk on Water" features.
- **Webhook Tab**: Configuration for Discord notifications, including URL input and rarity filtering.
- **Misc Tab**: Performance boosters (FPS Cap), Anti-AFK, and Auto-Reconnect.

---

## 2. Execution Flow

The script follows a sequential startup process followed by asynchronous background tasks.

### **Step 1: Bootstrap & UI Loading**
- Loads the WindUI library from a remote source.
- Initializes the main window and creates the sidebar tabs.
- Populates tabs with toggles, sliders, and buttons.

### **Step 2: Hooking & Monitoring (Immediate)**
- Immediately begins monitoring remote events.
- If a `Notification` event occurs and it's a "Fish Caught" message, the script extracts the fish details.
- **Webhook Processing**: If `state.WebhookEnabled` is true and the fish rarity meets the user's selected threshold, it compiles a JSON payload and sends it to Discord via a proxy.

### **Step 3: Feature Loops (On-Demand)**
When a user toggles a feature, a `task.spawn` loop is often created:
- **Auto-Fishing**: Continuously fires the fishing remote and handles the mini-game logic automatically.
- **Auto-Sell**: Periodically (default 60s) invokes the sell remote to clear the inventory.
- **Anti-AFK**: Periodically simulates input or moves the character to prevent server disconnection.

### **Step 4: Persistence & Maintenance**
- **Auto-Reconnect**: Monitors the `GuiService` for "Disconnected" prompts and attempts to rejoin the server automatically.
- **Inventory Sync**: Uses `getItems()` with `deepCopy` whenever the inventory needs to be scanned for UI updates or webhook data, ensuring no data loss for the game's internal controllers.

---

## 3. Key Components Reference

| Component | Function | Implementation |
| :--- | :--- | :--- |
| **WindUI** | Handles the visual interface. | Remote LoadString |
| **Inventory Safe Access** | Prevents "Empty Controller" bug using `deepCopy`. | `deepCopy` function |
| **Webhook Logic** | Formats and sends Discord notifications. | `HttpService:PostAsync` via Proxy |
| **Remote Hooks** | Intercepts fish catches for immediate notification. | `hookmetamethod` / `__namecall` |
