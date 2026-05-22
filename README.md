# vela_bakery

## About Vela Bakery
**Vela Bakery** is a beautifully crafted, premium hybrid bakery ordering mobile application built with **Flutter** and powered by **Firebase**. Designed with a warm, modern aesthetic and responsive animations, it provides users with a seamless storefront, real-time interactive delivery tracking on live maps, interactive gamified order selection, and custom profile management. 

Additionally, it comes equipped with a comprehensive, secure **Admin Panel** for bakery managers to orchestrate categories, items, and cloud-stored image uploads in real-time.

---

## Key Features

### 🛒 1. Customer Shopping Experience
- **Interactive Menu Browsing**: Visually appealing presentation of fresh pastries, bread, and cakes, categorized with real-time updates from Cloud Firestore.
- **Can't Decide? (Random Pick Gacha)**: A fun gamified page featuring a customized curved text painter (`_CurvedTextPainter`) and smooth elastic animations to pick a random bakery item for undecided users, adding interactive delight!
- **Real-Time Cart & Checkout**: Seamless adding/removing of items, live total calculations, and custom checkout flows incorporating dynamic shipping address selection and mock payment gateways.

### 📍 2. Interactive Map & Live Order Tracking
- **Live Location Visualization**: Uses `flutter_map` (OpenStreetMap standard) and `latlong2` to plot bakery locations, customer coordinates, and a simulated path for the delivery driver.
- **Rider Animation**: Features a custom pulsing delivery rider icon (`🛵`) moving along route segments based on real-time order states.
- **Expandable Bottom Sheet**: Elegant draggable bottom sheet (`DraggableScrollableSheet`) detailing estimated arrival times, order items, driver info/rating, and dynamic contact shortcuts (chat/call).

### 🎨 3. Elegant Dark & Light Theme System
- Powered by a Singleton `ThemeService` and persisted locally via `shared_preferences`.
- **Warm Mocha Palette**: Switching to dark mode shifts the entire app into a luxurious espresso/mocha-inspired dark palette (`#1C1714` & `#2A2320`) matching the signature bakery colors, avoiding harsh stark black backgrounds.

### 🛡️ 4. Dynamic Menu Management (Admin Panel)
- **Role-Based Views**: Securely limits full CRUD database access to designated admin accounts.
- **Category & Item Management**: Admins can instantly add, edit, or delete items and categories directly from their mobile app.
- **Cloud Media Upload**: Connects to **Firebase Storage** via `image_picker` to let admins snap or choose a photo from their device and upload it instantly as a high-performance product image.

---

## Technology Stack

| Component | Technology / Package | Description |
| :--- | :--- | :--- |
| **Frontend Framework** | `Flutter (SDK ^3.10.8)` | Cross-platform Material 3 application development |
| **Cloud Database** | `Cloud Firestore` | Real-time menu updates, cart management, and order synchronizations |
| **Authentication** | `Firebase Auth` | Secure user sign-up, sign-in, and session management |
| **Cloud Storage** | `Firebase Storage` | Cloud-hosted image assets uploaded by admin dashboard |
| **Local Storage** | `shared_preferences` | Caches theme settings, login credentials, and user preferences |
| **Map Integration** | `flutter_map` & `latlong2` | High-performance interactive map tile renderers and geolocators |
| **Image Handling** | `image_picker` | Select and crop menu images from gallery or camera |

---

## App Architecture & Project Structure

The project leverages a highly maintainable, **Singleton-based Service Pattern** which cleanly separates business logic (services) from the UI layer (screens).

```text
lib/
├── firebase_options.dart      # Auto-generated Firebase configurations
├── main.dart                  # App initialization, routing & theme listeners
├── screens/                   # High-fidelity User Interfaces
│   ├── splash_screen.dart          # Elegant loading introduction screen
│   ├── login_screen.dart           # Firebase authentication screen (Sign In)
│   ├── register_screen.dart        # Account registration screen (Sign Up)
│   ├── home_page.dart              # Main hub displaying popular categories/items
│   ├── cart_page.dart              # Interactive shopping cart
│   ├── random_pick_page.dart       # Gacha style "Can't decide" picker
│   ├── order_tracking_page.dart    # Live OpenStreetMap route delivery tracker
│   ├── manage_menu_page.dart       # [Admin Only] Dynamic CRUD menu creator
│   ├── profile_page.dart           # Account settings & details
│   ├── shipping_addresses_page.dart # Address manager
│   ├── payment_methods_page.dart   # Mock checkout payment cards
│   ├── settings_page.dart          # Dark/Light theme switches
│   └── help_center_page.dart       # FAQ & customer support
├── services/                  # Clean state & database service providers (Singletons)
│   ├── auth_service.dart           # Controls login sessions & admin permission state
│   ├── cart_service.dart           # Localized and synced active cart logic
│   ├── menu_service.dart           # Fetches & caches menu selections from Firestore
│   ├── order_service.dart          # Synchronizes user transactions and delivery states
│   └── theme_service.dart          # Toggles visual variables and writes to SharedPreferences
└── widgets/                   # Universal custom UI components
    └── menu_image.dart             # Smart network/asset/fallback image renderer
```

---

## Getting Started & Setup

### Prerequisites
- **Flutter SDK**: `^3.10.8` or newer installed on your machine.
- **Java / Gradle / CocoaPods** depending on your target OS.
- A **Firebase Project** set up in your Firebase Console.

### 1. Clone & Clean Workspace
```bash
git clone https://github.com/YOUR_USERNAME/vela_bakery.git
cd vela_bakery
flutter clean
flutter pub get
```

### 2. Configure Firebase Integration
If setting up a fresh project, run the **Firebase CLI** wizard to generate `firebase_options.dart`:
```bash
# Register apps and fetch configuration keys
flutterfire configure
```
Make sure you enable:
- **Email/Password Provider** in Firebase Authentication.
- **Cloud Firestore** in test mode or with strict rules.
- **Firebase Storage** to host bakery images.

### 3. Run the App
```bash
# Run on an active emulator or plugged device
flutter run
