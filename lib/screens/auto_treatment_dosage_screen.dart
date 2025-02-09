import 'package:flutter/material.dart';

class AutoTreatmentDosageScreen extends StatefulWidget {
  @override
  _AutoTreatmentDosageScreenState createState() =>
      _AutoTreatmentDosageScreenState();
}

class _AutoTreatmentDosageScreenState extends State<AutoTreatmentDosageScreen> {
  bool isCircularPond = false;
  bool isMetricUnit = false;
  double length = 0.0;
  double width = 0.0;
  double depth = 0.0;

  void clearFields() {
    setState(() {
      length = 0.0;
      width = 0.0;
      depth = 0.0;
    });
  }

  List<String> drugs = [
    'Fish Biotic',
    'Oxytetracycline',
    'Formalin',
    'Chloramphenicol',
    'Potassium Permanganate',
    'Sulphadimidine',
    'Erythromycin',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Auto Treatment Dosage',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Auto Treatment Dosage',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Calculate Drug And Treatment Dosage For Specified Drugs',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              buildPondShapeSelector(),
              SizedBox(height: 20),
              buildMeasurementUnitSelector(),
              SizedBox(height: 20),
              buildMeasurementFields(),
              SizedBox(height: 20),
              buildActionButtons(),
              SizedBox(height: 20),
              buildDrugList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPondShapeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT POND SHAPE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Radio(
                  value: false,
                  groupValue: isCircularPond,
                  onChanged: (value) {
                    setState(() {
                      isCircularPond = value ?? false;
                    });
                  },
                ),
                Text('Square or Rectangular Pond'),
              ],
            ),
            Row(
              children: [
                Radio(
                  value: true,
                  groupValue: isCircularPond,
                  onChanged: (value) {
                    setState(() {
                      isCircularPond = value ?? false;
                    });
                  },
                ),
                Text('Circular Pond'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget buildMeasurementUnitSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT MEASUREMENT UNIT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Radio(
              value: false,
              groupValue: isMetricUnit,
              onChanged: (value) {
                setState(() {
                  isMetricUnit = value ?? false;
                });
              },
            ),
            Text('Feet'),
            Radio(
              value: true,
              groupValue: isMetricUnit,
              onChanged: (value) {
                setState(() {
                  isMetricUnit = value ?? false;
                });
              },
            ),
            Text('Meters'),
          ],
        ),
      ],
    );
  }

  Widget buildMeasurementFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildMeasurementField('Length', length, (value) {
          setState(() {
            length = double.parse(value);
          });
        }),
        buildMeasurementField('Width', width, (value) {
          setState(() {
            width = double.parse(value);
          });
        }),
        SizedBox(height: 10),
        buildMeasurementField('Water Depth', depth, (value) {
          setState(() {
            depth = double.parse(value);
          });
        }),
      ],
    );
  }

  Widget buildMeasurementField(
      String label, double initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: initialValue.toString(),
            ),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: clearFields,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          ),
          child: Text('CLEAR'),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          ),
          child: Text('REFRESH DRUG LIST'),
        ),
      ],
    );
  }

  Widget buildDrugList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT ANY DRUG TO AUTOMATICALLY GENERATE DOSAGE',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 10),
        ...drugs.map((drug) => buildDrugButton(drug)).toList(),
      ],
    );
  }

  Widget buildDrugButton(String drugName) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          drugName,
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
      ),
    );
  }
}
