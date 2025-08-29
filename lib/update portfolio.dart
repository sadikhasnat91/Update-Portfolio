import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatefulWidget {
  const PortfolioApp({super.key});

  @override
  State<PortfolioApp> createState() => _PortfolioAppState();
}

class _PortfolioAppState extends State<PortfolioApp> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
      _saveThemePreference(isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sadik Hasnat - Flutter Developer',
      debugShowCheckedModeBanner: false,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainScreen(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.light,
        surface: Colors.grey[100],
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: Colors.grey[900],
        displayColor: Colors.grey[900],
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(color: Colors.black87),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      scaffoldBackgroundColor: Colors.grey[100],
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.dark,
        surface: Colors.grey[900],
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: Colors.grey[100],
        displayColor: Colors.grey[100],
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(color: Colors.white70),
        iconTheme: IconThemeData(color: Colors.white70),
      ),
      scaffoldBackgroundColor: Colors.grey[900],
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const MainScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  final PageController _pageController = PageController();
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(isDarkMode: widget.isDarkMode),
      const AboutScreen(),
      const ProjectsScreen(),
      const ContactScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double availableHeight = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        kBottomNavigationBarHeight -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sadik Hasnat',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            onPressed: widget.toggleTheme,
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: widget.isDarkMode ? Colors.white70 : Colors.black87,
            ),
            tooltip: 'Toggle Theme',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SizedBox(
        height: availableHeight,
        child: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'Contact',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final bool isDarkMode;

  const HomeScreen({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 800;
    final isTablet = size.width > 600 && size.width <= 800;

    double profileSize = isLargeScreen ? 200 : (isTablet ? 160 : 120);
    double titleFont = isLargeScreen ? 48 : (isTablet ? 36 : 24);
    double subtitleFont = isLargeScreen ? 24 : (isTablet ? 18 : 14);
    double descriptionFont = isLargeScreen ? 18 : (isTablet ? 14 : 12);
    double buttonFont = isLargeScreen ? 16 : (isTablet ? 14 : 12);
    double horizontalPadding = isLargeScreen ? size.width * 0.2 : (isTablet ? size.width * 0.15 : 16);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.1),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: size.height -
                  AppBar().preferredSize.height -
                  kBottomNavigationBarHeight -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'profile-image',
                  child: Container(
                    width: profileSize,
                    height: profileSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: 'https://media.licdn.com/dms/image/v2/D5603AQFurEqb0i-CTQ/profile-displayphoto-shrink_800_800/B56ZalMcsMHgAc-/0/1746528226724?e=1757548800&v=beta&t=j05rBAknkBd1tAeEbOBXU_OdAbzM7K7T3lr-qiL0g0I',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SpinKitCircle(color: Colors.blue),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                          ),
                          child: Icon(
                            Icons.person,
                            size: profileSize * 0.4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms, duration: 400.ms),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sadik Hasnat',
                  style: GoogleFonts.poppins(
                    fontSize: titleFont,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.3, delay: 400.ms),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Flutter Developer',
                    style: GoogleFonts.poppins(
                      fontSize: subtitleFont,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.3, delay: 600.ms),
                const SizedBox(height: 16),
                Text(
                  'Crafting beautiful, performant mobile apps\nwith Flutter & Dart',
                  style: GoogleFonts.poppins(
                    fontSize: descriptionFont,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideY(begin: 0.3, delay: 800.ms),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: socialLinks.map((link) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _SocialButton(
                        icon: link['icon'],
                        onTap: () => _launchUrl(context, link['url']),
                        delay: 1000 + (socialLinks.indexOf(link) * 100),
                        tooltip: link['name'],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _launchCall(context, '+8801798316467'),
                  icon: const Icon(Icons.call),
                  label: Text(
                    'Call Me',
                    style: GoogleFonts.poppins(
                      fontSize: buttonFont,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 48 : 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                  ),
                ).animate().fadeIn(delay: 1500.ms, duration: 600.ms).slideY(begin: 0.3, delay: 1500.ms),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProjectsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 48 : 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'View My Work',
                    style: GoogleFonts.poppins(
                      fontSize: buttonFont,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(delay: 1600.ms, duration: 600.ms).slideY(begin: 0.3, delay: 1600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  void _launchCall(BuildContext context, String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not make call to $phoneNumber')),
      );
    }
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int delay;
  final String? tooltip;

  const _SocialButton({
    required this.icon,
    required this.onTap,
    required this.delay,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 18,
          ),
        ),
      ).animate().fadeIn(delay: delay.ms, duration: 600.ms).scale(delay: delay.ms, duration: 400.ms),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 800;
    final isTablet = size.width > 600 && size.width <= 800;

    double titleFont = isLargeScreen ? 36 : (isTablet ? 28 : 20);
    double sectionFont = isLargeScreen ? 24 : (isTablet ? 20 : 16);
    double bodyFont = isLargeScreen ? 16 : (isTablet ? 14 : 12);
    double smallFont = isLargeScreen ? 14 : (isTablet ? 12 : 10);
    double profileSize = isLargeScreen ? 250 : (isTablet ? 220 : 180);
    double logoSize = isLargeScreen ? 80 : (isTablet ? 70 : 60);
    double horizontalPadding = isLargeScreen ? size.width * 0.1 : (isTablet ? size.width * 0.05 : 16);
    int skillCrossCount = isLargeScreen ? 4 : (isTablet ? 3 : 2);
    int techCrossCount = isLargeScreen ? 6 : (isTablet ? 4 : 3);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height -
              kBottomNavigationBarHeight -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'profile-image',
                child: Container(
                  width: profileSize,
                  height: profileSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 3,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.2),
                        theme.colorScheme.secondary.withOpacity(0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: 'https://media.licdn.com/dms/image/v2/D5603AQFurEqb0i-CTQ/profile-displayphoto-shrink_800_800/B56ZalMcsMHgAc-/0/1746528226724?e=1757548800&v=beta&t=j05rBAknkBd1tAeEbOBXU_OdAbzM7K7T3lr-qiL0g0I',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const SpinKitCircle(color: Colors.blue),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                        ),
                        child: Icon(
                          Icons.person,
                          size: profileSize * 0.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms, duration: 400.ms),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'About Me',
              style: GoogleFonts.poppins(
                fontSize: titleFont,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3, duration: 400.ms),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Passionate Flutter developer with 3+ years of experience building beautiful, high-performance mobile applications. I specialize in creating user-friendly interfaces and seamless user experiences using modern development practices and clean architecture patterns.\n\n'
                      'My focus is on delivering scalable and maintainable code while keeping up with the latest Flutter advancements. I thrive in collaborative environments and enjoy tackling complex challenges to create impactful solutions.',
                  style: GoogleFonts.poppins(
                    fontSize: bodyFont,
                    height: 1.6,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.3, delay: 200.ms),
            const SizedBox(height: 16),
            Text(
              'Education',
              style: GoogleFonts.poppins(
                fontSize: sectionFont,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideX(begin: -0.3, delay: 300.ms),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: 'https://tds-images.thedailystar.net/sites/default/files/styles/very_big_201/public/images/2022/05/30/nub_campus_picture_1.jpg',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const SpinKitCircle(color: Colors.blue, size: 30),
                              errorWidget: (context, url, error) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary,
                                ),
                                child: Icon(
                                  Icons.school,
                                  size: logoSize * 0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms, duration: 600.ms).scale(delay: 400.ms, duration: 400.ms),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bachelor of Science in Computer Science',
                                style: GoogleFonts.poppins(
                                  fontSize: bodyFont,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Northern University Business & Technology Khulna, Bangladesh\nPassing Year: 2026',
                                style: GoogleFonts.poppins(
                                  fontSize: smallFont,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: 'https://cdn.dhakapost.com/media/imgAll/BG/2024July/college-20240725082857.jpg',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const SpinKitCircle(color: Colors.blue, size: 30),
                              errorWidget: (context, url, error) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary,
                                ),
                                child: Icon(
                                  Icons.school,
                                  size: logoSize * 0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 500.ms, duration: 600.ms).scale(delay: 500.ms, duration: 400.ms),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Higher Secondary Certificate (HSC)',
                                style: GoogleFonts.poppins(
                                  fontSize: bodyFont,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Bongobandhu Govt College, Rupsha, Bangladesh\nPassing Year: 2021',
                                style: GoogleFonts.poppins(
                                  fontSize: smallFont,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: 'https://live.staticflickr.com/1589/24599609774_bed4b175cf_b.jpg',
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const SpinKitCircle(color: Colors.blue, size: 30),
                              errorWidget: (context, url, error) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary,
                                ),
                                child: Icon(
                                  Icons.school,
                                  size: logoSize * 0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 600.ms, duration: 600.ms).scale(delay: 600.ms, duration: 400.ms),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Khulna Zilla School',
                                style: GoogleFonts.poppins(
                                  fontSize: bodyFont,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Khulna Zilla School, Khulna, Bangladesh\nPassing Year: 2019',
                                style: GoogleFonts.poppins(
                                  fontSize: smallFont,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.3, delay: 400.ms),
            const SizedBox(height: 16),
            Text(
              'Core Skills',
              style: GoogleFonts.poppins(
                fontSize: sectionFont,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ).animate().fadeIn(delay: 700.ms, duration: 600.ms).slideX(begin: -0.3, delay: 700.ms),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: skillCrossCount,
                childAspectRatio: isLargeScreen ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: skills.length,
              itemBuilder: (context, index) {
                return _SkillCard(
                  skill: skills[index],
                  delay: 800 + (index * 100),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Tech Stack',
              style: GoogleFonts.poppins(
                fontSize: sectionFont,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ).animate().fadeIn(delay: 1200.ms, duration: 600.ms).slideX(begin: -0.3, delay: 1200.ms),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: techCrossCount,
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: techStack.length,
              itemBuilder: (context, index) {
                return _TechCard(
                  tech: techStack[index],
                  delay: 1400 + (index * 50),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final String skill;
  final int delay;

  const _SkillCard({required this.skill, required this.delay});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            skill,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 600.ms).scale(delay: delay.ms, duration: 400.ms);
  }
}

class _TechCard extends StatelessWidget {
  final Map<String, dynamic> tech;
  final int delay;

  const _TechCard({required this.tech, required this.delay});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tech['icon'],
              size: 24,
              color: tech['color'],
            ),
            const SizedBox(height: 4),
            Text(
              tech['name'],
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 600.ms).scale(delay: delay.ms, duration: 400.ms);
  }
}

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Map<String, dynamic>> projects = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final response = await http.get(Uri.parse('https://api.github.com/users/sadikhasnat91/repos'));
      if (response.statusCode == 200) {
        List<dynamic> repos = json.decode(response.body);
        projects = [];
        for (var repo in repos) {
          if (repo['fork'] == true) continue;

          final topicsResponse = await http.get(
            Uri.parse('https://api.github.com/repos/${repo['full_name']}/topics'),
            headers: {'Accept': 'application/vnd.github.mercy-preview+json'},
          );
          Map<String, dynamic> topicsData = json.decode(topicsResponse.body);
          List<dynamic> topics = topicsData['names'] ?? [];

          String category = 'Normal Apps';
          String lowerName = repo['name'].toLowerCase();
          String? lowerDesc = repo['description']?.toLowerCase();

          if (topics.contains('ecommerce') || lowerName.contains('commerce') || (lowerDesc?.contains('commerce') ?? false) || (lowerDesc?.contains('ecommerce') ?? false)) {
            category = 'E-Commerce';
          } else if (topics.contains('weather') || lowerName.contains('weather') || (lowerDesc?.contains('weather') ?? false)) {
            category = 'Weather';
          } else if (topics.contains('fitness') || lowerName.contains('fitness') || (lowerDesc?.contains('fitness') ?? false)) {
            category = 'Fitness';
          } else if (topics.contains('paint') || lowerName.contains('paint') || (lowerDesc?.contains('paint') ?? false)) {
            category = 'Paint';
          }

          projects.add({
            'name': repo['name'],
            'description': repo['description'] ?? 'No description provided.',
            'image': 'https://opengraph.githubassets.com/1/${repo['full_name']}',
            'github': repo['html_url'],
            'demo': repo['homepage']?.isNotEmpty == true ? repo['homepage'] : null,
            'tags': [
              if (repo['language'] != null) repo['language'],
              ...topics,
            ],
            'category': category,
            'pushed_at': repo['pushed_at'],
          });
        }

        projects.sort((a, b) => DateTime.parse(b['pushed_at']).compareTo(DateTime.parse(a['pushed_at'])));

        Set<String> categorySet = projects.map((p) => p['category'] as String).toSet();
        _categories = ['All', ...categorySet.toList()];
      }
    } catch (e) {
      // Handle error silently or show message
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 800;
    final isTablet = size.width > 600 && size.width <= 800;

    double titleFont = isLargeScreen ? 36 : (isTablet ? 28 : 20);
    double bodyFont = isLargeScreen ? 16 : (isTablet ? 14 : 12);
    double horizontalPadding = isLargeScreen ? size.width * 0.1 : (isTablet ? size.width * 0.05 : 16);
    int crossCount = isLargeScreen ? 2 : 1;
    double childAspect = isLargeScreen ? 1.0 : (isTablet ? 1.0 : 0.7);

    List<Map<String, dynamic>> filteredProjects = _selectedCategory == 'All'
        ? projects
        : projects.where((p) => p['category'] == _selectedCategory).toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Projects',
              style: GoogleFonts.poppins(
                fontSize: titleFont,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3, duration: 400.ms),
            const SizedBox(height: 16),
            Text(
              'Explore my GitHub projects, automatically updated and categorized.',
              style: GoogleFonts.poppins(
                fontSize: bodyFont,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
            const SizedBox(height: 16),
            if (!_isLoading)
              DropdownButton<String>(
                value: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: SpinKitCircle(color: Colors.blue))
            else if (filteredProjects.isEmpty)
              Center(
                child: Text(
                  'No projects in this category.',
                  style: GoogleFonts.poppins(
                    fontSize: bodyFont + 2,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  childAspectRatio: childAspect,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredProjects.length,
                itemBuilder: (context, index) {
                  return _ProjectCard(
                    project: filteredProjects[index],
                    delay: 400 + (index * 200),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Map<String, dynamic> project;
  final int delay;

  const _ProjectCard({
    required this.project,
    required this.delay,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 800;
    final isTablet = size.width > 600 && size.width <= 800;

    double titleFont = isLargeScreen ? 18 : (isTablet ? 17 : 16);
    double bodyFont = isLargeScreen ? 14 : (isTablet ? 13 : 12);
    double imageHeight = isLargeScreen ? 200 : (isTablet ? 180 : 150);

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
        child: Card(
          elevation: isHovered ? 12 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.05),
                  theme.colorScheme.secondary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: widget.project['image'] ?? 'https://via.placeholder.com/400',
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: SpinKitPulse(color: Colors.blue, size: 40),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: imageHeight,
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.image,
                        size: imageHeight * 0.3,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.project['name'] ?? 'Untitled Project',
                          style: GoogleFonts.poppins(
                            fontSize: titleFont,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.project['description'] ?? 'No description provided.',
                                  style: GoogleFonts.poppins(
                                    fontSize: bodyFont,
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: (widget.project['tags'] as List<dynamic>? ?? []).map((tag) {
                                    return Chip(
                                      label: Text(
                                        tag.toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: theme.colorScheme.primary.withOpacity(0.2),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              if (widget.project['github'] != null && widget.project['github'].isNotEmpty)
                                ElevatedButton.icon(
                                  onPressed: () => _launchUrl(context, widget.project['github']),
                                  icon: const Icon(Icons.code, size: 14),
                                  label: Text(
                                    'GitHub',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  ),
                                ),
                              if (widget.project['github'] != null && widget.project['github'].isNotEmpty && widget.project['demo'] != null && widget.project['demo'].isNotEmpty)
                                const SizedBox(width: 8),
                              if (widget.project['demo'] != null && widget.project['demo'].isNotEmpty)
                                OutlinedButton.icon(
                                  onPressed: () => _launchUrl(context, widget.project['demo']),
                                  icon: const Icon(Icons.launch, size: 14),
                                  label: Text(
                                    'Demo',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                    side: BorderSide(color: theme.colorScheme.primary),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: widget.delay.ms, duration: 600.ms).slideY(begin: 0.3, delay: widget.delay.ms);
  }

  void _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // EmailJS configuration - replace with your actual EmailJS credentials
        const String serviceId = 'YOUR_EMAILJS_SERVICE_ID'; // e.g., 'service_xxxxxxx'
        const String templateId = 'YOUR_EMAILJS_TEMPLATE_ID'; // e.g., 'template_xxxxxxx'
        const String userId = 'YOUR_EMAILJS_PUBLIC_KEY'; // e.g., 'user_xxxxxxx'

        final response = await http.post(
          Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'service_id': serviceId,
            'template_id': templateId,
            'user_id': userId,
            'template_params': {
              'from_name': _nameController.text,
              'from_email': _emailController.text,
              'message': _messageController.text,
            },
          }),
        );

        if (response.statusCode == 200) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Thank you for your message! I\'ll get back to you soon.',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          // Clear form
          _nameController.clear();
          _emailController.clear();
          _messageController.clear();
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send message. Please try again.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 800;
    final isTablet = size.width > 600 && size.width <= 800;

    double titleFont = isLargeScreen ? 36 : (isTablet ? 28 : 20);
    double bodyFont = isLargeScreen ? 16 : (isTablet ? 14 : 12);
    double buttonFont = isLargeScreen ? 16 : (isTablet ? 14 : 12);
    double horizontalPadding = isLargeScreen ? size.width * 0.2 : (isTablet ? size.width * 0.15 : 16);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                kBottomNavigationBarHeight -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get In Touch',
                style: GoogleFonts.poppins(
                  fontSize: titleFont,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3, duration: 400.ms),
              const SizedBox(height: 12),
              Text(
                'Let\'s discuss your next project or collaboration opportunity.',
                style: GoogleFonts.poppins(
                  fontSize: bodyFont,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Your Name',
                            hintText: 'Enter your full name',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            if (value.length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.3, delay: 400.ms),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Your Email',
                            hintText: 'Enter your email address',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(begin: 0.3, delay: 500.ms),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _messageController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: 'Your Message',
                            hintText: 'Tell me about your project...',
                            prefixIcon: const Icon(Icons.message),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your message';
                            }
                            if (value.length < 10) {
                              return 'Message must be at least 10 characters';
                            }
                            return null;
                          },
                        ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.3, delay: 600.ms),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 4,
                            ),
                            child: _isSubmitting
                                ? const SpinKitThreeBounce(
                              color: Colors.white,
                              size: 18,
                            )
                                : Text(
                              'Send Message',
                              style: GoogleFonts.poppins(
                                fontSize: buttonFont,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 700.ms, duration: 600.ms).slideY(begin: 0.3, delay: 700.ms),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Or connect with me on social media',
                      style: GoogleFonts.poppins(
                        fontSize: bodyFont,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: socialLinks.map((link) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _SocialButton(
                            icon: link['icon'],
                            onTap: () => _launchUrl(context, link['url']),
                            delay: 900 + (socialLinks.indexOf(link) * 100),
                            tooltip: link['name'],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _launchCall(context, '+8801798316467'),
                  icon: const Icon(Icons.call),
                  label: Text(
                    'Call Me',
                    style: GoogleFonts.poppins(
                      fontSize: buttonFont,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeScreen ? 48 : 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  void _launchCall(BuildContext context, String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not make call to $phoneNumber')),
      );
    }
  }
}

// Data Models
final List<String> skills = [
  'Flutter',
  'Dart',
  'Firebase',
  'REST API',
  'State Management',
  'UI/UX Design',
  'Git',
  'Agile',
  'Clean Architecture',
  'Unit Testing',
];

final List<Map<String, dynamic>> techStack = [
  {'name': 'Flutter', 'icon': Icons.flutter_dash, 'color': Colors.blue},
  {'name': 'Dart', 'icon': Icons.code, 'color': Colors.teal},
  {'name': 'Firebase', 'icon': Icons.cloud, 'color': Colors.orange},
  {'name': 'Git', 'icon': Icons.source, 'color': Colors.red},
  {'name': 'VS Code', 'icon': Icons.edit_note, 'color': Colors.blue},
  {'name': 'Android', 'icon': Icons.android, 'color': Colors.green},
  {'name': 'iOS', 'icon': Icons.apple, 'color': Colors.grey},
  {'name': 'Docker', 'icon': Icons.cloud_queue, 'color': Colors.blue},
];

final List<Map<String, dynamic>> socialLinks = [
  {
    'name': 'Email',
    'icon': Icons.email,
    'url': 'mailto:as1780646@gmail.com',
  },
  {
    'name': 'LinkedIn',
    'icon': Icons.link,
    'url': 'https://www.linkedin.com/in/sadik-hasnat-91/',
  },
  {
    'name': 'GitHub',
    'icon': Icons.code,
    'url': 'https://github.com/sadikhasnat91',
  },
  {
    'name': 'Twitter',
    'icon': Icons.message,
    'url': 'https://x.com/sadikhasnat',
  },
  {
    'name': 'Instagram',
    'icon': Icons.camera_alt,
    'url': 'https://www.instagram.com/sadik_hasnat_91/',
  },
];