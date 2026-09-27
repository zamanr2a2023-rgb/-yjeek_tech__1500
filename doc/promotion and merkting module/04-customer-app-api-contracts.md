# Customer App API Contracts — Marketing Module v1

**Audience:** Mobile (customer) team + backend implementers.  
**Status:** Contract draft NOW (decision: ship before/while backend builds).  
**Source:** OG §01–§12. Rider/driver APIs: none.  
**Currency:** BHD, 3 decimal places.  
**Auth:** Existing customer Bearer JWT unless noted.

Base path assumes existing API prefix (e.g. `/api/v1`). Adjust to match `yjeek_backend` conventions when implementing; keep resource names stable.

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

OG: Available · Pending · Expiring soon · Withdraw (existing rules).

**Shipped mapping (M01):** `available` ← `Wallet.cashback`; `pending` ← `Wallet.cashbackPending` (usually `0.000` — Available is credited on Delivered, not pending); `expiringSoon` / `expiringSoonBy` ← sum / earliest `expiresAt` of Available `CASHBACK` ledger rows in the next 7 days; `withdrawable` ← `Wallet.balance`. **M03 B6:** `vouchers.activeCount` = ACTIVE issued vouchers still within `validTo`. **M05 Ready:** `missions[]` filled when Missions campaigns ship (empty until then). Spin empty until M07.

### `GET /customer/wallet/ledger`

Query: `status?=available|expired|reversed`, `type?=cashback|referral_bonus|…`, `cursor`, `limit`.

Ledger row: `id`, `type`, `amount`, `status`, `withdrawable`, `expiresAt`, `orderId`, `createdAt`, `sourceRef`.

**Status (M01 closeout):** Not shipped yet — track for M13 app freeze / wallet surface. Engine writes Available / Expired / Reversed on `wallet_transactions`; rewards summary already exposes Available + Expiring soon.

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

**Lifecycle (M01):** Available credit (+ push “BHD X cashback added”) on Delivered / Collected / Completed — not on payment capture. Full refund / cancel → Reversed. Daily job: past `expiresAt` → Expired; push once 7 days before expiry. Partial refund does **not** reverse cashback (see M01 Batch 5 findings).

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
| Both sides `WalletTransaction` type `REFERRAL_BONUS`, `status=AVAILABLE`, `withdrawable=false`, expiry from settings | Invite → `REJECTED` + reason; no credit; fraud stub for M10 |
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

Daily job (shared lease with cashback expiry):

| Transition | Rule |
|------------|------|
| Referral credit → Expired | Available `REFERRAL_BONUS` past `expiresAt` (default 30d from credit) |
| Invite → Expired | Open `INVITED` past invite `expiresAt` (default 30d from send) |
| 7-day reminder | Push once per Available referral credit entering the 7-day window |

**Monthly programme budget:** when sum of referral bonuses issued this UTC month ≥ `monthlyBudget` (Admin-configured; `null` = uncapped), programme pauses (`programmeEnabled=false`) and ops is alerted (`OpsIncident` type `REFERRAL_BUDGET_PAUSE`). New invites return `REFERRAL_BLOCKED`; new match rewards reject with `programme_disabled` (no credit).

### Pattern freeze (pre-M10)

Daily scan detects OG patterns and freezes the inviter (no customer API change):

| Signal | Action |
|--------|--------|
| ≥ 5 rewarded invitees with 0 orders after 14 days | Inviter unused `REFERRAL_BONUS` → ledger `FROZEN`; invite ability paused |
| Same device on 2+ rewarded invites | Same |
| Bulk: ≥ `invitesPerMonth` zero-order rewards in UTC month | Same |

Writes `fraud_flags` (`decision=null`) + ops incident `REFERRAL_PATTERN_FREEZE` for **M10** Fraud & Limits review queue (Release / Cancel credits / Suspend). Full queue UI is out of M02.

---

## 5. Offers discovery

**Milestone:** M04 (execution deep — Ready). Vendor-funded promotions only — **not** M03 vouchers (`vouchersAccepted` is separate).

### `GET /customer/offers/items`

Lists items on **live vendor promotions** across vendors. Pagination + zone filters as needed.

### Store / item payloads

- Store card: `hasOffers: true` / label `"Offers"`.
- Item: `originalPrice`, `discountedPrice`, `onPromotion: true`.

---

## 6. Spin wheel

### `GET /customer/spin/active`

Campaign visuals + `spinsRemaining` + segments (labels only; **probabilities not exposed**).

### `POST /customer/spin/draw`

Server-side weighted draw. Response: winning segment + prize credit result. Client animation follows server outcome.

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
| `yjeek://referral` | Invite a friend |

Exact scheme follows existing app convention when known; document final scheme in M13.

Transactional order-tracking pushes are separate from marketing (OG §08).

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

Until each milestone ships, endpoints may 501 with `{ "error": "NOT_IMPLEMENTED", "milestone": "M0x" }`. Prefer shipping shapes early with empty data over silent absence so mobile can integrate.

**Shipped (M01 closeout):**

| Surface | Status |
|---------|--------|
| `GET /customer/rewards/summary` | Live — Available, Pending, Expiring soon (7-day window), Withdraw; **M03 B6** `vouchers.activeCount` |
| Cart/checkout `cashbackPreview` + legacy `cashbackEarn` | Live via `quoteCashback` |
| Available credit on Delivered + reverse on full refund/cancel | Live |
| Expire job + 7-day reminder push | Live (daily lease) |
| `GET /customer/wallet/ledger` | **Not shipped** — M13 |
| OG vouchers / spin / missions APIs | **M03 Done:** vouchers list/evaluate/lifecycle/discovery; **M04 Ready:** Offers feed/badges; **M05 Ready:** missions on rewards summary; spin → M07 |

**Shipped (M02 — Done):**

| Surface | Status |
|---------|--------|
| `GET /customer/referral/me` | Live — settings snapshot + day/month remaining quota |
| `POST /customer/referral/invites` | Live — create `INVITED` + WhatsApp/SMS share payload; blocked when programme paused / budget exhausted / inviter blocked |
| `GET /customer/referral/invites` | Live — list by status (+ reason) |
| Registration match + dual credit | Live — on OTP verify for new customers; optional `deviceId` |
| Checkout / confirm `referralCreditAmount` | Live — min order + coverage clamp; FIFO `REFERRAL_BONUS` spend (`FROZEN` excluded) |
| Credit + invite expiry + 7d remind | Live — daily lease with cashback tick |
| Monthly programme budget pause | Live — auto-pause + ops alert at 100% spend |
| Pattern freeze hooks | Live — freezes credits + `fraud_flags` lite; review queue → M10 |

Until each remaining milestone ships, endpoints may 501 with `{ "error": "NOT_IMPLEMENTED", "milestone": "M0x" }`. Prefer shipping shapes early with empty data over silent absence so mobile can integrate.
