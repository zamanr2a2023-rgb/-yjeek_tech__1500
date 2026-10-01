# Vape + Age Verification (18+) — Source of Truth

**Pack:** extends Multi-Store Catalog (`fashion-v1`). Store type remains the source of truth.  
**UI source:** Vape Figma screens (vendor list, vendor page, item page, ID verify 6–12).  
**Status:** **Done** (2026-09-26) — seed `seed-vape.ts` + age-verification APIs; covered in customer handoff `05`.

## Locked decisions

| Topic | Decision |
|-------|----------|
| Vape catalog mode | **`VARIANTS`** — e.g. Nicotine strength as one axis; Extras = `ProductAddon` |
| Age rule ownership | **Store type** flags: `requiresAgeVerification`, `minimumAge` (18), `champMustCheckId` |
| Vendor flag | Set `Vendor.ageRestricted=true` when store type requires age (seed + admin sync later) |
| Item page CTA | Unverified → **Verify your age** (not Add to Cart). Verified 18+ → normal Add to Cart |
| ID provider | **Pluggable**. Stub provider for now (instant simulate). Swap later via settings |
| CPR uniqueness | One verified CPR → one customer account (`ID_ALREADY_USED`) |
| Under 18 | `idStatus=REJECTED`, reason `UNDER_18`; 18+ catalog stays locked; rest of app OK |
| Champ door check | Orders with age-restricted vendors/items still require driver ID check (existing delivery flow) |
| Checkout gate | Existing `AGE_VERIFICATION_REQUIRED` when `vendor.ageRestricted` and not verified |
| Food / Fashion | Unchanged unless their store type enables age flags |

## Nicotine pricing (Cloud Nine seed — matches Figma)

Base display **BHD 12.500**; absolute variant prices:

| Strength | Price | Stock |
|----------|-------|-------|
| 0mg, 3mg, 6mg | 12.500 | in stock |
| 12mg | 12.750 | in stock |
| 20mg | 13.000 | **out of stock** |

Extras: Extra coil pack 4.500, Carry case 2.000, Lanyard 1.000.

## Customer API surface (age)

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/users/me/age-verification` | Status for product CTA / banners |
| POST | `/users/me/age-verification` | Submit front/back + consent → verify (stub) |

Product / vendor payloads include `ageRestriction` block when store type or vendor requires it.

## Reject codes

`UNDER_18` | `ID_ALREADY_USED` | `EXPIRED` | `UNREADABLE` | `PROVIDER_ERROR`
