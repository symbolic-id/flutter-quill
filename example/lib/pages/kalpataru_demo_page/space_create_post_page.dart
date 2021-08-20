import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill/utils/color.dart';

class SpaceCreatePostPage extends StatefulWidget {
  @override
  _SpaceCreatePostPage createState() => _SpaceCreatePostPage();
}

class _SpaceCreatePostPage extends State<SpaceCreatePostPage> {
  SymEditorSpace? editor;

  ValueNotifier<String> textListener = ValueNotifier('');

  @override
  Widget build(BuildContext context) {
    if (editor == null) {
      setState(() {
        editor = SymEditorSpace(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1),
          onChangeListener: (plainText) {
            textListener.value = plainText;
          },
        );
      });
    }
    return Dialog(
      insetPadding:
          EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.2),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _toolbar(),
            Padding(
              padding: EdgeInsets.only(
                  left: (MediaQuery.of(context).size.width * 0.1) + 60,
                  top: 80,
                  bottom: 24),
              child: TextButton(
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.select_all_outlined),
                    SizedBox(width: 7),
                    Text('Pilih Corner')
                  ],
                ),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 22)),
                    foregroundColor: MaterialStateProperty.all<Color>(
                        SymColors.light_textQuaternary),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    )),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        SymColors.light_backgroundSurfaceOne)),
              ),
            ),
            Expanded(
                child: editor != null
                    ? Container(
                        height: double.infinity,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: editor,
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ))
          ],
        ),
      ),
    );
  }

  Widget _toolbar() {
    return Row(
      children: [
        Material(
          clipBehavior: Clip.hardEdge,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.close,
                color: SymColors.light_iconPrimary,
                size: 14,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 14,
        ),
        const Expanded(
          child: Text(
            'Buat kiriman Hall',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: textListener,
          builder: (context, String value, _) {
            return TextButton(
                onPressed: value.isNotEmpty
                    ? () {
                        final md = editor!.getMarkdown();
                        print('========= markdown:\n$md');
                        // Navigator.pop(context);
                      }
                    : null,
                child: Text('Kirim'),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 22)),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    )),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        value.isNotEmpty
                            ? SymColors.light_bluePrimary
                            : SymColors.light_iconPrimary)));
          },
        )
      ],
    );
  }
}
