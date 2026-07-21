// flutter run -d chrome

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart' show rootBundle; 
import 'package:google_fonts/google_fonts.dart';
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

/* 
  TODO
 - Make the drop down score bar smaller 
 - Put the songs submitted somewhere, too
 - Show total points 
*/


class HomePage extends StatelessWidget {
  HomePage({super.key});

  final List<String> leagues = const ["Virginia_is_for_Music_Lovers", "Live_the_Riv", "Granny_Smith_", "A6D-7__Friends"];

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: buildMainAppBar("Music Leagues"), 
      body: ListView(  
        children: leagues.map( (league) {
          return SizedBox(
            height: 200.0, 
            width: 300.0,
            child: Card(  
              child: ListTile(  
                title: Center( 
                  child: Text(
                    league, 
                    style: GoogleFonts.roboto( //TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 24,
                    ),
                  ), 
                ),
                onTap: () { 
                  Navigator.push( 
                    context,  
                    MaterialPageRoute( 
                      builder: (context) => StatsPage(leagueName: league),  
                    ),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

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

              final N = scores['votesReceivedNames'].length;
              final votesReceived = List.generate(N, (i) => '(${scores['votesReceivedScores'][i]})  ${scores['votesReceivedNames'][i]}');
              final votesGiven    = List.generate(N, (i) => '(${scores['votesGivenScores'][i]}) ${scores['votesGivenNames'][i]}');
              final similarityScores = List.generate(N, (i) => '(${scores['similarityScores'][i]}) ${scores['similarityNames'][i]} ');


              final maxReceivedScore = scores['votesReceivedScores'].reduce( (a, b) => a > b ? a : b); 
              final maxGivenScore = scores['votesGivenScores'].reduce( (a, b) => a > b ? a : b); 
              final maxSimilarityScore = scores['similarityScores'].reduce( (a, b) => a > b ? a : b); 

              return Card(  
                child: ExpansionTile(  
                  title: Text(personMap["name"], style: TextStyle(fontWeight: FontWeight.bold)), 
                  subtitle: Text(  
                    "\tBiggest Fan: ${votesReceived[0]}\n"
                    "\tMost Liked: ${votesGiven[0]}\n"
                    "\tMost Similar: ${similarityScores[0]}\n"
                  ),
                  children: [
                    Padding( 
                      padding: const EdgeInsets.all(8.0), 
                      child: Column(  
                        crossAxisAlignment: CrossAxisAlignment.start, 

                        // Bar chart?
                        children: [
                          Text("Votes Received", style: TextStyle(fontWeight: FontWeight.bold)), 
                          const SizedBox(height: 4), 
                          ...List.generate(scores['votesReceivedNames'].length, (i) {
                            return Padding(  
                              padding: const EdgeInsets.symmetric(vertical: 4), 
                              child: BarRow( 
                                name: scores['votesReceivedNames'][i],  
                                score: scores['votesReceivedScores'][i], 
                                maxScore: maxReceivedScore, 
                              ), 
                            ); 
                          }),
                          const SizedBox(height: 25), 

                          Text("Votes Given", style: TextStyle(fontWeight: FontWeight.bold)), 
                          const SizedBox(height: 4), 
                          ...List.generate(scores['votesGivenNames'].length, (i) {
                            return Padding(  
                              padding: const EdgeInsets.symmetric(vertical: 4), 
                              child: BarRow( 
                                name: scores['votesGivenNames'][i],  
                                score: scores['votesGivenScores'][i], 
                                maxScore: maxGivenScore, 
                              ), 
                            ); 
                          }),
                          const SizedBox(height: 25), 



                          Text("Similarity Scores", style: TextStyle(fontWeight: FontWeight.bold)), 
                          const SizedBox(height: 4), 
                          ...List.generate(scores['similarityNames'].length, (i) {
                            return Padding(  
                              padding: const EdgeInsets.symmetric(vertical: 4), 
                              child: BarRow( 
                                name: scores['similarityNames'][i],  
                                score: scores['similarityScores'][i], 
                                maxScore: maxSimilarityScore, 
                              ), 
                            ); 
                          }),
                        ],

                        // // Bulletted list
                        // children: [
                        //   const SizedBox(height: 8), 
                        //   Text("Votes Received", style: TextStyle(fontWeight: FontWeight.bold)), 
                        //   const SizedBox(height: 4), 
                        //   Padding( 
                        //     padding: const EdgeInsets.only(left: 16.0), 
                        //     child: Column(  
                        //       children: List.generate( 
                        //         votesReceived.length, 
                        //         (i) => Padding(  
                        //           padding: const EdgeInsets.symmetric(vertical: 2), 
                        //           child: Row(  
                        //             crossAxisAlignment: CrossAxisAlignment.start,  
                        //             children: [
                        //               const Text("* "), 
                        //               Text(  
                        //                 "${votesReceived[i]}"
                        //               )
                        //             ]
                        //           )
                        //         ) 
                        //       )
                        //     )
                        //   )
                        // ],


                        // // Little cards 
                        // children: [ 
                        //   Text("Votes Received", style: TextStyle(fontWeight: FontWeight.bold)), 
                        //   Wrap(  
                        //     spacing: 8, 
                        //     runSpacing: 4, 
                        //     children: List.generate( 
                        //       votesReceived.length, 
                        //       (i) => Chip(  
                        //         label: Text('${votesReceived[i]}'),
                        //       ),
                        //     ),
                        //   ),
                        //   SizedBox(height: 12), 
                        //   Text("Votes Given", style: TextStyle(fontWeight: FontWeight.bold)), 
                        //   Wrap(  
                        //     spacing: 8, 
                        //     runSpacing: 4, 
                        //     children: List.generate(  
                        //       votesGiven.length, 
                        //       (i) => Chip(  
                        //         label: Text('${votesGiven[i]}'), 
                        //       ),
                        //     ),
                        //   ),
                        //   SizedBox(height: 12), 
                        //   Text("Similarity Scores", style: TextStyle(fontWeight: FontWeight.bold)), 
                        //   Wrap(  
                        //     spacing: 8, 
                        //     runSpacing: 4, 
                        //     children: List.generate(  
                        //       similarityScores.length, 
                        //       (i) => Chip(  
                        //         label: Text('${similarityScores[i]}'), 
                        //       ),
                        //     ),
                        //   ),
                        // ],


                      ),
                    ),
                  ],
                ),
              );

              // return Card(  
              //   child: ExpansionTile(  
              //     title: Text(  
              //       personMap["name"],  
              //       style: TextStyle(fontWeight: FontWeight.bold)
              //     ), 
              //     subtitle: Text(  
              //       "\tBiggest Fan: ${votesReceived[0]}\n"
              //       "\tMost Liked: ${votesGiven[0]}\n"
              //       "\tMost Similar: ${similarityScores[0]}\n"
              //     ),
              //     children: [
              //       ListTile( 
              //         title: Text(
              //           "Votes Received: ${votesReceived}\n"
              //           "Votes Given: ${votesGiven}\n"
              //           "Similarity Scores: ${similarityScores}\n"
              //         ),
              //       ),
              //     ],
              //   ),
              // );

            }).toList(),
          );
        }, 
      ), 
    ); 
  }
}

Text buildStatistic(String title) {
  return Text(  
    title, 
    style: TextStyle(fontSize: 18), 
    textAlign: TextAlign.center,
  );
}

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

Future<Map<String, dynamic>> loadStatsJson(String league) async { 
  final path = 'assets/data/$league.json';
  final rawData = await rootBundle.loadString(path);
  return jsonDecode(rawData) as Map<String, dynamic>;
}

class BarRow extends StatelessWidget { 
  final String name; 
  final int score; 
  final int maxScore; 
  
  const BarRow({ 
    super.key, 
    required this.name, 
    required this.score, 
    required this.maxScore, 
  }); 

  @override 
  Widget build(BuildContext context) { 
    final fraction = maxScore == 0 ? 0.0 : score / maxScore; 
  
    return Row(  
      children: [  
        SizedBox(  
          width: 100, 
          child: Text(  
            name, overflow: TextOverflow.ellipsis), 
          ), 

          const SizedBox(width: 8), 

          Expanded(  
            child: Stack(  
              children:  [  
                // Background bar  
                Container(  
                  height: 12,  
                  decoration: BoxDecoration(  
                    color: Colors.grey.shade300,  
                    borderRadius: BorderRadius.circular(6), 
                  ),
                ),

                // Foreground bar 
                FractionallySizedBox(  
                  widthFactor: fraction,  
                  child: Container(  
                    height: 12,  
                    decoration: BoxDecoration(  
                      color: Colors.blue,  
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8), 
          Text(score.toString()), 
        ],
      );
  }
}
