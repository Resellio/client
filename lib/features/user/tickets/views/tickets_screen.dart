import 'package:flutter/material.dart';

class CustomerTicketsScreen extends StatelessWidget {
  const CustomerTicketsScreen({super.key});

  final List<Map<String, String>> tickets = const [
    {
      'title': 'Opener Festival',
      'date': '02-05.07.2025',
      'location': 'Gdynia, Polska',
    },
    {
      'title': 'Koncert Muzyki Klasycznej',
      'date': '01.02.2025',
      'location': 'Olsztyn, Polska',
    },
    {
      'title': 'Warsztaty Lepienia Pierogów',
      'date': '10.01.2025',
      'location': 'Poznań, Polska',
    },
    {
      'title': 'Pokaz Obrazów Wodnych',
      'date': '27.12.2024',
      'location': 'Bydgoszcz, Polska',
    },
    {
      'title': 'Birmingham Festival',
      'date': '08.08.2026',
      'location': 'Birmingham, Anglia',
    },
    {
      'title': 'Warszawskie Dni Informatyki',
      'date': '06.12.2024',
      'location': 'Olsztyn, Polska',
    },
    {
      'title': 'Warszawskie Dni Informatyki',
      'date': '06.12.2024',
      'location': 'Olsztyn, Polska',
    },
    {
      'title': 'Warszawskie Dni Informatyki',
      'date': '06.12.2024',
      'location': 'Olsztyn, Polska',
    },
    {
      'title': 'Warszawskie Dni Informatyki',
      'date': '06.12.2024',
      'location': 'Olsztyn, Polska',
    },
    {
      'title': 'Warszawskie Dni Informatyki',
      'date': '06.12.2024',
      'location': 'Olsztyn, Polska',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bilety')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SizedBox(
              height: 90,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            ticket['title']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('${ticket['date']} ${ticket['location']}'),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue.shade300,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
