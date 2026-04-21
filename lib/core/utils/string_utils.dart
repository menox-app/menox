class StringUtils {
  static String removeDiacritics(String str) {
    if (str.isEmpty) return str;

    var result = str;
    final patterns = {
      '[àáạảãâầấậẩẫăằắặẳẵ]': 'a',
      '[ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴ]': 'A',
      '[èéẹẻẽêềếệểễ]': 'e',
      '[ÈÉẸẺẼÊỀẾỆỂỄ]': 'E',
      '[ìíịỉĩ]': 'i',
      '[ÌÍỊỈĨ]': 'I',
      '[òóọỏõôồốộổỗơờớợởỡ]': 'o',
      '[ÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠ]': 'O',
      '[ùúụủũưừứựửữ]': 'u',
      '[ÙÚỤỦŨƯỪỨỰỬỮ]': 'U',
      '[ỳýỵỷỹ]': 'y',
      '[ỲÝỴỶỸ]': 'Y',
      '[đ]': 'd',
      '[Đ]': 'D',
    };

    patterns.forEach((pattern, replacement) {
      result = result.replaceAll(RegExp(pattern), replacement);
    });

    return result;
  }
}
