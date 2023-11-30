import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Pets Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var historial = <WordPair>[];
  var index = -1;

  GlobalKey? historialListKey;

  void getNext() {
    if (index > 0) {
      --index;
      current = historial.elementAt(index);
    } else {
        if (!historial.contains(current)){
          historial.insert(0, current);    
          var animatedList = historialListKey?.currentState as AnimatedListState?;
          animatedList?.insertItem(0);
        }
        current = WordPair.random();
        index = -1;
    }
    notifyListeners();
  }

  void getPrevious() {
    if (index < historial.length-1) {
      if (index == -1) {
        historial.insert(0, current);        
        var animatedList = historialListKey?.currentState as AnimatedListState?;
        animatedList?.insertItem(0);
        ++index;
      } 
      ++index;
      current = historial.elementAt(index);
    }
    notifyListeners();
  }

  var favoritos = <WordPair>[];

  void toggleFavorito([WordPair? name]) {
    name = name ?? current;
    if (favoritos.contains(name)) {
      favoritos.remove(name);
    } else {
      favoritos.add(name);
    }
    notifyListeners();
  }

  void removeFavorito([WordPair? name]) {
    favoritos.remove(name);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritosPage();
        break;
      default:
        throw UnimplementedError('No hay un widget para: $selectedIndex');
    }
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 450 ) {
            return Row(
                children: [
                  SafeArea(
                    child: NavigationRail(
                      extended: constraints.maxWidth >= 600,
                      destinations: [
                        NavigationRailDestination(
                          icon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.favorite),
                          label: Text('Favoritos'),
                        ),
                      ],
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: page,
                    ),
                  ),
                ],
            );
          } else {
            return Column(
                children: [
                  Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: page,
                    ),
                  ),
                  SafeArea(
                    child: BottomNavigationBar(
                      items: [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home),
                          label: 'Home'
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.favorite),
                          label: 'Favoritos'
                        ),
                      ],
                      currentIndex: selectedIndex,
                      onTap: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                    ),
                  ),
                ],
            );
          }
        }
      )
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.name,
  });

  final WordPair name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          name.asLowerCase, 
          style: textStyle,
          semanticsLabel: "${name.first} ${name.second}",
        ),
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var name = appState.current;

    IconData icon;
    if (appState.favoritos.contains(name)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: HistorialListView(),
          ),
          SizedBox(height: 10),
          BigCard(name: name),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorito();
                },
                icon: Icon(icon),
                label: Text('Me gusta'),
              ),
              SizedBox(width: 10,),
              ElevatedButton(
                onPressed: () {
                  appState.getPrevious();
                },
                child: Text('Anterior'),
              ),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Siguiente'),
              ),              
            ],
          ),
          Spacer(flex: 2),
        ],
      ),
    );
  }
}

class FavoritosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favoritos.isEmpty) {
      return Center(
        child: Text("Aun no hay favoritos"),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Se han elegido ' '${appState.favoritos.length} favoritos'),
        ),
        Expanded(
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: 400 / 80,
            ),
            children: [
              for (var name in appState.favoritos)
                ListTile(
                  leading: IconButton(
                          icon: Icon(Icons.delete_outline, semanticLabel: 'Eliminar'),
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            appState.removeFavorito(name);
                          },
                        ),
                  title: Text(name.asLowerCase),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class HistorialListView extends StatefulWidget {
  const HistorialListView({Key? key}) : super(key: key);

  @override
  State<HistorialListView> createState() => _HistorialListViewState();
}

class _HistorialListViewState extends State<HistorialListView> {
  final _key = GlobalKey();

  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    appState.historialListKey = _key;

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: AnimatedList(
        key: _key,
        reverse: true,
        padding: EdgeInsets.only(top: 100),
        initialItemCount: appState.historial.length,
        itemBuilder: (context, index, animation) {
          final name = appState.historial[index];
          return SizeTransition(
            sizeFactor: animation,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorito(name);
                },
                icon: appState.favoritos.contains(name)
                    ? Icon(Icons.favorite, size: 12)
                    : SizedBox(),
                label: Text(
                  name.asLowerCase,
                  semanticsLabel: name.asPascalCase,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
