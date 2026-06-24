import 'package:flutter/material.dart';
import 'package:taptrade/Const/apiEndPoint.dart';
import 'package:taptrade/Models/ChatModels/matchModel.dart';
import 'package:taptrade/Services/ApiServices/apiServices.dart';
import 'package:taptrade/Utills/appColors.dart';

class CompletedDealScreen extends StatefulWidget {
  const CompletedDealScreen({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  State<CompletedDealScreen> createState() => _CompletedDealScreenState();
}

class _CompletedDealScreenState extends State<CompletedDealScreen> {
  bool _isLoading = false;
  List<MatchModel> _deals = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.getRequestData(
        '${ApiEndPoint.baseUrl}api/matches/?status=completed',
        context,
        useToken: true,
      );
      final parsed = MatchesResponseModel.fromJson(res);
      if (mounted) setState(() => _deals = parsed.matches ?? []);
    } catch (_) {}
    finally { if (mounted) setState(() => _isLoading = false); }
  }

  Widget _img(String? url, double sz) {
    final valid = url != null && url.startsWith('http');
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: valid
          ? Image.network(url!, width: sz, height: sz, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imgPlaceholder(sz))
          : _imgPlaceholder(sz),
    );
  }

  Widget _imgPlaceholder(double sz) => Container(
    width: sz, height: sz,
    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
    child: const Icon(Icons.image_not_supported, color: Colors.grey),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _deals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.handshake_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No completed deals yet', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 60),
                    itemCount: _deals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final d = _deals[i];
                      final completedAt = d.matchedAt; // best available date
                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => CompletedDealDetailScreen(deal: d),
                        )),
                        child: Card(
                          color: AppColors.surfaceVariantColor(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFFB3E5FC)),
                          ),
                          elevation: 0, margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Column(children: [
                                  _img(d.myProduct?.image, 80),
                                  const SizedBox(height: 6),
                                  SizedBox(width: 80, child: Text(
                                    d.myProduct?.title ?? '',
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                  )),
                                ]),
                                Expanded(child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.swap_horiz, color: Colors.teal, size: 28),
                                    const SizedBox(height: 4),
                                    Text(d.otherUser?.username ?? '',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center),
                                    if (completedAt != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${completedAt.day}/${completedAt.month}/${completedAt.year}',
                                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      ),
                                    ],
                                  ],
                                )),
                                Column(children: [
                                  _img(d.theirProduct?.image, 80),
                                  const SizedBox(height: 6),
                                  SizedBox(width: 80, child: Text(
                                    d.theirProduct?.title ?? '',
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                  )),
                                ]),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

// ─── Detail Screen ────────────────────────────────────────────────────────────
class CompletedDealDetailScreen extends StatelessWidget {
  final MatchModel deal;
  const CompletedDealDetailScreen({Key? key, required this.deal}) : super(key: key);

  Widget _img(String? url, double sz) {
    final valid = url != null && url.startsWith('http');
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: valid
          ? Image.network(url!, width: sz, height: sz, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(sz))
          : _placeholder(sz),
    );
  }

  Widget _placeholder(double sz) => Container(
    width: sz, height: sz,
    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(14)),
    child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 36),
  );

  Widget _infoRow(String label, String value, {Color? valueColor}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: valueColor)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final completedAt = deal.matchedAt;
    final dateStr = completedAt != null
        ? '${completedAt.day}/${completedAt.month}/${completedAt.year}  ${completedAt.hour}:${completedAt.minute.toString().padLeft(2, '0')}'
        : 'Unknown';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Completed Trade', style: TextStyle(color: AppColors.primaryText(context), fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 6),
                    Text('Trade Completed', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Products side-by-side
            Row(
              children: [
                Expanded(child: Column(
                  children: [
                    _img(deal.myProduct?.image, size.width * 0.38),
                    const SizedBox(height: 8),
                    Text(deal.myProduct?.title ?? 'Your Product',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 4),
                    const Text('Your item', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: const [
                      Icon(Icons.swap_horiz, size: 36, color: Colors.teal),
                      Text('traded for', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
                Expanded(child: Column(
                  children: [
                    _img(deal.theirProduct?.image, size.width * 0.38),
                    const SizedBox(height: 8),
                    Text(deal.theirProduct?.title ?? 'Their Product',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(deal.otherUser?.username ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                )),
              ],
            ),

            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 12),

            // Deal info
            Text('Trade Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primaryText(context))),
            const SizedBox(height: 12),
            _infoRow('Trading partner', deal.otherUser?.username ?? '—'),
            _infoRow('Completed on', dateStr),
            _infoRow('Status', 'Completed', valueColor: Colors.green),
            _infoRow('Match ID', '#${deal.id ?? "—"}'),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
