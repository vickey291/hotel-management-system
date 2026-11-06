-- ============================================================
-- XBay Hotel (Cross Bay Hotel & Motel) - Kotli, Azad Kashmir
-- MySQL schema: 42 tables + essential data (roles, permissions, admin, settings)
-- Import via phpMyAdmin, then (optional) import seed.sql for demo data.
-- ============================================================
CREATE DATABASE IF NOT EXISTS xbay_hotel_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE xbay_hotel_db;
SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;

-- A. Settings -------------------------------------------------
CREATE TABLE hotel_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  hotel_name VARCHAR(150) NOT NULL,
  tagline VARCHAR(200) NULL,
  logo VARCHAR(255) NULL,
  phone VARCHAR(50) NULL,
  email VARCHAR(120) NULL,
  address VARCHAR(255) NULL,
  city VARCHAR(80) NULL,
  country VARCHAR(80) NULL,
  website VARCHAR(150) NULL,
  currency VARCHAR(10) NOT NULL DEFAULT 'Rs.',
  tax_number VARCHAR(60) NULL,
  receipt_footer VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE system_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(80) NOT NULL UNIQUE,
  setting_value TEXT NULL,
  setting_group VARCHAR(50) NOT NULL DEFAULT 'general',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- K. Staff & security (created early: referenced by many tables) --
CREATE TABLE roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  role_name VARCHAR(60) NOT NULL UNIQUE,
  description VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE permissions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  permission_name VARCHAR(100) NOT NULL,
  permission_key VARCHAR(60) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE role_permissions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  role_id INT NOT NULL,
  permission_id INT NOT NULL,
  UNIQUE KEY uq_role_perm (role_id, permission_id),
  FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
  FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  username VARCHAR(60) NOT NULL UNIQUE,
  email VARCHAR(120) NULL,
  phone VARCHAR(40) NULL,
  password_hash VARCHAR(255) NOT NULL,
  role_id INT NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES roles(id)
) ENGINE=InnoDB;

-- B. Rooms ----------------------------------------------------
CREATE TABLE room_types (
  id INT AUTO_INCREMENT PRIMARY KEY,
  type_name VARCHAR(80) NOT NULL,
  description VARCHAR(255) NULL,
  default_price DECIMAL(12,2) NOT NULL DEFAULT 0,
  booking_mode ENUM('daily','vip','monthly') NOT NULL DEFAULT 'daily',
  capacity INT NOT NULL DEFAULT 2,
  is_active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE rooms (
  id INT AUTO_INCREMENT PRIMARY KEY,
  room_number VARCHAR(20) NOT NULL UNIQUE,
  room_type_id INT NOT NULL,
  floor_number VARCHAR(40) NULL,
  room_name VARCHAR(80) NULL,
  capacity INT NOT NULL DEFAULT 2,
  room_price DECIMAL(12,2) NOT NULL DEFAULT 0,
  cleaning_status ENUM('clean','dirty','in_progress') NOT NULL DEFAULT 'clean',
  maintenance_status ENUM('active','maintenance') NOT NULL DEFAULT 'active',
  description VARCHAR(255) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  FOREIGN KEY (room_type_id) REFERENCES room_types(id)
) ENGINE=InnoDB;

CREATE TABLE room_amenities (
  id INT AUTO_INCREMENT PRIMARY KEY,
  amenity_name VARCHAR(80) NOT NULL,
  description VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE room_amenity_map (
  id INT AUTO_INCREMENT PRIMARY KEY,
  room_id INT NOT NULL,
  amenity_id INT NOT NULL,
  UNIQUE KEY uq_room_amenity (room_id, amenity_id),
  FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE CASCADE,
  FOREIGN KEY (amenity_id) REFERENCES room_amenities(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- C. Guests ---------------------------------------------------
CREATE TABLE guests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  guest_code VARCHAR(30) NOT NULL UNIQUE,
  full_name VARCHAR(120) NOT NULL,
  father_husband_name VARCHAR(120) NULL,
  phone VARCHAR(40) NULL,
  email VARCHAR(120) NULL,
  address VARCHAR(255) NULL,
  city VARCHAR(80) NULL,
  country VARCHAR(80) NULL DEFAULT 'Pakistan',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_guest_name (full_name),
  KEY idx_guest_phone (phone)
) ENGINE=InnoDB;

CREATE TABLE guest_documents (
  id INT AUTO_INCREMENT PRIMARY KEY,
  guest_id INT NOT NULL,
  document_type VARCHAR(40) NOT NULL DEFAULT 'CNIC',
  document_number VARCHAR(40) NULL,
  front_image VARCHAR(255) NULL,
  back_image VARCHAR(255) NULL,
  issue_date DATE NULL,
  expiry_date DATE NULL,
  verification_status ENUM('pending','verified','rejected') NOT NULL DEFAULT 'pending',
  KEY idx_doc_number (document_number),
  FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- D. Bookings -------------------------------------------------
CREATE TABLE bookings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  booking_number VARCHAR(30) NOT NULL UNIQUE,
  guest_id INT NOT NULL,
  booking_source VARCHAR(30) NOT NULL DEFAULT 'walk_in',
  booking_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  checkin_datetime DATETIME NOT NULL,
  checkout_datetime DATETIME NOT NULL,
  adults INT NOT NULL DEFAULT 1,
  children INT NOT NULL DEFAULT 0,
  total_nights INT NOT NULL DEFAULT 1,
  room_total DECIMAL(12,2) NOT NULL DEFAULT 0,
  discount DECIMAL(12,2) NOT NULL DEFAULT 0,
  tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  grand_total DECIMAL(12,2) NOT NULL DEFAULT 0,
  advance_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  booking_status ENUM('confirmed','checked_in','checked_out','cancelled','no_show') NOT NULL DEFAULT 'confirmed',
  special_notes TEXT NULL,
  emergency_contact VARCHAR(150) NULL,
  created_by INT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_booking_dates (checkin_datetime, checkout_datetime),
  KEY idx_booking_status (booking_status),
  FOREIGN KEY (guest_id) REFERENCES guests(id),
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE booking_rooms (
  id INT AUTO_INCREMENT PRIMARY KEY,
  booking_id INT NOT NULL,
  room_id INT NOT NULL,
  room_rate DECIMAL(12,2) NOT NULL,
  checkin_datetime DATETIME NOT NULL,
  checkout_datetime DATETIME NOT NULL,
  room_status ENUM('reserved','checked_in','checked_out','cancelled') NOT NULL DEFAULT 'reserved',
  KEY idx_br_room_dates (room_id, checkin_datetime, checkout_datetime),
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  FOREIGN KEY (room_id) REFERENCES rooms(id)
) ENGINE=InnoDB;

CREATE TABLE booking_occupants (
  id INT AUTO_INCREMENT PRIMARY KEY,
  booking_id INT NOT NULL,
  guest_id INT NOT NULL,
  is_primary_guest TINYINT(1) NOT NULL DEFAULT 0,
  relationship VARCHAR(60) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  FOREIGN KEY (guest_id) REFERENCES guests(id)
) ENGINE=InnoDB;

CREATE TABLE checkin_checkout (
  id INT AUTO_INCREMENT PRIMARY KEY,
  booking_room_id INT NOT NULL,
  actual_checkin DATETIME NULL,
  actual_checkout DATETIME NULL,
  checked_in_by INT NULL,
  checked_out_by INT NULL,
  checkin_notes VARCHAR(255) NULL,
  checkout_notes VARCHAR(255) NULL,
  FOREIGN KEY (booking_room_id) REFERENCES booking_rooms(id) ON DELETE CASCADE,
  FOREIGN KEY (checked_in_by) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (checked_out_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE booking_status_history (
  id INT AUTO_INCREMENT PRIMARY KEY,
  booking_id INT NOT NULL,
  old_status VARCHAR(30) NULL,
  new_status VARCHAR(30) NOT NULL,
  changed_by INT NULL,
  change_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  remarks VARCHAR(255) NULL,
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- E. Monthly / permanent rooms --------------------------------
CREATE TABLE monthly_tenants (
  id INT AUTO_INCREMENT PRIMARY KEY,
  guest_id INT NOT NULL,
  room_id INT NOT NULL,
  contract_number VARCHAR(30) NOT NULL UNIQUE,
  monthly_rent DECIMAL(12,2) NOT NULL,
  security_deposit DECIMAL(12,2) NOT NULL DEFAULT 0,
  start_date DATE NOT NULL,
  end_date DATE NULL,
  rent_due_day TINYINT NOT NULL DEFAULT 1,
  billing_status ENUM('active','suspended') NOT NULL DEFAULT 'active',
  tenant_status ENUM('active','ended') NOT NULL DEFAULT 'active',
  agreement_file VARCHAR(255) NULL,
  notes TEXT NULL,
  FOREIGN KEY (guest_id) REFERENCES guests(id),
  FOREIGN KEY (room_id) REFERENCES rooms(id)
) ENGINE=InnoDB;

CREATE TABLE monthly_rent_invoices (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  invoice_number VARCHAR(30) NOT NULL UNIQUE,
  billing_month CHAR(7) NOT NULL,
  rent_amount DECIMAL(12,2) NOT NULL,
  electricity_charges DECIMAL(12,2) NOT NULL DEFAULT 0,
  water_charges DECIMAL(12,2) NOT NULL DEFAULT 0,
  other_charges DECIMAL(12,2) NOT NULL DEFAULT 0,
  discount DECIMAL(12,2) NOT NULL DEFAULT 0,
  total_amount DECIMAL(12,2) NOT NULL,
  paid_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  due_date DATE NOT NULL,
  invoice_status ENUM('unpaid','partial','paid') NOT NULL DEFAULT 'unpaid',
  UNIQUE KEY uq_tenant_month (tenant_id, billing_month),
  FOREIGN KEY (tenant_id) REFERENCES monthly_tenants(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE tenant_payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  tenant_id INT NOT NULL,
  rent_invoice_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  payment_method VARCHAR(30) NOT NULL DEFAULT 'cash',
  payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  receipt_number VARCHAR(30) NOT NULL UNIQUE,
  received_by INT NULL,
  FOREIGN KEY (tenant_id) REFERENCES monthly_tenants(id) ON DELETE CASCADE,
  FOREIGN KEY (rent_invoice_id) REFERENCES monthly_rent_invoices(id) ON DELETE CASCADE,
  FOREIGN KEY (received_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- F. Menu -----------------------------------------------------
CREATE TABLE menu_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(80) NOT NULL,
  description VARCHAR(255) NULL,
  category_image VARCHAR(255) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE menu_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_id INT NOT NULL,
  item_name VARCHAR(120) NOT NULL,
  item_code VARCHAR(30) NULL UNIQUE,
  description VARCHAR(255) NULL,
  item_image VARCHAR(255) NULL,
  purchase_price DECIMAL(12,2) NOT NULL DEFAULT 0,
  sale_price DECIMAL(12,2) NOT NULL DEFAULT 0,
  stock_quantity INT NOT NULL DEFAULT 0,
  is_stock_managed TINYINT(1) NOT NULL DEFAULT 0,
  is_available TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES menu_categories(id)
) ENGINE=InnoDB;

CREATE TABLE menu_item_variants (
  id INT AUTO_INCREMENT PRIMARY KEY,
  menu_item_id INT NOT NULL,
  variant_name VARCHAR(80) NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE menu_addons (
  id INT AUTO_INCREMENT PRIMARY KEY,
  addon_name VARCHAR(80) NOT NULL,
  addon_price DECIMAL(12,2) NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE menu_item_addons (
  id INT AUTO_INCREMENT PRIMARY KEY,
  menu_item_id INT NOT NULL,
  addon_id INT NOT NULL,
  UNIQUE KEY uq_item_addon (menu_item_id, addon_id),
  FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE CASCADE,
  FOREIGN KEY (addon_id) REFERENCES menu_addons(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- G. Restaurant tables ---------------------------------------
CREATE TABLE restaurant_tables (
  id INT AUTO_INCREMENT PRIMARY KEY,
  table_number VARCHAR(20) NOT NULL UNIQUE,
  table_name VARCHAR(60) NULL,
  floor VARCHAR(40) NULL,
  seating_capacity INT NOT NULL DEFAULT 4,
  status ENUM('available','occupied','reserved') NOT NULL DEFAULT 'available',
  is_active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE table_reservations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  table_id INT NOT NULL,
  guest_name VARCHAR(120) NOT NULL,
  phone VARCHAR(40) NULL,
  reservation_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NULL,
  guests_count INT NOT NULL DEFAULT 2,
  reservation_status ENUM('booked','seated','cancelled','completed') NOT NULL DEFAULT 'booked',
  FOREIGN KEY (table_id) REFERENCES restaurant_tables(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- I (part). Invoices are referenced by orders -----------------
CREATE TABLE invoices (
  id INT AUTO_INCREMENT PRIMARY KEY,
  invoice_number VARCHAR(30) NOT NULL UNIQUE,
  guest_id INT NULL,
  booking_id INT NULL,
  tenant_id INT NULL,
  invoice_type ENUM('room','restaurant','room_service','monthly','checkout') NOT NULL DEFAULT 'room',
  subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
  discount DECIMAL(12,2) NOT NULL DEFAULT 0,
  tax_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  service_charges DECIMAL(12,2) NOT NULL DEFAULT 0,
  grand_total DECIMAL(12,2) NOT NULL DEFAULT 0,
  paid_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  remaining_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  invoice_status ENUM('paid','unpaid','partial','pending') NOT NULL DEFAULT 'pending',
  invoice_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by INT NULL,
  KEY idx_invoice_booking (booking_id),
  KEY idx_invoice_status (invoice_status),
  FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE SET NULL,
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL,
  FOREIGN KEY (tenant_id) REFERENCES monthly_tenants(id) ON DELETE SET NULL,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE invoice_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  invoice_id INT NOT NULL,
  description VARCHAR(255) NOT NULL,
  item_type VARCHAR(30) NOT NULL DEFAULT 'other',
  reference_id INT NULL,
  quantity DECIMAL(10,2) NOT NULL DEFAULT 1,
  unit_price DECIMAL(12,2) NOT NULL DEFAULT 0,
  total_price DECIMAL(12,2) NOT NULL DEFAULT 0,
  FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  payment_number VARCHAR(30) NOT NULL UNIQUE,
  invoice_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  payment_method VARCHAR(30) NOT NULL DEFAULT 'cash',
  transaction_reference VARCHAR(100) NULL,
  payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  received_by INT NULL,
  notes VARCHAR(255) NULL,
  KEY idx_payment_date (payment_date),
  FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
  FOREIGN KEY (received_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- H. Orders & kitchen ----------------------------------------
CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_number VARCHAR(30) NOT NULL UNIQUE,
  order_type ENUM('dine_in','room_service','takeaway') NOT NULL,
  guest_id INT NULL,
  booking_id INT NULL,
  room_id INT NULL,
  table_id INT NULL,
  invoice_id INT NULL,
  order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  order_status ENUM('open','completed','cancelled') NOT NULL DEFAULT 'open',
  subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
  discount DECIMAL(12,2) NOT NULL DEFAULT 0,
  tax DECIMAL(12,2) NOT NULL DEFAULT 0,
  service_charges DECIMAL(12,2) NOT NULL DEFAULT 0,
  grand_total DECIMAL(12,2) NOT NULL DEFAULT 0,
  notes VARCHAR(255) NULL,
  created_by INT NULL,
  KEY idx_order_date (order_date),
  FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE SET NULL,
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE SET NULL,
  FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE SET NULL,
  FOREIGN KEY (table_id) REFERENCES restaurant_tables(id) ON DELETE SET NULL,
  FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE SET NULL,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  menu_item_id INT NULL,
  variant_id INT NULL,
  item_name VARCHAR(160) NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  unit_price DECIMAL(12,2) NOT NULL,
  discount DECIMAL(12,2) NOT NULL DEFAULT 0,
  total_price DECIMAL(12,2) NOT NULL,
  item_notes VARCHAR(255) NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE SET NULL,
  FOREIGN KEY (variant_id) REFERENCES menu_item_variants(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE order_item_addons (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_item_id INT NOT NULL,
  addon_name VARCHAR(80) NOT NULL,
  addon_price DECIMAL(12,2) NOT NULL DEFAULT 0,
  FOREIGN KEY (order_item_id) REFERENCES order_items(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE kitchen_orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  kitchen_status ENUM('pending','preparing','ready','completed') NOT NULL DEFAULT 'pending',
  sent_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  preparing_at DATETIME NULL,
  ready_at DATETIME NULL,
  completed_at DATETIME NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- I. Room charges & expenses ---------------------------------
CREATE TABLE room_charges (
  id INT AUTO_INCREMENT PRIMARY KEY,
  booking_id INT NOT NULL,
  room_id INT NULL,
  charge_type VARCHAR(30) NOT NULL DEFAULT 'other',
  description VARCHAR(255) NULL,
  quantity DECIMAL(10,2) NOT NULL DEFAULT 1,
  unit_price DECIMAL(12,2) NOT NULL DEFAULT 0,
  total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  charge_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by INT NULL,
  FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
  FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE SET NULL,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE expenses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  expense_title VARCHAR(150) NOT NULL,
  expense_category VARCHAR(60) NOT NULL DEFAULT 'General',
  amount DECIMAL(12,2) NOT NULL,
  expense_date DATE NOT NULL,
  payment_method VARCHAR(30) NOT NULL DEFAULT 'cash',
  description VARCHAR(255) NULL,
  created_by INT NULL,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- J. Inventory ------------------------------------------------
CREATE TABLE inventory_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(80) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE inventory_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  item_name VARCHAR(120) NOT NULL,
  category_id INT NULL,
  unit VARCHAR(20) NOT NULL DEFAULT 'pcs',
  current_stock DECIMAL(12,2) NOT NULL DEFAULT 0,
  minimum_stock DECIMAL(12,2) NOT NULL DEFAULT 0,
  purchase_price DECIMAL(12,2) NOT NULL DEFAULT 0,
  FOREIGN KEY (category_id) REFERENCES inventory_categories(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE stock_transactions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  inventory_item_id INT NOT NULL,
  transaction_type ENUM('in','out','adjust') NOT NULL,
  quantity DECIMAL(12,2) NOT NULL,
  transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  reference VARCHAR(150) NULL,
  created_by INT NULL,
  FOREIGN KEY (inventory_item_id) REFERENCES inventory_items(id) ON DELETE CASCADE,
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- K (rest). Logs ---------------------------------------------
CREATE TABLE audit_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  action VARCHAR(60) NOT NULL,
  module_name VARCHAR(60) NOT NULL,
  record_id INT NULL,
  description VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_audit_created (created_at),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- L. Backups & login logs ------------------------------------
CREATE TABLE database_backups (
  id INT AUTO_INCREMENT PRIMARY KEY,
  backup_file VARCHAR(255) NOT NULL,
  backup_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by INT NULL,
  backup_status ENUM('success','failed') NOT NULL DEFAULT 'success',
  FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE login_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  username VARCHAR(60) NULL,
  login_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  logout_time DATETIME NULL,
  ip_address VARCHAR(45) NULL,
  status ENUM('success','failed') NOT NULL DEFAULT 'success',
  KEY idx_login_attempts (ip_address, login_time),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- Essential data
-- ============================================================
INSERT INTO hotel_settings (hotel_name, tagline, phone, email, address, city, country, website, currency, tax_number, receipt_footer) VALUES
('XBay Hotel', 'Cross Bay Hotel & Motel', '+92 300 0000000', 'info@xbayhotel.com', 'Main Road, Kotli', 'Kotli, Azad Kashmir', 'Pakistan', '', 'Rs.', '', 'Thank you for staying with us!');

INSERT INTO system_settings (setting_key, setting_value, setting_group) VALUES
('checkin_time', '14:00', 'booking'),
('checkout_time', '12:00', 'booking'),
('tax_percent', '0', 'billing'),
('restaurant_tax_percent', '0', 'billing'),
('service_charge_percent', '0', 'billing'),
('receipt_size', '80', 'printing'),
('monthly_grace_days', '5', 'billing');

INSERT INTO roles (id, role_name, description) VALUES
(1, 'Admin', 'Full access to everything'),
(2, 'Manager', 'Everything except staff and settings'),
(3, 'Receptionist', 'Bookings, guests, rooms, billing'),
(4, 'Cashier', 'Restaurant POS, billing, payments'),
(5, 'Kitchen', 'Kitchen orders only');

INSERT INTO permissions (permission_name, permission_key) VALUES
('Dashboard', 'dashboard'), ('Rooms', 'rooms'), ('Bookings & Check-in/out', 'bookings'),
('Guests & CNIC documents', 'guests'), ('Monthly Rooms', 'monthly'), ('Restaurant POS & Orders', 'pos'),
('Kitchen', 'kitchen'), ('Menu & Tables', 'menu'), ('Billing', 'billing'), ('Payments', 'payments'),
('Expenses', 'expenses'), ('Inventory', 'inventory'), ('Reports', 'reports'),
('Staff & Roles', 'staff'), ('Settings & Backup', 'settings');

-- Manager: everything but staff/settings
INSERT INTO role_permissions (role_id, permission_id) SELECT 2, id FROM permissions WHERE permission_key NOT IN ('staff','settings');
-- Receptionist
INSERT INTO role_permissions (role_id, permission_id) SELECT 3, id FROM permissions WHERE permission_key IN ('dashboard','rooms','bookings','guests','monthly','billing','payments');
-- Cashier
INSERT INTO role_permissions (role_id, permission_id) SELECT 4, id FROM permissions WHERE permission_key IN ('dashboard','pos','billing','payments');
-- Kitchen
INSERT INTO role_permissions (role_id, permission_id) SELECT 5, id FROM permissions WHERE permission_key IN ('kitchen');

-- Default admin. Login: admin / Admin@123  (the hash is created on the first login; change the password after!)
INSERT INTO users (full_name, username, email, password_hash, role_id) VALUES
('Administrator', 'admin', 'admin@xbayhotel.com', 'RESET_ON_FIRST_LOGIN', 1);

INSERT INTO room_types (type_name, description, default_price, booking_mode, capacity) VALUES
('Standard', 'Daily booking room', 6000, 'daily', 3),
('Deluxe', 'Larger daily room', 7500, 'daily', 4),
('VIP', 'VIP suite with extra services', 8000, 'vip', 4),
('Monthly', 'Permanent / monthly rent room', 25000, 'monthly', 2);

INSERT INTO room_amenities (amenity_name) VALUES ('AC'), ('Wi-Fi'), ('TV'), ('Attached Bathroom'), ('Hot Water'), ('Heater'), ('Mini Fridge');

INSERT INTO inventory_categories (category_name) VALUES ('Kitchen'), ('Housekeeping'), ('Linen'), ('Maintenance');

INSERT INTO menu_categories (category_name, sort_order) VALUES
('Fast Food',1),('BBQ',2),('Chinese',3),('Pakistani Food',4),('Breakfast',5),('Lunch',6),('Dinner',7),
('Beverages',8),('Cold Drinks',9),('Tea & Coffee',10),('Desserts',11),('Special Menu',12);
