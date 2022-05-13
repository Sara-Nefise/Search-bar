import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kartal/kartal.dart';

main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SecondPage(),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  static const String prefSearchKey = "previousSearches";
  bool inErrorState = false;
  List<String> previousSearches = [];
  var searchTextController = TextEditingController();

  final duplicateItems = List<String>.generate(10000, (i) => "Item $i");
  List<String> items = [];
  FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    items.addAll(duplicateItems);
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
  }

  void _onFocusChange() {
    debugPrint("Focus: ${_focus.hasFocus.toString()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        SizedBox(height: context.dynamicHeight(0.1)),
        SizedBox(
          height: 55,
          child: CupertinoSearchTextField(
            onSuffixTap: () {
              searchTextController.clear();
              setState(() {
                items.clear();
                items.addAll(duplicateItems);
              });
              _focus.unfocus();
            },
            focusNode: _focus,
            padding: context.horizontalPaddingNormal,
            borderRadius: BorderRadius.circular(30),
            onChanged: (String value) {},
            onSubmitted: (String value) {
              if (!previousSearches.contains(value)) {
                previousSearches.add(value);
                savePreviousSearches();
              }
              _focus.unfocus();
              filterSearchResults(value);
            },
            prefixInsets: const EdgeInsets.only(left: 15),
            controller: searchTextController,
          ),
        ),
        Expanded(
          flex: 3,
          child: (_focus.hasPrimaryFocus == true)
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: previousSearches.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      trailing: const Icon(Icons.arrow_drop_up_outlined),
                      leading: const Icon(Icons.access_time_sharp),
                      title: Text(previousSearches[index]),
                      onTap: () {
                        searchTextController.text = previousSearches[index];
                        startSearch(searchTextController.text);
                      },
                    );
                  })
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text('${items[index]}'),
                    );
                  },
                ),
        )
      ]),
    );
  }

  void startSearch(String value) {
    setState(() {
      if (!previousSearches.contains(value)) {
        previousSearches.add(value);

        savePreviousSearches();
      }
    });
  }

  void romveSearch(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(key);
  }

  void getPreviousSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(prefSearchKey)) {
      previousSearches = prefs.getStringList(prefSearchKey)!;
    }
  }

  void savePreviousSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(prefSearchKey, previousSearches);
    if (previousSearches.length > 3) {
      setState(() {
        previousSearches.removeAt(0);
      });
    }
  }

  void filterSearchResults(String query) {
    List<String> dummySearchList = [];
    dummySearchList.addAll(duplicateItems);
    if (query.isNotEmpty) {
      List<String> dummyListData = [];
      for (var item in dummySearchList) {
        if (item.contains(query)) {
          dummyListData.add(item);
        }
      }

      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
    }
  }
}
