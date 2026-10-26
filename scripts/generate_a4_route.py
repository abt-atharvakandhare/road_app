#!/usr/bin/env python3
"""
Generate a realistic GPX route for A4 highway from Delft to Amsterdam.
Uses OpenStreetMap data and interpolates points at 1-second intervals for 100km/h speed.
"""

import requests
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
from math import radians, cos, sin, asin, sqrt, atan2, degrees
import sys

def haversine(lon1, lat1, lon2, lat2):
    """Calculate the great circle distance in meters between two points."""
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    dlon = lon2 - lon1
    dlat = lat2 - lat1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * asin(sqrt(a))
    r = 6371000  # Radius of earth in meters
    return c * r

def calculate_bearing(lon1, lat1, lon2, lat2):
    """Calculate the bearing between two points in degrees."""
    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
    dlon = lon2 - lon1
    x = sin(dlon) * cos(lat2)
    y = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dlon)
    initial_bearing = atan2(x, y)
    return (degrees(initial_bearing) + 360) % 360

def interpolate_point(lon1, lat1, lon2, lat2, fraction):
    """Interpolate a point between two coordinates."""
    lat = lat1 + (lat2 - lat1) * fraction
    lon = lon1 + (lon2 - lon1) * fraction
    return lon, lat

def get_a4_route():
    """
    Query OpenStreetMap Overpass API for A4 highway route from Delft to Amsterdam.
    Returns list of (lat, lon) tuples.
    """
    print("Querying OpenStreetMap for A4 highway route (Delft → Amsterdam)...")

    # Overpass API query for A4 highway
    overpass_url = "http://overpass-api.de/api/interpreter"
    overpass_query = """
    [out:json];
    (
      way["ref"="A4"]["highway"="motorway"](51.9,4.2,52.4,4.9);
    );
    out geom;
    """

    try:
        response = requests.post(overpass_url, data={'data': overpass_query}, timeout=60)
        response.raise_for_status()
        data = response.json()

        if not data.get('elements'):
            print("⚠️  No A4 route found in OpenStreetMap. Using fallback route.")
            return get_fallback_route()

        # Collect all coordinates from way segments
        ways = [el for el in data['elements'] if el['type'] == 'way']

        if not ways:
            print("⚠️  No ways found. Using fallback route.")
            return get_fallback_route()

        # Define start (Delft) and end (Amsterdam) points
        delft_coords = (52.00667, 4.35556)
        amsterdam_coords = (52.370216, 4.895168)

        # Build a continuous route from Delft to Amsterdam
        all_coords = []
        used_ways = set()

        # Find the way segment closest to Delft
        current_point = delft_coords
        remaining_ways = list(range(len(ways)))

        while remaining_ways:
            # Find closest unused way to current point
            best_way_idx = None
            best_distance = float('inf')
            best_reversed = False

            for idx in remaining_ways:
                way = ways[idx]
                first_point = (way['geometry'][0]['lat'], way['geometry'][0]['lon'])
                last_point = (way['geometry'][-1]['lat'], way['geometry'][-1]['lon'])

                dist_to_first = haversine(current_point[1], current_point[0], first_point[1], first_point[0])
                dist_to_last = haversine(current_point[1], current_point[0], last_point[1], last_point[0])

                if dist_to_first < best_distance:
                    best_distance = dist_to_first
                    best_way_idx = idx
                    best_reversed = False

                if dist_to_last < best_distance:
                    best_distance = dist_to_last
                    best_way_idx = idx
                    best_reversed = True

            # If the best connection is too far (>5km), we've likely reached Amsterdam
            if best_distance > 5000:
                break

            # Add the best way to our route
            way = ways[best_way_idx]
            coords = [(node['lat'], node['lon']) for node in way['geometry']]

            if best_reversed:
                coords = coords[::-1]

            # Skip first point if it's very close to last point (avoid duplicates)
            if all_coords and len(coords) > 0:
                last = all_coords[-1]
                first = coords[0]
                if haversine(last[1], last[0], first[1], first[0]) < 10:  # Within 10 meters
                    coords = coords[1:]

            all_coords.extend(coords)
            current_point = coords[-1] if coords else current_point
            remaining_ways.remove(best_way_idx)

            # Check if we're close enough to Amsterdam to stop
            dist_to_amsterdam = haversine(
                current_point[1], current_point[0],
                amsterdam_coords[1], amsterdam_coords[0]
            )
            if dist_to_amsterdam < 2000:  # Within 2km of Amsterdam
                break

        # Add final point to Amsterdam if not already close
        if all_coords:
            dist_to_amsterdam = haversine(
                all_coords[-1][1], all_coords[-1][0],
                amsterdam_coords[1], amsterdam_coords[0]
            )
            if dist_to_amsterdam > 500:
                all_coords.append(amsterdam_coords)

        total_distance = sum(
            haversine(all_coords[i][1], all_coords[i][0], all_coords[i+1][1], all_coords[i+1][0])
            for i in range(len(all_coords) - 1)
        )

        print(f"✓ Retrieved {len(all_coords)} waypoints from OpenStreetMap")
        print(f"  Route distance: {total_distance/1000:.1f} km")
        return all_coords

    except Exception as e:
        print(f"⚠️  Error querying OpenStreetMap: {e}")
        print("Using fallback route with interpolated points.")
        return get_fallback_route()

def get_fallback_route():
    """Fallback route if OSM query fails - key waypoints from Delft to Amsterdam via A4."""
    waypoints = [
        (52.00667, 4.35556),   # Delft
        (52.02000, 4.37000),   # Delft North
        (52.04000, 4.39000),   # Before Den Haag
        (52.06000, 4.42000),   # Den Haag area
        (52.08000, 4.45000),   # Wassenaar
        (52.10000, 4.48000),   # Katwijk area
        (52.13000, 4.52000),   # Noordwijkerhout
        (52.16000, 4.56000),   # Lisse area
        (52.19000, 4.60000),   # Nieuw-Vennep
        (52.22000, 4.64000),   # Hoofddorp area
        (52.25000, 4.68000),   # Badhoevedorp
        (52.28000, 4.72000),   # Sloten
        (52.31000, 4.76000),   # Amsterdam West
        (52.34000, 4.82000),   # Amsterdam Centrum
        (52.370216, 4.895168), # Amsterdam Centraal
    ]

    # Interpolate more points between waypoints
    detailed_coords = []
    for i in range(len(waypoints) - 1):
        lat1, lon1 = waypoints[i]
        lat2, lon2 = waypoints[i + 1]
        dist = haversine(lon1, lat1, lon2, lat2)

        # Add points every ~50 meters
        num_points = max(int(dist / 50), 1)
        for j in range(num_points):
            fraction = j / num_points
            lon, lat = interpolate_point(lon1, lat1, lon2, lat2, fraction)
            detailed_coords.append((lat, lon))

    detailed_coords.append(waypoints[-1])
    print(f"✓ Created {len(detailed_coords)} interpolated waypoints")
    return detailed_coords

def generate_gpx_with_speed(coords, speed_kmh=100, output_file='A4_Delft_to_Amsterdam.gpx'):
    """
    Generate GPX file with points at 1-second intervals.

    Args:
        coords: List of (lat, lon) tuples
        speed_kmh: Speed in km/h (default 100)
        output_file: Output GPX filename
    """
    speed_ms = speed_kmh / 3.6  # Convert to m/s (100 km/h = 27.78 m/s)
    distance_per_second = speed_ms  # Distance to travel in 1 second

    print(f"\nGenerating GPX with {speed_kmh} km/h speed ({speed_ms:.2f} m/s)")
    print(f"Distance per second: {distance_per_second:.2f} meters")

    # Create GPX structure
    gpx = ET.Element('gpx', {
        'version': '1.1',
        'creator': 'A4 Route Generator',
        'xmlns': 'http://www.topografix.com/GPX/1/1',
        'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:schemaLocation': 'http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd'
    })

    metadata = ET.SubElement(gpx, 'metadata')
    ET.SubElement(metadata, 'name').text = 'A4 Delft to Amsterdam'
    ET.SubElement(metadata, 'desc').text = f'A4 highway route at {speed_kmh} km/h with 1 second intervals'
    ET.SubElement(metadata, 'time').text = datetime.utcnow().isoformat() + 'Z'

    trk = ET.SubElement(gpx, 'trk')
    ET.SubElement(trk, 'name').text = 'A4 Highway Route'
    trkseg = ET.SubElement(trk, 'trkseg')

    # Generate points at 1-second intervals
    current_time = datetime.utcnow()
    trkpts_generated = []

    # Start at first coordinate
    accumulated_distance = 0
    coord_index = 0
    lat1, lon1 = coords[0]

    print("Interpolating points at 1-second intervals...")

    while coord_index < len(coords) - 1:
        lat2, lon2 = coords[coord_index + 1]
        segment_distance = haversine(lon1, lat1, lon2, lat2)

        # If we need to add points within this segment
        while accumulated_distance < segment_distance and coord_index < len(coords) - 1:
            # Calculate position along segment
            fraction = accumulated_distance / segment_distance if segment_distance > 0 else 0
            lon, lat = interpolate_point(lon1, lat1, lon2, lat2, fraction)

            # Calculate bearing for this segment
            bearing = calculate_bearing(lon1, lat1, lon2, lat2)

            # Add trackpoint
            trkpt = ET.SubElement(trkseg, 'trkpt', {
                'lat': f'{lat:.7f}',
                'lon': f'{lon:.7f}'
            })
            ET.SubElement(trkpt, 'ele').text = '0'  # Elevation (can be enhanced with real data)
            ET.SubElement(trkpt, 'time').text = current_time.isoformat() + 'Z'

            # Add extensions for speed and bearing
            extensions = ET.SubElement(trkpt, 'extensions')
            ET.SubElement(extensions, 'speed').text = f'{speed_ms:.2f}'
            ET.SubElement(extensions, 'course').text = f'{bearing:.2f}'

            trkpts_generated.append((lat, lon, current_time))

            # Move forward by 1 second worth of distance
            accumulated_distance += distance_per_second
            current_time += timedelta(seconds=1)

        # Move to next segment
        accumulated_distance -= segment_distance
        lat1, lon1 = lat2, lon2
        coord_index += 1

    # Add final point
    lat, lon = coords[-1]
    trkpt = ET.SubElement(trkseg, 'trkpt', {
        'lat': f'{lat:.7f}',
        'lon': f'{lon:.7f}'
    })
    ET.SubElement(trkpt, 'ele').text = '0'
    ET.SubElement(trkpt, 'time').text = current_time.isoformat() + 'Z'
    extensions = ET.SubElement(trkpt, 'extensions')
    ET.SubElement(extensions, 'speed').text = f'{speed_ms:.2f}'
    if len(trkpts_generated) > 0:
        last_bearing = calculate_bearing(
            trkpts_generated[-1][1], trkpts_generated[-1][0],
            lon, lat
        )
        ET.SubElement(extensions, 'course').text = f'{last_bearing:.2f}'

    trkpts_generated.append((lat, lon, current_time))

    # Write to file
    tree = ET.ElementTree(gpx)
    ET.indent(tree, space='  ')
    tree.write(output_file, encoding='utf-8', xml_declaration=True)

    # Calculate statistics
    total_distance = sum(
        haversine(
            trkpts_generated[i][1], trkpts_generated[i][0],
            trkpts_generated[i+1][1], trkpts_generated[i+1][0]
        )
        for i in range(len(trkpts_generated) - 1)
    )
    duration = (trkpts_generated[-1][2] - trkpts_generated[0][2]).total_seconds()

    print(f"\n✓ GPX file created: {output_file}")
    print(f"  Total trackpoints: {len(trkpts_generated)}")
    print(f"  Total distance: {total_distance/1000:.2f} km")
    print(f"  Duration: {int(duration//60)}m {int(duration%60)}s")
    print(f"  Average speed: {(total_distance/duration)*3.6:.1f} km/h")

def main():
    speed = 100  # km/h
    output = 'scripts/A4_Delft_to_Amsterdam.gpx'

    if len(sys.argv) > 1:
        try:
            speed = int(sys.argv[1])
        except ValueError:
            print(f"Invalid speed: {sys.argv[1]}, using default 100 km/h")

    if len(sys.argv) > 2:
        output = sys.argv[2]

    print("=" * 60)
    print("A4 Highway Route Generator")
    print("=" * 60)

    # Get route from OpenStreetMap
    coords = get_a4_route()

    if not coords:
        print("❌ Failed to generate route")
        return 1

    # Generate GPX file
    generate_gpx_with_speed(coords, speed_kmh=speed, output_file=output)

    print("\n" + "=" * 60)
    print("✓ Done!")
    print(f"\nTo use with iOS Simulator:")
    print(f"  xcrun simctl location booted {output}")
    print("=" * 60)

    return 0

if __name__ == '__main__':
    sys.exit(main())
