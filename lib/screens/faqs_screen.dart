import 'package:flutter/material.dart';
import 'package:parktronic/screens/navigation_drawer.dart';

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: Text('Intrebari frecvente'), actions: <Widget>[
        new IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: null)
      ]),
      drawer: NavigationDrawer(),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            EntryItem(data[index]),
        itemCount: data.length,
      ),
    );
  }
}

// One entry in the multilevel list displayed by this app.
class Entry {
  Entry(this.title, [this.children = const <Entry>[]]);

  final String title;
  final List<Entry> children;
}

// The entire multilevel list displayed by this app.
final List<Entry> data = <Entry>[
  Entry(
    'Cum se foloseste aplicatia?',
    <Entry>[
      Entry(
          'It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed '),
    ],
  ),
  Entry(
    'Cum pot sa fac rezervarea unui loc de parcare?',
    <Entry>[
      Entry(
          'It is a long established fact that a reader will be distracted by the readable content of a page when looking'),
    ],
  ),
  Entry(
    'Ce fac daca mi-am uitat contul?',
    <Entry>[
      Entry(
          'It is a long established fact that a reader will be distracted by the readable content of a page when looking'),
    ],
  ),
  Entry(
    'Nu mi se incarca harta, ce pot sa fac?',
    <Entry>[
      Entry(
          'Va rugam sa permiteti aplicatiei din setari sa va utilizeze locatia.'),
    ],
  ),
  Entry(
    'Cum pot sa platesc?',
    <Entry>[
      Entry(
          'It is a long established fact that a reader will be distracted by the readable content of a page when looking'),
    ],
  ),
  Entry(
    'Cum imi adaug masinile personale?',
    <Entry>[
      Entry(
          'It is a long established fact that a reader will be distracted by the readable content of a page when looking'),
    ],
  ),
];

// Displays one Entry. If the entry has children then it's displayed
// with an ExpansionTile.
class EntryItem extends StatelessWidget {
  const EntryItem(this.entry);

  final Entry entry;

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty) return ListTile(title: Text(root.title));
    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: Text(root.title),
      children: root.children.map(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}
