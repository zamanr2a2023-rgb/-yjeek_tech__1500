# Electronics + High-Value Restrictions — Source of Truth

**Pack:** Multi-Store Catalog (`fashion-v1`).  
**UI:** Electronics Figma (vendor list, Sharaf DG vendor page, Galaxy A55 customize, High-Value notes).  
**Status:** **Done** (2026-09-26) — seed `seed-electronics.ts` + restrictions engine; covered in customer handoff `05`.

## Locked decisions

| Topic | Decision |
|-------|----------|
| Electronics catalog mode | **`VARIANTS`** — Storage × Colour axes; Extras = `ProductAddon` |
| Customize UI default | Prefer **list** layout for Storage/Colour (grid toggle is client-only) |
| Restrictions engine | **One engine** for `AGE_RESTRICTED` + `HIGH_VALUE` (+ future types) |
| Levels | `STORE_TYPE` → `VENDOR` → `BRANCH` → `CATALOG_CATEGORY` → `PRODUCT` |
| Conflicts | **Strictest wins** — if any ancestor enables a restriction, it applies (item cannot opt out) |
| Product badges | `HIGH_VALUE` / `AGE_RESTRICTED` on product still force that type on |
| Price threshold | Store-type `highValuePriceThreshold` (BHD): product `priceFrom` ≥ threshold ⇒ HIGH_VALUE |
| Champ PoD | HIGH_VALUE → OTP + named recipient (existing secure delivery). AGE → ID check (existing) |
| Champ eligibility | Driver flags `canDeliverHighValue` / `canDeliverAgeRestricted` (dispatch uses later) |

## Electronics seed (Sharaf DG)

| Surface | Data |
|---------|------|
| Vendor | Sharaf DG · Seef · rating 4.6 · Scheduled · min order BHD 5 |
| Pills | Phones, Laptops, Audio, Accessories |
| Phones children | SMARTPHONES, TABLETS |
| Hero SKU | Samsung Galaxy A55 — Storage × Colour variants + warranty extras |

### Variant price model (absolute)

Base **149.000** (128GB / Navy). Deltas from Figma baked into absolute prices:

| Storage | Colour extras | Example |
|---------|---------------|---------|
| 128GB | +0 | 149.000 |
| 256GB | +25 | 174.000 (+ colour) |
| 512GB | +55 | 204.000 — **out of stock** |

Colour: Navy +0; Ice Blue / Lilac / Lemon / Graphite +2.000 (Graphite OOS in seed).

Extras: 2-year warranty 19.000, Screen protector 3.500, Protective case 5.000.
