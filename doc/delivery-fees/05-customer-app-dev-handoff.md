# Customer App Dev Handoff — Delivery Fees v1

**For:** Customer mobile developers.  
**Not for:** Rider/driver apps (see `07`).  
**Phase:** Hot food on-demand (**D04 Done**; **Phase 1 Frozen — D09 Batch 1 re-audit 2026-09-26**) + scheduled delivery fees (**D06 Done**; **Scheduled Frozen — D09 Batch 3, 2026-09-26**). Mobile can implement against `04` §3 + Appendix A (hot food) and `04` §5 + Appendix B (scheduled).  
**Source of truth for rules:** OG HTML. This file translates UX expectations.  
**APIs:** `04-api-contracts.md` (sample payloads: Appendix A + B).

## What backend/admin will deliver

- Branch-aware delivery pricing (`delivery_fees_v1` or `legacy_flat`).
- Quote/checkout fields: single customer delivery fee (`delivery.fee`), `waived`, min/free `prompts`, plus top-level `serviceFee` amount (not nested under `delivery`).
- Order stores economics snapshot **server-side only** — customer cart/checkout/order JSON never includes `deliveryEconomicsSnapshot`, `breakdownInternal`, vendor contribution, or driver pay.
- Scheduled: flat fee by **selected speed tier × order item class** (Normal/Special). No distance in the fee line.

## What mobile must build (OG §11)

### A. Checkout / cart fee lines (exactly three money lines for fees area)

1. **Order amount** (items) — existing.
2. **Delivery fee** — **one** combined figure (extra km already included on hot food; scheduled is flat). Never show base vs extra km to the customer. Never show vendor contribution. Never show Normal vs Special as two fee lines.
3. **Service fee** — show the amount returned by API (may be `0.000` while formula is pending).

Do **not** show: commission, VAT on commission, gateway fees, custom fees, driver pay, Yjeek margin, dual-radius explanation.

### B. Live prompts

| Condition | UX |
|-----------|-----|
| `prompts.minOrder.blocksCheckout === true` | Block place-order; show `message` e.g. “Add BHD 1.250 more to place your order”. Server also rejects with **409** `MIN_ORDER_NOT_MET` — do not rely on UI alone. |
| `prompts.freeDelivery.message` present | Informational only; does not block (no `blocksCheckout` on this object) |

Use server-computed `shortfall` / `message` — do not re-implement currency math on device beyond display. Amounts are **3 decimal places** BHD. Canonical JSON: `04` Appendix A1–A2 (hot food) / B1–B4 (scheduled).

### C. Out of range (hot food only)

If `delivery.outOfRange === true`, the vendor/branch is **not orderable** for delivery at that address (OG: beyond max distance). Show the server message; do **not** treat `delivery.fee` as a payable free/zero line — place-order is rejected with **409** `OUT_OF_DELIVERY_RANGE` (`This address is outside the delivery area`). Prefer the server flag + error over client distance math. Sample: `04` Appendix A3.

Scheduled fee quotes always set `distanceKm: null` and `outOfRange: false` on the fee object (flat pricing). Separate vendor delivery-radius checks may still reject checkout.

### D. Legacy vendors

If `pricingModel === "legacy_flat"`, still show one delivery fee line. Prompts may be partial; do not assume dual-radius or class-based behaviour. Scheduled legacy uses speed-tier constants only (Appendix B5).

### E. Non-delivery modes

Pickup / dine-in / services: API returns `delivery: null` (absent). Do **not** show a delivery fee line. Do not invent delivery UI for services bookings. Numeric `summary.deliveryFee` remains `0` where totals still include the field. Sample: `04` Appendix A3.

### F. Scheduled delivery (D06 / OG §05) — **Frozen — 2026-09-26**

**Checkout / cart fee line**

- Keep existing speed-tier picker (`SAME_DAY` / `NEXT_DAY` / `STANDARD` / `ECONOMY`). Option chips may show a fee hint from `deliveryOptions[].fee`; **charged** fee is always `delivery.fee` / `summary.deliveryFee` for the selected tier.
- Server picks **one** order item class (`NORMAL` \| `SPECIAL`) from store-type / vendor enablement + cart lines — mobile does **not** choose the class for pricing and must not show vendor/class economics.
- Still **one** delivery fee number — Normal vs Special only changes which column the server used (B1 fee `0.900` vs B2 fee `2.000` on the Same-day OG fixture). Never split into two fee lines.
- `delivery.distanceKm` is `null`; do **not** invent a km line, radius, or per-km UI on scheduled.
- Multi-vendor scheduled cart: each vendor order is priced separately server-side; show per-group or cart summary fees as returned — do not re-sum with client formulas.

**Prompts (same rules as hot food)**

| Prompt | Behaviour | Sample |
|--------|-----------|--------|
| Min order | Block place-order when `blocksCheckout`; server **409** `MIN_ORDER_NOT_MET` | B3 |
| Free delivery shortfall | Informational only (`message` present) | B1 / B2 |
| Free delivery waive | `fee: "0.000"`, `waived: true`, `waiveReason: "free_delivery"`; do not expose vendor contribution | B4 |

Canonical shapes: `04` §5 + Appendix B1–B5.

## Non-goals for mobile (this pack)

- Editing delivery settings.
- Seeing vendor or driver economics.
- Implementing fee formulas client-side (including inventing class rates).
- Driver pay / eligibility UI (see `07` — D07 backend Done; driver app UI still out of this pack).

## Acceptance checklist for mobile

Wire UI to the frozen shapes in `04` §3 + Appendix A (hot food) and `04` §5 + Appendix B (scheduled).  
**Phase 1 items (hot food A1–A3) revalidated 2026-09-26** against live presenters.  
**Scheduled items (B1–B5) frozen 2026-09-26** against `quoteScheduledDeliveryFee` / `presentScheduledCustomerDelivery` (D09 Batch 3):

- [ ] Cart/checkout shows a single delivery fee matching `delivery.fee` (A1/A2 / B1–B2)
- [ ] Min-order prompt blocks checkout when API says so (A1 / B3 → 409 `MIN_ORDER_NOT_MET`)
- [ ] Free-delivery prompt is informational only (A2 / B1–B2; no place-order reject)
- [ ] No internal breakdown fields shown (`breakdownInternal`, snapshot, vendor contribution, driver pay)
- [ ] Legacy flat vendors still display a delivery fee without crashing (A + B5)
- [ ] Service fee line present even when amount is zero (top-level / `summary.serviceFee`)
- [ ] `outOfRange` / `OUT_OF_DELIVERY_RANGE` treated as not orderable (not as free delivery) (A3 — hot food; `distanceKm > maxDistanceKm`)
- [ ] Pickup / dine-in / services hide delivery fee when `delivery` is null (A3)
- [ ] Scheduled tier change updates the single `delivery.fee` from the server (B1/B2); no distance line on scheduled
- [ ] Scheduled Normal vs Special still renders **one** fee line (B1 vs B2) — never two class columns
- [ ] Scheduled free-delivery waive shows `fee: "0.000"` + `waived` without exposing vendor contribution (B4)

## Deep links

None required for Phase 1 fee settings.
