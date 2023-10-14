# phone_number_controller

[![pub](https://img.shields.io/pub/v/phone_number_controller?label=version)](https://pub.dev/packages/phone_number_controller)
[![pub points](https://img.shields.io/pub/points/phone_number_controller)](https://pub.dev/packages/phone_number_controller/score)
[![popularity](https://img.shields.io/pub/popularity/phone_number_controller)](https://pub.dev/packages/phone_number_controller/score)
[![likes](https://img.shields.io/pub/likes/phone_number_controller)](https://pub.dev/packages/phone_number_controller/score)

This plugin provides a TextEditingController that formats international phone numbers
as you type them.

## Demo

![demo](https://github.com/QuisApp/phone_number_controller/assets/80799804/bf290aa1-e637-49f4-b38b-3f250f268763)

## Usage

Two steps:

1. In a stateful widget, define a `PhoneNumberController`:

```dart
final _controller = PhoneNumberController(countryCode: 'us');
```

2. When building the text field, specify the controller:

```dart
TextFormField(
    controller: _controller,
    keyboardType: TextInputType.phone,
    ...
);
```