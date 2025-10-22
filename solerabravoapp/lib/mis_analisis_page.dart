import 'package:flutter/material.dart';

class MisAnalisisPage extends StatelessWidget {
  const MisAnalisisPage({super.key});

  Widget buildAnalysisItem({
    required String title,
    required String date,
    required String imagePath,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text("Ver"),
                      style: TextButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6)),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_outlined, size: 16),
                      label: const Text("Descargar"),
                      style: TextButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6)),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share_outlined, size: 16),
                      label: const Text("Compartir"),
                      style: TextButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analyses = [
      {
        "title": "Análisis #1",
        "date": "15 ene 2024 · 14:30",
        "img": "assets/images/horse.jpg"
      },
      {
        "title": "Análisis #2",
        "date": "14 ene 2024 · 16:45",
        "img": "assets/images/horse.jpg"
      },
      {
        "title": "Análisis #3",
        "date": "12 ene 2024 · 10:20",
        "img": "assets/images/horse.jpg"
      },
      {
        "title": "Análisis #4",
        "date": "10 ene 2024 · 12:15",
        "img": "assets/images/horse.jpg"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xfff9fafc),
      appBar: AppBar(
        backgroundColor: const Color(0xff0c1931),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Mis análisis",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              "${analyses.length} análisis guardados",
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    "${analyses.length}",
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Análisis guardados",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            for (var a in analyses)
              buildAnalysisItem(
                  title: a["title"]!,
                  date: a["date"]!,
                  imagePath: a["img"]!),
          ],
        ),
      ),
      
    );
  }
}
