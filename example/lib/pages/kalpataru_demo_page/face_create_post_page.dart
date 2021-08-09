import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill/utils/color.dart';

class FaceCreatePostPage extends StatefulWidget {
  @override
  _FaceCreateCardPageState createState() => _FaceCreateCardPageState();
}

class _FaceCreateCardPageState extends State<FaceCreatePostPage> {
  SymEditorFace? editor;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (editor == null) {
      setState(() {
        editor = SymEditorFace(
          padding:
              EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1, top: 80),
        );
      });
    }
    return Dialog(
      insetPadding:
          EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.2),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            _toolbar(),
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
            'Buat kiriman Veranda',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        TextButton(
            onPressed: () {},
            child: Text('Kirim'),
            style: ButtonStyle(
                padding:
                    MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                )),
                backgroundColor: MaterialStateProperty.all<Color>(
                    SymColors.light_bluePrimary)))
      ],
    );
  }
}
