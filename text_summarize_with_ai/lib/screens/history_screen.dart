import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _loadHistory() {}

  @override
  Widget build(BuildContext context) {
    bool gecmisBos = true;

    return Scaffold(
      appBar: AppBar(title: const Text('Geçmiş Özetler'), centerTitle: true),
      body: gecmisBos ? _buildBosGecmisEkrani() : _buildGecmisListesi(),
    );
  }

  Widget _buildBosGecmisEkrani() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Henüz özet geçmişiniz yok.',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildGecmisListesi() {
    return ListView.builder(
      itemCount: 0,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: const Text(
              "Özet Başlığı (kısa metin)",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: const Text(
              "Özetin tam metni burada...",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
        );
      },
    );
  }
}
