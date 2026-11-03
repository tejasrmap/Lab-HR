# NET4207 Stock Inventory Manager

A Flutter mobile inventory application integrated with Google Firebase Cloud Firestore for real-time stock management, validation, and advanced filtering.

---

## 1. Setup and Run Instructions

### Prerequisites & Required Packages
* **Flutter SDK:** `>=3.0.0 <4.0.0`
* **Firebase Project ID:** `net4207-stock-inventory`
* **Dependencies (`pubspec.yaml`):**
  * `firebase_core: ^3.6.0`
  * `cloud_firestore: ^5.4.4`
  * `intl: ^0.19.0`

### Run Commands
```bash
# 1. Install dependencies
flutter pub get

# 2. Run the application
flutter run
```
*(Note: As per security guidelines, private service-account credentials and secret keys are excluded from this repository).*

---

## 2. Firestore Schema & Validation Rules

### Collection: `stockItems`
* `sku` (`String`): Format `STK-###` (enforced via regex `^STK-\d{3}$`).
* `itemName` (`String`): Item title, trimmed, minimum 3 characters.
* `category` (`String`): Compulsory selection from `Electronics`, `Stationery`, `Hardware`, `Grocery`.
* `quantity` (`int`): Non-negative integer ($\ge 0$).
* `unitPrice` (`double`): Monetary price in RM, strictly positive ($> 0$).
* `reorderLevel` (`int`): Non-negative threshold integer ($\ge 0$).
* `createdAt` (`Timestamp`): Firestore `FieldValue.serverTimestamp()`.

### Validation Gating
Submissions are evaluated through `GlobalKey<FormState>`. Any missing or malformed inputs trigger specific inline error messages and strictly block Firestore write operations.

---

## 3. Advanced Search & Low-Stock Filtering Logic
* **Keyword Matching:** Performs case-insensitive partial substring evaluation across both `itemName` and `sku`.
* **Category Filter:** Matches the selected category or shows all items when set to `All`.
* **Low-Stock Detection:** Filters for items where `quantity <= reorderLevel`.
* **Combined Multi-Criteria:** All active criteria are evaluated concurrently via an `AND` operation on the Firestore snapshot stream.
* **Sorting & Reset:** Real-time quantity sorting (Ascending / Descending) and an instant filter reset function.

---

## 4. Test Verification Log

| Test Case | Input / Action | Expected Result | Actual Result | Screenshot Reference |
| :--- | :--- | :--- | :--- | :--- |
| **1. Invalid Form Submission** | Blank inputs, invalid SKU (`ABC-12`), negative quantity (`-5`), zero price (`0.00`). | Inline error messages shown on invalid fields; Firestore write prevented. | As expected. Error flags displayed; no write initiated to database. | `screenshots/test1_invalid_form.png` |
| **2. Valid Firestore Save & Retrieval** | Input `STK-101`, `USB C Cable`, `Electronics`, Qty: `4`, Price: `19.90`, Reorder: `5`. | Item saved with timestamp; acknowledged by SnackBar; instantly visible in list. | As expected. Record persisted in Firestore and rendered with details. | `screenshots/test2_valid_save.png` |
| **3. Combined Search & Low-Stock** | Search keyword: `"mouse"`, Category: `Electronics`, Low Stock: `ON`. | Only `STK-103 Wireless Mouse` displayed (Qty $1 \le$ Reorder $3$). | As expected. Non-matching items filtered out; only `STK-103` visible. | `screenshots/test3_combined_search.png` |
