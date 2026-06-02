# Solo App 2 — BMI Calculator

## What This App Does

This Flutter app is a BMI (Body Mass Index) Calculator. The user enters their weight in kilograms and height in centimeters, taps 'Calculate BMI', and immediately sees their numeric BMI score, their BMI category (Underweight, Normal weight, Overweight, or Obese), and a reference guide with the current category highlighted.

The app also features tap-to-change background: tapping any empty area of the screen cycles through 5 background colors, and all text and icons automatically switch between black and white to stay readable on every color.

## How to Run It

1. Make sure Flutter is installed on your machine
2. Clone this repository:   git clone https://github.com/mrpatel2/bmi_calculator
3. Navigate into the project folder: cd bmi_calculator/lib/main.dart
4. Run the app on a simulator or emulator: flutter run

## Color Palette & Contrast Method

The app cycles through exactly 5 background colors when the user taps an empty area of the screen:

| # | Name | Hex |
|---|------|-----|
| 1 | Teal | `#0D7377` |
| 2 | Forest Green | `#1B4332` |
| 3 | Deep Violet | `#3A0CA3` |
| 4 | Deep Rose | `#8B2252` |
| 5 | Midnight Navy | `#1A1A2E` |

How readable contrast is ensured: The app uses Flutter's built-in 'color.computeLuminance()' method on the active background color. If the luminance is greater than 0.3 (a bright background), the foreground which is all text, icons, and the AppBar switches to black. If the luminance is 0.3 or below (a dark background), the foreground switches to white. This logic applies to the Scaffold background, the AppBar title and icons, all body labels, the Calculate button, and the result card.

## Sample Test Inputs & Expected Outputs

| Weight (kg) | Height (cm) | Expected BMI | Expected Category |
|-------------|-------------|--------------|-------------------|
| 70 | 175 | 22.9 | Normal weight |
| 90 | 180 | 27.8 | Overweight |
| 50 | 165 | 18.4 | Underweight |
| 100 | 170 | 34.6 | Obese |

### Edge Cases

| Input | What Happens |
|-------|-------------|
| Weight field left empty | Error shown below field: "Weight is required" |
| Height field left empty | Error shown below field: "Height is required" |
| Weight = 0 | Error: "Weight must be greater than 0" |
| Height = 0 | Error: "Height must be greater than 0" |
| Weight = 600 | Error: "Please enter a realistic weight (≤ 500 kg)" |
| Height = 400 | Error: "Please enter a realistic height (≤ 300 cm)" |
| Weight = 0.5, Height = 0.5 | BMI = 200.0, Category = Obese — extreme values handled gracefully, no crash |