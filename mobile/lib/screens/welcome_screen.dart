import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();

  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "assets/images/onboarding1.jpg",
      "title": "Track every shot.",
      "subtitle": "Improve every workout.",
    },
    {
      "image": "assets/images/onboarding2.jpg",
      "title": "Create custom workouts.",
      "subtitle": "Train smarter every day.",
    },
    {
      "image": "assets/images/onboarding3.jpg",
      "title": "Analyze your performance.",
      "subtitle": "Find your best shooting spots.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1224),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              "Welcome to",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            Image.asset("assets/images/logo_white.png", width: 180),

            const SizedBox(height: 20),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Image.asset(
                                  pages[index]["image"]!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  alignment: Alignment(0, -0.5),
                                ),
                              ),

                              if (index == 0)
                                Positioned(
                                  left: 20,
                                  bottom: 20,
                                  child: Container(
                                    width: 135,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.75),
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Shooting %",
                                          style: TextStyle(
                                            color: Color(0xFFacaeb8),
                                            fontSize: 13,
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        const Text(
                                          "72%",
                                          style: TextStyle(
                                            color: Color(0xFF3a7ff3),
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        const Text(
                                          "Made shots",
                                          style: TextStyle(
                                            color: Color(0xFFacaeb8),
                                            fontSize: 13,
                                          ),
                                        ),

                                        const Text(
                                          "180 / 250",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        const SizedBox(height: 14),

                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _bar(18),
                                            _bar(30),
                                            _bar(22),
                                            _bar(45),
                                            _bar(35),
                                            _bar(55),
                                            _bar(40),
                                          ],
                                        ),

                                        const SizedBox(height: 6),

                                        const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "M",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              "T",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              "W",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              "T",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              "F",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              "S",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              "S",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        pages[index]["title"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        pages[index]["subtitle"]!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 17,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentPage == index ? 8 : 6,
                  height: currentPage == index ? 8 : 6,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? const Color(0xFF2870f3)
                        : Colors.white24,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 62,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2870f3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Sign Up For Free",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF0D1224),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                "Log In",
                style: TextStyle(
                  color: Color(0xFF2870f3),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _bar(double height) {
    return Container(
      width: 10,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF4F8DFD),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
