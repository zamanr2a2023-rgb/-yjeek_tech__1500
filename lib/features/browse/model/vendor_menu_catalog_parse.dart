import 'package:yjeek_app/features/browse/model/browse_data.dart';
import 'package:yjeek_app/features/browse/model/vendor_menu_grouping.dart';
import 'package:yjeek_app/l10n/l10n.dart';

typedef VendorMenuProductMapper = BrowseMenuItem? Function(
  Map<String, dynamic> product, {
  required String section,
});

/// One node from GET /vendors/:id/menu `sections` (vendor catalog tree).
class VendorMenuSectionNode {
  const VendorMenuSectionNode({
    required this.id,
    required this.name,
    this.nameAr,
    required this.items,
    required this.children,
  });

  final String id;
  final String name;
  final String? nameAr;
  final List<BrowseMenuItem> items;
  final List<VendorMenuSectionNode> children;

  String get localizedName {
    if (L10n.isArabic) {
      final ar = nameAr?.trim();
      if (ar != null && ar.isNotEmpty) return ar;
    }
    return name;
  }

  bool get hasContent =>
      items.isNotEmpty ||
      children.any((c) => c.hasContent);
}

class VendorMenuCatalogParseResult {
  const VendorMenuCatalogParseResult({
    required this.roots,
    required this.sections,
    required this.items,
    required this.chipGroups,
  });

  final List<VendorMenuSectionNode> roots;
  final List<String> sections;
  final List<BrowseMenuItem> items;
  final List<VendorMenuChipGroup> chipGroups;
}

/// Parses nested menu sections from the vendor panel / customer menu API.
VendorMenuCatalogParseResult parseVendorMenuCatalogSections(
  List<dynamic>? sectionsRaw, {
  required VendorMenuProductMapper mapProduct,
}) {
  final roots = <VendorMenuSectionNode>[];
  if (sectionsRaw != null) {
    for (final raw in sectionsRaw) {
      if (raw is! Map<String, dynamic>) continue;
      final node = _parseSectionNode(raw, mapProduct: mapProduct);
      if (node != null && node.hasContent) roots.add(node);
    }
  }

  final sections = <String>[];
  final items = <BrowseMenuItem>[];
  for (final root in roots) {
    _collectFlat(root, sections, items);
  }

  final chipGroups = buildVendorMenuChipGroupsFromCatalog(roots);
  return VendorMenuCatalogParseResult(
    roots: roots,
    sections: sections,
    items: items,
    chipGroups: chipGroups,
  );
}

/// Main (chips) → sub (accordion) → sub-sub (group labels) from vendor catalog API tree.
List<VendorMenuChipGroup> buildVendorMenuChipGroupsFromCatalog(
  List<VendorMenuSectionNode> roots,
) {
  final groups = <VendorMenuChipGroup>[];
  for (final root in roots) {
    if (!root.hasContent) continue;
    final accordions = _accordionsForCatalogRoot(root);
    if (accordions.isEmpty) continue;
    groups.add(
      VendorMenuChipGroup(label: root.localizedName, accordions: accordions),
    );
  }
  return groups;
}

List<VendorMenuAccordion> _accordionsForCatalogRoot(VendorMenuSectionNode root) {
  final children =
      root.children.where((c) => c.hasContent).toList(growable: false);
  if (children.isEmpty) {
    if (root.items.isEmpty) return const [];
    return [
      VendorMenuAccordion(
        title: root.localizedName,
        groups: [VendorMenuItemGroup(items: root.items)],
      ),
    ];
  }

  final accordions = <VendorMenuAccordion>[
    for (final child in children)
      if (_groupsForCatalogNode(child).isNotEmpty)
        VendorMenuAccordion(
          title: child.localizedName,
          groups: _groupsForCatalogNode(child),
        ),
  ];

  if (root.items.isNotEmpty) {
    accordions.insert(
      0,
      VendorMenuAccordion(
        title: root.localizedName,
        groups: [VendorMenuItemGroup(items: root.items)],
      ),
    );
  }
  return accordions;
}

List<VendorMenuItemGroup> _groupsForCatalogNode(VendorMenuSectionNode node) {
  final grandchildren =
      node.children.where((c) => c.hasContent).toList(growable: false);
  if (grandchildren.isEmpty) {
    if (node.items.isEmpty) return const [];
    return [VendorMenuItemGroup(items: node.items)];
  }

  final groups = <VendorMenuItemGroup>[
    for (final grand in grandchildren)
      if (grand.items.isNotEmpty)
        VendorMenuItemGroup(
          label: grand.localizedName.toUpperCase(),
          items: grand.items,
        ),
  ];
  if (node.items.isNotEmpty) {
    groups.insert(0, VendorMenuItemGroup(items: node.items));
  }
  return groups;
}

VendorMenuSectionNode? _parseSectionNode(
  Map<String, dynamic> section, {
  required VendorMenuProductMapper mapProduct,
}) {
  final name = (section['name'] as String?)?.trim();
  if (name == null || name.isEmpty) return null;
  final nameAr = (section['nameAr'] as String?)?.trim();
  final id = section['id']?.toString() ?? name;

  final items = <BrowseMenuItem>[];
  final products = section['products'];
  if (products is List) {
    for (final product in products) {
      if (product is! Map<String, dynamic>) continue;
      final mapped = mapProduct(product, section: name);
      if (mapped != null) items.add(mapped);
    }
  }

  final children = <VendorMenuSectionNode>[];
  final childrenRaw = section['children'];
  if (childrenRaw is List) {
    for (final child in childrenRaw) {
      if (child is! Map<String, dynamic>) continue;
      final node = _parseSectionNode(child, mapProduct: mapProduct);
      if (node != null && node.hasContent) children.add(node);
    }
  }

  if (items.isEmpty && children.isEmpty) return null;

  return VendorMenuSectionNode(
    id: id,
    name: name,
    nameAr: nameAr,
    items: items,
    children: children,
  );
}

void _collectFlat(
  VendorMenuSectionNode node,
  List<String> sections,
  List<BrowseMenuItem> items,
) {
  if (node.items.isNotEmpty) {
    if (!sections.contains(node.name)) sections.add(node.name);
    items.addAll(node.items);
  }
  for (final child in node.children) {
    _collectFlat(child, sections, items);
  }
}
