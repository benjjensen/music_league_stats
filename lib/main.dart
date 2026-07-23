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
  - In Drop down:
    - Need to store SONG TITLES + ARTISTS to show in drop down 
    - Need to store VOTES_PER_ROUND to show in plot
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

              final receivedNames = (scores['votesReceivedNames'] as List).cast<String>();
              final votesReceived = (scores['votesReceivedScores'] as List).cast<int>();

              final givenNames = (scores['votesGivenNames'] as List).cast<String>();
              final votesGiven = (scores['votesGivenScores'] as List).cast<int>();

              final similarityNames = (scores['similarityNames'] as List).cast<String>();
              final similarityScores = (scores['similarityScores'] as List).cast<int>();

              final totalReceived = votesReceived.fold(0, (a, b) => a + b);

              final maxReceivedScore = votesReceived.reduce((a, b) => a > b ? a : b);
              final biggestFan = receivedNames[ votesReceived.indexOf(maxReceivedScore) ];

              final maxGivenScore = votesGiven.reduce((a, b) => a > b ? a : b);
              final mostLiked = givenNames[ votesGiven.indexOf(maxGivenScore) ];

              final maxSimilarityScore = similarityScores.reduce((a, b) => a > b ? a : b);
              final mostSimilar = similarityNames[ similarityScores.indexOf(maxSimilarityScore) ];

    
              final pointsPerRound = List.generate( 
                votesReceived.length, 
                (i) => FlSpot( 
                  i.toDouble(),                 // x = round number 
                  votesReceived[i].toDouble(),  // y = score
                ),
              );

              return Card(  
                child: ExpansionTile(  
                  title: Text("${personMap["name"]}  (${totalReceived} pts)", style: const TextStyle(fontWeight: FontWeight.bold)), 
                  subtitle: Text(  
                    "\t\tBiggest Fan:    ${biggestFan}  (${votesReceived[0]} pts)\n"
                    "\t\tMost Liked:     ${mostLiked}  (${votesGiven[0]} pts)\n"
                    "\t\tMost Similar:   ${mostSimilar}  (${similarityScores[0]} pts)\n"
                  ),

                  // Expanded contents
                  children: [
                    Padding( 
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 8), //EdgeInsets.all(8.0), 
                      child: Column(  
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [

                          // TODO: This is just showing who votes by person, NOT round! 
                          // scorePlot(pointsPerRound: pointsPerRound),
                          // const SizedBox(height: 24),  

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: buildScoreBar( 
                                  title: "Votes Received", 
                                  names: receivedNames, 
                                  scores: votesReceived, 
                                  maxScore: maxReceivedScore, 
                                ), 
                              ), 

                              const SizedBox(width: 30),   

                              Expanded( 
                                child: buildScoreBar( 
                                  title: "Votes Given", 
                                  names: givenNames, 
                                  scores: votesGiven, 
                                  maxScore: maxGivenScore, 
                                ), 
                              ),

                              const SizedBox(width: 30),  

                              Expanded(
                                child: buildScoreBar( 
                                  title: "Similarity Scores", 
                                  names: similarityNames, 
                                  scores: similarityScores, 
                                  maxScore: maxSimilarityScore,
                                )
                              ),                              
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );

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
    style: const TextStyle(fontSize: 18), 
    textAlign: TextAlign.center,
  );
}

AppBar buildMainAppBar(String title) {
  return AppBar( 
    backgroundColor: const Color.fromARGB(255, 173, 47, 196),
    title: Text( 
      title,
      style: const TextStyle( 
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


Widget buildScoreBar({
  required String title, 
  required List<String> names, 
  required List<int> scores, 
  required int maxScore,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start, 
    children: [
      Center(
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ), 
      const SizedBox(height: 4), 
      ...List.generate(scores.length, (i) {
        return Padding(  
          padding: const EdgeInsets.symmetric(vertical: 4), 
          child: BarRow( 
            name: names[i],  
            score: scores[i], 
            maxScore: maxScore, 
          ), 
        ); 
      }),
    ],
  );
}


Widget scorePlot({ 
  required List<FlSpot> pointsPerRound,
}) {
  return Column( 
    children: [ 
      Center(
        child: const Text(  
          "Score Per Round", 
          style: TextStyle( 
            fontWeight: FontWeight.bold, 
            fontSize: 18, 
          )
        )
      ),

    Center(
      child: SizedBox(
        height: 250,
        width: 750, 
        child: LineChart( 
          LineChartData(  
            titlesData: FlTitlesData( 
              topTitles: AxisTitles( 
                sideTitles: SideTitles(showTitles: false), 
              ),
      
              rightTitles: AxisTitles( 
                sideTitles: SideTitles(showTitles: false),
              ),
      
              bottomTitles: AxisTitles( 
                sideTitles: SideTitles( 
                  showTitles: true, 
                  getTitlesWidget: (value, meta) { 
                    return Text("${value.toInt()}");
                  },
                ),
              ),
            ),


            lineBarsData: [ 
              LineChartBarData(  
                spots: pointsPerRound, 
                isCurved: true,
              ),
            ],
          ),
        ),
      ),
    ),
    ],
  );
}

