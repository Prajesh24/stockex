import 'package:flutter/material.dart';
import 'package:stockex/features/auth/presentation/pages/login_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Track Your Stocks",
      "description": "Monitor your portfolio and analyze market trends easily.",
      "image": "assets/track.png",
    },
    {
      "title": "Real-Time Insights",
      "description": "Get real-time stock prices and stay ahead in the market.",
      "image": "assets/insights.jpeg",
    },
    {
      "title": "Smart Portfolio Tools",
      "description": "Build and manage your portfolio with smart tools.",
      "image": "assets/portfolio.jpeg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // MEDIA QUERY VARIABLES
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),

            // PAGE VIEW (IMAGES + TEXT)
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (_, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // RESPONSIVE IMAGE
                        Image.asset(
                          onboardingData[index]["image"]!,
                          height: height * 0.38,
                          width: width * 0.85,
                          fit: BoxFit.contain,
                        ),

                        // TITLE
                        Text(
                          onboardingData[index]["title"]!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: height * 0.035,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // DESCRIPTION
                        Text(
                          onboardingData[index]["description"]!,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: height * 0.02,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: height * 0.02),

            // PAGE INDICATORS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                  height: height * 0.01,
                  width: currentIndex == index ? width * 0.06 : width * 0.02,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? Colors.greenAccent
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            SizedBox(height: height * 0.03),

            // NEXT / GET STARTED BUTTON
            Padding(
              padding: EdgeInsets.all(width * 0.06),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (currentIndex == onboardingData.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: height * 0.02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    currentIndex == onboardingData.length - 1
                        ? "Get Started"
                        : "Next",
                    style: TextStyle(fontSize: height * 0.025),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
