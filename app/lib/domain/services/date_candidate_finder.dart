/// A date found in OCR'd document text, together with how it was read.
///
/// [ambiguous] is the important field: `03/04/2026` is a real date in two
/// different ways depending on locale, and the brief is explicit (§37)
/// that the app must never assume MM/DD/YYYY, and (§16) that it must
/// prefer uncertainty over incorrect certainty. Ambiguous input produces
/// *two* candidates — one per reading — and the UI makes the user pick.
class DateCandidate {
  const DateCandidate({
    required this.date,
    required this.matchedText,
    required this.interpretation,
    required this.ambiguous,
  });

  final DateTime date;

  /// The exact substring this was parsed from, so the UI can show the
  /// user where in the document it came from.
  final String matchedText;

  /// Human-readable note on how [matchedText] was read, e.g.
  /// 'day/month/year'. Shown next to ambiguous candidates.
  final String interpretation;

  final bool ambiguous;

  @override
  bool operator ==(Object other) =>
      other is DateCandidate &&
      other.date == date &&
      other.matchedText == matchedText &&
      other.interpretation == interpretation;

  @override
  int get hashCode => Object.hash(date, matchedText, interpretation);
}

/// Finds dates in free text using deterministic pattern matching — no AI.
///
/// This is the "UNDERSTAND" stage of the product loop for anything that
/// does not genuinely need a language model. The brief is explicit (§24,
/// §53) that an LLM must not be used where deterministic code is
/// superior, and finding `17/11/2026` in a string is squarely
/// deterministic work. AI-powered semantic extraction (working out that
/// this particular date is the *expiry* rather than the *issue* date, and
/// pulling out the provider and policy number) is Phase E/F and layers on
/// top of this — it does not replace it.
///
/// English month names only for now. Localized month names are tracked as
/// part of the i18n work in the brief (§37); adding them is a matter of
/// extending [_monthNames], not restructuring this class.
class DateCandidateFinder {
  DateCandidateFinder._();

  static const Map<String, int> _monthNames = {
    'jan': 1, 'january': 1,
    'feb': 2, 'february': 2,
    'mar': 3, 'march': 3,
    'apr': 4, 'april': 4,
    'may': 5,
    'jun': 6, 'june': 6,
    'jul': 7, 'july': 7,
    'aug': 8, 'august': 8,
    'sep': 9, 'sept': 9, 'september': 9,
    'oct': 10, 'october': 10,
    'nov': 11, 'november': 11,
    'dec': 12, 'december': 12,
  };

  // 2026-11-17 or 2026/11/17 — ISO-ish, year first, never ambiguous.
  static final RegExp _isoPattern =
      RegExp(r'\b(\d{4})[-/](\d{1,2})[-/](\d{1,2})\b');

  // 17/11/2026, 17.11.26, 11-17-2026 — ambiguous unless one part > 12.
  static final RegExp _numericPattern =
      RegExp(r'\b(\d{1,2})[/.\-](\d{1,2})[/.\-](\d{2,4})\b');

  // 17 November 2026 / 17th Nov, 2026
  static final RegExp _dayMonthYearPattern = RegExp(
    r'\b(\d{1,2})(?:st|nd|rd|th)?\s+([A-Za-z]{3,9})\.?,?\s+(\d{4})\b',
    caseSensitive: false,
  );

  // November 17, 2026 / Nov 17 2026
  static final RegExp _monthDayYearPattern = RegExp(
    r'\b([A-Za-z]{3,9})\.?\s+(\d{1,2})(?:st|nd|rd|th)?,?\s+(\d{4})\b',
    caseSensitive: false,
  );

  /// Returns every date found in [text], oldest first, de-duplicated.
  ///
  /// Never throws and never guesses: text with no recognizable date
  /// returns an empty list, which the UI must present as "no date found"
  /// rather than silently defaulting to today (brief §16).
  static List<DateCandidate> find(String text) {
    final found = <DateCandidate>[];

    for (final m in _isoPattern.allMatches(text)) {
      final date = _buildDate(
        year: int.parse(m.group(1)!),
        month: int.parse(m.group(2)!),
        day: int.parse(m.group(3)!),
      );
      if (date != null) {
        found.add(DateCandidate(
          date: date,
          matchedText: m.group(0)!,
          interpretation: 'year-month-day',
          ambiguous: false,
        ));
      }
    }

    for (final m in _numericPattern.allMatches(text)) {
      final first = int.parse(m.group(1)!);
      final second = int.parse(m.group(2)!);
      final year = _normalizeYear(int.parse(m.group(3)!));
      final matched = m.group(0)!;

      final asDayMonth = _buildDate(year: year, month: second, day: first);
      final asMonthDay = _buildDate(year: year, month: first, day: second);

      if (asDayMonth != null && asMonthDay != null) {
        if (asDayMonth == asMonthDay) {
          // e.g. 05/05/2026 — both readings agree, so it isn't ambiguous
          // in any way the user would care about.
          found.add(DateCandidate(
            date: asDayMonth,
            matchedText: matched,
            interpretation: 'day/month/year',
            ambiguous: false,
          ));
        } else {
          // Genuinely ambiguous: offer both, let the user choose.
          found.add(DateCandidate(
            date: asDayMonth,
            matchedText: matched,
            interpretation: 'day/month/year',
            ambiguous: true,
          ));
          found.add(DateCandidate(
            date: asMonthDay,
            matchedText: matched,
            interpretation: 'month/day/year',
            ambiguous: true,
          ));
        }
      } else if (asDayMonth != null) {
        // Only one reading is a real date (e.g. 17/11 — 17 is not a month).
        found.add(DateCandidate(
          date: asDayMonth,
          matchedText: matched,
          interpretation: 'day/month/year',
          ambiguous: false,
        ));
      } else if (asMonthDay != null) {
        found.add(DateCandidate(
          date: asMonthDay,
          matchedText: matched,
          interpretation: 'month/day/year',
          ambiguous: false,
        ));
      }
    }

    for (final m in _dayMonthYearPattern.allMatches(text)) {
      final month = _monthNames[m.group(2)!.toLowerCase()];
      if (month == null) continue;
      final date = _buildDate(
        year: int.parse(m.group(3)!),
        month: month,
        day: int.parse(m.group(1)!),
      );
      if (date != null) {
        found.add(DateCandidate(
          date: date,
          matchedText: m.group(0)!,
          interpretation: 'day month year',
          ambiguous: false,
        ));
      }
    }

    for (final m in _monthDayYearPattern.allMatches(text)) {
      final month = _monthNames[m.group(1)!.toLowerCase()];
      if (month == null) continue;
      final date = _buildDate(
        year: int.parse(m.group(3)!),
        month: month,
        day: int.parse(m.group(2)!),
      );
      if (date != null) {
        found.add(DateCandidate(
          date: date,
          matchedText: m.group(0)!,
          interpretation: 'month day year',
          ambiguous: false,
        ));
      }
    }

    final deduped = <DateCandidate>[];
    for (final candidate in found) {
      if (!deduped.contains(candidate)) deduped.add(candidate);
    }
    deduped.sort((a, b) => a.date.compareTo(b.date));
    return deduped;
  }

  /// Builds a [DateTime], returning null for impossible dates like
  /// 30 February. Constructing `DateTime(2026, 2, 30)` silently rolls
  /// over to 2 March rather than throwing, so the round-trip check is
  /// what actually rejects invalid input here.
  static DateTime? _buildDate({
    required int year,
    required int month,
    required int day,
  }) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  /// Two-digit years: 00-69 read as 2000-2069, 70-99 as 1970-1999. The
  /// cutoff is a convention, not a certainty — but a document showing
  /// "/26" in a prospective-memory app is far more likely to mean 2026
  /// than 1926.
  static int _normalizeYear(int year) {
    if (year >= 100) return year;
    return year < 70 ? 2000 + year : 1900 + year;
  }
}
