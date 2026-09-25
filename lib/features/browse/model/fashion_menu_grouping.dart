import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/vendor_menu_grouping.dart';

/// Fashion-style chip → accordion → subgroup from menu section names.
///
/// Supports:
/// - `"Men · Shirts"` / `"Men - Trousers"` → chip Men, subgroup SHIRTS
/// - plain `"Men"` → chip Men, no subgroup
List<VendorMenuChipGroup> buildFashionMenuChipGroups({
  required List<String> sections,
  required List<BrowseMenuItem> items,
}) {
  if (sections.isEmpty) return const [];

  final bySection = <String, List<BrowseMenuItem>>{};
  for (final section in sections) {
    bySection[section] =
        items.where((i) => i.section == section).toList(growable: false);
  }

  final chipOrder = <String>[];
  // chip → subgroupLabel? → items
  final chipMap = <String, Map<String?, List<BrowseMenuItem>>>{};

  for (final section in sections) {
    final sectionItems = bySection[section] ?? const [];
    if (sectionItems.isEmpty) continue;

    final parsed = _parseFashionSection(section);
    if (!chipMap.containsKey(parsed.chip)) {
      chipOrder.add(parsed.chip);
      chipMap[parsed.chip] = {};
    }
    final groups = chipMap[parsed.chip]!;
    groups.putIfAbsent(parsed.subgroup, () => []);
    groups[parsed.subgroup]!.addAll(sectionItems);
  }

  return [
    for (final chip in chipOrder)
      VendorMenuChipGroup(
        label: chip,
        accordions: [
          VendorMenuAccordion(
            title: chip,
            groups: [
              for (final entry in chipMap[chip]!.entries)
                if (entry.value.isNotEmpty)
                  VendorMenuItemGroup(
                    label: entry.key,
                    items: entry.value,
                  ),
            ],
          ),
        ],
      ),
  ];
}

({String chip, String? subgroup}) _parseFashionSection(String section) {
  final raw = section.trim();
  if (raw.isEmpty) return (chip: 'All', subgroup: null);

  // "Men · Shirts", "Men - Shirts", "Men / Shirts", "Men > Shirts"
  final delim = RegExp(r'\s*[·\-|/>]\s*');
  final parts = raw.split(delim).where((p) => p.trim().isNotEmpty).toList();
  if (parts.length >= 2) {
    final chip = parts.first.trim();
    final sub = parts.sublist(1).join(' ').trim().toUpperCase();
    return (chip: chip, subgroup: sub.isEmpty ? null : sub);
  }
  return (chip: raw, subgroup: null);
}
