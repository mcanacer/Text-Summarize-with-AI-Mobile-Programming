import 'package:flutter/material.dart';
import '../services/db_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Sayfayı yenilemek için kullanılan fonksiyon
  void _yenile() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Özet Geçmişi'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _yenile, // Manuel yenileme butonu
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DbHelper.gecmisiGetir(), // SQLite'tan verileri çek
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    "Henüz bir özet kaydınız yok.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final ozetler = snapshot.data!;

          return ListView.builder(
            itemCount: ozetler.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final item = ozetler[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    item['orijinal'].toString().split(
                      '\n',
                    )[0], // İlk satırı başlık yap
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      item['ozet'],
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () async {
                      await DbHelper.ozetSil(item['id']);
                      _yenile(); // Silince listeyi güncelle
                    },
                  ),
                  onTap: () {
                    // Tıklayınca tam özeti gösteren bir pencere aç
                    _ozetDetayGoster(context, item['orijinal'], item['ozet']);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Detay gösterme penceresi (Popup)
  void _ozetDetayGoster(BuildContext context, String orijinal, String ozet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: SizedBox(width: 40, child: Divider(thickness: 4)),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Orijinal Metin",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  Text(orijinal),
                  const Divider(height: 40),
                  const Text(
                    "AI Özeti",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(ozet, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
