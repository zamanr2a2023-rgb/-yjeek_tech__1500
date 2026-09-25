import 'package:yjeek_app/features/browse/model/browse_data.dart';

/// Parent chip for pinned category tabs (Figma MENU OPTION E).
class VendorMenuChipGroup {
  const VendorMenuChipGroup({
    required this.label,
    required this.accordions,
  });

  final String label;
  final List<VendorMenuAccordion> accordions;
}

/// Collapsible accordion under a chip (e.g. Crispy / Grilled / Nashville).
class VendorMenuAccordion {
  const VendorMenuAccordion({
    required this.title,
    required this.groups,
  });

  final String title;
  final List<VendorMenuItemGroup> groups;

  List<BrowseMenuItem> get allItems => [
        for (final g in groups) ...g.items,
      ];
}

/// Optional subgroup label inside an accordion (COMBOS / SINGLE).
class VendorMenuItemGroup {
  const VendorMenuItemGroup({
    this.label,
    required this.items,
  });

  final String? label;
  final List<BrowseMenuItem> items;
}

/// Builds Figma-style chip → accordion → subgroup hierarchy from flat menu sections.
List<VendorMenuChipGroup> buildVendorMenuChipGroups({
  required List<String> sections,
  required List<BrowseMenuItem> items,
}) {
  if (sections.isEmpty) return const [];

  final bySection = <String, List<BrowseMenuItem>>{};
  for (final section in sections) {
    bySection[section] = items.where((i) => i.section == section).toList();
  }

  final useHierarchy = _shouldUseHierarchy(sections);
  if (!useHierarchy) {
    return [
      for (final section in sections)
        VendorMenuChipGroup(
          label: section,
          accordions: [
            VendorMenuAccordion(
              title: section,
              groups: [
                VendorMenuItemGroup(
                  items: bySection[section] ?? const [],
                ),
              ],
            ),
          ],
        ),
    ];
  }

  // chip → accordion → subgroup → items (preserve section order)
  final chipOrder = <String>[];
  final chipMap = <String, Map<String, Map<String?, List<BrowseMenuItem>>>>{};

  for (final section in sections) {
    final sectionItems = bySection[section] ?? const [];
    if (sectionItems.isEmpty) continue;

    final chip = _chipForSection(section);
    final accordion = _accordionForSection(section);
    final subgroup = _subgroupForSection(section);

    if (!chipMap.containsKey(chip)) {
      chipOrder.add(chip);
      chipMap[chip] = {};
    }
    final accordionMap = chipMap[chip]!;
    accordionMap.putIfAbsent(accordion, () => {});
    accordionMap[accordion]!.putIfAbsent(subgroup, () => []);
    accordionMap[accordion]![subgroup]!.addAll(sectionItems);
  }

  return [
    for (final chip in chipOrder)
      VendorMenuChipGroup(
        label: chip,
        accordions: [
          for (final entry in chipMap[chip]!.entries)
            VendorMenuAccordion(
              title: entry.key,
              groups: [
                for (final group in entry.value.entries)
                  if (group.value.isNotEmpty)
                    VendorMenuItemGroup(
                      label: group.key,
                      items: group.value,
                    ),
              ],
            ),
        ],
      ),
  ];
}

bool _shouldUseHierarchy(List<String> sections) {
  if (sections.length <= 1) return false;
  var hits = 0;
  for (final s in sections) {
    final n = s.toLowerCase();
    if (n.contains('crispy') ||
        n.contains('grilled') ||
        n.contains('nashville') ||
        n.contains('sandwich') ||
        n.contains('drink') ||
        n == 'sides' ||
        n.contains('combo') ||
        n.contains('chicken')) {
      hits++;
    }
  }
  return hits >= 2;
}

String _chipForSection(String section) {
  final n = section.toLowerCase();
  if (n.contains('drink') ||
      n.contains('beverage') ||
      n.contains('juice') ||
      n.contains('shake') ||
      n.contains('soft drink')) {
    return 'Drinks';
  }
  if (n == 'sides' ||
      n.startsWith('side ') ||
      n.endsWith(' sides') ||
      n.contains(' fries') ||
      n.contains('dip')) {
    return 'Sides';
  }
  if (n.contains('sandwich')) return 'Sandwiches';
  if (n.contains('burger') && !n.contains('chicken')) return 'Sandwiches';
  return 'Chicken';
}

String _accordionForSection(String section) {
  final n = section.toLowerCase();
  if (n.contains('crispy')) return 'Crispy';
  if (n.contains('nashville')) return 'Nashville';
  if (n.contains('grilled') || n.contains('grill')) return 'Grilled';
  if (n.contains('homemade') || n.contains('burger')) return 'Homemade';
  if (n.contains('sharing') || n.contains('share')) return 'Sharing';
  if (n.contains('pasta')) return 'Pasta';
  if (n.contains('kids')) return 'Kids Meal';
  if (n.contains('salad')) return 'Salad';
  if (n.contains('picks') || n.contains('for you')) return 'Picks for you';
  if (n.contains('drink')) return 'Drinks';
  if (n == 'sides' || n.contains('side')) return 'Sides';
  // Strip common suffixes for a shorter accordion title.
  return section
      .replaceAll(RegExp(r'\s*(Combo|Box|Sandwiches?)\s*', caseSensitive: false), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

String? _subgroupForSection(String section) {
  final n = section.toLowerCase();
  if (n.contains('combo')) return 'COMBOS';
  if (n.contains('box') ||
      n.contains('single') ||
      n.contains('sandwich') ||
      n.contains('piece')) {
    return 'SINGLE';
  }
  return null;
}
