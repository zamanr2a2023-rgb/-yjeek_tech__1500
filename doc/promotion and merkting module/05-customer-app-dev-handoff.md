# Customer App Dev Handoff — Marketing Module v1

**For:** Customer mobile developers.  
**Not for:** Rider/driver apps.  
**Source of truth for rules:** OG HTML. This file translates UX expectations.

## What backend/admin/vendor will deliver

Engines, admin config, vendor acceptance, and the APIs in `04-customer-app-api-contracts.md`.

## What mobile must build (OG §12)

### A. My Rewards (new tab)

1. Wallet: Available · Pending · Expiring soon · Withdraw (keep existing withdraw rules).
2. Vouchers: active with countdown · used · expired.
3. Spin wheel tile when a campaign is live + spins remaining.
4. Mission progress when campaigns include missions.
5. Referral credit appears in wallet history; **Invite a friend** lives under Profile / Account (not only Rewards).

### B. Checkout additions

1. Vouchers section: applicable vs not applicable **with reason**.
2. Auto-select best applicable voucher (server indicates `autoSelect`).
3. “Use wallet balance” toggle — **disabled** when a voucher is selected.
4. Keep existing: Wallet + COD not permitted.
5. Live line: “You will earn BHD X.XXX cashback” from `cashbackPreview` after voucher/discount changes.
6. Optional **referral credit** apply (`referralCreditAmount`) — separate from MAIN wallet; server enforces min order (default BHD 5.000) and coverage cap (default 50%); show clamped applied amount from checkout extras.

### C. Offers (new home category)

1. Home tile “Offers” beside existing categories.
2. Screen lists every item on an active vendor promotion (all vendors).
3. Store cards with any live promotion show “Offers” label.
4. Item cards: strike-through original + discounted price.

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

### E. Spin wheel screen

1. Render segments/colors/images from API.
2. Spins remaining; call draw API; animate to **server-chosen** segment.
3. Show prize modal; credit is already applied server-side.

## Push copy expectations (examples)

| Event | Direction |
|-------|-----------|
| Cashback credited | “BHD X.XXX cashback added” |
| Credit expiring in 7 days | Reminder |
| Referral both sides rewarded | “Your BHD X.XXX referral credit is in your wallet” → `yjeek://rewards` |
| Referral credit expiring in 7 days | Reminder (same pattern as cashback) |
| Cart abandonment ~30 min | Marketing, frequency-capped |
| Order tracking states | Transactional / Live Activities — not marketing chrome |

## Non-goals for mobile (this pack)

- Creating vouchers or cashback rules.
- Vendor promo creation.
- Fraud review UI.
- Typed promo-code entry if product removes it later; today legacy codes may still exist — coordinate with backend before removing any code-entry UI.

## Acceptance checklist for mobile

- [ ] My Rewards shows wallet buckets from summary API  
- [ ] Checkout cashback line matches `paid_own` rule (verify with split wallet+card)  
- [ ] Voucher selected ⇒ wallet toggle off  
- [ ] Store cards show “Vouchers accepted” from `vouchersAcceptedBadge`; filter `acceptsMyVouchers=true`  
- [ ] Offers feed + store/item badges  
- [ ] Invite flow + invite list statuses (incl. Rejected + reason)  
- [ ] Checkout referral credit apply respects min order / coverage clamp  
- [ ] Spin never trusts client RNG  

## Contact / sequencing

Integrate against contract shapes as milestones land: M01 cashback ✓ · **M02 referral ✓** · **M03 vouchers ✓** · **M04 offers** (Ready) · **M05 missions/campaigns** (Ready) · M07 spin. Prefer feature flags per surface.
