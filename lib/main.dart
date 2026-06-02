import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

// Root widget — configures the app theme and launches the home screen
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const BMICalculatorScreen(),
    );
  }
}

// Main screen — StatefulWidget because the UI updates on user interaction
class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({super.key});

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  // used to read what the user typed ──
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String _bmiResult = '';
  String _bmiCategory = '';
  bool _hasResult = false;

  // null means no error, a string means show it
  String? _weightError;
  String? _heightError;

  // Background color cycling
  final List<Color> _backgroundColors = [
    const Color(0xFF0D7377), // 1. Teal
    const Color(0xFF1B4332), // 2. Forest green
    const Color(0xFF3A0CA3), // 3. Deep violet
    const Color(0xFFE3F2FD), // 4. Light sky blue (text turns black here)
    const Color(0xFF1A1A2E), // 5. Midnight navy
  ];

  // Tracks which color in the list is currently active
  int _colorIndex = 0;

  // Returns the currently active background color
  Color get _currentBackground => _backgroundColors[_colorIndex];

  // Determines foreground color (black or white) using luminance.
  // computeLuminance() returns 0.0 (black) to 1.0 (white).
  // If background is bright - use black text.
  // If background is dark - use white text.
  Color get _foregroundColor {
    return _currentBackground.computeLuminance() > 0.3
        ? Colors.black
        : Colors.white;
  }

  Color get _subtleColor => _foregroundColor.withOpacity(0.6);

  // Advances to the next background color
  void _cycleBackground() {
    setState(() {
      _colorIndex = (_colorIndex + 1) % _backgroundColors.length;
    });
  }

  // Validates weight
  String? _validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) return 'Weight is required';
    final weight = double.tryParse(value.trim());
    if (weight == null) return 'Please enter a valid number';
    if (weight <= 0) return 'Weight must be greater than 0';
    if (weight > 500) return 'Please enter a realistic weight (≤ 500 kg)';
    return null; // Valid
  }

  // Validates height
  String? _validateHeight(String? value) {
    if (value == null || value.trim().isEmpty) return 'Height is required';
    final height = double.tryParse(value.trim());
    if (height == null) return 'Please enter a valid number';
    if (height <= 0) return 'Height must be greater than 0';
    if (height > 300) return 'Please enter a realistic height (≤ 300 cm)';
    return null; // Valid
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal weight';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  // Validates both inputs, then computes BMI and updates the UI
  void _calculateBMI() {
    setState(() {
      _weightError = _validateWeight(_weightController.text);
      _heightError = _validateHeight(_heightController.text);
    });

    if (_weightError != null || _heightError != null) return;

    final double weight = double.parse(_weightController.text.trim());
    final double heightCm = double.parse(_heightController.text.trim());

    // Convert height from centimeters to meters for the formula
    final double heightM = heightCm / 100;

    // bmi formula
    final double bmi = weight / (heightM * heightM);

    setState(() {
      _bmiResult = bmi.toStringAsFixed(1); // Round to 1 decimal place
      _bmiCategory = _getBMICategory(bmi);
      _hasResult = true;
    });
  }

  // Builds one row of the BMI reference guide
  // highlights the row that matches the current result category.
  Widget _buildReferenceRow(String range, String label) {
    final bool isActive = label == _bmiCategory;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            range,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? _foregroundColor : _subtleColor,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? _foregroundColor : _subtleColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _currentBackground,
      appBar: AppBar(
        title: Text(
          'BMI Calculator',
          style: TextStyle(
            color: _foregroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _currentBackground,
        // foregroundColor drives the back-arrow and icon colors automatically
        foregroundColor: _foregroundColor,
        elevation: 0,
        // Syncs status bar icon brightness with the active background
        systemOverlayStyle: _currentBackground.computeLuminance() > 0.3
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),

      // Buttons and text fields keep their own tap behavior automatically
      // inner widgets win Flutter's gesture arena, so they consume their own
      // taps without triggering this parent GestureDetector.
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _cycleBackground,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Hint text so the user knows tapping cycles the background
                Text(
                  'Tap any empty area to change background color',
                  style: TextStyle(
                    color: _subtleColor,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                Text(
                  'Weight (kg)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _foregroundColor,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  // Show an error immediately if the input contains non-numeric characters
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty &&
                          RegExp(r'[^0-9.]').hasMatch(value)) {
                        _weightError = 'Please enter a valid number';
                      } else {
                        _weightError = null;
                      }
                    });
                  },
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'e.g. 70',
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.92),
                    // Red border when there is a validation error
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _weightError != null
                            ? Colors.red
                            : Colors.transparent,
                        width: _weightError != null ? 2 : 0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _weightError != null ? Colors.red : Colors.white,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                if (_weightError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                    child: Text(
                      _weightError!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                Text(
                  'Height (cm)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _foregroundColor,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  // Show an error immediately if the input contains non-numeric characters
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty &&
                          RegExp(r'[^0-9.]').hasMatch(value)) {
                        _heightError = 'Please enter a valid number';
                      } else {
                        _heightError = null;
                      }
                    });
                  },
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'e.g. 175',
                    hintStyle: const TextStyle(color: Colors.black38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.92),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _heightError != null
                            ? Colors.red
                            : Colors.transparent,
                        width: _heightError != null ? 2 : 0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _heightError != null ? Colors.red : Colors.white,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                // Error message displayed directly below the height field
                if (_heightError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                    child: Text(
                      _heightError!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                const SizedBox(height: 36),

                //Calculate button
                // Background = foreground color, text = background color
                ElevatedButton(
                  onPressed: _calculateBMI,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _foregroundColor,
                    foregroundColor: _currentBackground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Calculate BMI',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 36),

                // Result card and is only shown after a successful calculation
                if (_hasResult)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _foregroundColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _foregroundColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Your BMI Result',
                          style: TextStyle(fontSize: 14, color: _subtleColor),
                        ),
                        const SizedBox(height: 12),
                        // Large BMI number
                        Text(
                          _bmiResult,
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: _foregroundColor,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _bmiCategory,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: _foregroundColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Reference guide with the active row highlighted
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _foregroundColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'BMI Reference',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _subtleColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildReferenceRow('< 18.5', 'Underweight'),
                              _buildReferenceRow(
                                '18.5 – 24.9',
                                'Normal weight',
                              ),
                              _buildReferenceRow('25.0 – 29.9', 'Overweight'),
                              _buildReferenceRow('≥ 30.0', 'Obese'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
