import 'package:flutter/material.dart';
import 'package:road_mobile/services/car_screen/car_screen.dart';
import 'package:road_mobile/services/di/injection.dart';

class CarPlayDebugWidget extends StatelessWidget {
  const CarPlayDebugWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CarPlay Debug Controls',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final carScreen = getIt<CarScreen>();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Triggering CarPlay location update...'),
                      duration: Duration(seconds: 1),
                    ),
                  );

                  try {
                    await carScreen.triggerLocationUpdate();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('CarPlay location update triggered! Check logs for details.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.location_on),
                label: const Text('Trigger CarPlay Location Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
