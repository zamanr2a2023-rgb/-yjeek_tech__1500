# Customer App — Pharmacy

**Rules:** `00-source-of-truth-and-rules.md`.

## Vendor page

```http
GET /vendors/:id/order-modes?latitude=&longitude=
```

Call this on open **and** whenever the delivery address changes.

Inside the radius: `deliverNow.enabled=true`, `deliverNow.selected=true`, `banner=null`.  
Outside: `deliverNow.faded=true`, `deliverNow.enabled=false`, `scheduled.selected=true`, `banner` is the outside line.

Show both tabs in both cases.

| Inside (Deliver Now) | Outside (Scheduled) |
|----------------------|---------------------|
| `{etaMin} min` | `scheduled.earliestSlotLabel` (Tomorrow) |
| `deliverNow.deliveryFee` (0.500) | `scheduled.shippingFee` (1.000) |
| `deliverNow.minOrderAmount` (3) | `scheduled.minOrderAmount` (5) |

Menu pills come from the vendor catalog: Medicines, Personal Care, Baby & Mother, Vitamins.  
`PRESCRIPTION` badge + price `0` renders as **BHD —**.

## Checkout

- Deliver Now: existing delivery checkout (`fulfillmentType` omitted or `ON_DEMAND`) with `addressId`.
- Scheduled: `fulfillmentType=SCHEDULED` plus a future `scheduledAt` or `windowStartAt`, and `deliverySpeed` (default path accepts `NEXT_DAY`).

If Deliver Now checkout is outside the radius the API responds **409** `INSTANT_DELIVERY_UNAVAILABLE`:

```json
{
  "offerMoveToScheduled": true,
  "keepCart": true,
  "banner": "You are outside this pharmacy's instant delivery area, scheduled delivery only."
}
```

Keep the cart lines. Offer to continue the same cart as scheduled. Do not clear it.
