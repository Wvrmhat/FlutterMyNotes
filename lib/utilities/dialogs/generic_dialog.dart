import 'package:flutter/material.dart';



// specify a list of buttons which each have a type title and value
typedef DialogOptionBuilder<T> = Map<String, T?> Function();      // ensures every key is unique

// generics produce different values based off what is provided to it. They also have the same datatype. In this case we use T
Future<T?> showGenericDialog<T> ({
  required BuildContext context, 
  required String title, 
  required String content, 
  required DialogOptionBuilder optionsBuilder,
  }) {
    final options = optionsBuilder();
    return showDialog<T>(           // return showdialog of T
      context: context, 
      builder: (context) {
        return AlertDialog(        // return an alert diaglog
          title: Text(title),
          content: Text(content),         //
          actions: options.keys.map((optionTitle) {   // the actions are defined in options, and every key in options is defined by title, which is defined by the string of ACTIONS.
            final value = options[optionTitle];   // every title is mapped to a text button, whose child is the text of the actual title
            return TextButton(
              onPressed: () {
                if (value != null)
                {
                  Navigator.of(context).pop(value);
                }
                else
                {
                  Navigator.of(context).pop();
                }

              },
              child: Text(optionTitle),
            );
          }).toList(),    // actions require a list, but a map returns iterable. so we use .tolist() to fix that
        );
      },
    );
}




// import 'package:flutter/material.dart';

// Future<void> showErrorDialog(BuildContext context, String text,) 
// {
//   return showDialog(context: context, builder:(context) {
//     return AlertDialog(
//       title: const Text('An error occured'),
//       content: Text(text),
//       actions: [
//         TextButton(onPressed: () {
//           Navigator.of(context).pop();       
//         }, 
//         child: const Text("Ok")),
//       ],
//     );
    
//   },);
// }


  