import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/db_helper.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _metinController = TextEditingController();
  String _ozetSonucu = "Özet sonucu burada görünecek...";
  bool _yukleniyor = false;
  String _seciliModelKey = "BART (Dengeli)";
  int _verilenPuan = 0;

  void _ozetleMetni() async {
    if (_metinController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lütfen bir metin girin!")));
      return;
    }

    setState(() {
      _yukleniyor = true;
      _verilenPuan = 0;
    });

    try {
      String sonuc = await ApiService.metniOzetle(
        _metinController.text,
        ApiService.modeller[_seciliModelKey]!,
      );

      setState(() {
        _ozetSonucu = sonuc;
      });
    } catch (e) {
      setState(() {
        _ozetSonucu = "Hata: $e";
      });
    } finally {
      setState(() {
        _yukleniyor = false;
      });
    }
  }

  void _puanlaVeKaydet(int puan) async {
    setState(() {
      _verilenPuan = puan;
    });
    await DbHelper.ozetKaydet(
      _metinController.text,
      _ozetSonucu,
      _seciliModelKey,
      puan,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Model geri bildirimi kaydedildi!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Özetle AI - Metin Özetle'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade50,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Merhaba 👋",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Model seç ve özetlemeye başla.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              "Kullanılacak Yapay Zeka Modeli:",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ApiService.modeller.keys.map((String key) {
                return ChoiceChip(
                  label: Text(key),
                  selected: _seciliModelKey == key,
                  selectedColor: Colors.deepPurple.shade100,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _seciliModelKey = key;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: TextField(
                controller: _metinController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: "Uzun metni buraya bırak...",
                  contentPadding: const EdgeInsets.all(20),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () => _metinController.clear(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_yukleniyor)
              Center(
                child: Lottie.asset('assets/ai_animation.json', height: 120),
              ),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _yukleniyor ? null : _ozetleMetni,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  _yukleniyor ? "Analiz Ediliyor..." : "Özetle ✨",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_ozetSonucu.isNotEmpty)
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 450),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    colors: [Colors.deepPurple.shade50, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.deepPurple.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "AI ANALİZİ ($_seciliModelKey)",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 20),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: _ozetSonucu),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Kopyalandı!")),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.share_rounded, size: 20),
                              onPressed: () => Share.share(_ozetSonucu),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Text(
                          _ozetSonucu,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const Divider(),
                    const Center(
                      child: Text(
                        "Modelin performansını puanlayın:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _verilenPuan
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () => _puanlaVeKaydet(index + 1),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
