# phone_number_controller

[![pub](https://img.shields.io/pub/v/phone_number_controller?label=version)](https://pub.dev/packages/phone_number_controller)
[![pub points](https://img.shields.io/pub/points/phone_number_controller)](https://pub.dev/packages/phone_number_controller/score)
[![popularity](https://img.shields.io/pub/dm/phone_number_controller)](https://pub.dev/packages/phone_number_controller/score)
[![likes](https://img.shields.io/pub/likes/phone_number_controller)](https://pub.dev/packages/phone_number_controller/score)

[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-%E2%9D%A4-red?style=for-the-badge&logo=github)](https://github.com/sponsors/joachim-quis)
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/G2G11OWJA4)

This plugin provides a TextEditingController that formats international phone numbers
as you type them.

## Demo

<img src="https://github.com/QuisApp/phone_number_controller/assets/80799804/686f8c5e-448a-44b6-9bc2-0a3538ab7588" alt="demo" width="280"/>

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
