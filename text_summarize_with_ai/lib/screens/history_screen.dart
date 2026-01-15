import 'package:flutter/material.dart';
import '../services/db_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  void _yenile() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  /* -------------------- APP BAR -------------------- */

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Özet Geçmişi'),
      centerTitle: true,
      actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _yenile),
      ],
    );
  }

  /* -------------------- BODY -------------------- */

  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildHistoryList()),
      ],
    );
  }

  /* -------------------- SEARCH BAR -------------------- */

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: "Özetlerde veya metinlerde ara...",
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = "";
    });
  }

  /* -------------------- HISTORY LIST -------------------- */

  Widget _buildHistoryList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchQuery.isEmpty
          ? DbHelper.gecmisiGetir()
          : DbHelper.gecmisiAra(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        return _buildListView(snapshot.data!);
      },
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> ozetler) {
    return ListView.builder(
      itemCount: ozetler.length,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) {
        return _buildHistoryItem(ozetler[index]);
      },
    );
  }

  /* -------------------- HISTORY ITEM -------------------- */

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    return Dismissible(
      key: Key(item['id'].toString()),
      background: _buildDeleteBackground(),
      direction: DismissDirection.endToStart,
      onDismissed: (_) async {
        await DbHelper.ozetSil(item['id']);
      },
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: _buildItemTitle(item),
          subtitle: _buildItemSubtitle(item),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => _ozetDetayGoster(
            context,
            item['orijinal'],
            item['ozet'],
            item['model_adi'] ?? "Bilinmiyor",
            item['puan'] ?? 0,
          ),
        ),
      ),
    );
  }

  Widget _buildItemTitle(Map<String, dynamic> item) {
    return Text(
      item['orijinal'].toString().split('\n')[0],
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildItemSubtitle(Map<String, dynamic> item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(item['ozet'], maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildModelBadge(item['model_adi']),
            const SizedBox(width: 10),
            _buildStarRating(item['puan']),
          ],
        ),
      ],
    );
  }

  /* -------------------- SMALL UI PARTS -------------------- */

  Widget _buildModelBadge(String? modelName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        modelName ?? "BART",
        style: const TextStyle(
          fontSize: 10,
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStarRating(int? puan) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < (puan ?? 0) ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 14,
        );
      }),
    );
  }

  Widget _buildDeleteBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 12),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.history : Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? "Henüz bir özet kaydınız yok."
                : "Sonuç bulunamadı.",
          ),
        ],
      ),
    );
  }

  /* -------------------- DETAIL BOTTOM SHEET -------------------- */

  void _ozetDetayGoster(
    BuildContext context,
    String orijinal,
    String ozet,
    String model,
    int puan,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => _buildDetailSheet(orijinal, ozet, model, puan),
    );
  }

  Widget _buildDetailSheet(
    String orijinal,
    String ozet,
    String model,
    int puan,
  ) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SizedBox(width: 40, child: Divider(thickness: 4)),
              ),
              const SizedBox(height: 20),
              _buildDetailHeader(model, puan),
              const Divider(height: 40),
              _buildDetailText("Orijinal Metin", orijinal, Colors.grey),
              const Divider(height: 40),
              _buildDetailText(
                "AI Özeti",
                ozet,
                Colors.deepPurple,
                isBold: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailHeader(String model, int puan) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDetailInfo("ANALİZ EDEN MODEL", model),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              "KULLANICI PUANI",
              style: TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < puan ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailText(
    String title,
    String content,
    Color color, {
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: TextStyle(
            fontSize: isBold ? 17 : 15,
            height: 1.6,
            fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
