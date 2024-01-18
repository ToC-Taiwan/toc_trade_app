String commaNumber(String n) => n.replaceAllMapped(reg, mathFunc);

RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
String mathFunc(Match match) => '${match[1]},';
