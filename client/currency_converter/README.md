# currency-converter

## Purpose

This is a mobile app example implemented in Flutter which integrates with the Approov SDK.
The Approov SDK provides security for mobile applications as described at <https://approov.io>.

## Prerequisites

For adapting the mobile app to your own Approov account please follow instructions on <https://approov.io/docs/v2.0/approov-usage-documentation/#getting-the-initial-sdk-configuration>.

## Run

Connect mobile phone to the USB and run the Flutter program:

```bash
flutter run
```

## Comments

The current implementation uses synchronous token fetching from Approov.
However, consider using the asynchronous mechanism instead.
