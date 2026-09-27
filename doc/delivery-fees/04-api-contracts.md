# API Contracts — Delivery Fees v1

**Audience:** Backend implementers + customer/driver mobile teams.  
**Status:** Phase 1 **customer quote/checkout contract is Frozen** (D04 Done; **D09 Batch 1 re-audit 2026-09-26** — §3 + Appendix A still match live `quoteDeliveryFee` / `presentCustomerDelivery` / cart / checkout / `createOrder`). **Item class + Menu Settings (D05) Frozen** — §2b (D09 Batch 2, 2026-09-26). **Scheduled (D06) Frozen** — §5 + Appendix B (D09 Batch 3, 2026-09-26). **Driver rates + champ eligibility (D07) Frozen** — §6 + Appendix C (D09 Batch 4, 2026-09-26). **Commission / vendor settlement (D08) Frozen** — §6b + Appendix D (D09 Batch 5, 2026-09-26); admin-only; **no customer-facing total or line-item changes**. Mobile may implement hot-food against §3 + Appendix A and scheduled against §5 + Appendix B. Driver payout UX → `07-driver-app-dev-handoff.md`. Admin commission → `06-admin-console-dev-handoff.md`.  
**Source:** OG §01–§12.  
**Currency:** BHD, 3 decimal places (strings in JSON preferred, matching existing money style).  
**Auth:** Admin JWT for admin routes; customer Bearer JWT for customer routes; driver Bearer JWT for `/drivers/*`.  
**Base path:** Existing API prefix (e.g. `/api/v1`). Keep resource names stable when implementing.  
**Handoff:** Customer UX expectations → `05-customer-app-dev-handoff.md`. Admin → `06-admin-console-dev-handoff.md`. Driver → `07-driver-app-dev-handoff.md`.

---

## Conventions

| Concept | Contract meaning |
|---------|------------------|
| `pricingModel` | `"legacy_flat"` \| `"delivery_fees_v1"` — which path priced the order |
| Distance | Kilometers, decimal; server computes from branch → drop-off |
| Max contribution | Never accepted as an input — always computed server-side |
| Snapshot | Frozen economics blob on the order at checkout; settlement reads this, not live settings |

---

## 1. Admin — Store-type delivery defaults (D01)

### `GET /admin/store-types/:storeTypeId/delivery-defaults`

Returns defaults for modes Yjeek delivers, plus allowed vehicles and (later) item-class flags.

**Response (Phase 1 shape):**

```json
{
  "storeTypeId": "…",
  "allowedVehicles": { "bike": true, "car": true },
  "enabledOrderModes": ["HOT_FOOD_ON_DEMAND", "SCHEDULED", "PICKUP", "DINE_IN"],
  "hotFoodOnDemand": {
    "vendor": {
      "radiusKm": "8.00",
      "etaMin": 25,
      "minOrderAmount": "3.000",
      "contribution": "0.300",
      "freeDeliveryEnabled": true,
      "freeDeliveryOver": "8.000",
      "maxDistanceKm": "12.00",
      "extraPerKm": "0.100",
      "serviceFeeContribution": null
    },
    "customer": {
      "radiusKm": "4.00",
      "contribution": "0.650",
      "extraPerKm": "0.050",
      "serviceFeeContribution": null
    }
  },
  "scheduled": {
    "tiers": {
      "SAME_DAY": {
        "vendorNormal": "0.200",
        "vendorSpecial": "0.400",
        "customerNormal": "1.500",
        "customerSpecial": "2.250",
        "minOrderAmount": "3.000",
        "freeDeliveryEnabled": true,
        "freeDeliveryOver": "10.000"
      },
      "NEXT_DAY": { "…": "…" },
      "STANDARD": { "…": "…" },
      "ECONOMY": { "…": "…" }
    }
  },
  "driverRates": {
    "onDemand": {
      "bikeBase": "0.900",
      "carBase": "0.950",
      "freeRadiusKm": "9.00",
      "extraPerKm": "0.075"
    },
    "scheduledBike": {
      "tiers": {
        "SAME_DAY": { "normal": "1.500", "special": "3.500" },
        "NEXT_DAY": { "normal": null, "special": null },
        "STANDARD": { "normal": null, "special": null },
        "ECONOMY": { "normal": null, "special": null }
      }
    },
    "scheduledCar": {
      "tiers": {
        "SAME_DAY": { "normal": "2.000", "special": "4.000" },
        "NEXT_DAY": { "normal": null, "special": null },
        "STANDARD": { "normal": null, "special": null },
        "ECONOMY": { "normal": null, "special": null }
      }
    }
  }
}
```

Notes:

- `customer.maxDistanceKm` is not stored separately — mirrors vendor max distance (OG §02).
- `scheduled` may be `null` until admin PUTs rates (empty policy — do not invent zeros). Shape is flat per speed tier × class — **no** radius / per-km / max distance (OG §05 / §12 rule 10).
- `driverRates` may be `null` until admin PUTs rates (D07). Empty policy — do not invent zeros. Shape: on-demand (`bikeBase`/`carBase`/`freeRadiusKm`/`extraPerKm`) + separate `scheduledBike` / `scheduledCar` flat grids × tier × Normal/Special — **no** distance on scheduled grids (OG §06). Scheduled distance keys on write → 400.
- Pickup / Dine-in / Services have **no** fee objects.
- **Empty policy (D01 Batch 5):** New store types do not auto-seed money. Until admin PUTs rates, `hotFoodOnDemand` / `scheduled` / `driverRates` may be `null` (not zeroed placeholders). Allowed vehicles may still default to bike/car `true` on read.

### `PUT /admin/store-types/:storeTypeId/delivery-defaults`

Body mirrors GET (partial allowed). Server recalculates derived max contributions for validation/preview only; does not persist max as an input field.

**Side effect:** Does **not** update existing vendors/branches (OG §12 rule 2).

### `PUT /admin/store-types/:storeTypeId/allowed-vehicles`

```json
{ "bike": true, "car": false }
```

Vendor may narrow further later; never widen beyond store type.

---

## 2. Admin — Branch delivery settings (D02)

### `GET /admin/vendors/:vendorId/locations/:locationId/delivery-settings`

```json
{
  "pricingModel": "delivery_fees_v1",
  "modes": {
    "HOT_FOOD_ON_DEMAND": { "enabled": true, "seeded": true },
    "SCHEDULED": { "enabled": false, "seeded": false },
    "PICKUP": { "enabled": true },
    "DINE_IN": { "enabled": false },
    "SERVICES": { "enabled": false, "supportedByStoreType": false }
  },
  "hotFoodOnDemand": {
    "vendor": {
      "radiusKm": { "value": "5.00", "state": "overridden", "defaultValue": "8.00" },
      "etaMin": { "value": 30, "state": "overridden", "defaultValue": 25 },
      "minOrderAmount": { "value": "3.000", "state": "inherited", "defaultValue": "3.000" },
      "contribution": { "value": "0.300", "state": "inherited", "defaultValue": "0.300" },
      "freeDeliveryEnabled": { "value": true, "state": "inherited", "defaultValue": true },
      "freeDeliveryOver": { "value": "8.000", "state": "inherited", "defaultValue": "8.000" },
      "maxDistanceKm": { "value": "12.00", "state": "inherited", "defaultValue": "12.00" },
      "extraPerKm": { "value": "0.100", "state": "inherited", "defaultValue": "0.100" },
      "serviceFeeContribution": { "value": null, "state": "inherited", "defaultValue": null }
    },
    "customer": {
      "radiusKm": { "value": "4.00", "state": "inherited", "defaultValue": "4.00" },
      "contribution": { "value": "0.650", "state": "inherited", "defaultValue": "0.650" },
      "extraPerKm": { "value": "0.050", "state": "inherited", "defaultValue": "0.050" },
      "serviceFeeContribution": { "value": null, "state": "inherited", "defaultValue": null }
    },
    "computed": {
      "vendorMaxContribution": "1.000",
      "customerMaxContribution": "1.050",
      "customerMaxDistanceKm": "12.00"
    }
  },
  "scheduled": {
    "tiers": {
      "SAME_DAY": {
        "vendorNormal": { "value": "0.200", "state": "inherited", "defaultValue": "0.200" },
        "vendorSpecial": { "value": "0.400", "state": "inherited", "defaultValue": "0.400" },
        "customerNormal": { "value": "1.500", "state": "overridden", "defaultValue": "1.500" },
        "customerSpecial": { "value": "2.250", "state": "inherited", "defaultValue": "2.250" },
        "minOrderAmount": { "value": "3.000", "state": "inherited", "defaultValue": "3.000" },
        "freeDeliveryEnabled": { "value": true, "state": "inherited", "defaultValue": true },
        "freeDeliveryOver": { "value": "10.000", "state": "inherited", "defaultValue": "10.000" }
      },
      "NEXT_DAY": { "…": "…" },
      "STANDARD": { "…": "…" },
      "ECONOMY": { "…": "…" }
    }
  },
  "driverRates": {
    "onDemand": {
      "bikeBase": { "value": "0.900", "state": "inherited", "defaultValue": "0.900" },
      "carBase": { "value": "0.950", "state": "overridden", "defaultValue": "0.950" },
      "freeRadiusKm": { "value": "9.00", "state": "inherited", "defaultValue": "9.00" },
      "extraPerKm": { "value": "0.075", "state": "inherited", "defaultValue": "0.075" }
    },
    "scheduledBike": {
      "tiers": {
        "SAME_DAY": {
          "normal": { "value": "1.500", "state": "inherited", "defaultValue": "1.500" },
          "special": { "value": "3.500", "state": "inherited", "defaultValue": "3.500" }
        },
        "NEXT_DAY": { "…": "…" },
        "STANDARD": { "…": "…" },
        "ECONOMY": { "…": "…" }
      }
    },
    "scheduledCar": {
      "tiers": {
        "SAME_DAY": {
          "normal": { "value": "2.000", "state": "inherited", "defaultValue": "2.000" },
          "special": { "value": null, "state": "inherited", "defaultValue": null }
        },
        "NEXT_DAY": { "…": "…" },
        "STANDARD": { "…": "…" },
        "ECONOMY": { "…": "…" }
      }
    }
  },
  "allowedVehicles": {
    "bike": { "value": true, "state": "inherited", "defaultValue": true },
    "car": { "value": false, "state": "overridden", "defaultValue": true }
  }
}
```

Notes (scheduled panel — D06):

- First enable `SCHEDULED` seeds once from store-type defaults (empty grid allowed — null rates, never invent zeros). Re-enable keeps edits.
- Per-field inheritance + reset paths like `scheduled.tiers.SAME_DAY.customerNormal`.
- **No** `radiusKm` / `extraPerKm` / `maxDistanceKm` on scheduled — rejected on write.
- `scheduled` is `null` when mode never seeded.

Notes (driver rates / vehicles — D07):

- `driverRates` + `allowedVehicles` seed on first HOT_FOOD / SCHEDULED enable (same copy-on-create as fee panels) from store-type defaults; empty store-type → empty null grid (never invent).
- Re-enable keeps overrides (OG §02 rule 2).
- Separate `scheduledBike` / `scheduledCar` grids — never a shared scheduled set; distance keys on scheduled driver grids → 400.
- Reset paths: `driverRates.onDemand.bikeBase`, `driverRates.scheduledBike.tiers.SAME_DAY.normal`, `allowedVehicles.bike`.
- Vendor/branch may set a vehicle to `false`; enabling a vehicle disallowed by store type → 400 (`Vendor cannot widen vehicles beyond store type`).

### `PUT /admin/vendors/:vendorId/locations/:locationId/delivery-settings`

- Toggle mode on → if not yet seeded, copy store-type defaults for that mode once.
- Toggle off → hide panel; **keep** stored values.
- Field write sets `state: overridden` for that field.
- Reject turning off the last enabled mode.
- Reject enabling a mode not supported by store type.
- **Empty store-type defaults (D01 Batch 5):** Hot food first-enable requires either present store-type `hotFoodOnDemand` defaults **or** a complete explicit hot-food body on the enable request. Do not invent zeroed rates. Stable error: `Cannot enable Hot food on demand: store-type delivery defaults are empty. Set Hot food defaults on the store type (Admin › Store Management), or provide complete hot-food fee values on this branch when enabling.` (`resolveHotFoodSeedSource` in delivery-defaults service).

### `POST /admin/vendors/:vendorId/locations/:locationId/delivery-settings/reset-field`

```json
{ "path": "hotFoodOnDemand.vendor.radiusKm" }
```

Restores `defaultValue` and sets `state: inherited`. Scheduled paths use the same endpoint, e.g. `"scheduled.tiers.SAME_DAY.customerNormal"`. Driver-rate paths: `"driverRates.onDemand.bikeBase"`, `"driverRates.scheduledBike.tiers.SAME_DAY.normal"`, `"allowedVehicles.bike"`.

### `GET /admin/vendors/:vendorId/delivery-settings`

Vendor **template** (not live checkout). Same mode/hot-food shape as branch GET, plus:

```json
{
  "role": "vendor_template",
  "checkoutSource": "branch",
  "hasStoredTemplate": false,
  "storeTypeName": "Food",
  "modes": { "...": "..." },
  "hotFoodOnDemand": { "...": "..." },
  "scheduled": { "tiers": { "…": "…" } }
}
```

When no stored template yet, response may present an ephemeral seed from store-type defaults (`hasStoredTemplate: false`) without writing the DB. `scheduled` may still be `null` until seeded.

### `PUT /admin/vendors/:vendorId/delivery-settings`

Saves `Vendor.deliverySettingsV1` template (same body rules as branch PUT for modes / hotFoodOnDemand).

### `POST /admin/vendors/:vendorId/delivery-settings/reset-field`

Same body as branch reset-field; mutates the vendor template only.

### `POST /admin/vendors/:vendorId/delivery-settings/push-to-branches`

```json
{ "confirm": true }
```

Pushes vendor template delivery settings to all **active** branches. **Requires** `confirm: true` (UI confirmation). Overwrite policy (D02 Batch 5 / 09 #5): **all pushed fields** (modes + hotFoodOnDemand + scheduled + driverRates + allowedVehicles when present); branch fields rebaselined; legacy branches flip to `delivery_fees_v1`. Checkout continues to read each **branch**.

### Store-type change on vendor

### `PATCH /admin/vendors/:vendorId` (existing) — when `storeTypeId` changes

Require explicit choice:

```json
{
  "storeTypeId": "…",
  "deliverySettingsOnStoreTypeChange": "load_defaults" | "keep_current"
}
```

Return override count in a preview endpoint if useful:

### `GET /admin/vendors/:vendorId/delivery-settings/store-type-change-preview?toStoreTypeId=`

```json
{ "overriddenFieldCount": 2, "modesRemoved": ["DINE_IN"] }
```

---

## 2b. Admin — Item classes & Menu Settings (D05)

**Freeze stamp (D05 / D09 Batch 2):** **Frozen — 2026-09-26.** Admin-only. Vendor panel never exposes class UI (OG §03–§04 / §11). Cascade helper: `item-class.resolver.ts` (`effectiveItemClass`, `lockedBy`, `editableAt`, `resolveCartItemClass`).

### Store-type flags + convert (OG §03)

### `GET /admin/store-types/:storeTypeId`

Includes:

```json
{
  "itemClasses": {
    "allowsNormalItems": true,
    "allowsSpecialItems": true
  }
}
```

### `PATCH /admin/store-types/:storeTypeId`

Body (partial). At least one class must stay on.

```json
{
  "allowsNormalItems": true,
  "allowsSpecialItems": false,
  "confirmConvert": true,
  "convertAction": "convert_to_normal"
}
```

- Narrowing with impact **requires** `confirmConvert: true` + matching `convertAction` (`convert_to_normal` \| `convert_to_special`). Without → **400** (call preview first).
- Confirm cascades: store-type flags → all vendors under type → all catalog categories + products to the remaining class.

### `GET /admin/store-types/:storeTypeId/item-classes/convert-preview?disable=SPECIAL|NORMAL`

```json
{
  "disable": "SPECIAL",
  "remaining": "NORMAL",
  "convertAction": "convert_to_normal",
  "vendorCount": 2,
  "categoryCount": 5,
  "itemCount": 40
}
```

Counts = rows that **would change**. Auth: `STORE_MANAGEMENT` VIEW (router default).

### Vendor enablement (admin only)

### `PATCH /admin/vendors/:vendorId`

```json
{ "allowsNormalItems": true, "allowsSpecialItems": false }
```

Editable only when store type allows **both**; cannot widen beyond store type; at least one class must stay on.

### Menu Settings catalog (OG §04)

Mounted under `/admin/stores` (`admin-panel.routes` → `stores`).

| Method | Path | Class fields |
|--------|------|--------------|
| `GET` | `/admin/stores/vendors/:vendorId/catalog` | `vendor.itemClasses`, `vendor.storeType.itemClasses`; each category/product: `itemClass`, `effectiveItemClass`, `lockedBy` (`STORE_TYPE` \| `VENDOR` \| `CATEGORY` \| null), `editable` |
| `POST` | `/admin/stores/vendors/:vendorId/catalog-categories` | optional `itemClass`: `NORMAL` \| `SPECIAL` \| `null` (`null` = both open when editable) |
| `PATCH` | `/admin/stores/vendors/:vendorId/catalog-categories/:categoryId` | same `itemClass` |
| `POST` | `/admin/stores/vendors/:vendorId/products` | optional `itemClass`: `NORMAL` \| `SPECIAL` |
| `PATCH` | `/admin/stores/products/:productId` | optional `itemClass`: `NORMAL` \| `SPECIAL` (+ options/addons for full Menu edit) |

**Catalog GET sample (class meta only):**

```json
{
  "vendor": {
    "itemClasses": { "allowsNormalItems": true, "allowsSpecialItems": true },
    "storeType": {
      "itemClasses": { "allowsNormalItems": true, "allowsSpecialItems": true }
    }
  },
  "catalogCategories": [
    {
      "id": "…",
      "itemClass": null,
      "effectiveItemClass": "NORMAL",
      "lockedBy": null,
      "editable": true
    }
  ],
  "products": [
    {
      "id": "…",
      "itemClass": "SPECIAL",
      "effectiveItemClass": "SPECIAL",
      "lockedBy": null,
      "editable": true
    }
  ]
}
```

Locked writes (`editable: false`) are rejected server-side. Special-only vendor → item class selectors disabled in admin UI (still display `effectiveItemClass`).

---

## 3. Fee quote (customer + admin preview) — D03 / D04

**Freeze stamp (Phase 1 / D09 Batch 1):** **Frozen — 2026-09-26.** Hot-food customer `pricingModel` + `delivery` shape (§3 + Appendix A) re-audited against live cart/checkout/`createOrder` presenters after D05–D08. No customer-facing shape changes from later milestones. Mobile may keep implementing against this section.

**Shipped (D03):** One module prices delivery — `resolveDeliveryFee` → `quoteDeliveryFee` / `presentCustomerDelivery`. Cart, checkout, direct `createOrder`, and admin preview all call the same path.

### Extend cart / checkout quote

Existing cart/checkout responses **must** include (Phase 1). Customer presenter **omits** `breakdownInternal`. Cart also keeps existing numeric totals (`deliveryFee`, `serviceFee`, …) — not a nested `serviceFee` object on the quote. Checkout and direct create-order also return top-level `pricingModel` + `delivery` (same customer shape) and **omit** `deliveryEconomicsSnapshot`.

```json
{
  "pricingModel": "delivery_fees_v1",
  "delivery": {
    "fee": "0.750",
    "waived": false,
    "waiveReason": null,
    "distanceKm": "6.00",
    "outOfRange": false,
    "prompts": {
      "minOrder": {
        "required": "3.000",
        "shortfall": "0.000",
        "blocksCheckout": false,
        "message": null
      },
      "freeDelivery": {
        "threshold": "8.000",
        "shortfall": "3.000",
        "message": "Add BHD 3.000 to get free delivery"
      }
    }
  }
}
```

Notes:

- Customer sees **one** delivery fee number (`delivery.fee`). Never show vendor contribution / breakdown / driver pay / commission.
- Service fee line uses the existing top-level `serviceFee` (and `summary.serviceFee` on cart) money field — not nested under `delivery`.
- `outOfRange: true` when `distanceKm > vendor.maxDistanceKm`. Checkout / `createOrder` reject with **409** `OUT_OF_DELIVERY_RANGE` and message `This address is outside the delivery area` (does not place the order). Quote still returns a **non-zero** computed `delivery.fee` when out of range — never a silent `0.000` / free-delivery waive (D04 Batch 3).
- Free-delivery prompt is omitted when `outOfRange` (vendor not orderable).
- `waiveReason` is `"free_delivery"` or `null`.
- `prompts` are server-authored (D04 Batch 2). Min-order uses OG copy with **3 dp BHD**. Free-delivery shortfall is informational only (no `blocksCheckout` on that object).
- Place-order: when `prompts.minOrder.blocksCheckout === true`, `POST /cart/checkout` and direct `createOrder` reject with **409** `MIN_ORDER_NOT_MET` (message = prompt `message`). Free-delivery shortfall never rejects.
- Prompts apply to **delivery** only. Pickup / dine-in / services: top-level `delivery` is **`null`** (absent, not an empty/zero fee object — D04 Batch 3).
- Platform `serviceFee` remains the existing cart/order numeric total field; delivery **serviceFeeContribution** formula is still pending Yjeek (`09`).

### Legacy path

When branch is not on `delivery_fees_v1`:

```json
{
  "pricingModel": "legacy_flat",
  "delivery": {
    "fee": "0.450",
    "waived": false,
    "waiveReason": null,
    "distanceKm": "3.00",
    "outOfRange": false,
    "prompts": {
      "minOrder": null,
      "freeDelivery": {
        "threshold": "10.000",
        "shortfall": "5.000",
        "message": "Add BHD 5.000 to get free delivery"
      }
    }
  }
}
```

Cart legacy flat fee is `0.450` with free-delivery min `10` until the branch migrates. Direct `createOrder` uses `Vendor.deliveryFee` as the legacy flat amount.

### Admin fee preview (D03)

### `POST /admin/vendors/:vendorId/locations/:locationId/delivery-fee/preview`

Auth: `VENDOR_MANAGEMENT` VIEW (router default). Exact `locationId` required (404 if missing — no primary fallback).

**Body:**

```json
{ "distanceKm": 6.2, "itemsNet": 5 }
```

**Response** — same calculator as checkout; delivery includes `breakdownInternal` (string money):

```json
{
  "pricingModel": "delivery_fees_v1",
  "locationId": "…",
  "delivery": {
    "fee": "0.750",
    "waived": false,
    "waiveReason": null,
    "distanceKm": "6.20",
    "outOfRange": false,
    "prompts": { "minOrder": { "…": "…" }, "freeDelivery": { "…": "…" } },
    "breakdownInternal": {
      "customerBase": "0.650",
      "customerExtraKm": "0.100",
      "vendorContribution": "0.300",
      "vendorExtraKm": "0.000"
    }
  }
}
```

For `legacy_flat`, `breakdownInternal` is `null`.

### Hot-food math (server)

```text
# Vendor side
vendor_extra_km = max(0, distance - vendor.radiusKm)
vendor_pay = vendor.contribution + vendor_extra_km * vendor.extraPerKm
# capped conceptually by computed max; still compute from formula

# Customer side
if freeDeliveryEnabled and items_net >= freeDeliveryOver:
    customer_fee = 0
else:
    customer_extra_km = max(0, distance - customer.radiusKm)
    customer_fee = customer.contribution + customer_extra_km * customer.extraPerKm

# Hard stop
if distance > vendor.maxDistanceKm: outOfRange; checkout → 409 OUT_OF_DELIVERY_RANGE
```

Scheduled path: **do not** reuse this function (D06). `resolveDeliveryFee` rejects `SCHEDULED` mode.

---

## 4. Order snapshot (D03)

On successful on-demand checkout / `createOrder`, persist `Order.deliveryEconomicsSnapshot` (Json). **Customer** cart, checkout, list/get order, and create-order responses **omit** the snapshot (and never expose `breakdownInternal` / vendor contribution / driver pay) — OG §11 / D04 Batch 1. Admin fee preview keeps `breakdownInternal`. Settlement reads the column server-side only.

**v1 example:**

```json
{
  "pricingModel": "delivery_fees_v1",
  "mode": "HOT_FOOD_ON_DEMAND",
  "distanceKm": "6.00",
  "vehicle": null,
  "itemClass": null,
  "settings": {
    "locationId": "…",
    "hotFood": { "vendor": { "…": "…" }, "customer": { "…": "…" } },
    "minOrderAmount": 3
  },
  "resolved": {
    "customerFee": "0.750",
    "vendorContribution": "0.300",
    "driverPay": null,
    "serviceFee": "0.150",
    "waived": false,
    "waiveReason": null,
    "outOfRange": false,
    "breakdownInternal": {
      "customerBase": 0.65,
      "customerExtraKm": 0.1,
      "vendorContribution": 0.3,
      "vendorExtraKm": 0
    }
  },
  "capturedAt": "2026-09-25T12:00:00.000Z"
}
```

**Legacy policy:** Always write `{ "pricingModel": "legacy_flat", … }` for on-demand/create paths — never leave the column null for legacy. Settings shape uses `legacyDeliveryFee` + `freeDeliveryOver` instead of `hotFood`.

**Scheduled (D06):** Written via `buildScheduledDeliveryEconomicsSnapshot` on scheduled cart checkout and on-demand cart checkout with `fulfillmentType: SCHEDULED`. Customer APIs still **omit** the column. `distanceKm` is always `null` (flat fees). `itemClass` is `NORMAL` \| `SPECIAL` from `resolveCartItemClass`. `driverPay` is `null` at checkout (vehicle unknown).

**Driver pay (D07):** Checkout still writes `driverPay: null` / `vehicle: null`. At offer create, offer accept, and admin reassign, server calls `resolveDriverPay` + `applyDriverPayToSnapshot` and freezes `vehicle`, `resolved.driverPay`, and `resolved.driverPayBreakdown`. Settlement (`completeDelivery` / age-return) reads `readSnapshotDriverPay(snapshot)` first — never live branch rates. Null rate cells → unpriced leg (`driverPay` stays null; job may fall back to legacy earnings only if unpriced).

**v1 scheduled example (checkout — driverPay still null; OG §05 Same-day placeholder rates):**

```json
{
  "pricingModel": "delivery_fees_v1",
  "mode": "SCHEDULED",
  "distanceKm": null,
  "vehicle": null,
  "itemClass": "SPECIAL",
  "speedTier": "SAME_DAY",
  "settings": {
    "locationId": "…",
    "scheduled": {
      "vendorNormal": 0.5,
      "vendorSpecial": 1.5,
      "customerNormal": 0.9,
      "customerSpecial": 2.0,
      "minOrderAmount": 3,
      "freeDeliveryEnabled": true,
      "freeDeliveryOver": 8
    },
    "speedTier": "SAME_DAY"
  },
  "resolved": {
    "customerFee": "2.000",
    "vendorContribution": "1.500",
    "driverPay": null,
    "serviceFee": "0.300",
    "waived": false,
    "waiveReason": null,
    "outOfRange": false,
    "breakdownInternal": {
      "flat": true,
      "customerRate": 2,
      "vendorRate": 1.5
    }
  },
  "capturedAt": "2026-09-25T15:00:00.000Z"
}
```

**Legacy scheduled settings** use `legacyScheduledFee` + `speedTier` instead of `scheduled` rates (constants from `SCHEDULED_DELIVERY_FEES`).

`vehicle` is null at checkout (unknown until assignment). Hot-food / on-demand snapshots keep `itemClass: null` (distance path does not use class). After assignment, see Appendix C for filled `driverPay` / `driverPayBreakdown`.

Settlement, disputes, refunds, and cancel economics **read the snapshot**, never live branch settings.

---

## 5. Scheduled delivery fees (D06) — **Frozen — 2026-09-26** (D09 Batch 3)

Flat rate per **speed tier × item class**. No radius, per-km, or max distance for vendor, customer, or driver on this path. Do **not** call `resolveDeliveryFee` for scheduled — it rejects `SCHEDULED`.

**Freeze audit:** Customer shapes from `quoteScheduledDeliveryFee` / `presentScheduledCustomerDelivery`; samples use OG §05 Same-day placeholder rates (same fixture as `scheduled-delivery-fee-calculator.test.ts`). Full Normal vs Special + prompt samples → Appendix B.

### Calculator + quote modules

| Piece | Path |
|-------|------|
| Pure calculator | `resolveScheduledDeliveryFee` — `scheduled-delivery-fee.calculator.ts` |
| Cart/checkout quote | `quoteScheduledDeliveryFee` / `presentScheduledCustomerDelivery` — `scheduled-delivery-fee.quote.ts` |
| Item class | `resolveCartItemClass` — `item-class.resolver.ts` (one class per vendor order) |
| Snapshot | `buildScheduledDeliveryEconomicsSnapshot` — `delivery-fee.snapshot.ts` |

**v1 detector:** `VendorLocation.deliveryPricingModel === "delivery_fees_v1"` **and** `deliverySettingsV1.modes.SCHEDULED.seeded`. Otherwise `legacy_flat` → `SCHEDULED_DELIVERY_FEES[speed]` (class ignored).

**Empty-rate policy:** v1 + seeded with null class columns → **400** (never invent `0`, never silent legacy fallback).

### Sample fixture (Same day — illustrative)

| Field | Value |
|-------|-------|
| `vendorNormal` / `vendorSpecial` | `0.500` / `1.500` |
| `customerNormal` / `customerSpecial` | `0.900` / `2.000` |
| `minOrderAmount` | `3.000` |
| `freeDeliveryEnabled` / `freeDeliveryOver` | `true` / `8.000` |

Live branch rates are admin-configured; numbers below are what the calculator returns for this fixture.

### Customer scheduled quote (same `delivery` shape as §3)

Scheduled cart (`GET/POST` scheduled-cart surfaces) and on-demand checkout with `fulfillmentType: SCHEDULED` expose `pricingModel`, `selectedDeliverySpeed`, and `delivery`. Class is resolved server-side (may appear on cart **group** as `itemClass` — never as two fee lines).

**Normal** (`itemClass = NORMAL`, `itemsNet = 5`):

```json
{
  "pricingModel": "delivery_fees_v1",
  "selectedDeliverySpeed": "SAME_DAY",
  "delivery": {
    "fee": "0.900",
    "waived": false,
    "waiveReason": null,
    "distanceKm": null,
    "outOfRange": false,
    "prompts": {
      "minOrder": {
        "required": "3.000",
        "shortfall": "0.000",
        "blocksCheckout": false,
        "message": null
      },
      "freeDelivery": {
        "threshold": "8.000",
        "shortfall": "3.000",
        "message": "Add BHD 3.000 to get free delivery"
      }
    }
  }
}
```

**Special** (`itemClass = SPECIAL`, same tier / `itemsNet`):

```json
{
  "pricingModel": "delivery_fees_v1",
  "selectedDeliverySpeed": "SAME_DAY",
  "delivery": {
    "fee": "2.000",
    "waived": false,
    "waiveReason": null,
    "distanceKm": null,
    "outOfRange": false,
    "prompts": {
      "minOrder": {
        "required": "3.000",
        "shortfall": "0.000",
        "blocksCheckout": false,
        "message": null
      },
      "freeDelivery": {
        "threshold": "8.000",
        "shortfall": "3.000",
        "message": "Add BHD 3.000 to get free delivery"
      }
    }
  }
}
```

Notes:

- Still **one** customer delivery number (`delivery.fee`). Never vendor contribution / breakdown / driver pay. Never two Normal/Special fee lines.
- `distanceKm` is always `null` on scheduled (fee is flat — **no** km string, radius, or per-km fields on the customer contract).
- `outOfRange` is always `false` for fee math (scheduled has no max-distance gate in the fee calculator; vendor delivery-radius checks elsewhere may still 409).
- Min-order / free-delivery prompts match OG §11 copy; place-order still **409** `MIN_ORDER_NOT_MET` when `blocksCheckout`.
- Tier chips / `deliveryOptions[].fee` may show per-tier fees; charged fee follows selected speed + resolved `itemClass`.
- Multi-vendor scheduled cart: fee resolved **per vendor order** (each order gets its own snapshot).

### Item class for fee column

| Piece | Detail |
|-------|--------|
| Helper | `resolveCartItemClass` in `item-class.resolver.ts` |
| Role | Order-level class for scheduled fee column — **one class per order**, never split per line |
| Inputs | `storeType` + `vendor` enablement; cart line effective classes |
| Output | `'NORMAL'` \| `'SPECIAL'` |
| Rules (OG §03) | Store-type or vendor narrowed to Special → `SPECIAL`; Normal-only → `NORMAL`; else any cart line `SPECIAL` → `SPECIAL`; else `NORMAL` |

### Admin scheduled fee preview

### `POST /admin/vendors/:vendorId/locations/:locationId/scheduled-delivery-fee/preview`

**Body:**

```json
{ "speedTier": "SAME_DAY", "itemClass": "SPECIAL", "itemsNet": 5 }
```

**Response** (rich — includes vendor contribution + flat breakdown; **no** distance fields):

```json
{
  "pricingModel": "delivery_fees_v1",
  "mode": "SCHEDULED",
  "speedTier": "SAME_DAY",
  "itemClass": "SPECIAL",
  "distanceKm": null,
  "customerFee": "2.000",
  "vendorContribution": "1.500",
  "waived": false,
  "waiveReason": null,
  "prompts": {
    "minOrder": {
      "required": "3.000",
      "shortfall": "0.000",
      "blocksCheckout": false,
      "message": null
    },
    "freeDelivery": {
      "threshold": "8.000",
      "shortfall": "3.000",
      "message": "Add BHD 3.000 to get free delivery"
    }
  },
  "breakdownInternal": {
    "flat": true,
    "rates": {
      "vendorNormal": "0.500",
      "vendorSpecial": "1.500",
      "customerNormal": "0.900",
      "customerSpecial": "2.000"
    },
    "resolved": { "flat": true, "customerRate": 2, "vendorRate": 1.5 }
  }
}
```

Requires scheduled seeded on the branch; missing rates → 400. Admin waive enum uses `FREE_DELIVERY` (uppercase) when waived — customer JSON still uses `free_delivery`.

---

## 6. Driver rates & champ eligibility (D07) — **Frozen — 2026-09-26** (D09 Batch 4)

On-demand driver pay is **distance-based** (vehicle base + free radius + extra/km). Scheduled driver pay is **flat** — separate Bike and Car grids × speed tier × Normal/Special; **no** distance on scheduled grids (OG §06 / §12 rule 10).

**Freeze stamp (D07 / D09 Batch 4):** **Frozen — 2026-09-26.** Admin rates/eligibility, assignment gate, snapshot `driverPay` / `driverPayBreakdown`, driver job `driverEarnings`, and ops `DISPATCH_NO_ELIGIBLE_CHAMP` re-audited against live modules. Driver mobile may keep implementing against §6 + Appendix C + handoff `07`.

### Modules

| Piece | Path |
|-------|------|
| Types / parse | `driver-rates.types.ts` |
| Pay calculator | `resolveDriverPay` — `driver-pay.calculator.ts` |
| Rates resolve | `resolveOrderDriverRates` — branch → vendor template → store-type |
| Snapshot patch | `applyDriverPayToSnapshot` / `readSnapshotDriverPay` — `delivery-fee.snapshot.ts` |
| Persist at assign | `persistOrderDriverPay` — `driver-pay.persist.ts` (offer / accept / `POST /admin/orders/:orderId/reassign-champ`) |
| OG eligibility | `evaluateChampOgEligibility` — `champ-eligibility.ts` |
| Dispatch gate | `evaluateChampEligibility` + `pickDriver` — `dispatch.service.ts` |
| No-eligible alert | `flagNoEligibleChamp` → ops incident `DISPATCH_NO_ELIGIBLE_CHAMP` (P2, once per order) |

### Snapshot fields (when priced)

Written onto `Order.deliveryEconomicsSnapshot` at offer create / accept / admin reassign (checkout leaves them null). Customer APIs **omit** the whole snapshot.

| Field | When set | Notes |
|-------|----------|-------|
| `vehicle` | Assign | Champ `DriverVehicle.vehicleType` (e.g. `BIKE`, `CAR`) |
| `resolved.driverPay` | Assign | BHD string, 3 dp — total payout |
| `resolved.driverPayBreakdown` | Assign when priced | See Appendix C (`ON_DEMAND` base+extraKm or `SCHEDULED` flat) |
| Checkout `driverPay` | Always null | Vehicle unknown until assignment |

### Admin — store-type / branch / vendor rates

Same routes as §1–§2. `driverRates` on:

- `GET/PUT /admin/store-types/:storeTypeId/delivery-defaults` — flat money/km strings (see §1 example)
- `GET/PUT /admin/vendors/:vendorId/locations/:locationId/delivery-settings` — per-field `{ value, state, defaultValue }`
- `GET/PUT /admin/vendors/:vendorId/delivery-settings` — vendor template (same inheritance shape)
- `POST .../delivery-settings/reset-field` — paths under `driverRates.*` / `allowedVehicles.*`

**Seed:** First HOT_FOOD or SCHEDULED enable copies store-type `driverRates` + `allowedVehicles` once. Empty store-type → null/empty cells (never invent). Re-enable keeps overrides.

**Vehicle narrowing (OG §12.8):** Vendor/branch may set `false`. Enabling a vehicle the store type disallows → 400.

### Admin — champ eligibility

### `GET /admin/fleet/champs/:champId`

`profile.eligibility`:

```json
{
  "enabledModes": ["HOT_FOOD_ON_DEMAND", "SCHEDULED"],
  "scheduledClasses": "BOTH",
  "specialStoreTypeIds": ["…"]
}
```

### `POST /admin/fleet/champs` / `PATCH /admin/fleet/champs/:champId`

Body may include `enabledModes`, `scheduledClasses` (`NORMAL_ONLY` \| `SPECIAL_ONLY` \| `BOTH`), `specialStoreTypeIds` (Store Management Category ids). Progressive validation (OG §07):

| Rule | Behaviour |
|------|-----------|
| ≥1 mode | Required — empty modes → 400 |
| Scheduled off | Hides class / store-type UI; **keeps** stored values |
| Both→Normal (or Special→Normal) | Clears `specialStoreTypeIds` |
| Scheduled on + Special included | ≥1 valid store-type id required |
| Vehicles | Existing `DriverVehicle.vehicleType` — no duplicate columns |

### Assignment + snapshot fill

```text
eligible(champ, order) =
      order.mode in champ.enabled_modes
  and (order.mode != scheduled
       or order.item_class in champ.scheduled_classes)
  and (order.item_class != special
       or order.store_type in champ.special_store_types)
  and order.vehicle in champ.vehicles
```

- `pickDriver` never offers OG-ineligible champs (`MODE_NOT_ENABLED`, `SCHEDULED_CLASS_NOT_ALLOWED`, `SPECIAL_STORE_TYPE_NOT_ALLOWED`, plus operational gates).
- No eligible champ → `DISPATCH_NO_ELIGIBLE_CHAMP` ops incident (not silent). Order stays searchable until assigned.
- Admin `POST /admin/orders/:orderId/reassign-champ` rejects OG-ineligible champ and recomputes + persists `driverPay`.
- Tip stays separate — job/base pay = `driverPay` only; tip credited once at completion.

### Ops — no eligible champ (OG §07 rule 5)

| Concern | Live behaviour |
|---------|----------------|
| Trigger | `pickDriver` finds zero OG+ops-eligible champs (or zero online candidates) |
| Writer | `flagNoEligibleChamp` → `OpsIncident` type `DISPATCH_NO_ELIGIBLE_CHAMP`, priority **P2**, stage `DISPATCH`, **once** while OPEN |
| Admin list | `GET /admin/incidents` (+ dashboard / Live Orders incident sidebars) |
| Detail | `GET /admin/incidents/:incidentId` — title “No eligible champ — dispatch attention”; metadata includes `candidateCount`, `exclusionCounts`, `mode`, `itemClass`, `storeTypeId` |
| Driver app | Empty offer list only — no special error code |

### Driver-facing surfaces

| Surface | Endpoint / field | Notes |
|---------|------------------|-------|
| Job offer / active / history | `GET /api/v1/drivers/jobs/offers` (also `board`, `active`, `history`, `:id`) → `driverEarnings` | Frozen from snapshot `driverPay` when priced at accept |
| Accept | `POST /api/v1/drivers/jobs/:id/accept` | Persists snapshot `driverPay` + breakdown when vehicle known |
| Complete | `POST /api/v1/drivers/jobs/:id/complete` | Wallet credit reads `readSnapshotDriverPay` first |
| Earnings rollup | `GET /api/v1/drivers/earnings`, `…/earnings/transactions` | Tip separate from base pay |
| Breakdown (base / extra km) | Snapshot `resolved.driverPayBreakdown` | Server-owned; customer APIs never expose. Driver UI should show base + extra km separately when reading offer/job economics (see `07`) |

Customer APIs continue to **omit** snapshot / driver pay (OG §11).

## 6b. Commission & vendor settlement (D08) — **Frozen — 2026-09-26** (D09 Batch 5)

**Customer impact:** none. Customer quote/checkout/order totals and fee lines are unchanged — commission, VAT on commission, gateway, and custom fees stay off customer JSON (OG §11). Snapshot strip via `omitDeliveryEconomicsSnapshot` also hides `vendorSettlement`.

**Freeze stamp (D08 / D09 Batch 5):** **Frozen — 2026-09-26.** Admin commission APIs, settlement preview, checkout `vendorSettlement` freeze, and Commission UI (no platform service fee) re-audited against live modules. Full samples → Appendix D.

| Surface | Detail |
|---------|--------|
| Calculator | `resolveVendorSettlement` — OG §08; cash → gateway 0; **never** charges `platformServiceFee` |
| Preview | `POST /admin/orders/:orderId/settlement/preview` — dry-run; optional `{ cardKind?: "debit" \| "credit" }` |
| Snapshot | `deliveryEconomicsSnapshot.vendorSettlement` rates frozen at checkout; contribution from `resolved.vendorContribution` |
| Rates source | Prefer snapshot; legacy orders fall back to live vendor (`ratesSource`: `snapshot` \| `live_vendor`) |
| Live payout job | Not shipped; gate future writes with `VENDOR_SETTLEMENT_LIVE_ALLOWED` (default OFF) |
| Vendor commission | `GET/PATCH /admin/vendors/:vendorId/commission` — settings only (no payout math on this route) |
| Store-type defaults | `GET/PUT /admin/store-types/:id/commission-defaults` — copy-on-create; no cascade to existing vendors |

**Formula (OG §08):**

```text
items_value = order items only   # delivery + service fee NOT in commission base
commission = f(model, items_value)
commission_vat = commission × vatOnCommissionPct / 100   # Bahrain 10% default; read-only in UI
commission_due = commission + commission_vat
gateway_fee = cash ? 0 : order_total × (fixed_pct + method_rate) / 100 + fixed_charge
vendor_payout = items_value − commission_due − custom_total − vendor_delivery_contribution − gateway_fee
```

**Preview response (`data`):** `orderId`, `vendorId`, `ratesSource`, `contributionFromSnapshot`, `paymentMethod`, `rates` (no `platformServiceFee`), `settlement` (numbers, 3 dp). See Appendix D.

---


## 7. Error / validation examples

| Case | HTTP | Message direction |
|------|------|-------------------|
| Last mode toggled off | 400 | At least one order mode must stay on |
| Mode unsupported by store type | 400 | Mode not available for this store type |
| Distance > max | 409 `OUT_OF_DELIVERY_RANGE` (checkout / createOrder); quote sets `delivery.outOfRange: true` with non-zero computed fee (no silent zero / free waive) | `This address is outside the delivery area` |
| Pickup / dine-in / services | Quote/checkout `delivery: null` (block absent) | No delivery fee line |
| items_net < min order | Quote `blocksCheckout: true`; checkout / `createOrder` → **409** `MIN_ORDER_NOT_MET` | “Add BHD X.XXX more to place your order” |
| items_net < free delivery threshold | Quote free-delivery `message` only (no place-order reject) | “Add BHD X.XXX to get free delivery” |
| Reset unknown field path | 400 | Unknown field |
| Scheduled distance keys on write | 400 | Distance fields not allowed on scheduled fees |
| Scheduled driver-rate distance keys | 400 | Scheduled driver rates must not include distance fields |
| Vehicle widen beyond store type | 400 | Vendor cannot widen vehicles beyond store type |
| Champ modes empty | 400 | At least one order mode must stay on |
| Champ Special without store types | 400 | Special store types required when Special included |
| Scheduled v1 rate missing for class | 400 | Scheduled delivery rates for this speed tier and item class are not configured |
| Scheduled preview before seed | 400 | Scheduled fees not seeded on this branch |
| Manual assign OG-ineligible champ | 400 | Champ is not eligible for this order (…) |

---

## Appendix A — Sample customer quote payloads (D04 Batch 4)

**Frozen — 2026-09-26** (D09 Batch 1). Phase 1 shapes from `quoteDeliveryFee` / `presentCustomerDelivery` (OG §11 examples). Cart/checkout wrap these under the existing response; customer JSON **never** includes `breakdownInternal`, `deliveryEconomicsSnapshot`, vendor contribution, driver pay, or settlement rates. Service fee remains the existing top-level `serviceFee` / `summary.serviceFee` field (not shown below).

### A1. Min-order shortfall (blocks checkout) — OG “Add BHD 1.250…”

`itemsNet = 1.750`, `minOrderAmount = 3.000`, in range, distance within customer radius.

```json
{
  "pricingModel": "delivery_fees_v1",
  "delivery": {
    "fee": "0.650",
    "waived": false,
    "waiveReason": null,
    "distanceKm": "3.00",
    "outOfRange": false,
    "prompts": {
      "minOrder": {
        "required": "3.000",
        "shortfall": "1.250",
        "blocksCheckout": true,
        "message": "Add BHD 1.250 more to place your order"
      },
      "freeDelivery": {
        "threshold": "8.000",
        "shortfall": "6.250",
        "message": "Add BHD 6.250 to get free delivery"
      }
    }
  }
}
```

Place-order (`POST /cart/checkout`, `createOrder`) → **409** `MIN_ORDER_NOT_MET` with the same `message`. Free-delivery prompt alone never rejects.

### A2. Free-delivery shortfall only (informational) — OG “Add BHD 1.730…”

`itemsNet = 6.270` (≥ min, < free-delivery over). Min-order does **not** block.

```json
{
  "pricingModel": "delivery_fees_v1",
  "delivery": {
    "fee": "0.650",
    "waived": false,
    "waiveReason": null,
    "distanceKm": "3.00",
    "outOfRange": false,
    "prompts": {
      "minOrder": {
        "required": "3.000",
        "shortfall": "0.000",
        "blocksCheckout": false,
        "message": null
      },
      "freeDelivery": {
        "threshold": "8.000",
        "shortfall": "1.730",
        "message": "Add BHD 1.730 to get free delivery"
      }
    }
  }
}
```

### A3. Compact variants (same contract)

**Out of range** (`distanceKm > vendor.maxDistanceKm` — strict greater-than; equality is still in range): `outOfRange: true`, non-zero `fee` (not silent `0.000`), `prompts.freeDelivery: null`. Place-order → **409** `OUT_OF_DELIVERY_RANGE` / `This address is outside the delivery area`.

```json
{
  "pricingModel": "delivery_fees_v1",
  "delivery": {
    "fee": "1.100",
    "waived": false,
    "waiveReason": null,
    "distanceKm": "13.00",
    "outOfRange": true,
    "prompts": {
      "minOrder": {
        "required": "3.000",
        "shortfall": "0.000",
        "blocksCheckout": false,
        "message": null
      },
      "freeDelivery": null
    }
  }
}
```

**Pickup / dine-in / services:** delivery block absent.

```json
{
  "pricingModel": "delivery_fees_v1",
  "delivery": null
}
```

---

## Appendix B — Sample scheduled quote payloads (D06) — **Frozen — 2026-09-26** (D09 Batch 3)

Shapes from `quoteScheduledDeliveryFee` / `presentScheduledCustomerDelivery` (OG §05 + §11). Same customer privacy rules as Appendix A — **never** `breakdownInternal`, snapshot, vendor contribution, or driver pay on customer JSON.

**No distance on scheduled contract:** `distanceKm` is always `null`; there is no radius / per-km / max-distance field on customer or admin fee responses for this path.

**Fixture (Same day):** OG §05 placeholders — `customerNormal 0.900`, `customerSpecial 2.000`, `minOrderAmount 3.000`, `freeDeliveryOver 8.000` (matches `scheduled-delivery-fee-calculator.test.ts`).

### B1. Normal class — one delivery number

`speedTier = SAME_DAY`, `itemClass = NORMAL`, `itemsNet = 5` (≥ min, < free-delivery over).

```json
{
  "pricingModel": "delivery_fees_v1",
  "selectedDeliverySpeed": "SAME_DAY",
  "delivery": {
    "fee": "0.900",
    "waived": false,
    "waiveReason": null,
    "distanceKm": null,
    "outOfRange": false,
    "prompts": {
      "minOrder": {
        "required": "3.000",
        "shortfall": "0.000",
        "blocksCheckout": false,
        "message": null
      },
      "freeDelivery": {
        "threshold": "8.000",
        "shortfall": "3.000",
        "message": "Add BHD 3.000 to get free delivery"
      }
    }
  }
}
```

### B2. Special class — one delivery number (same tier)

`speedTier = SAME_DAY`, `itemClass = SPECIAL`, `itemsNet = 5`. Server picks Special when the vendor is Special-only or any cart line is Special — mobile never chooses the class for pricing.

```json
{
  "pricingModel": "delivery_fees_v1",
  "selectedDeliverySpeed": "SAME_DAY",
  "delivery": {
    "fee": "2.000",
    "waived": false,
    "waiveReason": null,
    "distanceKm": null,
    "outOfRange": false,
    "prompts": {
      "minOrder": {
        "required": "3.000",
        "shortfall": "0.000",
        "blocksCheckout": false,
        "message": null
      },
      "freeDelivery": {
        "threshold": "8.000",
        "shortfall": "3.000",
        "message": "Add BHD 3.000 to get free delivery"
      }
    }
  }
}
```

### B3. Min-order blocks checkout

`itemsNet = 1.75` → `prompts.minOrder.blocksCheckout: true`. Fee still computed; place-order → **409** `MIN_ORDER_NOT_MET`.

```json
{
  "pricingModel": "delivery_fees_v1",
  "selectedDeliverySpeed": "SAME_DAY",
  "delivery": {
    "fee": "0.900",
    "waived": false,
    "waiveReason": null,
    "distanceKm": null,
    "outOfRange": false,
    "prompts": {
      "minOrder": {
        "required": "3.000",
        "shortfall": "1.250",
        "blocksCheckout": true,
        "message": "Add BHD 1.250 more to place your order"
      },
      "freeDelivery": {
        "threshold": "8.000",
        "shortfall": "6.250",
        "message": "Add BHD 6.250 to get free delivery"
      }
    }
  }
}
```

### B4. Free-delivery waive (customer fee only)

`itemsNet ≥ freeDeliveryOver` → customer fee `0.000`, `waived: true`, `waiveReason: "free_delivery"`. Vendor contribution still charged server-side (not shown to customer).

```json
{
  "pricingModel": "delivery_fees_v1",
  "selectedDeliverySpeed": "SAME_DAY",
  "delivery": {
    "fee": "0.000",
    "waived": true,
    "waiveReason": "free_delivery",
    "distanceKm": null,
    "outOfRange": false,
    "prompts": {
      "minOrder": {
        "required": "3.000",
        "shortfall": "0.000",
        "blocksCheckout": false,
        "message": null
      },
      "freeDelivery": null
    }
  }
}
```

### B5. Legacy scheduled branch

`pricingModel: "legacy_flat"` — fee from `SCHEDULED_DELIVERY_FEES[speed]` only (`SAME_DAY` → `2.000`); class ignored; prompts typically null.

```json
{
  "pricingModel": "legacy_flat",
  "selectedDeliverySpeed": "SAME_DAY",
  "delivery": {
    "fee": "2.000",
    "waived": false,
    "waiveReason": null,
    "distanceKm": null,
    "outOfRange": false,
    "prompts": {
      "minOrder": null,
      "freeDelivery": null
    }
  }
}
```

---

## Appendix C — Driver pay snapshot samples (D07) — **Frozen — 2026-09-26** (D09 Batch 4)

Filled at offer / accept / admin reassign via `applyDriverPayToSnapshot`. Customer JSON never includes these fields. Settlement reads `resolved.driverPay` (string) via `readSnapshotDriverPay`.

**Freeze stamp:** Samples match live `resolveDriverPay` + `presentDriverPayBreakdown` (C1 = bike 12 km beyond 9 km free @ 0.075/km → `1.125`; C2 = scheduled car Same-day Special cell `4.000`).

### C1. On-demand (base + extra km)

Distance 12 km, bike, free radius 9 km, extra 0.075/km → base 0.900 + extra 0.225 = 1.125.

```json
{
  "vehicle": "BIKE",
  "resolved": {
    "driverPay": "1.125",
    "driverPayBreakdown": {
      "kind": "ON_DEMAND",
      "vehicle": "bike",
      "total": "1.125",
      "base": "0.900",
      "extraKm": "0.225",
      "distanceKm": "12.00",
      "freeRadiusKm": "9.00",
      "extraPerKm": "0.075",
      "speedTier": null,
      "itemClass": null
    }
  }
}
```

Driver job payloads expose the total as `driverEarnings` (same BHD number). UI should show **base** and **extra km** separately when reading the breakdown (OG §11).

### C2. Scheduled (flat)

Same-day Special, car grid cell `4.000` — no distance fields.

```json
{
  "vehicle": "CAR",
  "mode": "SCHEDULED",
  "itemClass": "SPECIAL",
  "speedTier": "SAME_DAY",
  "resolved": {
    "driverPay": "4.000",
    "driverPayBreakdown": {
      "kind": "SCHEDULED",
      "vehicle": "car",
      "total": "4.000",
      "base": "4.000",
      "extraKm": null,
      "distanceKm": null,
      "freeRadiusKm": null,
      "extraPerKm": null,
      "speedTier": "SAME_DAY",
      "itemClass": "SPECIAL"
    }
  }
}
```

### C3. Unpriced leg

Null rate cell (or missing rates) → `driverPay` stays `null` / breakdown omitted. Never invent `0`. Settlement may fall back to legacy job earnings only when the snapshot is unpriced.

---

## Appendix D — Vendor settlement preview samples (D08) — **Frozen — 2026-09-26** (D09 Batch 5)

Admin-only. `POST /admin/orders/:orderId/settlement/preview` → `{ success, data }`. Numbers are BHD to 3 dp (JS numbers from `resolveVendorSettlement`). Customer / driver APIs never expose this shape.

**Freeze stamp:** Samples match live `assembleVendorSettlementPreview` + calculator unit tests (OG §08 worked example).

### D1. Credit card — OG worked example (live_vendor rates)

`itemsValue = 10`, `orderTotal = 10`, `paymentMethod = CREDIT`, 10% commission, default Food gateway (`fixedPct` 1 + `creditPct` 2 + `fixedCharge` 0.05).

```json
{
  "orderId": "ord-1",
  "vendorId": "ven-1",
  "ratesSource": "live_vendor",
  "contributionFromSnapshot": false,
  "paymentMethod": "CREDIT",
  "rates": {
    "model": "PERCENT_OF_ORDER",
    "commissionRate": 10,
    "flatFeePerOrder": null,
    "commissionTiers": null,
    "vatOnCommissionPct": 10,
    "gatewayFees": {
      "fixedPct": 1,
      "debitPct": 0.5,
      "creditPct": 2,
      "applePayPct": 1.5,
      "googleWalletPct": 1.5,
      "otherChargesPct": 0.5,
      "fixedCharge": 0.05
    },
    "customFees": []
  },
  "settlement": {
    "itemsValue": 10,
    "commission": 1,
    "commissionVat": 0.1,
    "commissionDue": 1.1,
    "gatewayFee": 0.35,
    "gatewayMethodRatePct": 2,
    "customTotal": 0,
    "vendorDeliveryContribution": 0,
    "vendorPayout": 8.55,
    "breakdown": {
      "model": "PERCENT_OF_ORDER",
      "paymentMethod": "CREDIT",
      "gatewayFixedPct": 1,
      "gatewayFixedCharge": 0.05
    }
  }
}
```

`platformServiceFee` is **absent** from `rates` and `settlement` (never invent / never deduct).

### D2. Cash — gateway fee 0

Same rates; `paymentMethod = CASH` → `gatewayFee: 0`, `vendorPayout: 8.9` (10 − 1.1).

### D3. Snapshot preferred

When checkout froze `vendorSettlement` + `resolved.vendorContribution`, preview sets `ratesSource: "snapshot"`, `contributionFromSnapshot: true`, and uses frozen rates / contribution — **not** live vendor columns (even if admin changed them after checkout).

