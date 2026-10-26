#!/usr/bin/env python3
"""
Play a GPX route on iOS Simulator or physical device by feeding coordinates.
Handles large GPX files efficiently.
"""

import xml.etree.ElementTree as ET
import subprocess
import sys
import time
import argparse

def extract_coordinates(gpx_file):
    """Extract lat,lon pairs from GPX file."""
    try:
        tree = ET.parse(gpx_file)
        root = tree.getroot()

        # Handle GPX namespace
        ns = {'gpx': 'http://www.topografix.com/GPX/1/1'}
        trkpts = root.findall('.//gpx:trkpt', ns)

        if not trkpts:
            # Try without namespace
            trkpts = root.findall('.//trkpt')

        coords = []
        for trkpt in trkpts:
            lat = trkpt.get('lat')
            lon = trkpt.get('lon')
            if lat and lon:
                coords.append(f"{lat},{lon}")

        return coords
    except Exception as e:
        print(f"❌ Error parsing GPX: {e}")
        return []

def play_route_simulator(device_id, coords, speed=27.78, interval=1.0):
    """
    Play route on simulator by feeding coordinates.

    Args:
        device_id: Simulator device ID (or 'booted')
        coords: List of 'lat,lon' strings
        speed: Speed in m/s (default 27.78 = 100 km/h)
        interval: Update interval in seconds
    """
    if not coords:
        print("❌ No coordinates to play")
        return False

    print(f"📍 Playing route with {len(coords)} waypoints")
    print(f"🚗 Speed: {speed} m/s ({speed * 3.6:.1f} km/h)")
    print(f"⏱️  Update interval: {interval}s")

    # Build command
    cmd = [
        'xcrun', 'simctl', 'location', device_id, 'start',
        f'--speed={speed}',
        f'--interval={interval}'
    ]

    # Add all coordinates
    cmd.extend(coords)

    try:
        # Execute command
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode != 0:
            print(f"❌ Error starting simulation:")
            print(result.stderr)
            return False

        print("✅ Route playback started!")
        return True

    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def play_route_physical(device_id, coords, speed=27.78, interval=1.0):
    """
    Play route on physical device by updating location at intervals.

    Args:
        device_id: Device UDID
        coords: List of 'lat,lon' strings
        speed: Speed in m/s (default 27.78 = 100 km/h)
        interval: Update interval in seconds
    """
    if not coords:
        print("❌ No coordinates to play")
        return False

    print(f"📍 Playing route with {len(coords)} waypoints")
    print(f"🚗 Speed: {speed} m/s ({speed * 3.6:.1f} km/h)")
    print(f"⏱️  Update interval: {interval}s")
    print(f"⏳ Estimated duration: {len(coords) * interval / 60:.1f} minutes")
    print()

    try:
        for i, coord in enumerate(coords):
            lat, lon = coord.split(',')

            # Set location using pymobiledevice3
            cmd = [
                'python3', '-m', 'pymobiledevice3', 'developer', 'dvt', 'simulate-location', 'set',
                '--udid', device_id,
                lat,
                lon
            ]

            result = subprocess.run(cmd, capture_output=True, text=True)

            # Check for tunneld connection errors in stderr even if returncode is 0
            if 'Unable to connect to Tunneld' in result.stderr or 'InvalidServiceError' in result.stderr:
                print(f"\n❌ Cannot connect to device - tunneld is not running!")
                print()
                print("   Location simulation on physical iOS devices (iOS 17+) requires")
                print("   a tunnel daemon running in a separate terminal.")
                print()
                print("   To fix, open another terminal and run:")
                print("   sudo python3 -m pymobiledevice3 remote tunneld")
                print()
                print("   Leave it running, then re-run this script.")
                return False

            if result.returncode != 0:
                print(f"\n❌ Error at waypoint {i+1}:")
                print(result.stderr)
                return False

            # Progress indicator
            if (i + 1) % 10 == 0 or i == 0:
                print(f"📍 Waypoint {i+1}/{len(coords)} ({(i+1)/len(coords)*100:.1f}%)")

            # Wait before next update (except for last point)
            if i < len(coords) - 1:
                time.sleep(interval)

        print("\n✅ Route playback completed!")
        return True

    except KeyboardInterrupt:
        print("\n\n⚠️  Route playback interrupted by user")
        return False
    except Exception as e:
        print(f"\n❌ Error: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(
        description='Play a GPX route on iOS Simulator or physical device'
    )
    parser.add_argument('gpx_file', help='Path to GPX file')
    parser.add_argument('device_id', nargs='?', default='booted',
                       help='Device ID/UDID or "booted" for simulator (default: booted)')
    parser.add_argument('speed_kmh', type=float, nargs='?', default=100.0,
                       help='Speed in km/h (default: 100)')
    parser.add_argument('--physical', action='store_true',
                       help='Force physical device mode')
    parser.add_argument('--interval', type=float, default=1.0,
                       help='Update interval in seconds (default: 1.0)')

    args = parser.parse_args()

    gpx_file = args.gpx_file
    device_id = args.device_id
    speed_kmh = args.speed_kmh
    speed_ms = speed_kmh / 3.6
    is_physical = args.physical

    # Auto-detect physical device if not explicitly set
    if not is_physical and device_id != 'booted':
        # Check if it's a 40-char hex UDID (physical device)
        if len(device_id) == 40 and all(c in '0123456789abcdefABCDEF-' for c in device_id):
            is_physical = True

    device_type = "Physical Device" if is_physical else "iOS Simulator"

    print("=" * 60)
    print(f"GPX Route Player for {device_type}")
    print("=" * 60)
    print(f"GPX File: {gpx_file}")
    print(f"Device: {device_id}")
    print()

    # Extract coordinates
    print("Extracting coordinates from GPX...")
    coords = extract_coordinates(gpx_file)

    if not coords:
        print("❌ No coordinates found in GPX file")
        return 1

    # Play route based on device type
    if is_physical:
        success = play_route_physical(device_id, coords, speed=speed_ms, interval=args.interval)
        stop_cmd = f"python3 -m pymobiledevice3 developer dvt simulate-location clear --udid {device_id}"
    else:
        success = play_route_simulator(device_id, coords, speed=speed_ms, interval=args.interval)
        stop_cmd = f"xcrun simctl location {device_id} clear"

    if success:
        print()
        print("=" * 60)
        if is_physical:
            print("✓ Route playback completed")
        else:
            print("✓ Route is now playing")
        print(f"To stop: {stop_cmd}")
        print("=" * 60)
        return 0
    else:
        return 1

if __name__ == '__main__':
    sys.exit(main())
