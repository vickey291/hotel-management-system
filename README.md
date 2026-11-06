# XBay Hotel — Hotel Management & POS System
**Cross Bay Hotel & Motel · Kotli · Azad Kashmir**
Rooms · Bookings · Monthly Rooms · Restaurant POS · Kitchen · Billing · Payments · Inventory · Reports

Stack: PHP 8+, MySQL/MariaDB (PDO), HTML5, CSS3, Bootstrap 5, JavaScript (Fetch), Chart.js. Runs on XAMPP (localhost).

## 1. Install (5 minutes)
1. Install XAMPP (PHP 8.0 or newer). Start **Apache** and **MySQL** in the XAMPP Control Panel.
2. Copy the folder `XBayHotel` into `C:\xampp\htdocs\`  (so you get `C:\xampp\htdocs\XBayHotel\index.php`).
3. Open `http://localhost/phpmyadmin` → **Import** → choose `database/schema.sql` → Go.
   (It creates the database `xbay_hotel_db` with all 42 tables, roles, permissions, settings and the admin user.)
4. *(Optional demo data)* Import `database/seed.sql` the same way: sample rooms, menu items, tables and add-ons.
5. If your MySQL has a root password, edit `config/database.php`.
6. Open **http://localhost/XBayHotel/** → click **Staff Login**.

**First login:** username `admin`, password `Admin@123`. The system asks you to change it immediately.

> The pages load Bootstrap, Bootstrap Icons and Chart.js from a CDN, so the first load needs internet. To work fully offline, download those files into `assets/vendor/` and change the links in `includes/header.php`, `includes/footer.php`, `login.php` and `index.php`.
> To see PHP errors while testing, set `display_errors` to `'1'` in `config/app.php` (turn it back to `'0'` for daily use).

## 2. Roles (Staff Management → Roles / Permissions)
| Role | Access |
|---|---|
| Admin | everything |
| Manager | everything except Staff and Settings |
| Receptionist | Dashboard, Rooms, Bookings, Guests (CNIC), Monthly rooms, Billing, Payments |
| Cashier | Dashboard, Restaurant POS & orders, Billing, Payments |
| Kitchen | Kitchen board only |

Admin can change what every role may open in **Staff → Permissions**.

## 3. Daily workflow
**Booking a family**
1. *Room Booking* → enter guest, CNIC number and CNIC front/back images, family members, pick room(s), dates, advance → *Confirm*.
2. The system blocks overlapping bookings for the same room (checked inside a database transaction, so two receptionists cannot double-book).
3. On arrival: Booking details → **Check-in** (room must be clean and not under maintenance) → room becomes *Occupied*.
4. Extra services: *Add charge* (laundry, extra bed…) or room-service food orders from the POS — all land on the one room bill.
5. Departure: **Check-out** → bill shown → receive the balance → rooms are marked *dirty*. After housekeeping, open the room and set cleaning to *Clean*; it is *Available* again.

**Room status** is calculated from: reservations, actual check-in, cleaning status, maintenance status and monthly tenancy — not from a single field.

**Monthly rooms**
Create a tenant/contract (room type must be of mode *Monthly*). Rent invoices are created automatically each month when someone opens *Monthly Rooms* / *Rent*, or press *Generate rent invoices*. Add electricity/water/repair charges per invoice, receive rent, print receipt, see balance history, print the agreement.

**Restaurant**
POS → choose *Dine-in* (table), *Room Service* (only rooms with a checked-in guest) or *Takeaway* → tap items (sizes and extras via pop-up) → *Place order*. A kitchen token prints and the order appears on the **Kitchen** board (auto-refresh). Dine-in/takeaway are paid on the order page; room-service goes to the room bill.

**Billing**: every bill has a unique invoice number; statuses Paid / Unpaid / Partial / Pending (*Pending* = guest still staying, nothing paid yet). Several partial payments per invoice. Methods: Cash, Bank Transfer, Card, Online.

**Printing** (`print/`): booking receipt, room bill, monthly rent receipt, restaurant bill, kitchen token, invoice, payment receipt — 58 mm, 80 mm or A4 (switch on the print page, default in Settings → Receipt & printing).

**Reports**: 13 reports with date range; *Excel (CSV)* export and *PDF / Print* (use "Save as PDF" in the print dialog).

## 4. Security notes
- Passwords: `password_hash()`; all SQL uses PDO prepared statements; CSRF token on every form/AJAX call; login throttling (5 failures / 15 min).
- CNIC images and agreements are stored in `storage/` (blocked from the web by `.htaccess`) and are served only by `modules/guests/doc.php` to logged-in staff with the Guests permission; every view is written to the audit log.
- Uploaded files are type-checked (JPG/PNG/WEBP/PDF) and renamed; PHP execution is blocked in `uploads/`.
- Take regular backups: **Settings → Database backup**.
- Before using it for real guests: change the admin password, set a MySQL root password, and keep the PC/network access restricted. (`.htaccess` rules need Apache with `AllowOverride All`, which is the XAMPP default.)

## 5. Folder map
```
config/      database.php, app.php, constants.php
includes/    functions.php (core logic), header/sidebar/navbar/footer, crud.php (generic list/add/edit), monthly.php
assets/      css/style.css, js/app.js, booking.js, pos.js
modules/     dashboard, rooms, room_types, bookings, guests, monthly_rooms, room_services, restaurant, menu,
             tables, orders, kitchen, billing, payments, expenses, inventory, reports, staff, settings
api/orders/  create.php  (POS order, JSON)
print/       receipts & tokens
database/    schema.sql (42 tables), seed.sql (demo data), backup/
storage/     private CNIC / agreement files      uploads/  logo & menu images
```
Simple list/add/edit screens (room types, rooms, guests, menu, tables, expenses, inventory, staff…) use one shared CRUD engine, so `add.php` / `edit.php` in those modules just open `index.php?action=add|edit`.

## 6. Known simplifications
- Monthly rent is billed as a full month from the first month (no part-month proration).
- Cancelling a booking keeps any advance on the invoice; refunds are handled manually.
- Rent for extra nights after the planned check-out is added by *Edit / extend* on the booking before check-out.
- PDF export uses the browser's print-to-PDF.

