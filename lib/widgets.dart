import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = value
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: TextStyle(color: labelColor)),
        Checkbox(
          value: value,
          onChanged: (bool? newValue) => onChanged(newValue),
        ),
      ],
    );
  }
}

class LabeledRadio extends StatelessWidget {
  const LabeledRadio({
    super.key,
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int groupValue;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = (value == groupValue)
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface;

    return Column(
      children: <Widget>[
        Text(label, style: TextStyle(color: labelColor)),
        Radio(
          value: value,
          groupValue: groupValue,
          onChanged: (int? newValue) => onChanged(newValue),
        ),
      ],
    );
  }
}

class PathPicker extends StatelessWidget {
  const PathPicker(
      {super.key,
      required this.pickerText,
      required this.path,
      required this.onChanged,
      this.nameCheck});

  final String pickerText;
  final String path;
  final Function onChanged;
  final String? nameCheck;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.normal,
                  fontSize: 15),
              children: [
                const TextSpan(text: "Path to "),
                TextSpan(
                    text: pickerText,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: " directory"),
              ]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(path),
            const SizedBox(width: 25),
            ElevatedButton(
                onPressed: () async {
                  final result = await FilePicker.platform.getDirectoryPath();
                  if (result != null) {
                    if (nameCheck != null && !result.endsWith(nameCheck!)) {
                      SnackBar snackBar = SnackBar(
                        content: Text('The selected directory is not named $nameCheck !!'),
                        duration: const Duration(seconds: 2),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      onChanged(result);
                    }
                  } else {
                    const SnackBar snackBar = SnackBar(
                      content: Text('No directory selected'),
                      duration: Duration(seconds: 2),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: const Text('Pick Directory')),
          ],
        ),
      ],
    );
  }
}

class SwitchSetting extends StatelessWidget {
  const SwitchSetting(
      {super.key,
      required this.text,
      required this.value,
      required this.onChanged});

  final String text;
  final bool value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(text, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 10),
      Switch(value: value, onChanged: (bool newValue) => onChanged(newValue)),
    ]);
  }
}
