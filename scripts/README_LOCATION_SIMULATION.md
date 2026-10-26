# Location Simulation Scripts

Tools for simulating GPS routes on iOS Simulator, specifically optimized for testing highway driving scenarios on the A4 from Delft to Amsterdam.

## Quick Start

```bash
# Generate the A4 route GPX file (only needed once)
python3 scripts/generate_a4_route.py

# Run the interactive simulation menu
./scripts/simulate_a4_route.sh
```

## Scripts Overview

### 1. `generate_a4_route.py` - Route Generator

Fetches real A4 highway data from OpenStreetMap and generates a GPX file with points at 1-second intervals.

**Usage:**
```bash
# Generate at 100 km/h (default)
python3 scripts/generate_a4_route.py

# Generate at different speed
python3 scripts/generate_a4_route.py 120

# Custom output file
python3 scripts/generate_a4_route.py 100 custom_route.gpx
```

**Features:**
- Fetches real road geometry from OpenStreetMap
- Generates trackpoints at exactly 1-second intervals
- Includes speed and bearing/course data for each point
- Configurable speed (default: 100 km/h)
- Falls back to interpolated route if OSM is unavailable

**Output:**
- File: `scripts/A4_Delft_to_Amsterdam.gpx`
- ~7,065 waypoints
- ~196 km route (includes A4 branches)
- ~2 hours simulated driving time at 100 km/h

### 2. `play_gpx_route.py` - GPX Player

Plays any GPX route on the iOS Simulator.

**Usage:**
```bash
# Play default route at 100 km/h
python3 scripts/play_gpx_route.py scripts/A4_Delft_to_Amsterdam.gpx

# Play on specific device
python3 scripts/play_gpx_route.py route.gpx <device-udid>

# Play at different speed
python3 scripts/play_gpx_route.py route.gpx booted 120
```

**Arguments:**
1. GPX file path (required)
2. Device ID (default: `booted`)
3. Speed in km/h (default: 100)

### 3. `simulate_a4_route.sh` - Interactive Menu

Interactive menu for quick location simulation.

**Options:**
1. **Set static location (Delft)** - Fix GPS at Delft starting point
2. **Simulate A4 route (key waypoints)** - Quick simulation with ~8 major waypoints
3. **Simulate A4 route (detailed)** - Full 7000+ point simulation at 100 km/h
4. **Use built-in Freeway Drive** - Apple's built-in freeway scenario
5. **Clear location simulation** - Stop any running simulation
6. **List available scenarios** - Show all Apple built-in scenarios

## How It Works

### Route Generation Process

1. **Query OpenStreetMap** - Fetches all A4 highway segments in the region
2. **Build Continuous Route** - Connects segments from Delft → Amsterdam
3. **Interpolate Points** - Generates points every 1 second based on speed
4. **Add Metadata** - Includes elevation, timestamps, speed, and bearing

### iOS Simulator Integration

The scripts use `xcrun simctl location` to control the simulator's GPS:

```bash
# Basic syntax
xcrun simctl location <device> start --speed=<m/s> --interval=<sec> <lat1>,<lon1> <lat2>,<lon2> ...
```

**Key Parameters:**
- `--speed`: Movement speed in meters/second (27.78 m/s = 100 km/h)
- `--interval`: Update frequency in seconds (1.0 = every second)
- Coordinates: Space-separated `lat,lon` pairs

## Testing Highway Mode Features

The generated route is perfect for testing features that activate at highway speeds:

```dart
// Example: Your highway mode logic
if (userLocation.speed >= 50.0 / 3.6) { // 50 km/h in m/s
  // Enable highway mode
  // The simulated route maintains 100 km/h (27.78 m/s)
}
```

**Route Characteristics:**
- Constant speed: 27.78 m/s (100 km/h)
- Consistent bearing updates (important for directional filtering)
- 1-second update intervals (matches real GPS behavior)
- Real highway geometry (curves, exits, etc.)

## Troubleshooting

### "No booted simulators found"
```bash
# List available simulators
xcrun simctl list devices

# Boot a simulator
open -a Simulator
# Or via command line:
xcrun simctl boot <device-id>
```

### "Failed to extract coordinates from GPX"
```bash
# Regenerate the GPX file
python3 scripts/generate_a4_route.py
```

### Route is too long/short
The current route (~196 km) includes some A4 branches. To get a shorter route:
1. Edit `generate_a4_route.py`
2. Adjust the distance threshold in line 134: `if dist_to_amsterdam < 2000:`
3. Decrease the value (e.g., `500`) for a more direct route
4. Regenerate: `python3 scripts/generate_a4_route.py`

### Simulation not updating location
```bash
# Clear any existing simulation
xcrun simctl location booted clear

# Check simulator location services are enabled
# Settings > Privacy > Location Services > ON

# Restart simulation
./scripts/simulate_a4_route.sh
```

## Advanced Usage

### Generate Custom Routes

You can modify `generate_a4_route.py` to create routes between any two points:

```python
# Edit these coordinates (around line 72-73)
delft_coords = (52.00667, 4.35556)      # Start point
amsterdam_coords = (52.370216, 4.895168) # End point
```

### Multiple Simultaneous Routes

```bash
# Terminal 1: Play route on device 1
python3 scripts/play_gpx_route.py route1.gpx <device-1-id> 100

# Terminal 2: Play different route on device 2
python3 scripts/play_gpx_route.py route2.gpx <device-2-id> 120
```

### Monitor Location Updates

```bash
# In your Flutter app, add logging:
# lib/ui/mainapp/home/nearest_stations/bloc/nearest_stations_cubit.dart

print('Location update: ${userLocation.latitude}, ${userLocation.longitude}');
print('Speed: ${userLocation.speed} m/s (${userLocation.speed * 3.6} km/h)');
print('Heading: ${userLocation.heading}°');
```

## Files Generated

- `scripts/A4_Delft_to_Amsterdam.gpx` - Main route file (~7065 points)
- `scripts/A4_Delft_to_Amsterdam_Detailed.gpx` - Old version (can be deleted)

## Requirements

- macOS with Xcode Command Line Tools
- Python 3.x
- `requests` library: `pip3 install requests`
- iOS Simulator (comes with Xcode)

## Performance Notes

- **7000+ coordinates** may take a few seconds to load into simulator
- Once loaded, updates happen smoothly at 1-second intervals
- Simulation runs in real-time (2 hours for full route)
- You can stop/restart anytime with `xcrun simctl location booted clear`
