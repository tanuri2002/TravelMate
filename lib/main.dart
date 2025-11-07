// void main() {
//   // print("Hello, Dart!");
//   // print(stringify(2, 3)); // testing stringify
//   String? abc
//   abc.isEmpty();
//   assert(stringify(2,3) == '2 3',
//   );
// }

// String stringify(int a, int b) {
//   return '$a $b';
// }

String? upperCaseIt(String? str) {
  // TODO: Try conditionally accessing the `toUpperCase` method here.
}

// Tests your solution (Don't edit!):
// void main() {
//   try {
//     String? one = upperCaseIt(null);
//     if (one != null) {
//       print('Looks like you\'re not returning null for null inputs.');
//     } else {
//       print('Success when str is null!');
//     }
//   } catch (e) {
//     print('Tried calling upperCaseIt(null) and got an exception: \n ${e.runtimeType}.');
//   }

//   try {
//     String? two = upperCaseIt('a string');
//     if (two == null) {
//       print('Looks like you\'re returning null even when str has a value.');
//     } else if (two != 'A STRING') {
//       print('Tried upperCaseIt(\'a string\'), but didn\'t get \'A STRING\' in response.');
//     } else {
//       print('Success when str is not null!');
//     }
//   } catch (e) {
//     print('Tried calling upperCaseIt(\'a string\') and got an exception: \n ${e.runtimeType}.');
//   }
// }

// void main(){
//   final a=<int>[1,10,3,4];
//   final b=<int>{1,2,3,4,4,5};
//   a.sort();
// }

// // Assign this a list containing 'a', 'b', and 'c' in that order:
// final aListOfStrings = null;

// // Assign this a set containing 3, 4, and 5:
// final aSetOfInts = null;

// // Assign this a map of String to int so that aMapOfStringsToInts['myKey'] returns 12:
// final aMapOfStringsToInts = null;

// // Assign this an empty List<double>:
// final anEmptyListOfDouble = null;

// // Assign this an empty Set<String>:
// final anEmptySetOfString = null;

// // Assign this an empty Map of double to int:
// final anEmptyMapOfDoublesToInts = null;

// Tests your solution (Don't edit!):
// void main() {
//   final errs = <String>[];

//   if (aListOfStrings is! List<String>) {
//     errs.add('aListOfStrings should have the type List<String>.');
//   } else if (aListOfStrings.length != 3) {
//     errs.add('aListOfStrings has ${aListOfStrings.length} items in it, \n rather than the expected 3.');
//   } else if (aListOfStrings[0] != 'a' || aListOfStrings[1] != 'b' || aListOfStrings[2] != 'c') {
//     errs.add('aListOfStrings doesn\'t contain the correct values (\'a\', \'b\', \'c\').');
//   }

//   if (aSetOfInts is! Set<int>) {
//     errs.add('aSetOfInts should have the type Set<int>.');
//   } else if (aSetOfInts.length != 3) {
//     errs.add('aSetOfInts has ${aSetOfInts.length} items in it, \n rather than the expected 3.');
//   } else if (!aSetOfInts.contains(3) || !aSetOfInts.contains(4) || !aSetOfInts.contains(5)) {
//     errs.add('aSetOfInts doesn\'t contain the correct values (3, 4, 5).');
//   }

//   if (aMapOfStringsToInts is! Map<String, int>) {
//     errs.add('aMapOfStringsToInts should have the type Map<String, int>.');
//   } else if (aMapOfStringsToInts['myKey'] != 12) {
//     errs.add('aMapOfStringsToInts doesn\'t contain the correct values (\'myKey\': 12).');
//   }

//   if (anEmptyListOfDouble is! List<double>) {
//     errs.add('anEmptyListOfDouble should have the type List<double>.');
//   } else if (anEmptyListOfDouble.isNotEmpty) {
//     errs.add('anEmptyListOfDouble should be empty.');
//   }

//   if (anEmptySetOfString is! Set<String>) {
//     errs.add('anEmptySetOfString should have the type Set<String>.');
//   } else if (anEmptySetOfString.isNotEmpty) {
//     errs.add('anEmptySetOfString should be empty.');
//   }

//   if (anEmptyMapOfDoublesToInts is! Map<double, int>) {
//     errs.add('anEmptyMapOfDoublesToInts should have the type Map<double, int>.');
//   } else if (anEmptyMapOfDoublesToInts.isNotEmpty) {
//     errs.add('anEmptyMapOfDoublesToInts should be empty.');
//   }

//   if (errs.isEmpty) {
//     print('Success!');
//   } else {
//     errs.forEach(print);
//   }

// ignore_for_file: unnecessary_type_check
//}

void printName(String firstName, String lastName, {String? middleName}) {
  print('$firstName ${middleName ?? ''} $lastName');
}

void main() {
  printName('Dash', 'Dartisan');
  printName('John', 'Smith', middleName: 'Who');
  // Named arguments can be placed anywhere in the argument list.
  printName('John', middleName: 'Who', 'Smith');
}
