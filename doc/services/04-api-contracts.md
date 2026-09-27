# API Contracts — Services v1

> **Frozen** 2026-09-26 (S03). Samples captured live against Sparkle Home + Glow Beauty after S01 seed + S02 availability.  
> Raw captures: `samples/*.json`.

## Mode truth

```json
{
  "storeTypeSlug": "services",
  "catalogMode": "MODIFIERS",
  "isBookable": true,
  "supportsDelivery": false,
  "supportsPickup": false,
  "supportsDineIn": false,
  "supportsScheduled": false
}
```

Booking modes come from vendor booking settings (`fulfillmentModes`), not food delivery flags:

| Provider | Modes on slots |
|----------|----------------|
| Sparkle Home | `AT_HOME` |
| Glow Beauty | `IN_SALON` |

## Age restriction — N/A

Services are **not** age-gated. Menu/vendor payloads include the standard `ageRestriction` object with `required: false`:

```json
{
  "ageRestricted": false,
  "ageBadge": null,
  "ageRestriction": {
    "required": false,
    "minimumAge": null,
    "champMustCheckId": false,
    "canPurchase": true,
    "cta": null,
    "banner": null
  }
}
```

## Delivery quote — null

Services never use the food delivery fee engine:

| Surface | Behaviour |
|---------|-----------|
| `GET /cart?type=SERVICE` | Top-level `delivery: null`; `summary.deliveryFee` is `0` until AT_HOME checkout applies call-out |
| `GET /vendors/:id/delivery-options` | `{ "supported": false, "delivery": null, "reason": "SERVICES_BOOKING", "speeds": [], "windows": [] }` |

Live: `samples/14-delivery-options-sparkle.json`, `samples/17-cart-sparkle-service-summary.json`.

## Browse

```http
GET /vendors?category=services
GET /vendors?category=services&subcategory=cleaning
GET /vendors?category=services&subcategory=beauty-salon
```

Provider card (live excerpt — Glow ranks first when sooner / same slot):

```json
{
  "id": "cmuihhxng000ov9h8ux08mbqs",
  "name": "Glow Beauty Lounge",
  "slug": "glow-beauty",
  "area": "Seef",
  "rating": 4.8,
  "fromPrice": 12,
  "isBookable": true,
  "nextAvailableAt": "2026-09-28T03:00:00.000Z",
  "fullyBooked": false,
  "offerBadge": null,
  "serviceCategory": "Beauty & Salon",
  "ageRestricted": false
}
```

```json
{
  "id": "cmuihhxm5000av9h8qim3h7vj",
  "name": "Sparkle Home Services",
  "slug": "sparkle-home",
  "area": "Seef",
  "fromPrice": 6,
  "nextAvailableAt": "2026-09-28T03:00:00.000Z",
  "fullyBooked": false,
  "serviceCategory": "Cleaning"
}
```

Full list: `samples/01-browse-services.json`.

## Menu / product (MODIFIERS)

```http
GET /vendors/sparkle-home/menu
GET /vendors/glow-beauty/menu
GET /vendors/glow-beauty/products/:productId
```

- `catalogMode: "MODIFIERS"`
- Duration: `prepTimeMin` (minutes)
- **No** `variants` / `variantId` (arrays empty / omit on add-to-cart)

Glow — Haircut & Blow Dry (Short + Treatment mask → BHD 20.000 at checkout):

```json
{
  "name": "Haircut & Blow Dry",
  "price": 12,
  "prepTimeMin": 60,
  "catalogMode": "MODIFIERS",
  "variants": [],
  "optionGroups": [
    {
      "name": "Hair length",
      "minSelect": 1,
      "maxSelect": 1,
      "isRequired": true,
      "options": [
        { "name": "Short", "priceDelta": 0 },
        { "name": "Medium", "priceDelta": 3 },
        { "name": "Long", "priceDelta": 6 },
        { "name": "Extra long", "priceDelta": 10 }
      ]
    }
  ],
  "addons": [
    { "name": "Treatment mask", "price": 8 },
    { "name": "Scalp massage", "price": 5 },
    { "name": "Styling upgrade", "price": 4 }
  ]
}
```

Live: `samples/08-product-glow-haircut.json`, `samples/06-menu-sparkle-home.json`.

## Staff

```http
GET /vendors/:id/staff
```

```json
{
  "vendorId": "...",
  "bookable": true,
  "count": 0,
  "staff": []
}
```

Seed demos ship with empty staff lists; `serviceStaffId` on checkout is optional.

## Slots

```http
GET /vendors/:id/booking-slots?date=2026-09-28&durationMin=180
GET /vendors/:id/booking-slots?date=2026-09-28&durationMin=60&staffId=
```

Sparkle (AT_HOME, buffer 30, capacity 2, duration override 180):

```json
{
  "vendorId": "cmuihhxm5000av9h8qim3h7vj",
  "bookable": true,
  "date": "2026-09-28",
  "durationMin": 180,
  "bufferMin": 30,
  "bookingWindowDays": 30,
  "coveredAreas": [
    { "key": "seef", "label": "Seef", "callOutFee": 0 },
    { "key": "manama", "label": "Manama", "callOutFee": 1.5 },
    { "key": "juffair", "label": "Juffair", "callOutFee": 2 }
  ],
  "slots": [
    {
      "id": "slot_2026-09-28T03:00:00.000Z",
      "startAt": "2026-09-28T03:00:00.000Z",
      "endAt": "2026-09-28T06:00:00.000Z",
      "label": "9:00",
      "durationMin": 180,
      "bufferMin": 30,
      "available": true,
      "remainingCapacity": 2,
      "fulfillmentModes": ["AT_HOME"]
    }
  ]
}
```

Notes:
- Pass product `prepTimeMin` (plus option deltas if any) as `durationMin`.
- Blocked / closed days / outside `bookingWindowDays` → empty `slots` (+ optional `reason`).
- Slot ISO times are server-local wall clock encoded as UTC (`Z`).

Live: `samples/10-slots-sparkle.json`, `samples/11-slots-glow.json`.

## Cart + checkout

All cart mutations for bookings use **`?type=SERVICE`** (separate cart from DELIVERY).

```http
POST /cart/items?type=SERVICE
PATCH /cart?type=SERVICE
GET  /cart?type=SERVICE
POST /cart/checkout?type=SERVICE
```

### Add item (Glow)

```json
{
  "productId": "<glow-haircut-id>",
  "quantity": 1,
  "replaceCart": true,
  "options": {
    "optionIds": ["<short-option-id>"],
    "addonIds": ["<treatment-mask-id>"]
  }
}
```

### Patch booking fields

```json
{
  "serviceMode": "IN_SALON",
  "serviceScheduledAt": "2026-09-28T03:00:00.000Z"
}
```

### Checkout body

```json
{
  "orderType": "SERVICE",
  "serviceFulfillmentMode": "IN_SALON",
  "serviceStaffId": null,
  "scheduledAt": "2026-09-28T03:00:00.000Z",
  "serviceDurationMin": 60,
  "paymentMethod": "CASH"
}
```

AT_HOME requires `addressId` in a covered area (`area` matched before `city`).

### Live checkout results

**Glow IN_SALON** (`samples/15-checkout-glow-in-salon.json`):

| Field | Value |
|-------|-------|
| orderNumber | `YJK-2026-52111` |
| subtotal | `20` (12 + mask 8) |
| deliveryFee | `0` |
| serviceFee | `0.6` |
| totalAmount | `22.66` (incl. VAT) |
| serviceBooking.fulfillmentMode | `IN_SALON` |
| serviceBooking.durationMin | `60` |

**Sparkle AT_HOME · Juffair** (`samples/16-checkout-sparkle-at-home.json`):

| Field | Value |
|-------|-------|
| orderNumber | `YJK-2026-55544` |
| subtotal | `15` |
| deliveryFee | `2` (Juffair call-out) |
| serviceFee | `0.45` |
| totalAmount | `19.195` |
| serviceBooking.fulfillmentMode | `AT_HOME` |
| serviceBooking.durationMin | `180` |

Rules:
1. `scheduledAt` required; capacity checked **inside** the checkout transaction (race → one fails).
2. Creating the order holds the slot; `CANCELLED` / `REJECTED` / terminal statuses free capacity.
3. IN_SALON: `deliveryFee = 0`. AT_HOME: `deliveryFee` = matched covered area `callOutFee`.
4. Food `delivery` quote stays `null` on cart; do not show delivery ETA UI for Services.
