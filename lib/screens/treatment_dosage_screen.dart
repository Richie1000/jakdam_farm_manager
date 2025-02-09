import 'package:flutter/material.dart';

class TreatmentDosageScreen extends StatefulWidget {
  @override
  _TreatmentDosageScreenState createState() => _TreatmentDosageScreenState();
}

class _TreatmentDosageScreenState extends State<TreatmentDosageScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedPondShape = 'Circular';
  String _selectedUnit = 'Meters';
  String _selectedMedicationType = 'Solid/Powdered';
  String _selectedDosageUnit = 'Dose per Liter';
  final TextEditingController _diameterController = TextEditingController();
  final TextEditingController _depthController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();

  double _calculateVolume() {
    double depth = double.parse(_depthController.text);
    double volume;

    if (_selectedPondShape == 'Circular') {
      double diameter = double.parse(_diameterController.text);
      double radius = diameter / 2;
      volume = 3.14159 * radius * radius * depth;
    } else {
      double length = double.parse(_lengthController.text);
      double width = double.parse(_widthController.text);
      volume = length * width * depth;
    }

    if (_selectedUnit == 'Feet') {
      volume *= 28.317;
    } else if (_selectedUnit == 'Meters') {
      volume *= 1000;
    }

    return volume;
  }

  void _calculateDosage() {
    if (_formKey.currentState!.validate()) {
      double volume = _calculateVolume();
      double dose = double.parse(_doseController.text);
      double totalDosage;

      if (_selectedDosageUnit == 'Dose per Liter') {
        totalDosage = volume * dose;
      } else {
        totalDosage = (dose * volume) / 1000;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Calculated Dosage'),
            content: Text(
              'For a pond volume of ${volume.toStringAsFixed(2)} liters, the total amount of medication needed is: ${totalDosage.toStringAsFixed(2)} ${_selectedMedicationType == 'Solid/Powdered' ? 'grams' : 'liters'}.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Treatment Dosage Calculation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Pond Shape', style: TextStyle(fontSize: 16)),
              ListTile(
                title: const Text('Circular'),
                leading: Radio<String>(
                  value: 'Circular',
                  groupValue: _selectedPondShape,
                  onChanged: (value) {
                    setState(() {
                      _selectedPondShape = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Square/Rectangle'),
                leading: Radio<String>(
                  value: 'Square/Rectangle',
                  groupValue: _selectedPondShape,
                  onChanged: (value) {
                    setState(() {
                      _selectedPondShape = value!;
                    });
                  },
                ),
              ),
              if (_selectedPondShape == 'Circular') ...[
                TextFormField(
                  controller: _diameterController,
                  decoration: InputDecoration(labelText: 'Diameter'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter diameter';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _depthController,
                  decoration: InputDecoration(labelText: 'Depth'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter depth';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
              ] else if (_selectedPondShape == 'Square/Rectangle') ...[
                TextFormField(
                  controller: _lengthController,
                  decoration: InputDecoration(labelText: 'Length'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter length';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _widthController,
                  decoration: InputDecoration(labelText: 'Width'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter width';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _depthController,
                  decoration: InputDecoration(labelText: 'Depth'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter depth';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
              ],
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: InputDecoration(labelText: 'Measurement Unit'),
                items: ['Meters', 'Feet']
                    .map((unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              Text(
                'Medication Type',
                style: TextStyle(fontSize: 16),
              ),
              ListTile(
                title: const Text('Solid/Powdered'),
                leading: Radio<String>(
                  value: 'Solid/Powdered',
                  groupValue: _selectedMedicationType,
                  onChanged: (value) {
                    setState(() {
                      _selectedMedicationType = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Liquid'),
                leading: Radio<String>(
                  value: 'Liquid',
                  groupValue: _selectedMedicationType,
                  onChanged: (value) {
                    setState(() {
                      _selectedMedicationType = value!;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedDosageUnit,
                decoration: InputDecoration(labelText: 'Dosage Unit'),
                items: ['Dose per Liter', 'Dosage in ppm']
                    .map((unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDosageUnit = value!;
                  });
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _doseController,
                decoration: InputDecoration(labelText: 'Dose'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dose';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateDosage,
                child: Text('Calculate Dosage'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
