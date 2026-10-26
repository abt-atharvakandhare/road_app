import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:road_mobile/l10n/app_localizations.dart';
import 'package:road_mobile/ui/mainapp/charge_now/bloc/charge_now_bloc.dart';
import 'package:road_mobile/ui/mainapp/location/bloc/location_bloc.dart';
import 'package:road_mobile/ui/onboarding/login/cubit/auth_cubit.dart';
import 'package:road_mobile/services/flow/ui_flow.dart';
import 'package:road_mobile/ui/utils/widgets/rm_content_box.dart';
import 'package:app_settings/app_settings.dart';
import 'package:road_mobile/ui/utils/evse_id_extractor.dart';
import 'package:road_mobile/services/analytics/analytics.dart';
import 'package:road_mobile/services/di/injection.dart';

class QrScannerWidget extends StatefulWidget {
  const QrScannerWidget({super.key});

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget> {
  late MobileScannerController _controller;
  bool _hasProcessedCode = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      formats: [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_hasProcessedCode) return; // Prevent multiple processing

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _processQrCode(barcode.rawValue!);
        break;
      }
    }
  }

  void _processQrCode(String qrContent) {
    // Prevent processing multiple times
    _hasProcessedCode = true;

    // Extract EVSE ID from URL
    final evseId = EvseIdExtractor.extractEvseIdFromDashboardUrl(qrContent);
    final analytics = getIt<Analytics>();

    if (evseId != null) {
      // Log successful QR scan
      analytics.logQrCodeScanResult(
        success: true,
        qrContent: qrContent,
        extractedEvseId: evseId,
      );

      // Submit the EVSE ID using the existing event
      final partyIds = BlocProvider.of<AuthCubit>(context).state.remoteSessionEnabledPartyIds;
      final userLocation = BlocProvider.of<LocationBloc>(context).state.lastKnownLocation;
      BlocProvider.of<ChargeNowBloc>(context).add(ChargeNowEvent.manualEvseIdSubmitted(evseId, partyIds, userLocation));
    } else {
      // Log failed QR scan
      analytics.logQrCodeScanResult(
        success: false,
        qrContent: qrContent,
      );

      BlocProvider.of<ChargeNowBloc>(context).add(
        const ChargeNowEvent.invalidQrCode('Not a valid charging QR code.'),
      );

      Future.delayed(Duration(seconds: 2), () {
        if (!mounted) return;
        _hasProcessedCode = false;
      });
    }
  }

  void _handlePermissionDenied() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(dialogContext)!.cameraPermissionRequired,
              style: Theme.of(dialogContext).textTheme.headlineSmall),
          content: Text(AppLocalizations.of(dialogContext)!.cameraPermissionMessage,
              style: Theme.of(dialogContext).textTheme.labelMedium),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                BlocProvider.of<ChargeNowBloc>(context).add(const ChargeNowEvent.backButtonTapped());
              },
              child: Text(AppLocalizations.of(dialogContext)!.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await AppSettings.openAppSettings();
              },
              child: Text(AppLocalizations.of(dialogContext)!.openSettings),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChargeNowBloc, ChargeNowState>(
      listener: (context, state) {
        // Reset the processing flag if we get an error while still on QR scanner screen
        if (state is ScanningQrCode && state.flow.isError) {
          Future.delayed(Duration(seconds: 2), () {
            if (!mounted) return;
            _hasProcessedCode = false;
          });
        }
      },
      child: SingleChildScrollView(
        child: Center(
          child: RMContentBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.scanStationQrCode,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.useCameraToIdentifyStationId,
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 10,
                    ),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: double.infinity,
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: MobileScanner(
                            controller: _controller,
                            onDetect: _handleBarcode,
                            errorBuilder: (context, error) {
                              if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
                                // Handle permission denied
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _handlePermissionDenied();
                                });
                                return Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.cameraPermissionDenied,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              return Center(
                                child: Text(
                                  AppLocalizations.of(context)!.errorAccessingCamera,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: ValueListenableBuilder<MobileScannerState>(
                            valueListenable: _controller,
                            builder: (context, state, _) {
                              final isOn = state.torchState == TorchState.on;
                              final torchLabel = AppLocalizations.of(context)!.qrScannerTorchToggle;
                              return Semantics(
                                button: true,
                                label: torchLabel,
                                child: Material(
                                  color: Colors.black54,
                                  shape: const CircleBorder(),
                                  child: IconButton(
                                    tooltip: torchLabel,
                                    icon: Icon(
                                      isOn ? Icons.flashlight_on : Icons.flashlight_off,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => _controller.toggleTorch(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
