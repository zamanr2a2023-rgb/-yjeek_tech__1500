# Customer App API Contracts — Marketing Module v1

> **Status: FROZEN (v1-freeze)**  
> **Date:** 2026-09-30  
> **Source of Truth Rule:** The OG HTML (`yjeek-marketing-module-workflow_v1.html`) still wins if this file disagrees.

## Changelog
- **v1-freeze (2026-09-30):** Full customer API contract freeze. Shipped `GET /api/v1/customer/wallet/ledger` (M13 Batch 2) with status/type filters and cursor pagination. All customer endpoints across M00–M13 are live and tested in `yjeek_backend`. Response envelope standardized on `{ success: true, data: ... }`.
- **v1-draft (M00–M12):** Incremental contract specifications across cashback (M01), referral (M02), vouchers (M03), vendor promo discovery (M04), campaigns & missions (M05), spin wheel (M07), push triggers & live tracking (M08), clocks (M12).

**Audience:** Mobile (customer) engineering team.  
**Currency:** BHD, 3 decimal places (formatted strings).  
**Auth:** Existing customer Bearer JWT unless noted as public.  
**Clocks:** Asia/Bahrain (UTC+3, no DST). See §10.  
**Base Path:** `/api/v1`.  
**Response Envelope:** All successful customer endpoints wrap responses in `{ "success": true, "data": <payload> }`. Errors follow `{ "success": false, "error": { "code": string, "message": string } }` (see §8).

### Intentionally Absent (By Design)
- **Customer App UI screens:** Rendered by the mobile engineering team (OG §12); backend delivers API contracts only.
- **Rider/driver marketing endpoints:** None (OG marketing module is customer and vendor facing).
- **Admin/fraud internal queues:** Exposed under `/admin/marketing/` for operations/admin, not customer apps.

---

## 1. Rewards home (My Rewards)

### `GET /customer/rewards/summary`

Returns wallet snapshot + counts for the My Rewards tab.

**Live path (M00):** `GET /api/v1/customer/rewards/summary` (customer JWT).

**Response (shape):**

```json
{
  "wallet": {
    "available": "12.500",
    "pending": "0.000",
    "expiringSoon": "1.200",
    "expiringSoonBy": "2026-10-01T00:00:00.000Z",
    "withdrawable": "8.000"
  },
  "vouchers": { "activeCount": 2 },
  "spin": { "campaignId": "…", "spinsRemaining": 1, "live": true },
  "missions": [{ "id": "…", "title": "…", "progress": 2, "target": 5 }]
}
```

That object is `data`. The HTTP body is `{ "success": true, "data": { … } }`.

OG: Available · Pending · Expiring soon · Withdraw (existing rules).

**Shipped mapping (M01):** `available` ← `Wallet.cashback`; `pending` ← `Wallet.cashbackPending` (usually `0.000` — Available is credited on Delivered, not pending); `expiringSoon` / `expiringSoonBy` ← sum / earliest `expiresAt` of Available `CASHBACK` ledger rows in the next 7 days; `withdrawable` ← `Wallet.balance`. **M03 B6:** `vouchers.activeCount` = ACTIVE issued vouchers still within `validTo`. **M05 Done:** `missions[]` is live (see below). **M07 Batch 7:** `spin` is the live wheel (see §6). When none is live, `campaignId` is `null`, `spinsRemaining` is `0`, and `live` is `false`.

**Missions (M05 Done):** each item is a LIVE Missions campaign the customer is in (no segment means all customers) whose dates contain now.

| Field | Meaning |
|-------|---------|
| `id` | Mission id |
| `title` | Campaign name |
| `progress` | Counted completed orders, capped at `target`. `0` before the first one |
| `target` | `target_orders` |

A counted order is Delivered, Collected, or Completed. The customer's window opens on their first counted order and lasts `window_days` elapsed 24-hour periods. An unfinished mission is left off this list after that window. A completed mission stays while the campaign is still live. The reward voucher is issued once and then shows in the voucher list, not as an extra field here.

### `GET /customer/wallet/ledger`

**Live path (M13 B2):** `GET /api/v1/customer/wallet/ledger` (customer JWT).

Query: `status?=available|expired|reversed|frozen`, `type?=cashback|referral_bonus|…`, `cursor`, `limit`.

Response:

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "cuid…",
        "type": "cashback",
        "amount": "0.750",
        "status": "available",
        "withdrawable": true,
        "expiresAt": "2026-10-30T10:00:00.000Z",
        "orderId": "order_123",
        "createdAt": "2026-09-30T09:00:00.000Z",
        "sourceRef": "order:order_123"
      }
    ],
    "nextCursor": null,
    "hasMore": false
  }
}
```

Ledger row: `id`, `type`, `amount`, `status`, `withdrawable`, `expiresAt`, `orderId`, `createdAt`, `sourceRef`. Amounts are formatted BHD with 3 decimal places. Filterable by status and transaction type. Cursor pagination using `cursor` and `limit`. Only returns the authenticated customer's ledger entries.

---

## 2. Cashback (checkout preview)

### Extend cart/checkout quote

Existing cart/checkout response **must** include:

```json
{
  "cashbackPreview": {
    "amount": "0.300",
    "rate": "0.030",
    "paidOwn": "10.000",
    "message": "You will earn BHD 0.300 cashback"
  }
}
```

Also present on `summary.cashbackPreview` for cart GET. Legacy numeric `cashbackEarn` remains for older clients.

Rules (OG): `items_net` after vendor/voucher discount; `paid_own` excludes wallet-paid; round 3 dp; no cashback on fees/tips/wallet.

**Shipped (M01):** Preview via `quoteCashback` (rules resolver + OG `paid_own` calculator; fallback rate `0.03` only when no active rule). Live on cart GET, checkout, and scheduled cart.

**Lifecycle (M01, clocks M12 Done):** Available credit (+ push “BHD X cashback added”) on Delivered / Collected / Completed — not on payment capture. Full refund / cancel → Reversed. **03:00 Asia/Bahrain:** past `expiresAt` → Expired. **10:00 Asia/Bahrain:** one 7-day reminder and one 24-hour reminder per credit. Partial refund does **not** reverse cashback (see M01 Batch 5 findings). The cashback-added push has `type` `ORDER_UPDATE` and `metadata.trigger` `cashback_credited`. It has no `kind` and no `deepLink`. Open My Rewards (`yjeek://rewards`).

---

## 3. Vouchers (no typed codes)

**Milestone:** M03 (execution deep — **Done**, closeout B12). Parallel to legacy typed promo codes (decision A).

### `GET /customer/vouchers`

Query: `status=active|used|expired`.

Item: `id`, `title`, `type`, `value`, `maxDiscount`, `minOrder`, `maxOrder`, `validTo`, `status`, `fundedBy`, `vendorScopeSummary`.

**Live path (M03 B6):** `GET /api/v1/customer/vouchers` (customer JWT). Status labels lowercase; money fields BHD 3 dp strings (or null for free_delivery value). Lazy + daily job expire ACTIVE past `validTo` → EXPIRED. Admin issue: `POST /admin/marketing/voucher-templates/:id/grant` (`phone` or `segmentId`).

### `POST /customer/checkout/vouchers/evaluate`

Body: `cartId` and/or `orderType`, or `basket` snapshot (`vendorId`, `items[]`, optional `deliveryFee`).

**Live path (M03 B8):** `POST /api/v1/customer/checkout/vouchers/evaluate` (customer JWT).

Response:

```json
{
  "applicable": [{ "voucherId": "…", "estimatedSaving": "2.000", "autoSelect": true }],
  "notApplicable": [{ "voucherId": "…", "reason": "Add BHD 1.200 more" }]
}
```

**Reasons (OG):** `Add BHD X.XXX more` (min order) · `Max order BHD X.XXX` · `Not accepted by this store` · exclusions · `This voucher has ended` · free-delivery with no fee.

**Best-value:** exactly one applicable row has `autoSelect: true` (highest `estimatedSaving`).

**Checkout selection (M03 B8):** `POST /cart/checkout` accepts optional `voucherId`. Server rejects MAIN `walletAmount` / `YJEEK_WALLET` with `VOUCHER_WALLET_EXCLUSIVE`. Mid-checkout expiry → `VOUCHER_EXPIRED_IN_CART` (totals unchanged / without voucher). Soft-reserves via `vouchers.used_order_id` (status stays ACTIVE until payment). Cashback `voucherDiscount` uses post-voucher item discount.

**Lifecycle (M03 B9):** mark `USED` only on successful payment (`AUTHORIZED` / `PAID`); payment fail / void / unpaid cancel → restore `ACTIVE` (clear `used_order_id`); full refund within `validTo` → restore `ACTIVE`; **partial refund does not restore**.

**Vendor gate (M03 B5, used by evaluate in B8):** voucher is applicable for a cart vendor only when `voucher_vendor_requests` is `ACCEPTED` + `admin_confirmed` + not withdrawn. Otherwise reason **`Not accepted by this store`**. Admin item/category exclusions (`excluded_item_ids` = Product.id, `excluded_category_ids` = VendorCatalogCategory.id) remove lines; if every cart line is excluded → **`Not applicable — excluded items/categories for this store`**. Admin preview: `POST /admin/marketing/voucher-templates/:id/preview-applicability`.

### Discovery — store badge + “Accepts my vouchers” (M03 B11)

**Live paths:** `GET /api/v1/vendors` · `GET /api/v1/vendors/:id` (optional customer JWT via `optionalAuthenticate`).

Store card / detail extras:

| Field | Meaning |
|-------|---------|
| `vouchersAccepted` | `true` when the store has ≥1 **live** voucher acceptance (`ACCEPTED` + `admin_confirmed` + not withdrawn + active template) |
| `vouchersAcceptedBadge` | `"Vouchers accepted"` when `vouchersAccepted`, else `null` (OG store-card badge copy) |
| `acceptsMyVouchers` | When customer JWT present: `true` if ≥1 of the customer's **ACTIVE** vouchers (within `validTo`) is live for this store; guests get `null` |

Listing filters (AND with existing category / offers filters):

| Query | Auth | Behaviour |
|-------|------|-----------|
| `acceptsMyVouchers=true` | **Required** customer JWT | Only stores that accept ≥1 of **my** ACTIVE vouchers (OG filter **"Accepts my vouchers"**) |
| `vouchersAccepted=true` | Optional | Only stores with the generic live badge (any confirmed acceptance) |

No customer app UI in this batch — mobile renders the badge / filter from these fields.

### Selection rules

- Selecting a voucher **disables** “Use wallet balance”.
- Wallet + COD remains disallowed (existing rule).
- Mark used only on successful payment; restore on full refund within validity; never on partial refund.

---

## 4. Referral

**Milestone:** M02 — **Done** (closeout B8). Customer APIs live under `/api/v1` with customer JWT.

### `GET /customer/referral/me`

Reward amounts, min order, coverage cap, remaining invite quota (day/month).

**Response (shape):**

```json
{
  "programmeEnabled": true,
  "inviterRewardAmount": "1.000",
  "inviteeRewardAmount": "1.000",
  "creditValidityDays": 30,
  "inviteExpiryDays": 30,
  "minOrderAmount": "5.000",
  "coverageCapPercent": 50,
  "coverageCapEnabled": true,
  "invitesPerDay": 5,
  "invitesPerMonth": 15,
  "remainingDay": 4,
  "remainingMonth": 12
}
```

### `POST /customer/referral/invites`

Body: `{ "phoneE164": "+973…" }` (also accepts BH 8-digit national; normalized server-side).

Creates invite `INVITED`, expiry from settings (default 30 days). Returns share text / deep link for WhatsApp/SMS (app opens the channel; backend does not send SMS).

**Response (shape):**

```json
{
  "invite": {
    "id": "…",
    "status": "INVITED",
    "reason": null,
    "phoneMasked": "+973****2233",
    "expiresAt": "2026-10-13T00:00:00.000Z",
    "rewardedAt": null,
    "createdAt": "2026-09-13T12:00:00.000Z"
  },
  "share": {
    "whatsAppText": "Join me on Yjeek! … https://yjeek.com/app",
    "smsBody": "Join me on Yjeek! … https://yjeek.com/app",
    "downloadUrl": "https://yjeek.com/app",
    "deepLink": "yjeek://referral"
  }
}
```

**Errors:** `REFERRAL_RATE_LIMIT` (429 day/month), `REFERRAL_BLOCKED` (403 self-invite / programme off / budget exhausted / inviter blocked / duplicate open invite).

Invite row stores `phone_hash` only (HMAC-SHA256 of E.164; pepper `REFERRAL_PHONE_HASH_PEPPER`). Raw phone is never persisted on `referral_invites`.

### `GET /customer/referral/invites`

List: `INVITED` · `REWARDED` · `EXPIRED` · `REJECTED` (+ `reason` when rejected). `phoneMasked` is null on list (hash-only storage).

### Registration match + dual credit

On `POST /auth/verify-otp` when the customer account is **new**, backend hashes phone → earliest open `INVITED` (first inviter wins) → fraud gates → both wallets credited immediately (no first-order wait).

Optional body field on verify-otp: `deviceId` (stable client device id) for the OG new-device gate.

| Pass | Fail |
|------|------|
| Both sides `WalletTransaction` type `REFERRAL_BONUS`, `status=AVAILABLE`, `withdrawable=false`, expiry from settings | Invite → `REJECTED` + reason; no credit. Fraud review is **M10 Done** (no customer API) |
| Invite → `REWARDED` + `rewarded_at`; invitee `referredById` set | Reasons: `phone_previously_registered`, `device_already_registered`, `programme_disabled`, `self_invite` |
| Push both: “Your BHD X referral credit is in your wallet” | Idempotent per invitee — never double-pay |

Fraud checks at **send**: programme on, rate limits, self-phone / device-linked / card-linked, inviter not blocked. At **match**: one-number-one-reward (incl. deleted accounts), new device, programme on / budget not exhausted.

### Checkout spend

Referral credit is **in-app only** (`withdrawable=false`). Checkout / payment confirm accept optional `referralCreditAmount` (separate from MAIN `walletAmount`).

| Rule | Enforcement |
|------|-------------|
| Min item value | `itemsNet` (subtotal − discounts) ≥ `minOrderAmount` (default BHD 5.000) — else `REFERRAL_CREDIT_MIN_ORDER` |
| Coverage cap | Applied amount ≤ `coverageCapPercent` of order total when enabled (default 50%) — **clamped** |
| Selection | Available `REFERRAL_BONUS` ledger rows only (not cashback-type rows; those stay non-spendable). `FROZEN` rows are excluded |
| Cashback | `paid_own` excludes MAIN wallet + referral credit |

Checkout response extras: `referralCreditApplied`, `referralCreditMaxApplicable`, `referralCreditAvailable`. Confirm response: `referralCreditApplied`.

### Expiry + programme budget

**M12 Done** clocks (Asia/Bahrain): expire at **03:00**, reminders at **10:00**.

| Transition | Rule |
|------------|------|
| Referral credit → Expired | Available `REFERRAL_BONUS` past `expiresAt` (default 30d from credit) |
| Invite → Expired | Open `INVITED` past invite `expiresAt` (default 30d from send) |
| 7-day reminder | Push once per Available referral credit. `metadata.kind` `referral_expiry_reminder_7d`, `deepLink` `yjeek://rewards` |
| 24-hour reminder | Push once per Available referral credit. `metadata.kind` `referral_expiry_reminder_24h`, `deepLink` `yjeek://rewards` |

**Monthly programme budget:** when sum of referral bonuses issued this UTC month ≥ `monthlyBudget` (Admin-configured; `null` = uncapped), programme pauses (`programmeEnabled=false`) and ops is alerted (`OpsIncident` type `REFERRAL_BUDGET_PAUSE`). New invites return `REFERRAL_BLOCKED`; new match rewards reject with `programme_disabled` (no credit).

### Pattern freeze (M10 Done, clock M12 Done)

The **04:00 Asia/Bahrain** scan detects OG patterns and freezes the inviter (no customer API change):

| Signal | Action |
|--------|--------|
| ≥ 5 rewarded invitees with 0 orders after 14 days | Inviter unused `REFERRAL_BONUS` → ledger `FROZEN`; invite ability paused |
| Same device on 2+ rewarded invites | Same |
| Bulk: ≥ `invitesPerMonth` zero-order rewards in UTC month | Same |

Writes `fraud_flags` + ops incident `REFERRAL_PATTERN_FREEZE`. Admin › Marketing › Fraud & Limits (Super Admin) can Release, Cancel credits, or Suspend. There is no customer endpoint for that queue. A `FROZEN` referral row is excluded from checkout spend.

---

## 5. Offers discovery

**Milestone:** M04 Done. Vendor-funded promotions only — **not** M03 vouchers (`vouchersAccepted` / `vouchersAcceptedBadge` stay separate). Cashback is unchanged.

Live means workflow `LIVE` or `APPROVED`, inside start/end, not paused, and under `totalUsageLimit` when set. Pending, rejected, cancelled, ended, and paused promotions are omitted. `APPROVED` still in its window counts as live until the window job stores `LIVE`.

### `GET /customer/offers/items`

Public. Optional customer JWT is used only when `opened=true`.

Lists items covered by a **live** item/category/store price promotion or BOGO (`ITEM_CATEGORY_DEAL`, `BUY_X_GET_Y`) across visible vendors. A live **free-delivery** promotion does not add every SKU here; it still sets the store Offers label.

Query (same zone idea as `GET /vendors`):

| Param | Meaning |
|-------|---------|
| `page` | Default 1 |
| `limit` | Default 20, max 50 |
| `latitude`, `longitude` | Customer point |
| `withinDeliveryRadius=true` | With lat/lng, keep vendors inside `deliveryRadiusKm` (default 10 km). Vendors with no coordinates are left out. |
| `opened=true` | Record one `offers_opened` platform event (`source: "offers"`). Omit on polls so attribution is not inflated. Admin `GET /admin/marketing/vendor-promotions/report` counts a later non-cancelled order by that customer (`offersAttributedOrders`). Guest opens are not counted. |

```json
{
  "success": true,
  "data": {
    "source": "offers",
    "page": 1,
    "limit": 20,
    "total": 1,
    "items": [
      {
        "id": "product_id",
        "vendorId": "vendor_id",
        "name": "Tea",
        "imageUrl": null,
        "price": 2.5,
        "originalPrice": 2.5,
        "discountedPrice": 2.0,
        "onPromotion": true,
        "promotionId": "promotion_id",
        "vendor": {
          "id": "vendor_id",
          "name": "Store",
          "slug": "store",
          "logoUrl": null,
          "hasOffers": true,
          "offersLabel": "Offers"
        }
      }
    ]
  }
}
```

`originalPrice` is the catalog `price` (strike-through). `discountedPrice` is that unit after the best live price promotion. `compareAtPrice` on other item payloads is unchanged and is not this field. When they are equal (BOGO qualifying item), show the Offer label and do not strike. Percent and fixed amounts are a qty-1 card preview; checkout still applies the cart evaluator (a fixed amount is once on the eligible subtotal).

Home tile “Offers” is app UI. It should call this endpoint. Deep link `yjeek://offers` (section 7).

### Store / item payloads

On `GET /vendors`, `GET /vendors/:id`, menu `vendor`, and `GET /search` vendors:

- `hasOffers: true` when the store has any customer-live vendor promotion (including free delivery).
- `offersLabel: "Offers"` when `hasOffers` is true, otherwise `null`.
- `GET /vendors?hasOffers=true` uses that same live-promotion rule. Legacy `Offer` rows still fill `offerBadge` and do not set `hasOffers`.

On menu items, `GET /vendors/:id/products`, product detail, and `GET /search` products:

- `originalPrice`, `discountedPrice`, `onPromotion`
- `promotionId` when `onPromotion` is true, otherwise `null`
- `onPromotion: false` and both prices equal to catalog `price` when the item is not on a live price/BOGO promotion

`vouchersAccepted` is not derived from promotions and `hasOffers` is not derived from vouchers.

### Listing boost (M04 Batch 7)

Admin setting `listingBoostEnabled` on vendor-promotion settings (default **off**). No new customer field.

When it is **on**, `GET /vendors` with no `sort`, or with `sort=name`, lists stores that have a live vendor promotion (`hasOffers`) before stores that do not. Order inside each group stays the previous default order. `sort=rating`, `popular`, `fastest`, and `distance` are unchanged. When the setting is **off**, directory order is unchanged.

### Admin report (M04 Batch 8)

Not a customer endpoint. `GET /admin/marketing/vendor-promotions/report` (`MARKETING` VIEW) returns active promotion count, distinct items covered, distinct categories covered, distinct stores covered, and `offersAttributedOrders`. Cashback is unchanged. Campaign cost projection is on the campaign builder (**M05 Done**), not this payload. Founder budget approval is M11.

---

## 6. Spin wheel

**Milestone:** M07 **Done**. Probabilities stay server-side. Prizes: cashback (M01) or voucher template (M03). Rewards `spin` is live. The admin report is not a customer endpoint: `GET /admin/marketing/spin-wheels/:id/report`.

**Entry tile:** OG spin entry tiles (home tile that opens the wheel) are **M07**. They are not the Marketing › Banners screen (**M06 Done** is admin placement only). M06 did not add a spin tap on `promotions`. The app opens the tile with `yjeek://spin/{campaignId}`. This API does not place the tile.

### `GET /customer/spin/active`

**Shipped (M07 Batch 7).** Customer auth. One live wheel: `active` is on, start is null or already passed, and end is null or still ahead. When more than one wheel is live, the lowest `sortOrder` wins, then the earliest created row.

| Field | Meaning |
|-------|---------|
| `campaignId` | Live wheel id, or `null` |
| `spinsRemaining` | Spins left for this customer. `0` when nothing is live |
| `live` | `true` when `campaign` is present |
| `campaign` | Visuals below, or `null` |

`campaign` fields: `id`, `entryTileImageAr`, `entryTileImageEn`, `headerTextAr`, `headerTextEn`, `subHeaderAr`, `subHeaderEn`, `wheelBgType`, `wheelBgValue`, `screenBgType`, `screenBgValue`, `spinButtonText`, `spinButtonColor`, `startsAt`, `endsAt`, `deepLink` (`yjeek://spin/{campaignId}`), `segments`.

Each segment is `id`, `labelAr`, `labelEn`, `image`, `segmentColor`, `textColor`, `prizeType`, in clockwise order. Probabilities, prize amounts, and template ids are not in this JSON.

### `POST /customer/spin/draw`

**Shipped (M07 Batch 5).** Customer auth. Body is only `{ "campaignId" }`. Any other field, including a winning `segmentId`, is rejected.

The server picks the segment from the stored weights, writes `wheel_spins`, and returns:

- `campaignId`
- `spinsRemaining` after this spin
- `segment`: `id`, `labelAr`, `labelEn`, `image`, `segmentColor`, `textColor`, `prizeType`
- `noticeCode`: `SPIN_BUDGET_EXHAUSTED` when the daily prize cap forced try-again, otherwise `null`
- `prizeRef`: cashback ledger id, or issued voucher id. `null` for try again

**Shipped (M07 Batch 6).** The same request credits the prize once for that spin row. Cashback is an Available ledger row that expires 48 hours after the spin. A voucher or free-delivery prize is an issued M03 voucher. If that template has `validityDays` or `validTo`, those dates are used. If it has neither, the voucher expires 48 hours after the spin. There is no separate wheel expiry field. Try again does not credit and does not send a push. A second credit of the same spin does not add another row.

Probabilities are not in the JSON. No spins left is `400` `SPIN_NONE_LEFT`.

---

## 7. Push / deep links (consume)

Deep-link targets apps must handle (examples):

| `deepLink` | Opens |
|------------|--------|
| `yjeek://rewards` | My Rewards |
| `yjeek://vouchers/{id}` | Voucher detail |
| `yjeek://spin/{campaignId}` | Spin wheel |
| `yjeek://offers` | Offers |
| `yjeek://vendor/{id}` | Vendor |
| `yjeek://category/{id}` | Category |
| `yjeek://referral` | Invite a friend |
| `yjeek://orders/{id}` | Order tracking card (M08 Batch 7) |
| `yjeek://orders/{id}/chat` | Rider chat (M08 Batch 7) |

A live campaign push (**M05 Done**) uses the same scheme. The title and body are the attached marketing-notify row, not a new composer. One vendor on a linked voucher template → `yjeek://vendor/{id}`. A Missions campaign → `yjeek://rewards`. Otherwise `yjeek://offers`. Win-back still uses `yjeek://vouchers/{id}` when the voucher is issued. The deep link is on the customer notification `metadata.deepLink` and on the FCM data payload. **M08 Batch 2:** a composed push stores Arabic and English. At send time the customer’s `CustomerProfile.language` picks Arabic when it is `ar`; every other value uses English. An optional image is `metadata.imageUrl` and FCM data `imageUrl`. Category opens `yjeek://category/{id}`. **Send test** (M08 Batch 3) uses the same payload for one linked customer and sets notification `metadata.test` to `true`. Those rows are not campaign stats. **M08 Batch 4:** `CustomerProfile.marketingOptIn` (`marketing_opt_in`, default true) is set with `PATCH /api/v1/users/me` `{ "marketingOptIn": false }`. When it is false, a composed marketing push is not sent and the skip counts as an opt-out. Order-status notifications still send. The admin report `GET /admin/marketing/notifications/:id/report` returns `sent`, `delivered`, `opened`, `orderedWithin24h`, and `optOuts`. `delivered` is set only when FCM accepts a token. `opened` counts an in-app mark-read of that notification (`metadata.pushLogId`); there is no FCM open receipt. `orderedWithin24h` counts a customer once when they place a non-cancelled, non-rejected order after the send and within 24 hours. **M08 Batch 5:** each automated trigger has an admin on/off and a max per customer per Bahrain week (Monday 00:00 Asia/Bahrain) on `GET/PATCH /admin/marketing/push-triggers`. Cart abandon, expiry, win-back, and birthday seed at 1. Cashback credited and referral rewarded seed on with no cap. An empty cap means no weekly limit. Composer blasts are not capped by these rows. **M08 Batch 6:** a cart with items is reminded about 30 minutes after its last change, once for that idle cart (`metadata.kind` `cart_abandon`). Credits and vouchers expiring within 24 hours get one reminder per row (`cashback_expiry_reminder_24h`, `referral_expiry_reminder_24h`, `voucher_expiry_reminder_24h`). Vouchers also get one 7-day reminder (`voucher_expiry_reminder_7d`). A customer with `dateOfBirth` is scanned on the Bahrain calendar day; an active birthday distribution rule issues once per Bahrain year, and the push is once per year. The 14-day win-back reminder (`win_back_inactive_14d`) does not issue a voucher and does not send when a live Win-back campaign covers that customer or a win-back push was already sent today. These new reminders skip `marketingOptIn: false`. Order lock-screen UI stays the app; M08 only adds status payloads.

**M06 Done:** banner management moved under Admin › Marketing. Customer banner payloads and these deep links are unchanged. Banner taps stay `OPEN_STORE`, `OPEN_CATEGORY`, `OPEN_OFFER`, `OPEN_URL`, `OPEN_CHAMP_SCREEN`, or `NONE`. `yjeek://spin/{campaignId}` is the spin target for **M07**, not a banner field added in M06.

Exact scheme follows existing app convention when known. **M13 Done** froze this scheme in this file and in `05`.

Transactional order-tracking pushes are separate from marketing (OG §08). See §7b.

### 7b. Order tracking payloads (M08 Batch 7)

The lock-screen card is app UI (iOS Live Activities / Android ongoing notification). Backend sends one customer notification when the order enters a stage. `marketingOptIn: false` does not suppress these.

| `stage` | Written when status becomes | Title | Body |
|---------|------------------------------|-------|------|
| `confirmed` | `CONFIRMED` or `VENDOR_ACCEPTED` | Confirmed | Confirmed |
| `preparing` | `PREPARING` | Preparing | Preparing |
| `on_the_way` | `PICKED_UP`, `ON_THE_WAY`, `IN_TRANSIT`, or `ARRIVED_AT_CUSTOMER` | On the way | `etaWindow`, or “On the way” |
| `delivered` | `DELIVERED` | Delivered | Order delivered — Enjoy your order! |

`type` is `ORDER_UPDATE`. `metadata.kind` is `order_tracking`. `metadata.deepLink` is `yjeek://orders/{orderId}`. `metadata.etaWindow` is set only for `on_the_way`. A later status on the same stage does not send another payload. FCM `data` copies `kind`, `stage`, `etaWindow`, and `deepLink`.

`etaWindow` uses `windowStartAt`–`windowEndAt` when both are set. Otherwise it adds `estimatedArrivalMin` and `estimatedArrivalMax` to the send time and formats Asia/Bahrain as `Arrives h:mm–h:mm AM/PM`. A minute window that has already ended is omitted.

Rider chat is a different notification: `type` `GENERAL`, `metadata.kind` `rider_chat`, no `stage`. Title is “Rider”. Body is the message. Deep link is `yjeek://orders/{orderId}/chat`. Active driver threads today are operations (`DISPATCH`) and do not use this payload. A `CUSTOMER_DRIVER` rider message does.

**M08 Done. M12 Done** runs expiry reminders at **10:00 Asia/Bahrain** and removes dead push tokens at **02:00**. The customer sets `marketingOptIn` on `PATCH /api/v1/users/me`. After a token is removed, the next app open must register a fresh FCM token. A token whose `registeredAt` is older than 90 days is removed even if FCM has not rejected it yet.

---

## 7a. Live campaign windows (flash deal · happy hour)

**Milestone:** M05 Done (windows shipped in Batch 4; banner tap in Batch 7). Public. No customer JWT.

**Live path:** `GET /api/v1/customer/campaigns/windows`

Query: `vendorId` optional. When set, a row is kept when a linked voucher template is `ALL` or `VENDOR` and lists that store. A category-scoped template does not pin a store page.

Returns LIVE flash deals and happy hours whose `endsAt` is still in the future (or unset). Times are Bahrain (`Asia/Bahrain`, UTC+3). Happy hour `windowDaysOfWeek` is ISO 1=Monday … 7=Sunday; empty means every day. The end clock is exclusive.

```json
{
  "success": true,
  "data": {
    "timezone": "Asia/Bahrain",
    "campaigns": [
      {
        "id": "…",
        "name": "30% off Vendor X",
        "type": "FLASH_DEAL",
        "startsAt": "2026-09-27T10:00:00.000Z",
        "endsAt": "2026-09-27T12:00:00.000Z",
        "windowStartTime": null,
        "windowEndTime": null,
        "windowDaysOfWeek": [],
        "bannerId": "…",
        "banner": {
          "id": "…",
          "title": "Flash Friday",
          "imageUrl": null,
          "isActive": true,
          "tapAction": "OPEN_STORE",
          "targetId": "vendor_id",
          "ctaUrl": null
        },
        "inWindow": true,
        "countdownEndsAt": "2026-09-27T12:00:00.000Z",
        "templates": [
          { "id": "…", "name": "30% off", "scope": "VENDOR", "scopeIds": ["vendor_id"], "fundedBy": "VENDOR" }
        ]
      }
    ]
  }
}
```

`inWindow` is false before the flash start, or outside today's happy hour. `countdownEndsAt` is set only while the window is open: the flash `endsAt`, or today's Bahrain happy-hour end. Discount and funded-by stay on the voucher template. Banner image is the linked UI Editor row when `bannerId` is set. After activate, that row also includes `tapAction`, `targetId`, and `ctaUrl`: `OPEN_STORE` plus the vendor id when the voucher is for one store, otherwise `OPEN_URL` and `ctaUrl` `yjeek://offers`.

---

## 7b. On-time promise banner

**Milestone:** M05 Done (Batch 6). Public. No customer JWT.

**Live path:** `GET /api/v1/customer/campaigns/on-time-promise`

The late-delivery amount stays `systemConfig.lateDeliveryCreditBhd` (default BHD 1.000). A late order issues one FIXED_AMOUNT voucher from the template named **On-time promise** (`source` compensation, funded by Yjeek). This endpoint is the branded banner copy. It creates that template and its `ORDER_LATE` rule when they are missing. `active` is false when the rule or template is off, or when the late-delivery amount is 0.

```json
{
  "success": true,
  "data": {
    "name": "On-time promise",
    "bannerTitle": "On-Time Promise",
    "bannerBody": "Sorry we were late — here's BHD 1.000 on us",
    "label": "Sorry we were late — here's BHD 1.000 on us",
    "active": true,
    "ruleId": "…",
    "template": {
      "id": "…",
      "name": "On-time promise",
      "type": "FIXED_AMOUNT",
      "value": "1.000",
      "fundedBy": "YJEEK",
      "source": "COMPENSATION",
      "validityDays": 14
    }
  }
}
```

The same `bannerTitle` and `bannerBody` are on the customer notification when the voucher is issued. The voucher list title is the template name. Validity is 14 days at seed (the template form default); OG does not set a validity. Admin can edit validity on the template. The face value is kept equal to the late-delivery setting.

---

## 8. Error envelope

Use existing backend error shape. Marketing-specific codes (illustrative):

| Code | Meaning |
|------|---------|
| `CASHBACK_NONE` | Preview 0 (e.g. fully wallet-paid) |
| `VOUCHER_NOT_APPLICABLE` | With reason |
| `VOUCHER_EXPIRED_IN_CART` | Re-evaluate totals |
| `VOUCHER_WALLET_EXCLUSIVE` | Voucher selected with MAIN wallet / YJEEK_WALLET |
| `REFERRAL_RATE_LIMIT` | Day/month cap |
| `REFERRAL_BLOCKED` | Fraud/self-invite/etc. |
| `REFERRAL_CREDIT_MIN_ORDER` | Referral credit blocked — item value below min |
| `REFERRAL_CREDIT_BLOCKED` | Referral credit cannot apply (e.g. no available credit) |
| `REFERRAL_CREDIT_INSUFFICIENT` | Ledger balance too low at apply time |
| `SPIN_NONE_LEFT` | No spins |
| `SPIN_BUDGET_EXHAUSTED` | Forced try-again outcome |

---

## 9. Implementation note for backend

All customer routes in the tables below are live. Do not return 501 for them.

**Shipped (M01 closeout & M13):**

| Surface | Status |
|---------|--------|
| `GET /customer/rewards/summary` | Live — Available, Pending, Expiring soon (7-day window), Withdraw; **M03 B6** `vouchers.activeCount` |
| Cart/checkout `cashbackPreview` + legacy `cashbackEarn` | Live via `quoteCashback` |
| Available credit on Delivered + reverse on full refund/cancel | Live |
| Expire job + 7-day and 24-hour reminder pushes | Live — **03:00** expire and **10:00** reminders, Asia/Bahrain (**M12 Done**) |
| `GET /customer/wallet/ledger` | **Live (M13 B2)** — Available, Expired, Reversed, Frozen rows for signed-in customer with cursor pagination |
| OG vouchers / spin / missions APIs | **M03 Done:** vouchers list/evaluate/lifecycle/discovery; **M04 Done:** Offers feed + store/item badges + listing boost on default `GET /vendors` when the admin toggle is on; admin Offers order count uses `opened=true`; **M05 Done:** `GET /customer/campaigns/windows` (flash / happy hour, banner tap deep link), rewards `missions[]`, `GET /customer/campaigns/on-time-promise`. **M07 Done:** `GET /customer/spin/active`, `POST /customer/spin/draw` (prize credit, `prizeRef`), and Rewards `spin` (`campaignId`, `spinsRemaining`, `live`). Entry tile deep link `yjeek://spin/{campaignId}`. The reset job runs at **00:00 Asia/Bahrain**; the allowance day is still **UTC midnight** (03:00 Bahrain) |
| Push and order tracking | **M08 Done:** composed push uses `CustomerProfile.language` (`ar` or English), `metadata.imageUrl`, and `metadata.deepLink`. `PATCH /api/v1/users/me` `{ "marketingOptIn": false }` skips composed and reminder pushes. Order-status payloads are §7b (`order_tracking`). Rider chat is `rider_chat`. **M12 Done:** 10:00 reminder clock and 02:00 `token_cleanup` |
| Automatic vouchers | **M12 Done:** hourly `FIRST_ORDER` and `NO_ORDER_N_DAYS` rules issue vouchers that appear on `GET /customer/vouchers`. No new customer route. Birthday still issues on the same hourly job |

**Shipped (M02 — Done):**

| Surface | Status |
|---------|--------|
| `GET /customer/referral/me` | Live — settings snapshot + day/month remaining quota |
| `POST /customer/referral/invites` | Live — create `INVITED` + WhatsApp/SMS share payload; blocked when programme paused / budget exhausted / inviter blocked |
| `GET /customer/referral/invites` | Live — list by status (+ reason) |
| Registration match + dual credit | Live — on OTP verify for new customers; optional `deviceId` |
| Checkout / confirm `referralCreditAmount` | Live — min order + coverage clamp; FIFO `REFERRAL_BONUS` spend (`FROZEN` excluded) |
| Credit + invite expiry + 7d and 24h remind | Live — **03:00** expire, **10:00** reminders (Asia/Bahrain) |
| Monthly programme budget pause | Live — auto-pause + ops alert at 100% spend. Hourly budget sweep is **M12 Done** |
| Pattern freeze hooks | Live — **04:00** scan; review queue is **M10 Done** (admin only) |

All customer routes in the tables above are live.

---

## 10. Clocks and automatic vouchers (M12 Done)

No new customer routes. These times are Asia/Bahrain.

| Time | What the app sees |
|------|-------------------|
| 00:00 | The spin reset job runs. The allowance **day is still UTC midnight** (03:00 Asia/Bahrain). `spinsRemaining` follows that UTC day on the next read of rewards summary or `GET /customer/spin/active`, even if this job is late |
| 02:00 | Dead FCM tokens are removed (FCM-rejected, malformed, or `registeredAt` older than 90 days). A valid token stays. Register a new token on the next launch if pushes stop |
| 03:00 | Cashback, referral credits, referral invites, and vouchers past their end time become expired. Refresh rewards summary and the voucher list |
| 04:00 | Referral pattern scan. No customer payload. Frozen referral credit stops applying at checkout |
| 10:00 | Expiry reminders: cashback and referral at 7 days and at 24 hours; vouchers at 7 days and at 24 hours. One push per row per window |
| Hourly | `FIRST_ORDER` and `NO_ORDER_N_DAYS` distribution rules can add a voucher. Birthday vouchers and the 14-day win-back reminder use the same hour. Refresh `GET /customer/vouchers` |

`FIRST_ORDER` issues once, to a customer who has exactly one non-cancelled order, when an admin rule with that trigger is active. `NO_ORDER_N_DAYS` uses the rule’s `triggerDays` (default 14). The voucher then uses the same list, evaluate, and checkout paths as any other issued voucher.

Cart-abandon reminders stay on a 5-minute check, about 30 minutes after the last cart change. That is not one of the clocks above.

Push `metadata.kind` values the app should branch on:

| `kind` | Open |
|--------|------|
| `cashback_expiry_reminder_7d` | My Rewards. This row has **no** `deepLink` |
| `cashback_expiry_reminder_24h` | `yjeek://rewards` |
| `referral_expiry_reminder_7d` | `yjeek://rewards` |
| `referral_expiry_reminder_24h` | `yjeek://rewards` |
| `voucher_expiry_reminder_7d` | `yjeek://vouchers/{id}` |
| `voucher_expiry_reminder_24h` | `yjeek://vouchers/{id}` |
| `cart_abandon` | Cart. This row has **no** `deepLink` (`metadata.cartId` is set) |
| `win_back_inactive_14d` | Offers. This row has **no** `deepLink` and does not issue a voucher |
| `birthday` | `yjeek://vouchers/{id}` when a voucher was issued; otherwise no `deepLink` |
| `order_tracking` | `yjeek://orders/{id}` |
| `rider_chat` | `yjeek://orders/{id}/chat` |

Cashback credited uses `metadata.trigger` `cashback_credited` and has no `kind`. Referral rewarded uses `metadata.trigger` `referral_rewarded` and `deepLink` `yjeek://rewards`.

