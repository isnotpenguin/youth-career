import "package:flutter/material.dart";
import "policy_card_cache.dart";
import "policy_card_model.dart";

class PolicyCard extends StatefulWidget {
  final PolicyCardData card;
  final Future<void> Function(bool nextSaved)? onToggleSave;
  final bool isOffline;

  const PolicyCard({
    super.key,
    required this.card,
    this.onToggleSave,
    required this.isOffline,
  });

  @override
  State<PolicyCard> createState() => _PolicyCardState();
}

class _PolicyCardState extends State<PolicyCard> {
  bool saving = false;

  Color _statusBg(PolicyCardStatus s) {
    switch (s) {
      case PolicyCardStatus.eligible:
        return const Color(0xFFE8F7EE);
      case PolicyCardStatus.maybe:
        return const Color(0xFFFFF7ED);
      case PolicyCardStatus.ineligible:
        return const Color(0xFFFEF2F2);
      case PolicyCardStatus.saved:
        return const Color(0xFFEEF2FF);
    }
  }

  Color _statusFg(PolicyCardStatus s) {
    switch (s) {
      case PolicyCardStatus.eligible:
        return const Color(0xFF166534);
      case PolicyCardStatus.maybe:
        return const Color(0xFF9A3412);
      case PolicyCardStatus.ineligible:
        return const Color(0xFF991B1B);
      case PolicyCardStatus.saved:
        return const Color(0xFF3730A3);
    }
  }

  Future<void> _toggleSave() async {
    setState(() => saving = true);
    try {
      final isSaved = widget.card.status == PolicyCardStatus.saved;
      final nextSaved = !isSaved;

      final nextCard = PolicyCardData(
        id: widget.card.id,
        title: widget.card.title,
        summary: widget.card.summary,
        benefits: widget.card.benefits,
        location: widget.card.location,
        educationBackground: widget.card.educationBackground,
        status: nextSaved ? PolicyCardStatus.saved : PolicyCardStatus.maybe,
        sourceUrl: widget.card.sourceUrl,
        updatedAtISO: DateTime.now().toUtc().toIso8601String(),
      );

      // Always cache locally so it survives offline.
      await PolicyCardCache.put(nextCard);
      await widget.onToggleSave?.call(nextSaved);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isOffline)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Offline mode: showing cached policy cards",
                  style: TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                ),
              ),
            if (widget.isOffline) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      if (card.summary != null) ...[
                        const SizedBox(height: 6),
                        Text(card.summary!, style: const TextStyle(fontSize: 14, color: Color(0xFF374151))),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (card.location != null) _chip(card.location!),
                          if (card.educationBackground != null) _chip(card.educationBackground!),
                          Text(
                            "Updated ${DateTime.tryParse(card.updatedAtISO)?.toLocal().toString().split(" ").first ?? ""}",
                            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusBg(card.status),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Text(
                    card.status.name,
                    style: TextStyle(fontSize: 12, color: _statusFg(card.status), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...card.benefits.map(
              (b) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(b.label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                        ),
                        Expanded(
                          child: Text(
                            b.value,
                            textAlign: TextAlign.right,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilledButton(
                  onPressed: saving ? null : _toggleSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: (card.status == PolicyCardStatus.saved) ? const Color(0xFF111827) : const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  child: Text(saving ? "Saving…" : (card.status == PolicyCardStatus.saved) ? "Saved" : "Save"),
                ),
                if (card.sourceUrl != null)
                  TextButton(
                    onPressed: () {
                      // Intentionally left to app integration (url_launcher, etc.)
                    },
                    child: const Text("View source"),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      );
}

