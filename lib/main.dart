import 'package:flutter/material.dart';

void main() {
  runApp(MyApp()); 
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return Scaffold(  
    //   appBar: AppBar( 
    //     backgroundColor: const Color.fromARGB(255, 176, 44, 199), 
    //     title: const Text( 
    //       "Music League Stats", 
    //       style: TextStyle( 
    //         fontSize: 28, 
    //         fontWeight: FontWeight.bold, 
    //         color: Colors.white, 
    //       ),
    //     ),
    //     centerTitle: true,
    //   ),
    //   body: Center( 
    //     child: Text("Testing..."), //HomePage(),
    //   ),
    // );
    return MaterialApp(
      title: "Music League Statistics", 
      theme: ThemeData( 
        primarySwatch: Colors.purple, 
      ), 
      home: HomePage(),
    );
  }
}


class HomePage extends StatelessWidget {
  HomePage({super.key});
  final List<String> dataSets = ["Granny Smith", "Live the Riv", "Virginia is for (Music) Lovers"];

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar( 
        backgroundColor: const Color.fromARGB(255, 173, 47, 196),
        title: Text( 
          "Music League Stats",
          style: TextStyle( 
            fontSize: 36, 
            fontWeight: FontWeight.bold, 
            color: Colors.white, 
          ),
        ), 
        centerTitle: true,
      ),
      body: GridView.extent(  
        maxCrossAxisExtent: 500, 
        padding: const EdgeInsets.all(16), 
        crossAxisSpacing: 16, 
        mainAxisSpacing: 16, 
        children: [
          Padding(  
            padding: const EdgeInsets.all(32), 
            child: GestureDetector(  
              onTap: () {
                Navigator.push( 
                  context, 
                  MaterialPageRoute(builder: (context) => DetailPage()), 
                );
              },
              child: const Card(  
                color: Colors.purple, 
                child: Center(  
                  child: Text(  
                    "Granny Smith", 
                    style: TextStyle(fontSize: 20, color: Colors.white), 
                  ),
                ),
              ),
            ), 
          ),


          Padding(  
            padding: const EdgeInsets.all(32), 
            child: GestureDetector(  
              onTap: () {
                Navigator.push( 
                  context, 
                  MaterialPageRoute(builder: (context) => DetailPage()), 
                );
              },
              child: const Card(  
                color: Colors.purple, 
                child: Center(  
                  child: Text(  
                    "Live the Riv", 
                    style: TextStyle(fontSize: 20, color: Colors.white), 
                  ),
                ),
              ),
            ), 
          ),


          Padding(  
            padding: const EdgeInsets.all(32), 
            child: GestureDetector(  
              onTap: () {
                Navigator.push( 
                  context, 
                  MaterialPageRoute(builder: (context) => DetailPage()), 
                );
              },
              child: const Card(  
                color: Colors.purple, 
                child: Center(  
                  child: Text(  
                    "Virginia is for (Music) Lovers", 
                    style: TextStyle(fontSize: 20, color: Colors.white), 
                  ),
                ),
              ),
            ), 
          ),
        ],
      ),
      // Padding(  
      //   padding: EdgeInsets.all(16), 
      //   child: ListView(  
      //     children: dataSets.map( (data) { 
      //       return Card( 
      //         margin: EdgeInsets.symmetric( 
      //           vertical: 10, 
      //           horizontal: 32
      //         ), 
      //         child: ListTile(  
      //           title: Text(
      //             data, 
      //             style: TextStyle( 
      //               fontSize: 18, 
      //               fontWeight: FontWeight.bold, 
      //             ),
      //           ), 
      //           subtitle: Text("Click to see details"), 
      //           trailing: Icon(Icons.arrow_forward), 
      //           onTap: () {
      //             print("Tapped $data");    // UPDATE LATER
      //           },
      //         ),
      //       );
      //     }).toList(),
      //   ),
      // ),
    );
  }
}

class DetailPage extends StatelessWidget { 
  DetailPage({super.key}); 

  @override
  Widget build(BuildContext context) {
    final names = ["Benj", "Daniel", "Etc"]; 

    return Scaffold(  
      appBar: AppBar(title: const Text("Select a Name")),  
      body: ListView.builder(  
        itemCount: names.length , 
        itemBuilder: (context, index) {
          return ListTile(  
            title: Text(names[index]), 
            onTap: () { 
              ScaffoldMessenger.of(context).showSnackBar( 
                SnackBar(content: Text("You selected ${names[index]}")),
              );
            },
          );
        },
      ),
    );
  }
}