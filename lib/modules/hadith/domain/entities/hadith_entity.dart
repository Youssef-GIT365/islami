class HadithEntity {
  final int id;
  final String hadithArabic;

  HadithEntity({required this.id, required this.hadithArabic});

  String get dynamicTitle {
    const ones = [
      "",
      "الأول",
      "الثاني",
      "الثالث",
      "الرابع",
      "الخامس",
      "السادس",
      "السابع",
      "الثامن",
      "التاسع",
      "العاشر",
    ];
    const teens = [
      "",
      "الحادي عشر",
      "الثاني عشر",
      "الثالث عشر",
      "الرابع عشر",
      "الخامس عشر",
      "السادس عشر",
      "السابع عشر",
      "الثامن عشر",
      "التاسع عشر",
    ];
    const tens = [
      "",
      "",
      "العشرون",
      "الثلاثون",
      "الأربعون",
      "الخمسون",
      "الستون",
      "السبعون",
      "الثمانون",
      "التسعون",
    ];

    if (id <= 10) {
      return "الحديث ${ones[id]}";
    }

    if (id >= 11 && id <= 19) {
      return "الحديث ${teens[id - 10]}";
    }

    if (id >= 20 && id < 100) {
      int oneDigit = id % 10;
      int tenDigit = id ~/ 10;

      if (oneDigit == 0) {
        return "الحديث ${tens[tenDigit]}";
      } else {
        String oneWord = oneDigit == 1 ? "الحادي" : ones[oneDigit];
        return "الحديث $oneWord و${tens[tenDigit]}";
      }
    }

    return "الحديث رقم $id";
  }
}
