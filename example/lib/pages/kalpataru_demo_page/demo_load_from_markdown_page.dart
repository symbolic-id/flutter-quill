import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

class DemoLoadFromMarkdownPage extends StatefulWidget {
  @override
  _KalpataruLoadFromMarkdownPage createState() =>
      _KalpataruLoadFromMarkdownPage();
}

class _KalpataruLoadFromMarkdownPage extends State<DemoLoadFromMarkdownPage> {
  List<String> examples = [_markdownExample1, _markdownExample2, _markdownExample3];
  // List<String> examples = [_markdownExample3];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _random = Random();

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
                child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Text(_markdownExample1),
            )),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  // child: viewer,
                  child: ListView.builder(
                      itemCount: 100,
                      itemBuilder: (context, index) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: SymTextViewer(
                            examples[_random.nextInt(examples.length)],
                            maxHeight: 84,
                          ))),
                ))
          ],
        ),
      ),
    );
  }
}

final _markdownExample1 =
    "Markdown `supports` two style of links: *inline* and *reference*.[[^space-22b480bd-440b-4805-84c8-e38cc3275c87]]\\n";

final _markdownExample2 =
    "![Minion](https://octodex.github.com/images/minion.png)\nMarkdown supports two style of links: *inline* and *reference*.[[^space-22b480bd-440b-4805-84c8-e38cc3275c87]]\\n[[^space-34dc154c-400c-4e8f-ac6f-d8f6be6d7fda]]\\nIn both styles, the link text is delimited by [square brackets].[[^space-953f42ed-1a79-465a-bd26-0c04cd8e383e]]\\n[[^space-5de25502-395b-451a-8c22-6250b5eda9c3]]\\nTo create an inline link, use a set of regular parentheses immediately[[^space-81af6d0c-165c-4b02-b228-b1d53a3ad44f]]\\n[[^space-85b6f08a-aca6-4abf-99ca-820d86f18a18]]\\nafter the link text's closing square bracket. Inside the parentheses,[[^space-66e6baf7-0dd5-4fdd-bc46-9116d78c9572]]\\n[[^space-fc778a76-df2b-4ac4-acab-d0952271fb2b]]\\nput the URL where you want the link to point, along with an *optional*[[^space-29210b1b-1636-4f00-89b2-54ebb3f08375]]\\n[[^space-38ff4ac4-ef73-4fd0-b377-75060b9ccc04]]\\ntitle for the link, surrounded in quotes. For example:[[^space-be90eb14-1872-4fee-8ef2-6f575629548c]]\\n[[^space-e7d6b2a1-abb7-4760-9655-591248d85a9f]]\\nThis is [an example](http://example.com/) inline link.[[^space-355a7b38-cb06-4acb-80e0-ae9eb68ec428]]\\n[[^space-b58d7bc9-315f-444c-948a-6d8051e95838]]\\n[This link](http://example.net/) has no title attribute.[[^space-ad671f0f-c82c-4c1c-8510-83ac8e33ad4f]]\\n[[^space-47bd404d-f530-4596-b828-0e593b36d667]]\\n### Emphasis[[^space-f93af75a-b205-4ebd-a090-ed03fdc620b6]]\\n[[^space-0031a2c9-bff5-441a-ba6c-6cb737e51d6b]]\\nMarkdown treats asterisks (`*`) and underscores (`_`) as indicators of[[^space-62ad0579-58d5-4d5d-87aa-15c11f39045c]]\\n[[^space-0a44eb4f-dfc3-45e6-8e02-4fd7d2f9f241]]\\nemphasis. Text wrapped with one `*` or `_` will be wrapped with an[[^space-39548714-1fcf-4c24-84a7-677b5a1fd6de]]\\n[[^space-c07a77f0-16bc-4e04-8091-a09bee027655]]\\nHTML `<em>` tag; double `*`'s or `_`'s will be wrapped with an HTML[[^space-2244f7c9-6f02-41a0-82d8-f07c952efdcc]]\\n[[^space-b0aaeb0f-3c01-4128-a7be-22a77d236eb6]]\\n`<strong>` tag. E.g., this input:[[^space-2cad322b-5063-49f8-88d3-d03343f3f8b1]]\\n[[^space-7a59dae1-6343-45a6-9fa8-e74f5e60e3ef]]\\n*single asterisks*[[^space-7810d4ae-aef3-45a0-a16a-8a8e51b445a4]]\\n[[^space-cb0db787-a542-4c41-aef6-ca105b0b7d37]]\\n_single underscores_[[^space-c5aaf796-64d7-4af1-bb10-62ad33544ad6]]\\n[[^space-5962939c-da70-44c0-9e9a-7a1b9e62e2a5]]\\n**double asterisks**[[^space-7f3d02b9-f2d1-4e81-8312-7308ab2f2bc3]]\\n[[^space-8c177c64-76c5-4ef9-b96a-7b9f8f9fa620]]\\n__double underscores__[[^space-637a7c2f-ce56-4a3c-a26f-adf5c2f4ffee]]\\n";

final _markdownExample3 =
    "![Minion](https://octodex.github.com/images/minion.png)[[^space-22b480bd-440b-4805-84c8-e38cc3275c87]]\\n**Markdown**[[^space-22b480bd-440b-4805-84c8-e38cc3275c87]]\\n";
