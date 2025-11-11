import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // TODO: SQLite'tan çekilecek özetlerin listesi
  // final List<OzetModel> _gecmisOzetler = [];

  @override
  void initState() {
    super.initState();
    // TODO: Bu fonksiyonun içinde SQLite veritabanından verileri çek
    // _loadHistory();
  }

  void _loadHistory() {
    // setState(() {
    //   _gecmisOzetler = ... // veritabanı sorgusu
    // });
  }

  @override
  Widget build(BuildContext context) {
    bool gecmisBos = true; // Şimdilik hep boş göster

    return Scaffold(
      appBar: AppBar(title: const Text('Geçmiş Özetler'), centerTitle: true),
      body: gecmisBos
          ? _buildBosGecmisEkrani() // Eğer geçmiş boşsa
          : _buildGecmisListesi(), // Eğer geçmiş doluysa
    );
  }

  // Geçmiş listesi boşken gösterilecek widget
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

  // TODO: SQLite verileri ile doldurulacak liste
  Widget _buildGecmisListesi() {
    return ListView.builder(
      // itemCount: _gecmisOzetler.length,
      itemCount: 0, // şimdilik
      itemBuilder: (context, index) {
        // final ozet = _gecmisOzetler[index];
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
            onTap: () {
              // TODO: Detay sayfasına git veya özeti göster
            },
          ),
        );
      },
    );
  }
}
