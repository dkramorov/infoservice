String cleanUpPhone(String? value) =>
    value
        ?.replaceAll(' ', '')
        .replaceAll('+', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '') ??
    '';
