// flutter run -d chrome

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MyApp()); 
}

class MyApp extends StatelessWidget {
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
  final List<String> leagues = ["Granny Smith", "Live the Riv", "Virginia is for (Music) Lovers"];

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: buildMainAppBar("Music Leagues"), 
      body: GridView.extent(  
        maxCrossAxisExtent: 500, 
        padding: const EdgeInsets.all(16), 
        crossAxisSpacing: 16, 
        mainAxisSpacing: 16, 
        children: leagues.map( (league) { 
          return buildInkwellCard(league, context);
        }).toList(),
      ),
    );
  }
}

class LeaguePage extends StatelessWidget {
  final String leagueName; 
  final players = ["Benj", "Daniel", "Ian", "Chase", "Maren", "Emma", "Etc..."];

  LeaguePage({ required this.leagueName });

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: buildMainAppBar("Music Leagues"), 
      body: Center( 
        child: ConstrainedBox(  
          constraints: BoxConstraints( 
            minWidth: 300, 
            maxWidth: 500, 
            minHeight: 100, 
            maxHeight: 800, //double.infinity, 
          ),
          child: Container( 
            color: const Color.fromARGB(255, 214, 220, 224),
            child: ListView.builder(  
              padding: const EdgeInsets.all(16.0), 
              itemCount: players.length, 
              itemBuilder: (context, index) {
                return ListTile(  
                  title: Text(
                    players[index], 
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ), 
                  onTap: () {
                    Navigator.push( 
                      context, 
                      MaterialPageRoute( 
                        builder: (context) => StatsPage( 
                          leagueName: leagueName, 
                          playerName: players[index], 
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ), 
      ), 
    );
  }
}

class StatsPage extends StatelessWidget { 
  final String leagueName; 
  final String playerName; 
  final points = [10, 9, 12, 0, -1, 8, 20];

  StatsPage({required this.leagueName, required this.playerName}); 

  @override 
  Widget build(BuildContext context) { 
    return Scaffold(  
      appBar: buildMainAppBar("Music League: $leagueName"), 
      body: Center(  
        child: SingleChildScrollView(  
          child: Column( 
            children: [
              Text(
                "Statistics for $playerName", 
                style: TextStyle( 
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                )
              ),

              SizedBox(height: 50), 

              Center( 
                child: Container( 
                  padding: const EdgeInsets.all(16), 
                  color: Colors.blue[50], 
                  child: SizedBox( 
                    height: 300, 
                    child: LineChart( 
                      LineChartData( 
                        borderData: FlBorderData(show: true), 
                        titlesData: FlTitlesData( 
                          bottomTitles: AxisTitles( 
                            sideTitles: SideTitles( 
                              showTitles: true, 
                              getTitlesWidget: (value, meta) { 
                                return Text("R${value.toInt() + 1}");
                              },
                            ),
                          ),
                          leftTitles: AxisTitles( 
                            sideTitles: SideTitles( showTitles: true), 
                          ),
                        ) ,
                        lineBarsData: [
                          LineChartBarData( 
                            spots: List.generate( 
                              points.length, 
                              (index) => 
                                  FlSpot(index.toDouble(), points[index].toDouble())), 
                            isCurved: true, 
                            color: Colors.deepPurple, 
                            barWidth: 3, 
                            dotData: FlDotData(show: true), 
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Text("Points Received: "), 
              Text("[Plot of points per round?]"), 
              buildStatistic("Most Liked Player: "), 
              buildStatistic("Least Liked Player: "), 
              buildStatistic("Biggest Fan: "), 
              buildStatistic("Biggest Hater: "), 
              buildStatistic("Most Similar Taste: "),
            ]
          ),
        ),
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

Card buildInkwellCard(String leagueName, BuildContext context) {
    return Card(  
      child: InkWell( 
        onTap: () {
          Navigator.push( 
            context, 
            MaterialPageRoute( 
              builder: (context) => LeaguePage(leagueName: leagueName), 
            ),
          );
        },
        hoverColor: const Color.fromARGB(255, 197, 230, 199),
        child: Center(  
          child: Text(  
            leagueName, 
            style: TextStyle(  
              fontSize: 18, 
              fontWeight: FontWeight.bold
            ), 
            textAlign: TextAlign.center, 
          ),
        ),
      ),
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
