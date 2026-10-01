# Customer App Dev Handoff — Services v1

**Status:** **Frozen** (S06).  
**Rules:** `00-source-of-truth-and-rules.md`.  
**Shapes:** `04-api-contracts.md` (**Frozen**) + `samples/`.

## One rule

**Service mode = booking**, not a goods cart. Branch on store-type `services: true` / `isBookable` — never hardcode slug alone.

| Step | API / behaviour |
|------|-----------------|
| Sub-cats | Services TWO_LEVEL children: Cleaning, AC & Plumbing, Beauty & Salon, Car Services — list/grid client-only |
| Providers | `GET /vendors?category=services&subcategory=cleaning` — sorted by `nextAvailableAt`; sink `fullyBooked` |
| Provider menu | Same menu/product APIs; `catalogMode=MODIFIERS`; `ageRestriction.required=false` |
| Booking page | Options + `GET …/booking-slots?date=&durationMin=` + address if AT_HOME |
| Cart | Always `?type=SERVICE`; `delivery` is `null` |
| Checkout | `orderType=SERVICE`, `serviceFulfillmentMode`, `scheduledAt` (+ `addressId` for AT_HOME) |
| Cancel | Existing cancel quote/API — SERVICE uses platform `cancelWindowHours` / `cancelFeePercent`. Reschedule UI: hide (`rescheduleSupported: false`) |

## UX notes

- Do **not** show delivery ETA / food fee quote for Services.
- AT_HOME: address must match a covered area (`area` preferred over `city`); show call-out fee from slots payload.
- Slot list empty → show blocked / outside window / closed day messaging from API `reason` when present.
- Option groups + addons drive price; duration from `prepTimeMin` (+ option deltas if product has them).

## Demo vendors

| Vendor | Sub-cat | Modes | Notes |
|--------|---------|-------|-------|
| **Sparkle Home** (`sparkle-home`) | Cleaning | AT_HOME | Buffer 30; covered Seef/Manama/Juffair; call-out on Manama/Juffair |
| **Glow Beauty** (`glow-beauty`) | Beauty & Salon | IN_SALON | Haircut & Blow Dry → Short + Treatment mask = BHD 20.000 |

## Samples index

See `samples/` (`01-browse` … `17-cart`). Checkout: `15-checkout-glow-in-salon.json`, `16-checkout-sparkle-at-home.json`.
