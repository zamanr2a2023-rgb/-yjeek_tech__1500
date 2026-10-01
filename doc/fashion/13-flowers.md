# Flowers — Source of Truth

**Pack:** Multi-Store Catalog (`fashion-v1`).  
**UI:** Flowers Figma (vendor list, Bloom Bahrain vendor page, Classic Red Roses customize).  
**Status:** **Done** (2026-09-26) — seed `seed-flowers.ts`; covered in customer handoff `05`.

## Locked decisions

| Topic | Decision |
|-------|----------|
| Store type | New **`flowers`** (`STORE_TYPE`) — distinct from legacy `gifts` / Floward |
| Catalog mode | **`VARIANTS`** — bouquet **size** axis; Extras = `ProductAddon` |
| Delivery | Scheduled (matches Figma banner) |
| Age / high-value | Not required for Flowers v1 |

## Seed (Bloom Bahrain)

| Surface | Data |
|---------|------|
| Vendor | Bloom Bahrain · Seef · 4.8 · Scheduled · min BHD 5 |
| Pills | Bouquets, Boxes, Plants, Occasions |
| Bouquets children | ROSES, SEASONAL |
| Hero | Classic Red Roses — size variants + greeting card / vase / chocolate extras |

### Size prices (absolute, base 18.000)

| Size | Price | Stock |
|------|-------|-------|
| Small | 18.000 | in stock |
| Medium | 18.000 | in stock |
| Large | 26.000 | in stock |
| Grand | 36.000 | **out of stock** |

Extras: Greeting card 1.500, Glass vase 6.000, Chocolate box 8.000.
