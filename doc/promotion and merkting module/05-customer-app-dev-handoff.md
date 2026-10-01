# Customer App Dev Handoff — Marketing Module v1

> **Status: FROZEN (v1-freeze)**  
> **Date:** 2026-09-30  
> **Backend Delivery Status:** All marketing customer APIs are live and tested in `yjeek_backend` (M01–M13).  
> **For:** Customer mobile developers.  
> **Not for:** Rider/driver apps.  
> **Source of truth for rules:** OG HTML. This file translates UX expectations.

## What backend/admin/vendor will deliver

Engines, admin config, vendor acceptance, and the APIs in `04-customer-app-api-contracts.md`.

## What mobile must build (OG §12)

### A. My Rewards (new tab)

1. Wallet: Available · Pending · Expiring soon · Withdraw (keep existing withdraw rules).
2. Vouchers: active with countdown · used · expired.
3. Spin wheel tile when a campaign is live + spins remaining.
4. Mission progress from `GET /customer/rewards/summary` `missions[]` (`id`, `title`, `progress`, `target`) while that campaign is live (**M05 Done**).
5. Referral credit appears in the wallet **summary** (`available` is cashback only; referral spend is the checkout field `referralCreditAvailable`). A per-row ledger list is **live** (`GET /customer/wallet/ledger`). **Invite a friend** lives under Profile / Account (not only Rewards).

### B. Checkout additions

1. Vouchers section: applicable vs not applicable **with reason**.
2. Auto-select best applicable voucher (server indicates `autoSelect`).
3. “Use wallet balance” toggle — **disabled** when a voucher is selected.
4. Keep existing: Wallet + COD not permitted.
5. Live line: “You will earn BHD X.XXX cashback” from `cashbackPreview` after voucher/discount changes.
6. Optional **referral credit** apply (`referralCreditAmount`) — separate from MAIN wallet; server enforces min order (default BHD 5.000) and coverage cap (default 50%); show clamped applied amount from checkout extras.

### C. Offers (new home category) — APIs live (M04 Done)

1. Home tile “Offers” beside existing categories (app UI). Data: `GET /customer/offers/items`.
2. That screen lists items on a live vendor price or BOGO promotion (all vendors in the delivery zone when `withinDeliveryRadius=true`).
3. Store cards: when `hasOffers === true`, show `offersLabel` (**"Offers"**). `GET /vendors`, vendor detail, menu vendor, and search.
4. Item cards: strike `originalPrice`, show `discountedPrice`, Offer label when `onPromotion === true`. Menu, product list/detail, and search.
5. Do not use `vouchersAccepted` for this label.
6. Optional: call the feed with `opened=true` once when the Offers screen opens. Do not send it on every page poll. Admin counts a later order by that customer. Cashback copy is unchanged.

### C2. Voucher discovery on store listing (M03 B11 — APIs live)

1. Store cards: when `vouchersAccepted === true`, show badge from `vouchersAcceptedBadge` (**"Vouchers accepted"**).
2. Listing filter **"Accepts my vouchers"** → `GET /vendors?acceptsMyVouchers=true` with customer JWT.
3. Optional: use per-card `acceptsMyVouchers` (boolean when logged in) to highlight stores that take the user's vouchers without applying the filter.
4. No typed voucher codes; discovery is badge/filter only (checkout evaluate remains separate).

### D. Profile — Invite a friend

1. Enter number or contacts (permission once).
2. Call `POST /customer/referral/invites` → share WhatsApp (preferred) or SMS via returned `share` payload (app opens the channel).
3. List from `GET /customer/referral/invites`: **Invited · Rewarded · Expired · Rejected** (+ show `reason` when Rejected).
4. Settings / quota from `GET /customer/referral/me` (remaining day/month; hide send when `programmeEnabled` false).
5. On new registration OTP verify, pass stable `deviceId` when available (fraud new-device gate).
6. Dual reward push opens My Rewards (`yjeek://rewards`); invite entry deep link `yjeek://referral`.

### E. Campaign windows and On-time promise — APIs live (M05 Done)

1. Flash deal and happy hour: `GET /customer/campaigns/windows`. Use `inWindow` and `countdownEndsAt`. Banner tap uses `banner.tapAction`, `targetId`, and `ctaUrl`.
2. On-time promise: `GET /customer/campaigns/on-time-promise`. Show `bannerTitle` and `bannerBody` when `active` is true. The amount is the existing late-delivery compensation, issued as a labelled voucher.
3. A live campaign push opens `yjeek://offers`, `yjeek://vendor/{id}`, or `yjeek://rewards`. Win-back opens `yjeek://vouchers/{id}`.

### F. Spin wheel screen — APIs live (M07 Done)

1. Home entry tile opens `yjeek://spin/{campaignId}`. Visuals and spins left: `GET /customer/spin/active`. Segments have no probabilities.
2. My Rewards tile: `GET /customer/rewards/summary` `spin` (`campaignId`, `spinsRemaining`, `live`).
3. Call `POST /customer/spin/draw` with `{ campaignId }` only. Animate to the **server-chosen** segment. The prize is already credited. `prizeRef` is the cashback ledger id or the issued voucher id. Try again leaves `prizeRef` null.
4. The reset job runs at **00:00 Asia/Bahrain**. A new `spinsRemaining` appears at **UTC midnight** (03:00 Bahrain), because the allowance day is still UTC. Refresh the summary after that.

### G. Vouchers that appear without a tap (M12 Done)

Hourly jobs can add a voucher the customer did not request. Show it on the next `GET /customer/vouchers` refresh. There is no extra endpoint.

- First non-cancelled order, when an admin `FIRST_ORDER` rule is on.
- No orders for N days (`NO_ORDER_N_DAYS`, default 14).
- Birthday, when `dateOfBirth` matches the Bahrain calendar day and a birthday rule is on. The push `kind` is `birthday`.

Expired vouchers, cashback, and referral credits flip at **03:00 Asia/Bahrain**. Refresh the voucher list and rewards summary after that if the app stays open overnight.

## Push copy expectations (examples)

Times below are Asia/Bahrain. Expiry reminders are sent at **10:00**. Marketing opt-out (`marketingOptIn: false`) hides these marketing pushes and does not hide order tracking.

| Event | `metadata` | Open |
|-------|------------|------|
| Cashback credited | `trigger` `cashback_credited`. No `kind`, no `deepLink`. Body `BHD X.XXX cashback added` | My Rewards |
| Cashback expiring in 7 days | `kind` `cashback_expiry_reminder_7d`. No `deepLink` | My Rewards |
| Cashback or referral expiring in 24 hours | `kind` `cashback_expiry_reminder_24h` or `referral_expiry_reminder_24h`. `deepLink` `yjeek://rewards` | My Rewards |
| Referral both sides rewarded | `trigger` `referral_rewarded`. `deepLink` `yjeek://rewards`. Body `Your BHD X.XXX referral credit is in your wallet` | My Rewards |
| Referral credit expiring in 7 days | `kind` `referral_expiry_reminder_7d`. `deepLink` `yjeek://rewards` | My Rewards |
| Voucher expiring in 7 days or 24 hours | `kind` `voucher_expiry_reminder_7d` or `voucher_expiry_reminder_24h`. `deepLink` `yjeek://vouchers/{id}` | That voucher |
| Cart abandonment ~30 min | `kind` `cart_abandon`. No `deepLink`. `cartId` is set | Cart |
| 14-day inactivity | `kind` `win_back_inactive_14d`. No voucher issued. No `deepLink` | Offers |
| Birthday | `kind` `birthday`. `deepLink` `yjeek://vouchers/{id}` only when a voucher was issued | That voucher, or Rewards |
| Order tracking states | `kind` `order_tracking`. See below. Opt-out does not hide them | `yjeek://orders/{id}` |
| Campaign goes live | Title and body from the attached marketing push | `yjeek://offers`, `yjeek://vendor/{id}`, or `yjeek://rewards` |
| Win-back voucher issued | Same attached push, once | `yjeek://vouchers/{id}` |
| Late delivery (On-time promise) | Banner copy from `GET /customer/campaigns/on-time-promise` | The issued voucher |

Register the FCM token on launch. A nightly cleanup at **02:00** drops tokens FCM has rejected and tokens whose `registeredAt` is older than 90 days. A still-valid token is kept.

### Order tracking payloads (M08 Batch 7)

Render the lock-screen card in the app. Backend does not draw it.

One push per stage change. `metadata.kind` `order_tracking`, `type` `ORDER_UPDATE`, `stage` `confirmed` | `preparing` | `on_the_way` | `delivered`. Open `metadata.deepLink` `yjeek://orders/{orderId}`. On `on_the_way`, show `etaWindow` when present (`Arrives 2:00–2:10 PM`). Delivered body is exactly `Order delivered — Enjoy your order!`.

A rider message is `metadata.kind` `rider_chat` and `type` `GENERAL`, with no `stage`. Open `yjeek://orders/{orderId}/chat`. Keep it off the status card.

## Non-goals for mobile (this pack)

- Creating vouchers or cashback rules.
- Vendor promo creation.
- Fraud review UI.
- Typed promo-code entry if product removes it later; today legacy codes may still exist — coordinate with backend before removing any code-entry UI.

## Sample JSON Payloads (Real Shapes)

### 1. Rewards Summary (`GET /api/v1/customer/rewards/summary`)
```json
{
  "success": true,
  "data": {
    "wallet": {
      "available": "12.500",
      "pending": "0.000",
      "expiringSoon": "1.200",
      "expiringSoonBy": "2026-10-07T00:00:00.000Z",
      "withdrawable": "8.000"
    },
    "vouchers": { "activeCount": 2 },
    "spin": { "campaignId": "cm123spin", "spinsRemaining": 1, "live": true },
    "missions": [
      { "id": "cm123mission", "title": "5 Orders this week", "progress": 2, "target": 5 }
    ]
  }
}
```

### 2. Wallet Ledger Page (`GET /api/v1/customer/wallet/ledger`)
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "cuid_tx1",
        "type": "cashback",
        "amount": "0.750",
        "status": "available",
        "withdrawable": true,
        "expiresAt": "2026-10-30T10:00:00.000Z",
        "orderId": "order_test_123",
        "createdAt": "2026-09-30T09:00:00.000Z",
        "sourceRef": "order:order_test_123"
      },
      {
        "id": "cuid_tx2",
        "type": "referral_bonus",
        "amount": "1.000",
        "status": "available",
        "withdrawable": false,
        "expiresAt": "2026-10-30T10:00:00.000Z",
        "orderId": null,
        "createdAt": "2026-09-30T09:30:00.000Z",
        "sourceRef": "referral_match:invite_999"
      }
    ],
    "nextCursor": null,
    "hasMore": false
  }
}
```

### 3. Voucher Evaluate (`POST /api/v1/customer/checkout/vouchers/evaluate`)
```json
{
  "success": true,
  "data": {
    "applicable": [
      { "voucherId": "vch_123", "estimatedSaving": "2.000", "autoSelect": true }
    ],
    "notApplicable": [
      { "voucherId": "vch_456", "reason": "Add BHD 1.200 more" }
    ]
  }
}
```

### 4. Cashback Preview (Cart & Checkout Quote)
```json
{
  "amount": "0.300",
  "rate": "0.030",
  "paidOwn": "10.000",
  "message": "You will earn BHD 0.300 cashback"
}
```

### 5. Offers Feed Item (`GET /api/v1/customer/offers/items`)

One element of `data.items`. The HTTP body is `{ "success": true, "data": { "source": "offers", "page": 1, "limit": 20, "total": 1, "items": [ … ] } }`.

```json
{
  "id": "prod_tea_1",
  "vendorId": "vnd_store_1",
  "name": "Karak Tea",
  "imageUrl": "https://cdn.yjeek.com/items/tea.jpg",
  "price": 2.5,
  "originalPrice": 2.5,
  "discountedPrice": 2.0,
  "onPromotion": true,
  "promotionId": "promo_deal_1",
  "vendor": {
    "id": "vnd_store_1",
    "name": "Chai & Karak House",
    "slug": "chai-karak-house",
    "logoUrl": "https://cdn.yjeek.com/vendors/chai.png",
    "hasOffers": true,
    "offersLabel": "Offers"
  }
}
```

### 6. Spin Active (`GET /api/v1/customer/spin/active`)
```json
{
  "success": true,
  "data": {
    "campaignId": "cm_wheel_1",
    "spinsRemaining": 1,
    "live": true,
    "campaign": {
      "id": "cm_wheel_1",
      "entryTileImageAr": "https://cdn.yjeek.com/spin/tile-ar.png",
      "entryTileImageEn": "https://cdn.yjeek.com/spin/tile-en.png",
      "headerTextAr": "أدر العجلة",
      "headerTextEn": "Spin the Wheel",
      "subHeaderAr": "اربح جوائز فورية",
      "subHeaderEn": "Win instant prizes",
      "wheelBgType": "COLOR",
      "wheelBgValue": "#111827",
      "screenBgType": "COLOR",
      "screenBgValue": "#030712",
      "spinButtonText": "SPIN",
      "spinButtonColor": "#F59E0B",
      "startsAt": "2026-09-01T00:00:00.000Z",
      "endsAt": "2026-10-31T23:59:59.000Z",
      "deepLink": "yjeek://spin/cm_wheel_1",
      "segments": [
        {
          "id": "seg_1",
          "labelAr": "0.500 د.ب كاشباك",
          "labelEn": "BHD 0.500 Cashback",
          "image": null,
          "segmentColor": "#3B82F6",
          "textColor": "#FFFFFF",
          "prizeType": "CASHBACK"
        },
        {
          "id": "seg_2",
          "labelAr": "حاول مرة أخرى",
          "labelEn": "Try Again",
          "image": null,
          "segmentColor": "#6B7280",
          "textColor": "#FFFFFF",
          "prizeType": "NONE"
        }
      ]
    }
  }
}
```

### 7. Spin Draw (`POST /api/v1/customer/spin/draw`)
```json
{
  "success": true,
  "data": {
    "campaignId": "cm_wheel_1",
    "spinsRemaining": 0,
    "noticeCode": null,
    "segment": {
      "id": "seg_1",
      "labelAr": "0.500 د.ب كاشباك",
      "labelEn": "BHD 0.500 Cashback",
      "image": null,
      "segmentColor": "#3B82F6",
      "textColor": "#FFFFFF",
      "prizeType": "CASHBACK"
    },
    "prizeRef": "cuid_cashback_tx_777"
  }
}
```

### 8. Referral Me (`GET /api/v1/customer/referral/me`)
```json
{
  "success": true,
  "data": {
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
}
```

### 9. Campaign Windows (`GET /api/v1/customer/campaigns/windows`)
```json
{
  "success": true,
  "data": {
    "timezone": "Asia/Bahrain",
    "campaigns": [
      {
        "id": "cmp_flash_1",
        "name": "Flash Friday 30% Off",
        "type": "FLASH_DEAL",
        "startsAt": "2026-10-02T10:00:00.000Z",
        "endsAt": "2026-10-02T14:00:00.000Z",
        "windowStartTime": null,
        "windowEndTime": null,
        "windowDaysOfWeek": [],
        "bannerId": "ban_flash_1",
        "banner": {
          "id": "ban_flash_1",
          "title": "Flash Friday",
          "imageUrl": "https://cdn.yjeek.com/banners/flash.jpg",
          "isActive": true,
          "tapAction": "OPEN_STORE",
          "targetId": "vnd_store_1",
          "ctaUrl": null
        },
        "inWindow": true,
        "countdownEndsAt": "2026-10-02T14:00:00.000Z",
        "templates": [
          {
            "id": "vtpl_1",
            "name": "30% off Store",
            "scope": "VENDOR",
            "scopeIds": ["vnd_store_1"],
            "fundedBy": "VENDOR"
          }
        ]
      }
    ]
  }
}
```

### 10. Order Tracking Notification Payload (`metadata.kind = order_tracking`)

`orderId` is the notification column, not a metadata field. On the way, `body` is `etaWindow` when that window exists, otherwise the title `On the way`.

```json
{
  "type": "ORDER_UPDATE",
  "title": "On the way",
  "body": "Arrives 2:00–2:10 PM",
  "orderId": "ord_12345",
  "metadata": {
    "kind": "order_tracking",
    "stage": "on_the_way",
    "etaWindow": "Arrives 2:00–2:10 PM",
    "deepLink": "yjeek://orders/ord_12345"
  }
}
```

---

## Acceptance checklist for mobile

*(All backend endpoints are live. Mobile team checks off UI implementation as screens are built).*

- [ ] My Rewards shows wallet buckets from summary API `GET /api/v1/customer/rewards/summary` *(API Live)*
- [ ] Checkout cashback line matches `paid_own` rule via `cashbackPreview` *(API Live)*
- [ ] Voucher selected ⇒ wallet toggle off (`VOUCHER_WALLET_EXCLUSIVE` rejection enforced) *(API Live)*
- [ ] Store cards show “Vouchers accepted” from `vouchersAcceptedBadge`; filter `acceptsMyVouchers=true` *(API Live)*
- [ ] Offers feed (`GET /api/v1/customer/offers/items`) + store/item badges *(API Live)*
- [ ] Invite flow + invite list statuses (incl. Rejected + reason) via `GET/POST /api/v1/customer/referral/` *(API Live)*
- [ ] Checkout referral credit apply respects min order / coverage clamp *(API Live)*
- [ ] Mission progress matches rewards summary `missions[]` *(API Live)*
- [ ] Flash / happy hour countdown uses `campaigns/windows` *(API Live)*
- [ ] On-time promise banner uses `bannerTitle` / `bannerBody` when `active` *(API Live)*
- [ ] Spin uses `GET /customer/spin/active` and never trusts client RNG on `POST /customer/spin/draw` *(API Live)*
- [ ] After 03:00 Asia/Bahrain (UTC midnight), spin remaining matches a fresh summary *(Clocks Live)*
- [ ] A voucher from first order, inactivity, or birthday appears on `GET /customer/vouchers` without a new API *(Jobs Live)*
- [ ] Order tracking uses `order_tracking` stage payloads (`yjeek://orders/{id}`); rider chat stays `rider_chat` (`yjeek://orders/{id}/chat`) *(Push Live)*
- [ ] `marketingOptIn: false` hides composed marketing pushes and still shows order-status payloads *(API Live)*
- [ ] Wallet **history rows** use `GET /api/v1/customer/wallet/ledger` *(API Live)*

## Contact / sequencing

**All marketing milestones are complete:** M01 cashback ✓ · **M02 referral ✓** · **M03 vouchers ✓** · **M04 vendor promotions ✓** · **M05 campaigns ✓** · **M06 banners ✓** · **M07 spin ✓** · **M08 push ✓** · **M09 segments ✓** · **M10 fraud ✓** · **M11 budget ✓** · **M12 clocks ✓** · **M13 customer API freeze & ledger ✓**. All customer routes in `04` and `05` are frozen and live in `yjeek_backend`. Mobile team can build screens directly against these specifications.
