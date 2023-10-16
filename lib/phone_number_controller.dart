import 'package:flutter/material.dart';
import 'package:libphonenumber/libphonenumber.dart';

/// A [TextEditingController] that formats phone numbers as they are typed.
class PhoneNumberController extends TextEditingController {
  final String countryCode;

  bool _shouldFormat = true;
  String _previous = '';
  String _raw = '';
  Set<int> _insertedChars = {};

  PhoneNumberController({required this.countryCode, String? text})
      : super(text: text) {
    // TODO: also support format-as-you-type for existing numbers
    _shouldFormat = text == null || text.isEmpty;
    addListener(_format);
  }

  @override
  void dispose() {
    removeListener(_format);
    super.dispose();
  }

  void _cancelFormat() {
    _resetFormat();
    _shouldFormat = false;
  }

  void _resetFormat() {
    _shouldFormat = true;
    _previous = '';
    _raw = '';
    _insertedChars = {};
  }

  Future<void> _format() async {
    final current = text;
    if (current.isEmpty) {
      _resetFormat();
      _maybePrint('format: cleared and reset');
      return;
    }

    if (!_shouldFormat) {
      _maybePrint('format: return because shouldFormat is false');
      return;
    }

    final cursor = selection.baseOffset;
    final change = inferDiffWithCursorHint(_previous, current, cursor) ??
        inferDiff(_previous, current);
    _maybePrint(
        'format: inferred change from `$_previous` to `$current`: $change');

    String newRaw = '';
    int? newCursor;
    int? desiredRawCursor;

    if (change is NoDiff) {
      _maybePrint('format: return because change is NoDiff');
      return;
    } else if (change is AddedChars) {
      final offset = change.offset - _numInsertedBeforeOffset(change.offset);
      final suffix = _raw.substring(offset);
      newRaw = _raw.substring(0, offset) + change.addedChars + suffix;
      if (suffix.isNotEmpty) {
        desiredRawCursor = offset + change.addedChars.length;
        _maybePrint('format: desiredRawCursor = $desiredRawCursor');
      }
    } else if (change is RemovedChars) {
      final (offset, numToRemove) =
          computeRemovedCharsFromRaw(change, _insertedChars);
      final suffix = _raw.substring(offset + numToRemove);
      _maybePrint(
          'format: computeRemovedCharsFromRaw with $change and $_insertedChars = ($offset, $numToRemove)');
      newRaw = _raw.substring(0, offset) + suffix;
      if (suffix.isNotEmpty) {
        desiredRawCursor = offset;
        _maybePrint('format: desiredRawCursor = $desiredRawCursor');
      }
    } else {
      _maybePrint('format: cancel format because change is null');
      _cancelFormat();
      return;
    }

    final newPrevious = await PhoneNumberUtil.formatAsYouType(
        phoneNumber: newRaw, isoCode: countryCode);
    if (newPrevious == null) {
      _maybePrint('format: cancel format because newPrevious is null');
      _cancelFormat();
      return;
    }
    final newInsertedChars = computeInsertedChars(newRaw, newPrevious);
    if (newInsertedChars == null) {
      _maybePrint('format: cancel format because newInsertedChars is null');
      _cancelFormat();
      return;
    }
    if (desiredRawCursor != null) {
      var i = 0;
      var j = 0;
      while (j < desiredRawCursor) {
        if (!newInsertedChars.contains(i)) {
          j++;
        }
        i++;
      }
      newCursor = i;
    }
    _maybePrint('format:');
    _maybePrint('  -> newRaw: $newRaw');
    _maybePrint('  -> newPrevious: $newPrevious');
    _maybePrint('  -> newInsertedChars: $newInsertedChars');
    _maybePrint('  -> newCursor: $newCursor');
    _raw = newRaw;
    _previous = newPrevious;
    _insertedChars = newInsertedChars;

    text = newPrevious;
    if (newCursor != null) {
      selection = TextSelection.fromPosition(TextPosition(offset: newCursor));
    }
  }

  int _numInsertedBeforeOffset(int offset) {
    return _insertedChars.where((i) => i < offset).length;
  }
}

void _maybePrint(String s) {
  // print(s);
}

/// Base class for Diff between two strings.
@visibleForTesting
abstract class Diff {}

/// No diff between two strings.
@visibleForTesting
class NoDiff extends Diff {}

/// The two strings differ by adding contiguous characters.
@visibleForTesting
class AddedChars extends Diff {
  final int offset;
  final String addedChars;

  AddedChars({this.offset = -1, required this.addedChars});

  @override
  String toString() => 'AddedChars(offset: $offset, addedChars: $addedChars)';

  @override
  operator ==(Object other) {
    if (other is AddedChars) {
      return offset == other.offset && addedChars == other.addedChars;
    }
    return false;
  }

  @override
  int get hashCode => offset.hashCode ^ addedChars.hashCode;
}

/// The two strings differ by removing contiguous characters.
@visibleForTesting
class RemovedChars extends Diff {
  final int offset;
  final int numChars;

  RemovedChars({this.offset = -1, required this.numChars});

  @override
  String toString() => 'RemovedChars(offset: $offset, numChars: $numChars)';

  @override
  operator ==(Object other) {
    if (other is RemovedChars) {
      return offset == other.offset && numChars == other.numChars;
    }
    return false;
  }

  @override
  int get hashCode => offset.hashCode ^ numChars.hashCode;
}

/// Infer the diff between two strings.
@visibleForTesting
Diff? inferDiff(String previous, String current) {
  if (previous == current) return NoDiff();

  String prefix = longestCommonPrefix(previous, current);
  String suffix = longestCommonSuffix(
      previous.substring(prefix.length), current.substring(prefix.length));

  if (prefix + suffix == previous) {
    return AddedChars(
      offset: prefix.length,
      addedChars:
          current.substring(prefix.length, current.length - suffix.length),
    );
  } else if (prefix + suffix == current) {
    return RemovedChars(
      offset: prefix.length,
      numChars: previous.length - current.length,
    );
  }

  return null;
}

/// Infer the diff between two strings, with a hint about the cursor position.
@visibleForTesting
Diff? inferDiffWithCursorHint(String previous, String current, int cursor) {
  if (previous.length < current.length) {
    int numAdded = current.length - previous.length;
    int offset = cursor - numAdded;
    if (offset >= 0 &&
        current.substring(0, offset) + current.substring(cursor) == previous) {
      _maybePrint('inferDiffWithCursorHint: AddedChars(offset: $offset, '
          'addedChars: ${current.substring(offset, cursor)})');
      return AddedChars(
          offset: offset, addedChars: current.substring(offset, cursor));
    }
  } else if (previous.length > current.length) {
    int numRemoved = previous.length - current.length;
    int endOffset = cursor + numRemoved;
    if (endOffset <= previous.length &&
        previous.substring(0, cursor) + previous.substring(endOffset) ==
            current) {
      _maybePrint('inferDiffWithCursorHint: RemovedChars(offset: $cursor, '
          'numChars: $numRemoved)');
      return RemovedChars(offset: cursor, numChars: numRemoved);
    }
  }

  return null;
}

/// Returns the longest common prefix between two strings.
@visibleForTesting
String longestCommonPrefix(String a, String b) {
  for (var i = 0; i < a.length && i < b.length; i++) {
    if (a[i] != b[i]) {
      return a.substring(0, i);
    }
  }
  if (a.length < b.length) {
    return a;
  } else {
    return b;
  }
}

/// Returns the longest common suffix between two strings.
@visibleForTesting
String longestCommonSuffix(String a, String b) {
  for (var i = 0; i < a.length && i < b.length; i++) {
    if (a[a.length - i - 1] != b[b.length - i - 1]) {
      return a.substring(a.length - i);
    }
  }
  if (a.length < b.length) {
    return a;
  } else {
    return b;
  }
}

/// Returns the set of indices of characters that were inserted between raw and
/// formatted strings.
@visibleForTesting
Set<int>? computeInsertedChars(String raw, String formatted) {
  final insertedChars = <int>{};
  var i = 0;
  var j = 0;
  while (i < raw.length && j < formatted.length) {
    if (raw[i] == formatted[j]) {
      i++;
      j++;
    } else {
      insertedChars.add(j);
      j++;
    }
  }
  if (j == formatted.length && i < raw.length) {
    return null;
  }
  while (j < formatted.length) {
    insertedChars.add(j);
    j++;
  }
  return insertedChars;
}

/// Returns the offset and number of characters to remove from the raw string.
@visibleForTesting
(int, int) computeRemovedCharsFromRaw(
    RemovedChars change, Set<int> insertedChars) {
  final insertedToRemove = insertedChars
      .where((i) => i >= change.offset && i < change.offset + change.numChars)
      .length;
  final insertedBeforeOffset =
      insertedChars.where((i) => i < change.offset).length;
  _maybePrint('format: computeRemovedCharsFromRaw: '
      'insertedToRemove = $insertedToRemove, '
      'insertedBeforeOffset = $insertedBeforeOffset');
  // Special case: if all removed chars are inserted, we remove the character
  // before the offset instead.
  if (insertedToRemove == change.numChars) {
    if (change.offset == 0) {
      return (0, 0);
    }
    return (change.offset - insertedBeforeOffset - 1, 1);
  }
  return (
    change.offset - insertedBeforeOffset,
    change.numChars - insertedToRemove
  );
}
