# Customer App Dev Handoff — Multi-Store Catalog / Fashion v1

**For:** Customer mobile developers.  
**Not for:** Admin / vendor panel (see `06` / `07` when published).  
**Status:** **Frozen** (2026-09-26, F05) — read path + cart `variantId` + checkout stock decrement.  
**Rules:** `00-source-of-truth-and-rules.md`.  
**Shapes:** `04-api-contracts.md` (**Frozen**).

## One rule that drives the whole app

**Store type is the source of truth.**

Read `catalogMode` from the vendor (or product) response — **never** hardcode “if fashion then …”:

| `catalogMode` | Product UI | Cart line |
|---------------|------------|-----------|
| `MODIFIERS` | Today’s Food path: `optionGroups` + `addons` | `productId` + `options.optionIds` + `addonIds` |
| `VARIANTS` | Axes + variant matrix (Size×Colour, etc.) + optional `addons` | `productId` + **`variantId`** + `addonIds` only |
| `HYBRID` | Reserved — do not implement yet | — |

Fashion, Electronics, Pharmacy (retail SKU), **Vape** all use **`VARIANTS`** with different store-type axes. Food stays **`MODIFIERS`**.

---

## Flowers (Figma)

**Rules:** `13-flowers.md`.

| Screen | Wire |
|--------|------|
| Flowers vendor list | `GET /vendors?category=flowers` |
| Bloom Bahrain menu | Bouquets→ROSES/SEASONAL; Boxes; Plants; Occasions |
| Classic Red Roses | axis `size` (PILL); variants Small–Grand; extras greeting card / vase / chocolate |
| Cart | `variantId` + `addonIds` |

Demo: Medium (18) + Greeting card (1.5) → **19.500**.

---

## Electronics (Figma)

**Rules:** `12-electronics-and-high-value.md`.

| Screen | Wire |
|--------|------|
| Electronics vendor list | `GET /vendors?category=electronics` — Scheduled, Offers, Top rated; list/grid client-only |
| Sharaf DG menu | `GET /vendors/sharaf-dg/menu` — sections Phones/Laptops/… with `children` SMARTPHONES/TABLETS |
| Galaxy A55 | `GET .../products/:id` — axes `storage` (PILL) + `colour` (SWATCH); variants; addons; prefer **list** customize UI |
| High value | `restrictions.highValue === true` → Champ OTP PoD (server-side secure delivery). Show no internal economics |

Cart: `variantId` + `addonIds` (same as Fashion/Vape).

---

## Vape + 18+ age verification (Figma)

**Rules:** `11-vape-and-age-verification.md`.

### Vendor list / vendor page

| UI | Data |
|----|------|
| Orange banner “18+ only · your ID is checked on delivery” | `vendor.ageRestriction.banner` or `ageRestricted === true` |
| `18+` chip on cards | `vendor.ageBadge` (`"18+"`) |
| Scheduled / Offers / Top rated / list-grid | Same as Fashion |

### Item page CTA

| `ageRestriction.cta` | Button |
|----------------------|--------|
| `"VERIFY_AGE"` | Show **Verify your age** (not Add to Cart) |
| `null` and `canPurchase: true` | Normal Add to Cart with `variantId` |

Nicotine strength = axis `nicotine` (`uiHint: PILL`); extras = `addons[]`.

### Age verification APIs

```http
GET  /users/me/age-verification
POST /users/me/age-verification
```

```json
{
  "idFrontUrl": "<uploaded>",
  "idBackUrl": "<uploaded>",
  "consent": true,
  "simulate": "SUCCESS"
}
```

`simulate` is **stub-only** for QA: `SUCCESS` | `UNDER_18` | `ID_ALREADY_USED` | `UNREADABLE` | `EXPIRED`.

Response `data.screen`: `verified` | `under_18` | `id_already_used` | `rejected` — map to Figma screens 10–12.

Upload images via existing secure upload (`AGE_VERIFICATION` category), then pass URLs into POST.

### Cart / checkout errors

`403` `AGE_VERIFICATION_REQUIRED` if add-to-cart or checkout without verification on age-restricted vendors.

---

## What backend delivers (mobile-facing)

1. Store-type browse tree (e.g. Fashion → Clothes / Watches / …).
2. Vendor list filters (offers, rating, scheduled capability) — existing vendor list APIs.
3. Vendor menu sections from **catalog categories** when `catalogMode=VARIANTS` (Men / Women / …).
4. Product detail with `axes`, `variants` (`stockStatus`), `addons`; `optionGroups: []` for VARIANTS.
5. Cart accept `variantId`; unit price = variant absolute price + addon prices.
6. Seed demo: **H&M** Oxford (Fashion) + **Cloud Nine** Caliburn G2 (Vape / nicotine variants) after migrate + seed.
7. Age verification status + submit endpoints for 18+ store types (Vape).

Grid vs list toggle is **client-only** — no API field.

---

## Screen map (Fashion mockups → API)

### 1) Store-type home / sub-categories (Clothes, Watches, Accessories, Shoes)

| UI | Data |
|----|------|
| Title “Fashion” | Store type name / slug `fashion` |
| Cards / list rows | Platform menu categories under Fashion (`StoreTypeMenuCategory`) |
| Search “categories & vendors” | Client filter or existing `q` on vendors / taxonomy |
| Grid / list toggle | Local preference only |

**Wire:** home / category taxonomy endpoints you already use for Food; categories for Fashion include children menu cats (Clothes…).  
If a dedicated list endpoint is missing in your client SDK, use admin-published store-type detail / home entries — product will confirm exact home route in F05 freeze. Until then, treat menu category ids as the `subcategory` query for vendor list.

### 2) Vendor list under a sub-category (e.g. Clothes)

| UI | Data |
|----|------|
| “Scheduled” chip / banner | Vendor / branch supports scheduled (`supportsScheduled` / order-mode flags) |
| Offers / Top rated | Existing list filters (`hasOffers` / `sort=rating`) |
| Vendor row: name, area, rating, promo badge | Existing vendor list presenter |
| Order again | Existing reorder / order-history rail (not Fashion-specific) |

**Wire:** `GET /vendors?category=fashion` (+ `subcategory=` when drilling into Clothes).

### 3) Vendor page (H&M) — list / grid

| UI | Data |
|----|------|
| Header: logo, “Fashion — Seef”, rating, Scheduled, Min order | `GET /vendors/:id/menu` → `vendor.*` (`catalogMode`, `storeTypeSlug`, `area`, `minOrderAmount`, `supportsScheduled`, …) |
| Pills: Men / Women / Kids / Accessories | `sections[]` (from `VendorCatalogCategory`) |
| Product card: image, title, price, `+` | `sections[].products[]` — use **`priceFrom`** (not Food-only `price` semantics) |
| List / grid toggle | Client-only |

**Branch on `vendor.catalogMode`:**

- `VARIANTS` → show catalog sections; products may have `variantCount` / `hasModifiers` (addons).
- `MODIFIERS` → keep current Food menu section UI.

### 4) Item page (Oxford shirt)

| UI | Data |
|----|------|
| Title, description, hero image | Product fields |
| Displayed price | Selected **variant** `price` (default = first `IN_STOCK` or cheapest `priceFrom`) |
| Select size (required) | `axes` where `key=size`, `uiHint=PILL` — enable only sizes that exist on ≥1 available variant for current colour (or all, then grey OOS combos) |
| Select colour (required) | `axes` where `key=colour`, `uiHint=SWATCH` — use `colorHex` when present |
| Stock labels | Variant `stockStatus`: `IN_STOCK` \| `LOW_STOCK` \| `OUT_OF_STOCK` |
| Add extras (optional) | `addons[]` (multi-select) |
| Qty + Add to Cart total | `variant.price + sum(selected addons)` × qty |

**Wire:** `GET /vendors/:vendorId/products/:productId`

**Selection algorithm (required):**

1. User picks one value per **required** axis (from `axes`).
2. Find the unique `variants[]` row where `attributes` matches those keys.
3. If none or `stockStatus === OUT_OF_STOCK` / `isAvailable === false` → disable Add to Cart.
4. Do **not** send `optionIds` for VARIANTS.

Optional UI: show “+BHD x.xxx” vs a default size/colour for marketing — **charged** price is always the selected variant’s absolute `price`.

### 5) Add to cart

```http
POST /cart/items
```

```json
{
  "productId": "<product id>",
  "variantId": "<selected variant id>",
  "quantity": 1,
  "options": { "addonIds": ["<optional addon ids>"] }
}
```

| Mode | Required | Forbidden |
|------|----------|-----------|
| `VARIANTS` | `variantId` | `options.optionIds` |
| `MODIFIERS` | (options as today) | `variantId` |

Cart line display: product name + variant `label` (e.g. `M / Navy`) + addon names from options snapshot.

---

## Stock & availability UX

| `stockStatus` | Suggested copy |
|---------------|----------------|
| `IN_STOCK` | In stock |
| `LOW_STOCK` | Low stock |
| `OUT_OF_STOCK` | Out of stock (grey out; not selectable) |

Threshold comes from store type (`lowStockThreshold`, default 5) — mobile does **not** recompute; trust `stockStatus`.

---

## Delivery / order mode (Fashion)

Fashion vendors are typically **Scheduled** (+ Pickup if flags allow).  
Do **not** assume Hot food on-demand UI for Fashion. Follow existing scheduled cart / delivery-fees customer handoff for fee lines when order type is scheduled delivery.

---

## Multi-store-type readiness (for app architecture)

Build **one** product/customize pipeline driven by `catalogMode` + `axes` / `uiHint`:

| Store type (examples) | Expected mode | Axes examples (admin-configured) |
|----------------------|---------------|----------------------------------|
| Food | `MODIFIERS` | (option groups — existing) |
| Fashion | `VARIANTS` | Size (PILL), Colour (SWATCH) |
| Electronics | `VARIANTS` | Storage, Colour, Condition, … |
| Pharmacy / Vape (SKU retail) | `VARIANTS` or still thin | TBD per Figma — same engine |

When you share **Figma for Electronics / Pharmacy / …**, backend mostly **configures axes + seeds** on that store type; mobile should already branch on `catalogMode` / `uiHint` without a new screen family per vertical (unless Figma invents a new pattern).

---

## Non-goals for mobile (this pack)

- Editing store-type attributes or catalog.
- Implementing Size×Colour stock math client-side beyond matching `variants[]`.
- Treating Fashion as a hardcoded special case instead of `catalogMode`.
- `HYBRID` mode.
- Renaming delivery “hot food” modes.

---

## Acceptance checklist (Fashion)

After migrate + seed:

- [ ] Fashion sub-cats show Clothes / Watches / Accessories / Shoes (not dummy placeholders)
- [ ] Clothes vendor list includes H&M with area/rating (Seef / 4.6 seed)
- [ ] H&M menu pills: Men / Women / Kids / Accessories; Oxford under Men/Shirts
- [ ] Product detail: Size pills + Colour swatches + Extras; OOS variants disabled
- [ ] Add to Cart sends `variantId`; total matches variant + extras
- [ ] Food vendor product detail still uses `optionGroups` (regression)
- [ ] Grid/list toggles work without API changes
- [ ] App branches on `catalogMode`, not `storeTypeSlug === 'fashion'` alone

---

## Deep links (optional)

| Intent | Suggested |
|--------|-----------|
| Fashion vertical | Home tile / `category=fashion` |
| Sub-category | `category=fashion&subcategory=<menuCategoryId\|slug>` |
| Vendor | `/vendors/hm` or vendor id |
| Product | `/vendors/:id/products/:productId` |

Exact deep-link scheme is owned by the mobile app; backend ids/slugs above are stable.

---

## When to ask backend again

- New `uiHint` values beyond `PILL` | `SWATCH` | `DROPDOWN`
- True matrix features not in `variants[]` (e.g. image per colour only) if missing in payload
- Checkout stock race / decrement UX copy (Batch 4)
- Home taxonomy endpoint gaps for store-type menu categories

Share **Figma per store type** when ready; we map screens → same handoff sections and extend `04` if fields change.
