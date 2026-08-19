import 'package:flutter_test/flutter_test.dart';
import 'package:keepmind/domain/services/date_candidate_finder.dart';

/// These are the "different date formats" and "ambiguous dates" fixtures
/// the brief asks for (§36), exercised against real parsing logic rather
/// than a mock. No AI, no platform channels, no I/O — this suite runs in
/// milliseconds and is where date-handling regressions should be caught.
void main() {
  group('unambiguous formats', () {
    test('parses ISO year-first dates', () {
      final found = DateCandidateFinder.find('Valid until 2026-11-17.');
      expect(found, hasLength(1));
      expect(found.single.date, DateTime(2026, 11, 17));
      expect(found.single.ambiguous, isFalse);
    });

    test('parses "17 November 2026"', () {
      final found = DateCandidateFinder.find('Expires 17 November 2026');
      expect(found.single.date, DateTime(2026, 11, 17));
      expect(found.single.ambiguous, isFalse);
    });

    test('parses "November 17, 2026"', () {
      final found = DateCandidateFinder.find('Expires November 17, 2026');
      expect(found.single.date, DateTime(2026, 11, 17));
    });

    test('parses abbreviated months and ordinal suffixes', () {
      final found = DateCandidateFinder.find('Due 3rd Feb 2027');
      expect(found.single.date, DateTime(2027, 2, 3));
    });

    test('day > 12 disambiguates a numeric date on its own', () {
      // 17 cannot be a month, so this can only be day/month/year.
      final found = DateCandidateFinder.find('Expiry: 17/11/2026');
      expect(found, hasLength(1));
      expect(found.single.date, DateTime(2026, 11, 17));
      expect(found.single.ambiguous, isFalse);
    });

    test('second part > 12 forces a month/day reading', () {
      final found = DateCandidateFinder.find('Dated 11/17/2026');
      expect(found, hasLength(1));
      expect(found.single.date, DateTime(2026, 11, 17));
      expect(found.single.ambiguous, isFalse);
    });
  });

  group('ambiguity', () {
    test('offers both readings when a numeric date is genuinely ambiguous',
        () {
      // 03/04/2026 is 3 April (most of the world) or 4 March (US). The
      // brief forbids silently assuming MM/DD/YYYY (§37), so both are
      // surfaced for the user to choose between.
      final found = DateCandidateFinder.find('Renewal 03/04/2026');
      expect(found, hasLength(2));
      expect(found.every((c) => c.ambiguous), isTrue);
      expect(
        found.map((c) => c.date).toSet(),
        {DateTime(2026, 4, 3), DateTime(2026, 3, 4)},
      );
    });

    test('is not ambiguous when both readings agree', () {
      final found = DateCandidateFinder.find('On 05/05/2026');
      expect(found, hasLength(1));
      expect(found.single.ambiguous, isFalse);
    });
  });

  group('rejects invalid input', () {
    test('does not invent a date when none is present', () {
      final found = DateCandidateFinder.find(
        'Thank you for your custom. No dates here at all.',
      );
      expect(found, isEmpty);
    });

    test('returns empty for empty text rather than throwing', () {
      expect(DateCandidateFinder.find(''), isEmpty);
    });

    test('rejects impossible calendar dates like 30 February', () {
      // DateTime(2026, 2, 30) silently rolls over to 2 March in Dart, so
      // this asserts the round-trip validation actually rejects it rather
      // than quietly returning the wrong day.
      final found = DateCandidateFinder.find('Nonsense 30/02/2026');
      expect(found, isEmpty);
    });

    test('rejects an unknown month word', () {
      expect(DateCandidateFinder.find('17 Smarch 2026'), isEmpty);
    });
  });

  group('real-world documents', () {
    test('finds several dates and returns them oldest first', () {
      const ocrText = '''
        CAR INSURANCE CERTIFICATE
        Policy AB123456
        Issued: 17 November 2025
        Valid until 2026-11-17
      ''';
      final found = DateCandidateFinder.find(ocrText);
      expect(found.map((c) => c.date).toList(), [
        DateTime(2025, 11, 17),
        DateTime(2026, 11, 17),
      ]);
    });

    test('de-duplicates the same date written the same way twice', () {
      final found = DateCandidateFinder.find(
        'Expires 2026-11-17. Reminder: 2026-11-17.',
      );
      expect(found, hasLength(1));
    });

    test('reads two-digit years as 20xx for near-future dates', () {
      final found = DateCandidateFinder.find('Exp 17/11/26');
      expect(found.single.date, DateTime(2026, 11, 17));
    });

    test('handles dot-separated European dates', () {
      final found = DateCandidateFinder.find('Gültig bis 17.11.2026');
      expect(found.single.date, DateTime(2026, 11, 17));
    });
  });

  group('does not mistake other numbers for dates', () {
    // Real documents are full of digit groups. A false positive here is
    // worse than a miss: it puts a wrong date in front of the user as a
    // plausible-looking suggestion.
    const notDates = {
      'policy number': 'Policy AB123456',
      'money': 'Annual premium EUR486.00',
      'certificate reference': 'Certificate No. NM-88421-C',
      'pagination': 'Page 1 of 1',
      'phone number': 'Call us on 555-1234',
      'version string': 'Document template v1.2.3',
      'fraction-like quantity': 'Item 12/24 in stock',
      'bank details': 'IBAN GB29 1234 5678',
    };

    for (final entry in notDates.entries) {
      test('ignores a ${entry.key}', () {
        expect(DateCandidateFinder.find(entry.value), isEmpty);
      });
    }
  });
}
