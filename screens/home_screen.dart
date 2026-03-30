import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/weather_service.dart';
import '../models/weather_model.dart' as model;
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService weatherService = WeatherService();

  model.Weather? weather;
  String? errorMessage;
  bool isLoading = false;

  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentLocationWeather();
  }

  /// 🔍 SEARCH
  void getWeather() async {
    final city = controller.text.trim();

    if (city.isEmpty) {
      setState(() => errorMessage = "Enter city name");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await weatherService.fetchWeather(city);

      setState(() {
        weather = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "$e";
        isLoading = false;
      });
    }
  }

  /// 📍 LOCATION
  Future<void> getCurrentLocationWeather() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception("Enable location services");
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception("Permission denied");
      }

      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final data = await weatherService.fetchWeatherByCoords(
          pos.latitude, pos.longitude);

      setState(() {
        weather = data;
        controller.text = data.cityName;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "$e";
        isLoading = false;
      });
    }
  }

  /// 🎨 SKY SYSTEM (LEVEL 3)
  List<Color> getGradient() {
    final hour = DateTime.now().hour;

    if (weather == null) return [Colors.black, Colors.blueGrey];

    final d = weather!.description.toLowerCase();

    // 🌙 NIGHT
    if (hour < 6 || hour > 18) {
      return [Color(0xFF0D1B2A), Color(0xFF1B263B)];
    }

    // 🌧 RAIN
    if (d.contains("rain")) {
      return [Color(0xFF2C3E50), Color(0xFF4CA1AF)];
    }

    // ☁️ CLOUD / OVERCAST
    if (d.contains("cloud") || d.contains("overcast")) {
      return [Color(0xFF8A9BA8), Color(0xFF4F5D75)];
    }

    // ☀️ CLEAR
    return [Color(0xFF56CCF2), Color(0xFFF2994A)];
  }

  Widget _infoTile(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(color: Colors.white)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            children: [
              Image.network(weather!.icon, width: 90),
              const SizedBox(height: 10),
              Text(weather!.cityName,
                  style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("${weather!.temperature.toStringAsFixed(1)}°C",
                  style: const TextStyle(fontSize: 60, color: Colors.white)),
              Text(weather!.description.toUpperCase(),
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),

              Wrap(
                spacing: 25,
                runSpacing: 15,
                alignment: WrapAlignment.center,
                children: [
                  _infoTile("💧", "${weather!.humidity}%", "Humidity"),
                  _infoTile("🌡",
                      "${weather!.feelsLike.toStringAsFixed(1)}°", "Feels"),
                  _infoTile("🌬",
                      "${weather!.windSpeed.toStringAsFixed(1)} m/s", "Wind"),
                  _infoTile("📊", "${weather!.pressure}", "Pressure"),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        title: Text(
          "MY WEATHER",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Stack(
        children: [
          /// 🌈 SKY
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: getGradient(),
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// ☁️ CLOUDS
          const Positioned.fill(child: CloudAnimation()),

          /// 🌧 RAIN
          if (weather != null &&
              weather!.description.toLowerCase().contains("rain"))
            const Positioned.fill(child: RainAnimation()),

          /// ☀️ SUN
          if (weather != null &&
              weather!.description.toLowerCase().contains("clear"))
            const Positioned.fill(child: SunAnimation()),

          /// UI
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Enter City",
                            hintStyle:
                            const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: getWeather,
                      ),
                      IconButton(
                        icon:
                        const Icon(Icons.my_location, color: Colors.white),
                        onPressed: getCurrentLocationWeather,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (isLoading) const CircularProgressIndicator(),

                  if (errorMessage != null)
                    Text(errorMessage!,
                        style: const TextStyle(color: Colors.red)),

                  if (weather != null) _buildCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// ☁️ SMOOTH CLOUDS
////////////////////////////////////////////////////////////
class CloudAnimation extends StatefulWidget {
  const CloudAnimation({super.key});

  @override
  State<CloudAnimation> createState() => _CloudAnimationState();
}

class _CloudAnimationState extends State<CloudAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController c;

  @override
  void initState() {
    super.initState();
    c = AnimationController(
        vsync: this, duration: const Duration(seconds: 40))
      ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: c,
      builder: (_, __) => Stack(
        children: [
          Positioned(
              left: c.value * 600 - 300,
              top: 120,
              child: const Icon(Icons.cloud,
                  size: 160, color: Colors.white24)),
          Positioned(
              left: c.value * 700 - 350,
              top: 280,
              child: const Icon(Icons.cloud,
                  size: 200, color: Colors.white10)),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// 🌧️ CLEAN REALISTIC RAIN
////////////////////////////////////////////////////////////
class RainAnimation extends StatefulWidget {
  const RainAnimation({super.key});

  @override
  State<RainAnimation> createState() => _RainAnimationState();
}

class _RainAnimationState extends State<RainAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController c;
  bool flash = false;

  @override
  void initState() {
    super.initState();
    c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat();
    _lightning();
  }

  void _lightning() async {
    final r = Random();
    while (mounted) {
      await Future.delayed(Duration(seconds: 3 + r.nextInt(4)));
      setState(() => flash = true);
      await Future.delayed(const Duration(milliseconds: 120));
      setState(() => flash = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: c,
          builder: (_, __) => CustomPaint(
            painter: RainPainter(c.value),
            size: Size.infinite,
          ),
        ),
        if (flash)
          Container(color: Colors.white.withOpacity(0.3)),
      ],
    );
  }
}

class RainPainter extends CustomPainter {
  final double t;
  RainPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 100; i++) {
      final x = (i * 17) % size.width;
      final y = (t * size.height + i * 25) % size.height;

      canvas.drawLine(
        Offset(x, y),
        Offset(x + 1.5, y + 8),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

////////////////////////////////////////////////////////////
/// ☀️ SUN
////////////////////////////////////////////////////////////
class SunAnimation extends StatefulWidget {
  const SunAnimation({super.key});

  @override
  State<SunAnimation> createState() => _SunAnimationState();
}

class _SunAnimationState extends State<SunAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController c;

  @override
  void initState() {
    super.initState();
    c = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: c,
      builder: (_, __) => Center(
        child: Icon(
          Icons.wb_sunny,
          size: 180 + (c.value * 20),
          color: Colors.yellow.withOpacity(0.4),
        ),
      ),
    );
  }
}