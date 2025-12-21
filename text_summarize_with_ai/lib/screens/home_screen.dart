import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _metinController = TextEditingController();

  // HATA 1 ÇÖZÜMÜ: 'final' kelimesini kaldırdık ki değeri güncelleyebilelim.
  String _ozetSonucu = "Özet sonucu burada görünecek...";
  bool _yukleniyor = false;

  void _ozetleMetni() async {
    if (_metinController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lütfen bir metin girin!")));
      return;
    }

    setState(() {
      _yukleniyor = true;
    });

    try {
      // 1. AI Modelinden Özeti Al
      String sonuc = await ApiService.metniOzetle(_metinController.text);

      // 2. Başarılıysa SQLite'a Kaydet
      if (!sonuc.startsWith("Hata") && !sonuc.startsWith("Bağlantı")) {
        await DbHelper.ozetKaydet(_metinController.text, sonuc);
      }

      setState(() {
        _ozetSonucu = sonuc;
      });
    } catch (e) {
      setState(() {
        _ozetSonucu = "Bir hata oluştu: $e";
      });
    } finally {
      setState(() {
        _yukleniyor = false;
      });
    }
  }

  // HATA 2 ÇÖZÜMÜ: Buradaki kopuk setState bloğunu tamamen sildik.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öz.AI - Metin Özetle'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade50,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              "Özetlenecek Metin",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _metinController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: "Uzun metni buraya yapıştırın...",
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _yukleniyor
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Yapay Zeka ile Özetle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _ozetleMetni,
                  ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Sonuç:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
                border: Border.all(color: Colors.deepPurple.withOpacity(0.2)),
              ),
              child: SelectableText(
                _ozetSonucu,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
