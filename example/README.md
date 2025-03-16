# EVCC API Examples

This directory contains examples demonstrating how to use the EVCC Dart API client.

## Running the Examples

To run an example, use the following command:

```bash
dart run example/basic_usage.dart
```

Make sure to update the EVCC API URL and credentials in each example to match your setup.

## Available Examples

- **basic_usage.dart**: Demonstrates basic API client initialization, authentication, and system state retrieval.
- **loadpoint_management.dart**: Shows how to manage charging points, including setting modes, limits, and plans.
- **vehicle_management.dart**: Illustrates vehicle management, including SoC limits and charging plans.
- **battery_management.dart**: Demonstrates home battery control and configuration.
- **tariffs_and_sessions.dart**: Shows how to work with electricity tariffs and charging sessions.
- **system_operations.dart**: Illustrates system operations like log retrieval and telemetry management.

## Notes

- These examples are intended for educational purposes.
- Always be careful when using methods that modify your EVCC configuration.
- Some operations (like shutdown) are commented out to prevent accidental execution.
