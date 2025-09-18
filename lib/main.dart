// flutter run -d chrome

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart' show rootBundle; 
import 'dart:convert';

void main() {
  runApp(MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); 

  @override
  Widget build(BuildContext context) {
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

  final List<String> leagues = const ["virginia_is_for_music_lovers", "live_the_riv", "granny_smith"];

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: buildMainAppBar("Music Leagues"), 
      body: ListView(  
        children: leagues.map( (league) {
          return Card(  
            child: ListTile(  
              title: Text(league), 
              onTap: () { 
                Navigator.push( 
                  context,  
                  MaterialPageRoute( 
                    // builder: (context) => LeaguePage(leagueName: league),
                    builder: (context) => StatsPage(leagueName: league),  
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );

    //   body: GridView.extent(  
    //     maxCrossAxisExtent: 500, 
    //     padding: const EdgeInsets.all(16), 
    //     crossAxisSpacing: 16, 
    //     mainAxisSpacing: 16, 
    //     children: leagues.map( (league) { 
    //       return buildInkwellCard(league, context);
    //     }).toList(),
    //   ),
    // );
  }
}

// class LeaguePage extends StatefulWidget {
//   final String leagueName; 
//   const LeaguePage({super.key, required this.leagueName});

//   @override
//   State<LeaguePage> createState() => _LeaguePageState(); 
// }

// class _LeaguePageState extends State<LeaguePage> {
//   Future<List<List<dynamic>>>? data;

//   void _loadRound(String roundFile) {
//     setState(() {
//       data = loadLeagueRound(widget.leagueName, roundFile);
//     });
//   }

//   void _backToRounds() {
//     setState(() {
//       selectedRound = null;
//       data = null;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final rounds = leagueRounds[widget.leagueName]!;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.leagueName),
//         actions: [
//           if (selectedRound != null)
//             IconButton(
//               icon: const Icon(Icons.refresh), // "back to round picker"
//               onPressed: _backToRounds,
//               tooltip: "Back to rounds",
//             ),
//         ],
//       ),
//       body: selectedRound == null
//           ? ListView(
//               children: rounds.map((round) {
//                 return ListTile(
//                   title: Text(round.replaceAll('.csv', '')),
//                   onTap: () => _loadRound(round),
//                 );
//               }).toList(),
//             )
//           : FutureBuilder<List<List<dynamic>>>(
//               future: data,
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final rows = snapshot.data!;

//                 return ListView(
//                   children: rows.map((row) {
//                     return ListTile(
//                       title: Text(row[0].toString()), // voter/submitter
//                       subtitle: Text(row.skip(1).join(", ")), // their votes
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//     );
//   }
// }

// class _LeaguePageStart extends State<LeaguePage> {
//   late Future<List<List<dynamic>>> _data; 

//   @override  
//   void initState() {
//     super.initState(); 
//     _data = loadCsvData(path); //////////////////////
//   }

// }
// {
//   final String leagueName; 
//   final players = ["Benj", "Daniel", "Ian", "Chase", "Maren", "Emma", "Etc..."];

//   LeaguePage({ required this.leagueName });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(  
//       appBar: buildMainAppBar("Music Leagues"), 
//       body: Center( 
//         child: ConstrainedBox(  
//           constraints: BoxConstraints( 
//             minWidth: 300, 
//             maxWidth: 500, 
//             minHeight: 100, 
//             maxHeight: 800, //double.infinity, 
//           ),
//           child: Container( 
//             color: const Color.fromARGB(255, 214, 220, 224),
//             child: ListView.builder(  
//               padding: const EdgeInsets.all(16.0), 
//               itemCount: players.length, 
//               itemBuilder: (context, index) {
//                 return ListTile(  
//                   title: Text(
//                     players[index], 
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ), 
//                   onTap: () {
//                     Navigator.push( 
//                       context, 
//                       MaterialPageRoute( 
//                         builder: (context) => StatsPage( 
//                           leagueName: leagueName, 
//                           playerName: players[index], 
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ), 
//       ), 
//     );
//   }
// }

class StatsPage extends StatefulWidget { 
  final String leagueName; 

  const StatsPage({super.key, required this.leagueName}); 

  @override  
  State<StatsPage> createState() => _StatsPageState(); 
}

class _StatsPageState extends State<StatsPage> {
  late Future<Map<String, dynamic>> _data; 

  @override 
  void initState() {
    super.initState(); 
    _data = loadStatsJson(widget.leagueName);
  }

  @override 
  Widget build(BuildContext context) { 
    return Scaffold(  
      appBar: buildMainAppBar("Music League: ${widget.leagueName}"), 
      body: FutureBuilder<Map<String, dynamic>> ( 
        future: _data, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) { 
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) { 
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final stats = snapshot.data!; 
          if (!stats.containsKey("people")) {
            return const Center(child: Text("Invalid JSON format: missing 'people'!")); 
          }
          final people = stats["people"] as List<dynamic>; 

          return ListView(  
            padding: const EdgeInsets.all(16), 
            children: people.map<Widget>( (person) {
              final personMap = person as Map<String, dynamic>; 
              final scores = personMap["scores"] as Map<String, dynamic>; 

              // final name = entry.key; 
              // final personStats = entry.value as Map<String, dynamic>; 
              return Card(  
                margin: const EdgeInsets.symmetric(vertical: 8), 
                child: ListTile(   
                  title: Text(personMap["name"], style: const TextStyle(fontWeight: FontWeight.bold)), 
                  subtitle: Text(  
                    "\t\tBiggest Fan: ${scores['biggestFanName']} (${scores['biggestFanScore']} votes)\n" 
                    "\t\tBiggest Hater: ${scores['biggestHaterName']} (${scores['biggestHaterScore']} votes)\n" 
                    "\t\tMost Liked: ${scores['mostLikedName']} (${scores['mostLikedScore']} votes)\n" 
                    "\t\tLeast Liked: ${scores['leastLikedName']} (${scores['leastLikedScore']} votes)" 
                  ),
                ),
              );
            }).toList(),
          );
        }, 
      ), 
    ); 
  }
}
          
      //     Center(  
      //   child: SingleChildScrollView(  
      //     child: Column( 
      //       children: [
      //         Text(
      //           "Statistics for $playerName", 
      //           style: TextStyle( 
      //             fontSize: 24, 
      //             fontWeight: FontWeight.bold, 
      //           )
      //         ),

      //         SizedBox(height: 50), 

      //         Center( 
      //           child: Container( 
      //             padding: const EdgeInsets.all(16), 
      //             color: Colors.blue[50], 
      //             child: SizedBox( 
      //               height: 300, 
      //               child: LineChart( 
      //                 LineChartData( 
      //                   borderData: FlBorderData(show: true), 
      //                   titlesData: FlTitlesData( 
      //                     bottomTitles: AxisTitles( 
      //                       sideTitles: SideTitles( 
      //                         showTitles: true, 
      //                         getTitlesWidget: (value, meta) { 
      //                           return Text("R${value.toInt() + 1}");
      //                         },
      //                       ),
      //                     ),
      //                     leftTitles: AxisTitles( 
      //                       sideTitles: SideTitles( showTitles: true), 
      //                     ),
      //                   ) ,
      //                   lineBarsData: [
      //                     LineChartBarData( 
      //                       spots: List.generate( 
      //                         points.length, 
      //                         (index) => 
      //                             FlSpot(index.toDouble(), points[index].toDouble())), 
      //                       isCurved: true, 
      //                       color: Colors.deepPurple, 
      //                       barWidth: 3, 
      //                       dotData: FlDotData(show: true), 
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ),

      //         Text("Points Received: "), 
      //         Text("[Plot of points per round?]"), 
      //         buildStatistic("Most Liked Player (include 2nd and 3rd / all in drop down): "), 
      //         buildStatistic("Least Liked Player: "), 
      //         buildStatistic("Biggest Fan: "), 
      //         buildStatistic("Biggest Hater: "), 
      //         buildStatistic("Most Similar Taste: "),
      //       ]
      //     ),
      //   ),
      // ),
//     );
//   }
// }

Text buildStatistic(String title) {
  return Text(  
    title, 
    style: TextStyle(fontSize: 18), 
    textAlign: TextAlign.center,
  );
}

// Card buildInkwellCard(String leagueName, BuildContext context) {
//     return Card(  
//       child: InkWell( 
//         onTap: () {
//           Navigator.push( 
//             context, 
//             MaterialPageRoute( 
//               builder: (context) => LeaguePage(leagueName: leagueName), 
//             ),
//           );
//         },
//         hoverColor: const Color.fromARGB(255, 197, 230, 199),
//         child: Center(  
//           child: Text(  
//             leagueName, 
//             style: TextStyle(  
//               fontSize: 18, 
//               fontWeight: FontWeight.bold
//             ), 
//             textAlign: TextAlign.center, 
//           ),
//         ),
//       ),
//     );
// }

AppBar buildMainAppBar(String title) {
  return AppBar( 
    backgroundColor: const Color.fromARGB(255, 173, 47, 196),
    title: Text( 
      "Music Leagues",
      style: TextStyle( 
        fontSize: 36, 
        fontWeight: FontWeight.bold, 
        color: Colors.white, 
      ),
    ), 
    centerTitle: true,
  );
}

// Future<List<List<dynamic>>> loadLeagueRound(String league, String roundFile) async {
//   final path = 'assets/data/$league/$roundFile';
//   final rawData = await rootBundle.loadString(path); 
//   return const CsvToListConverter().convert(rawData);
// }

// final leagueRounds = {
//   "virginia_is_for_music_lovers" : ["round1.csv", "round2.csv"], 
//   "live_the_riv" : ["round1.csv", "round2.csv"], 
//   "granny_smith" : ["round1.csv", "round2.csv"],
// };

Future<Map<String, dynamic>> loadStatsJson(String league) async { 
  final path = 'assets/data/$league.json';
  final rawData = await rootBundle.loadString(path);
  return jsonDecode(rawData) as Map<String, dynamic>;
}


