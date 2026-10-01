# API Contracts — Fashion / Multi-Store Catalog v1

> **Frozen** 2026-09-26 (F05). Samples below match H&M Oxford + VARIANTS cart/menu.

## Catalog mode

Store type field:

```json
{
  "catalogMode": "MODIFIERS | VARIANTS | HYBRID",
  "lowStockThreshold": 5
}
```

Customer/vendor responses that expose a vendor include:

```json
{
  "storeTypeId": "...",
  "storeTypeSlug": "fashion",
  "catalogMode": "VARIANTS"
}
```

## Store-type attribute axes (admin)

`GET /admin/store-types/:id/attributes`

```json
{
  "axes": [
    {
      "id": "...",
      "key": "size",
      "name": "Size",
      "uiHint": "PILL",
      "isRequired": true,
      "sortOrder": 0,
      "values": [
        { "id": "...", "key": "m", "label": "M", "colorHex": null, "sortOrder": 2, "isActive": true }
      ]
    },
    {
      "id": "...",
      "key": "colour",
      "name": "Colour",
      "uiHint": "SWATCH",
      "isRequired": true,
      "sortOrder": 1,
      "values": [
        { "id": "...", "key": "navy", "label": "Navy", "colorHex": "#001F3F", "sortOrder": 1, "isActive": true }
      ]
    }
  ]
}
```

## Customer product detail (`VARIANTS`)

`GET /vendors/:vendorId/products/:productId`

```json
{
  "id": "...",
  "name": "Classic Fit Oxford Shirt",
  "description": "...",
  "catalogMode": "VARIANTS",
  "imageUrl": "...",
  "priceFrom": 12.9,
  "axes": [ /* same shape as store-type axes used by this product */ ],
  "variants": [
    {
      "id": "...",
      "sku": "HM-OXF-M-NAVY",
      "attributes": { "size": "m", "colour": "navy" },
      "label": "M / Navy",
      "price": 12.9,
      "compareAtPrice": null,
      "stockQty": 8,
      "stockStatus": "IN_STOCK",
      "isAvailable": true,
      "imageUrl": null
    }
  ],
  "addons": [
    { "id": "...", "name": "Gift wrapping", "price": 1.0, "isActive": true }
  ],
  "optionGroups": []
}
```

`MODIFIERS` products keep today’s `optionGroups` + `addons`; `variants` is `[]`.

## Add to cart (`VARIANTS`)

`POST /cart/items`

```json
{
  "productId": "...",
  "variantId": "...",
  "quantity": 1,
  "options": { "addonIds": ["..."] }
}
```

Rules:

- If vendor `catalogMode=VARIANTS`, `variantId` is **required**; `optionIds` rejected/ignored.
- Variant must belong to `productId`, be available, and have stock ≥ quantity (when tracking qty).
- Unit price = variant.price + sum(addons).

`MODIFIERS` carts unchanged: `options.optionIds` + `addonIds`, no `variantId`.

## Age verification (Vape / 18+)

`GET /users/me/age-verification`

```json
{
  "status": "NOT_VERIFIED | PENDING | VERIFIED | REJECTED",
  "canPurchaseAgeRestricted": false,
  "cta hint via product": "see ageRestriction.cta",
  "banner": { "title": "18+ only", "message": "your ID is checked on delivery" }
}
```

`POST /users/me/age-verification`

```json
{
  "idFrontUrl": "...",
  "idBackUrl": "...",
  "consent": true,
  "simulate": "SUCCESS"
}
```

Response includes `outcome`, `screen` (`verified` | `under_18` | `id_already_used` | `rejected`).

Product detail adds:

```json
{
  "ageRestriction": {
    "required": true,
    "minimumAge": 18,
    "champMustCheckId": true,
    "canPurchase": false,
    "cta": "VERIFY_AGE",
    "banner": { "title": "18+ only", "message": "your ID is checked on delivery" }
  },
  "restrictions": {
    "ageRestricted": false,
    "highValue": true,
    "age": null,
    "highValuePod": { "otpRequired": true, "namedRecipientOnly": true },
    "badges": ["HIGH_VALUE"]
  }
}
```

## Vendor menu (`VARIANTS`)

`GET /vendors/:id/menu` returns sections derived from **`VendorCatalogCategory`** (active, approved). Top-level sections may include nested `children` (e.g. Devices → PODS / MODS). Products list `priceFrom`, `variantCount`. `MenuSection` remains for Food/`MODIFIERS`.