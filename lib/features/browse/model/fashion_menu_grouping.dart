import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/vendor_menu_grouping.dart';

/// Fallback chip → sub-accordion → sub-sub group when API tree is flat section names.
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
  // chip → accordion → subgroup? → items
  final chipMap =
      <String, Map<String, Map<String?, List<BrowseMenuItem>>>>{};

  for (final section in sections) {
    final sectionItems = bySection[section] ?? const [];
    if (sectionItems.isEmpty) continue;

    final parsed = _parseFashionSection(section);
    if (!chipMap.containsKey(parsed.chip)) {
      chipOrder.add(parsed.chip);
      chipMap[parsed.chip] = {};
    }
    final accordionMap = chipMap[parsed.chip]!;
    accordionMap.putIfAbsent(parsed.accordion, () => {});
    accordionMap[parsed.accordion]!.putIfAbsent(parsed.subgroup, () => []);
    accordionMap[parsed.accordion]![parsed.subgroup]!.addAll(sectionItems);
  }

  return [
    for (final chip in chipOrder)
      VendorMenuChipGroup(
        label: chip,
        accordions: [
          for (final accordion in chipMap[chip]!.keys)
            VendorMenuAccordion(
              title: accordion,
              groups: [
                for (final entry in chipMap[chip]![accordion]!.entries)
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

({String chip, String accordion, String? subgroup}) _parseFashionSection(
  String section,
) {
  final raw = section.trim();
  if (raw.isEmpty) return (chip: 'All', accordion: 'All', subgroup: null);

  final delim = RegExp(r'\s*[·\-|/>]\s*');
  final parts = raw.split(delim).where((p) => p.trim().isNotEmpty).toList();
  if (parts.length >= 3) {
    final chip = parts.first.trim();
    final accordion = parts[1].trim();
    final sub = parts.sublist(2).join(' ').trim().toUpperCase();
    return (
      chip: chip,
      accordion: accordion,
      subgroup: sub.isEmpty ? null : sub,
    );
  }
  if (parts.length == 2) {
    final chip = parts.first.trim();
    final sub = parts[1].trim().toUpperCase();
    return (chip: chip, accordion: chip, subgroup: sub.isEmpty ? null : sub);
  }
  return (chip: raw, accordion: raw, subgroup: null);
}
