#!/bin/bash
# A4 Highway Route Simulation Script
# Usage: ./simulate_a4_route.sh [device_id]

# If no device ID provided, auto-detect
if [ -z "$1" ]; then
    # First check if simulator is booted
    if xcrun simctl list devices | grep -q "Booted"; then
        DEVICE_ID="booted"
        echo "🔍 Auto-detected: Booted iOS Simulator"
    else
        # Try to find connected physical device (iPhone or iPad)
        # Get devices from "== Devices ==" section, excluding Mac, Watch, and offline devices
        ALL_DEVICES=$(xcrun xctrace list devices 2>/dev/null)
        PHYSICAL_DEVICES=$(echo "$ALL_DEVICES" | sed -n '/== Devices ==/,/== Devices Offline ==/p' | grep -E "(iPhone|iPad)" | grep -E "\([0-9]+\.[0-9.]+\)" | grep -v "Simulator")
        DEVICE_COUNT=$(echo "$PHYSICAL_DEVICES" | grep -c . 2>/dev/null || echo 0)

        if [ "$DEVICE_COUNT" -eq 1 ] && [ -n "$PHYSICAL_DEVICES" ]; then
            # Extract UDID from the line (last parenthesized group, format: 00008140-0011712A3AFB001C)
            DEVICE_ID=$(echo "$PHYSICAL_DEVICES" | sed -E 's/.*\(([0-9A-Fa-f-]+)\)$/\1/')
            # Extract device name (everything before first parenthesis)
            DEVICE_NAME=$(echo "$PHYSICAL_DEVICES" | sed -E 's/^([^(]+).*/\1/' | xargs)
            echo "🔍 Auto-detected: $DEVICE_NAME"
        elif [ "$DEVICE_COUNT" -gt 1 ]; then
            echo "❌ Multiple devices connected. Please specify device UDID:"
            echo ""
            echo "$PHYSICAL_DEVICES"
            echo ""
            echo "Usage: $0 <device_udid>"
            exit 1
        else
            echo "❌ No booted simulators or connected devices found."
            echo "Please either:"
            echo "  1. Start an iOS Simulator, or"
            echo "  2. Connect a physical device via USB"
            exit 1
        fi
    fi
else
    DEVICE_ID="$1"
fi

echo "🚗 A4 Highway Route Simulation"
echo "=============================="
echo "Device: $DEVICE_ID"
echo "Route: Delft → Amsterdam via A4"
echo ""

# Detect device type
IS_PHYSICAL_DEVICE=false
if [ "$DEVICE_ID" != "booted" ]; then
    # Check if it's a UDID (physical device) vs simulator UUID
    if [[ $DEVICE_ID =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
        # Simulator UUID format
        IS_PHYSICAL_DEVICE=false
    elif [[ $DEVICE_ID =~ ^[0-9A-Fa-f-]{36,40}$ ]]; then
        # Physical device UDID format (36-40 chars with hex and dashes)
        IS_PHYSICAL_DEVICE=true
    else
        # Check if it's a connected physical device
        if xcrun xctrace list devices 2>/dev/null | grep -q "$DEVICE_ID"; then
            IS_PHYSICAL_DEVICE=true
        fi
    fi
fi

if [ "$IS_PHYSICAL_DEVICE" = false ]; then
    # Check if simulator is running
    if ! xcrun simctl list devices | grep -q "Booted"; then
        echo "❌ No booted simulators found. Please start a simulator first."
        exit 1
    fi
    echo "📱 Mode: iOS Simulator"
else
    echo "📱 Mode: Physical Device (USB)"
    # Check if pymobiledevice3 is installed
    if ! python3 -c "import pymobiledevice3" 2>/dev/null; then
        echo "❌ pymobiledevice3 not found. Install it with:"
        echo "   pip3 install pymobiledevice3"
        exit 1
    fi

    # Check if tunneld is running
    if ! pgrep -f "pymobiledevice3 remote tunneld" > /dev/null 2>&1; then
        echo ""
        echo "❌ pymobiledevice3 tunneld is not running!"
        echo ""
        echo "   Location simulation on physical iOS devices (iOS 17+) requires"
        echo "   a tunnel daemon running in a separate terminal."
        echo ""
        echo "   To fix, open another terminal and run:"
        echo "   sudo python3 -m pymobiledevice3 remote tunneld"
        echo ""
        echo "   Leave it running, then re-run this script."
        exit 1
    fi
    echo "✅ pymobiledevice3 tunneld detected"
    echo ""
fi

echo "📍 Available commands:"
echo "1) Set static location (Delft)"
echo "2) Simulate A4 route (key waypoints)"
echo "3) Simulate A4 route (detailed - every 1 second)"
echo "4) Use built-in Freeway Drive"
echo "5) Clear location simulation"
echo "6) List all available scenarios"
echo ""

read -p "Choose option (1-6): " choice

case $choice in
    1)
        echo "Setting static location to Delft..."
        if [ "$IS_PHYSICAL_DEVICE" = true ]; then
            # Create a simple GPX file with the static location repeated
            STATIC_GPX="/tmp/delft_static.gpx"
            cat > "$STATIC_GPX" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="A4 Route Simulator">
  <trk>
    <trkseg>
      <trkpt lat="52.00667" lon="4.35556"><ele>0</ele></trkpt>
      <trkpt lat="52.00667" lon="4.35556"><ele>0</ele></trkpt>
    </trkseg>
  </trk>
</gpx>
EOF
            echo "Starting continuous location simulation (this will keep the location locked)..."
            echo "Press Ctrl+C to stop"
            python3 -m pymobiledevice3 developer dvt simulate-location play --udid "$DEVICE_ID" "$STATIC_GPX" 2>&1 | grep -v "NotOpenSSLWarning" | grep -v "urllib3" | grep -v "warnings.warn"
        else
            xcrun simctl location $DEVICE_ID set 52.00667,4.35556
        fi
        ;;
    2)
        if [ "$IS_PHYSICAL_DEVICE" = true ]; then
            echo "⚠️  Waypoint simulation not directly supported for physical devices."
            echo "Please use option 3 (GPX route) for best results."
            exit 1
        else
            echo "Starting A4 route simulation (key waypoints)..."
            xcrun simctl location $DEVICE_ID start --speed=28 --distance=50 52.00667,4.35556 52.025,4.365 52.08,4.4 52.1,4.42 52.16,4.5 52.3,4.68 52.32,4.75 52.370216,4.895168
        fi
        ;;
    3)
        echo "Starting detailed A4 route simulation..."
        GPX_FILE="$(dirname "$0")/A4_Delft_to_Amsterdam.gpx"
        SCRIPT_DIR="$(dirname "$0")"

        if [ ! -f "$GPX_FILE" ]; then
            echo "❌ GPX file not found: $GPX_FILE"
            echo "Run: python3 scripts/generate_a4_route.py"
            exit 1
        fi

        if [ "$IS_PHYSICAL_DEVICE" = true ]; then
            echo "Playing GPX route (press Ctrl+C to stop)..."
            echo "Note: Route will play back using GPX timestamps (1-second intervals at ~100 km/h)"
            python3 -m pymobiledevice3 developer dvt simulate-location play --udid "$DEVICE_ID" "$GPX_FILE" 2>&1 | grep -v "NotOpenSSLWarning" | grep -v "urllib3" | grep -v "warnings.warn"
        else
            python3 "$SCRIPT_DIR/play_gpx_route.py" "$GPX_FILE" "$DEVICE_ID" 100
        fi
        ;;
    4)
        if [ "$IS_PHYSICAL_DEVICE" = true ]; then
            echo "⚠️  Built-in scenarios only available for simulators"
            exit 1
        else
            echo "Starting built-in Freeway Drive..."
            xcrun simctl location $DEVICE_ID run "Freeway Drive"
        fi
        ;;
    5)
        echo "Clearing location simulation..."
        if [ "$IS_PHYSICAL_DEVICE" = true ]; then
            python3 -m pymobiledevice3 developer dvt simulate-location clear --udid "$DEVICE_ID" 2>&1 | grep -v "NotOpenSSLWarning" | grep -v "urllib3"
        else
            xcrun simctl location $DEVICE_ID clear
        fi
        ;;
    6)
        if [ "$IS_PHYSICAL_DEVICE" = true ]; then
            echo "⚠️  Scenario list only available for simulators"
        else
            echo "Available scenarios:"
            xcrun simctl location $DEVICE_ID list
        fi
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

echo ""
echo "✅ Command executed!"
if [ "$IS_PHYSICAL_DEVICE" = true ]; then
    echo "💡 To stop simulation: python3 -m pymobiledevice3 developer dvt simulate-location clear --udid $DEVICE_ID"
else
    echo "💡 To stop simulation: xcrun simctl location $DEVICE_ID clear"
fi
