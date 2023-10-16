import 'package:flutter_test/flutter_test.dart';
import 'package:phone_number_controller/phone_number_controller.dart';

void main() {
  group('PhoneNumberController', () {
    const countryCode = 'us';

    test('initial value', () {
      final controller = PhoneNumberController(countryCode: countryCode);
      expect(controller.text, '');
    });

    test('longestCommonPrefix', () {
      expect(longestCommonPrefix('', ''), '');

      expect(longestCommonPrefix('a', ''), '');
      expect(longestCommonPrefix('ab', ''), '');
      expect(longestCommonPrefix('', 'a'), '');
      expect(longestCommonPrefix('', 'ab'), '');

      expect(longestCommonPrefix('ab', 'ac'), 'a');
      expect(longestCommonPrefix('abc', 'abcd'), 'abc');

      expect(longestCommonPrefix('ab', 'cd'), '');
      expect(longestCommonPrefix('abd', 'abc'), 'ab');
    });

    test('longestCommonSuffix', () {
      expect(longestCommonSuffix('', ''), '');

      expect(longestCommonSuffix('a', ''), '');
      expect(longestCommonSuffix('ba', ''), '');
      expect(longestCommonSuffix('', 'a'), '');
      expect(longestCommonSuffix('', 'ba'), '');

      expect(longestCommonSuffix('ba', 'ca'), 'a');
      expect(longestCommonSuffix('cba', 'dcba'), 'cba');

      expect(longestCommonSuffix('ba', 'dc'), '');
      expect(longestCommonSuffix('dba', 'cba'), 'ba');
    });

    group('inferDiff', () {
      test('addedChars', () {
        expect(inferDiff('', 'a'), AddedChars(offset: 0, addedChars: 'a'));
        expect(inferDiff('', 'abc'), AddedChars(offset: 0, addedChars: 'abc'));
        expect(inferDiff('bc', 'abc'), AddedChars(offset: 0, addedChars: 'a'));
        expect(inferDiff('bc', 'bcd'), AddedChars(offset: 2, addedChars: 'd'));
        expect(inferDiff('bc', 'bac'), AddedChars(offset: 1, addedChars: 'a'));
        expect(inferDiff('bc', 'baca'), null);
      });

      test('removedChars', () {
        expect(inferDiff('a', ''), RemovedChars(offset: 0, numChars: 1));
        expect(inferDiff('abc', ''), RemovedChars(offset: 0, numChars: 3));
        expect(inferDiff('abc', 'bc'), RemovedChars(offset: 0, numChars: 1));
        expect(inferDiff('bcd', 'bc'), RemovedChars(offset: 2, numChars: 1));
        expect(inferDiff('bac', 'bc'), RemovedChars(offset: 1, numChars: 1));
        expect(inferDiff('baca', 'bc'), null);
      });

      test('prefix and suffix overlapping', () {
        expect(
          inferDiff('123-5', '123-55'),
          AddedChars(offset: 5, addedChars: '5'),
        );
      });
    });

    group('computeInsertedChars', () {
      test('empty', () {
        expect(computeInsertedChars('', ''), <int>{});
      });

      test('inserted', () {
        expect(computeInsertedChars('', 'a'), <int>{0});
        expect(computeInsertedChars('', 'abc'), <int>{0, 1, 2});
        expect(computeInsertedChars('bc', 'abc'), <int>{0});
        expect(computeInsertedChars('bc', 'bcd'), <int>{2});
        expect(computeInsertedChars('bc', 'bac'), <int>{1});
        expect(computeInsertedChars('bc', 'baca'), <int>{1, 3});
      });

      test('removed', () {
        expect(computeInsertedChars('a', ''), null);
        expect(computeInsertedChars('abc', ''), null);
        expect(computeInsertedChars('abc', 'bc'), null);
        expect(computeInsertedChars('bcd', 'bc'), null);
        expect(computeInsertedChars('bac', 'bc'), null);
        expect(computeInsertedChars('baca', 'bc'), null);
      });

      test('changed', () {
        expect(computeInsertedChars('abc', 'abd'), null);
        expect(computeInsertedChars('abc', 'adc'), null);
        expect(computeInsertedChars('abc', 'dbc'), null);
        expect(computeInsertedChars('abc', 'abd'), null);
        expect(computeInsertedChars('abc', 'abd'), null);
        expect(computeInsertedChars('abc', 'abd'), null);
      });

      test('identical', () {
        expect(computeInsertedChars('abc', 'abc'), <int>{});
      });
    });

    group('computeRemovedCharsFromRaw', () {
      test('starting with 0', () {
        expect(
          computeRemovedCharsFromRaw(RemovedChars(offset: 0, numChars: 3), {}),
          (0, 3),
        );
        expect(
          computeRemovedCharsFromRaw(RemovedChars(offset: 0, numChars: 3), {1}),
          (0, 2),
        );
        expect(
          computeRemovedCharsFromRaw(RemovedChars(offset: 0, numChars: 3), {
            1,
            2,
          }),
          (0, 1),
        );
        expect(
          computeRemovedCharsFromRaw(RemovedChars(offset: 0, numChars: 3), {
            1,
            4,
          }),
          (0, 2),
        );
        expect(
          computeRemovedCharsFromRaw(RemovedChars(offset: 0, numChars: 3), {
            4,
            5,
          }),
          (0, 3),
        );
      });

      test('starting with 1', () {
        expect(
          computeRemovedCharsFromRaw(RemovedChars(offset: 1, numChars: 3), {}),
          (1, 3),
        );
        expect(
          computeRemovedCharsFromRaw(RemovedChars(offset: 1, numChars: 3), {0}),
          (0, 3),
        );
        expect(
          computeRemovedCharsFromRaw(RemovedChars(offset: 1, numChars: 3), {
            0,
            1,
          }),
          (0, 2),
        );
        expect(
          computeRemovedCharsFromRaw(RemovedChars(offset: 1, numChars: 3), {
            1,
            4,
          }),
          (1, 2),
        );
      });

      test('special case', () {
        expect(
          computeRemovedCharsFromRaw(RemovedChars(offset: 1, numChars: 1), {
            1,
            4,
          }),
          (0, 1),
        );
        expect(
          computeRemovedCharsFromRaw(RemovedChars(offset: 3, numChars: 1), {3}),
          (2, 1),
        );
      });
    });
  });
}
