# Product Requirements Document (PRD)

## Electronic — Luxury E-Commerce تطبيق متجر إلكتروني فاخر

---

## 1. Project Overview

| Item | Value |
|---|---|
| **Project Name** | Electronic (ELCT) |
| **Type** | E-Commerce Mobile & Web App |
| **Tech Stack** | Flutter (Dart), Firebase (Auth, Firestore, Storage), Riverpod, GoRouter |
| **Target Platforms** | Android, iOS, Web |
| **Admin Dashboard** | Vanilla Firebase JS + Bootstrap (separate repo) |
| **Firebase Project ID** | `electronic-684de` |

### 1.1 Vision

تقديم تجربة تسوق إلكتروني فاخرة وسلسة للمستخدمين في منطقة الخليج والشرق الأوسط، مع تركيز على المنتجات الإلكترونية، الأزياء، العطور، والساعات.

### 1.2 Target Audience

- المستخدمون في الكويت، السعودية، الإمارات، قطر، البحرين، عمان، مصر
- الفئة العمرية: 18–50 سنة
- اللغة: العربية (افتراضي) والإنجليزية
- العملة: الدينار الكويتي (KWD)

---

## 2. Goals & Objectives

### 2.1 Business Goals
- توفير متجر إلكتروني متكامل مع تجربة مستخدم فاخرة
- دعم طرق دفع متعددة (COD حاليًا، بطاقات ائتمان ومحافظ إلكترونية مستقبلًا)
- تمكين الإدارة من التحكم في المنتجات، التصنيفات، البانرات، وأكواد الخصم عبر لوحة تحكم منفصلة

### 2.2 Technical Goals
- مشاركة الكود بين الـ Mobile والـ Web (Flutter)
- أداء سلس مع Pagination و Caching
- Offline Support (Firestore Persistence)
- Security: Firestore Rules صارمة (Admin-only writes, owner-only reads)

---

## 3. Functional Requirements

### 3.1 Authentication

| Feature | Status |
|---|---|
| Email/Password Registration + Login | ✅ Done |
| Google Sign-In | ✅ Done |
| Phone OTP Verification (as linking step after registration) | ✅ Done |
| Forgot Password (email reset) | ✅ Done |
| Account Deletion (cleans all user data) | ✅ Done |
| Guest Cart Merge on login/register | ✅ Done |
| Protected Routes (require auth) | ✅ Done |

#### Flow: Registration
1. User enters First Name, Last Name, Phone (country picker, Kuwait default), Email, Password, Confirm Password, agrees to ToS
2. System sends OTP to phone number
3. User enters 6-digit OTP
4. System creates Firebase Auth user + links phone credential
5. System creates Firestore doc `users/{uid}` with firstName, lastName, email, phoneNumber, isAdmin: false
6. Guest cart merged to Firestore
7. User redirected to Home

#### Flow: Login
1. User enters Email + Password
2. System authenticates via Firebase Auth
3. Guest cart merged to Firestore
4. User redirected to Home

#### Flow: Google Sign-In
1. User taps "Continue with Google"
2. System authenticates via Google Sign-In
3. Firestore doc `users/{uid}` created/merged with displayName, email, photoUrl
4. Guest cart merged to Firestore
5. User redirected to Home

### 3.2 Home Page

| Feature | Status |
|---|---|
| Banner Carousel (Header, zone: "header") — auto-scroll, tappable image → campaign | ✅ Done |
| Banner Carousel (Middle, zone: "middle") — height 150 | ✅ Done |
| Single Banner (Bottom, zone: "bottom") — height 150 | ✅ Done |
| Categories Row (circular icons) | ✅ Done |
| New Arrivals (horizontal scroll) | ✅ Done |
| Best Sellers (horizontal scroll) | ✅ Done |
| Exclusive Products (horizontal scroll) | ✅ Done |
| Filter Tabs (All, Offers, Rating 5★, Best Seller) | ✅ Done |
| Filtered Products Grid (paginated, infinite scroll, page size 4) | ✅ Done |
| Category-based filtering from filter bar | ✅ Done |

### 3.3 Categories Page

| Feature | Status |
|---|---|
| Sidebar with category list (80px, scrollable) | ✅ Done |
| Products grid with search bar | ✅ Done |
| Category-based filtering with pagination (page size 10) | ✅ Done |
| Debounced search (300ms) | ✅ Done |
| Product count per category | ✅ Done |

### 3.4 Product Detail

| Feature | Status |
|---|---|
| Product images gallery (header) | ✅ Done |
| Product info (name, price, rating, reviews count, stock) | ✅ Done |
| Description + Specifications tabs | ✅ Done |
| Reviews section with star ratings | ✅ Done |
| Add Review (rating + comment) | ✅ Done |
| Similar Products (horizontal scroll) | ✅ Done |
| Add to Cart + Quantity selector | ✅ Done |
| Wishlist toggle | ✅ Done |

### 3.5 Cart

| Feature | Status |
|---|---|
| Dual-mode: Guest (local StateNotifier) + Logged-in (Firestore realtime) | ✅ Done |
| Add, Update Quantity, Remove, Clear | ✅ Done |
| Out-of-stock handling | ✅ Done |
| Cart badge on bottom nav | ✅ Done |
| Guest cart merges to Firestore on login/register | ✅ Done |
| Real-time cart total + item count | ✅ Done |

### 3.6 Checkout

| Feature | Status |
|---|---|
| Shipping Address form (name, phone, address, city) | ✅ Done |
| Promo Code validation with real-time discount | ✅ Done |
| Payment Method selection (COD only, Card/Wallet coming soon) | ✅ Done |
| Shipping cost calculation (free above 500 KWD threshold) | ✅ Done |
| Order placement with Firestore transaction:
  - Validate promo code
  - Read & validate stock for each item
  - Decrement stock quantities
  - Create order document | ✅ Done |
| Order Success screen with order number + navigation options | ✅ Done |

### 3.7 Orders

| Feature | Status |
|---|---|
| Order list with Firestore realtime stream | ✅ Done |
| Order detail with products, invoice, status tracker | ✅ Done |
| Order status: Pending → Confirmed → Shipped → Delivered → Cancelled | ✅ Done |
| Order number copy + tracking info | ✅ Done |
| Empty state with "Go Shopping" button | ✅ Done |

### 3.8 Wishlist

| Feature | Status |
|---|---|
| Real-time Firestore stream of wishlist items | ✅ Done |
| Toggle add/remove | ✅ Done |
| Wishlist count provider | ✅ Done |
| Empty state | ✅ Done |

### 3.9 Profile

| Feature | Status |
|---|---|
| User profile display with stats (orders, wishlist, cart) | ✅ Done |
| Edit Profile (First Name, Last Name, Phone, Email) | ✅ Done |
| Address management (add, edit, delete, set default) | ✅ Done |
| Language toggle (Arabic/English, persisted) | ✅ Done |
| Logout with confirmation | ✅ Done |
| Account deletion (re-login required) | ✅ Done |
| Contact Us (call, email) | ✅ Done |
| App info, Terms, Privacy Policy, Return Policy | ✅ Done |

### 3.10 Notifications

| Feature | Status |
|---|---|
| Static placeholder screen with empty state + pull-to-refresh | ✅ Done |
| Real-time notifications | ❌ Not yet |

### 3.11 Search

| Feature | Status |
|---|---|
| Debounced search (500ms) | ✅ Done |
| Paginated search results (page size 10) | ✅ Done |
| Parallel Arabic/English prefix range queries with deduplication | ✅ Done |
| Empty / Initial / Error states | ✅ Done |
| Pull-to-refresh + infinite scroll | ✅ Done |

### 3.12 Campaign (Banner Landing)

| Feature | Status |
|---|---|
| Full-width hero banner (300px) with gradient overlay + title | ✅ Done |
| Products grid from linked category (banner.targetId) | ✅ Done |
| Transparent back button overlaying image | ✅ Done |
| Section header with gold accent | ✅ Done |
| Shimmer loading states | ✅ Done |

### 3.13 Admin Dashboard (Separate Repo)

| Path | `C:\Users\...\electronik-clean` |
|---|---|
| Tech | Vanilla Firebase JS + Bootstrap |
| Features | Products CRUD, Categories, Banners, Orders, Promo Codes, Store Settings |

---

## 4. Non-Functional Requirements

### 4.1 Performance
- **Cold start (Web)**: < 3s on fast 4G (target)
- **Cold start (Mobile)**: < 2s
- **Pagination**: Page size 10 for products, 4 for filtered
- **Image loading**: CachedNetworkImage with shimmer placeholders
- **Banner auto-scroll**: 5-second interval
- **Debounce**: Search 300ms (categories), 500ms (global search)

### 4.2 Security
- **Firestore Rules**: Admin-only writes, owner-only reads for user data
- **Authentication**: Firebase Auth with email/password, Google, Phone
- **Validation**: Client-side form validation for all inputs
- **Error Handling**: All Firestore reads have `.catchError(() => [])` fallback

### 4.3 SEO
- **Status**: ❌ Weak (Flutter Web dynamic rendering is not SEO-friendly)
- **Mitigation**: Meta tags in `web/index.html` updated for title/description/OG
- **Recommendation**: Consider SSR with `flutter_web_html_renderer` or static landing page

### 4.4 Localization
- **Languages**: Arabic (default) + English
- **L10n**: Flutter ARB files (126 keys each)
- **Entity Localization**: Extension methods for bilingual entity fields
- **Direction**: RTL for Arabic, LTR for English (switched at runtime via Directionality widget)

---

## 5. Technical Architecture

### 5.1 Flutter App Architecture

```
lib/
  core/           → Theme, Router, Widgets, Utils, Extensions, Providers, Firebase config
  data/           → Seeders
  features/
    {feature}/
      data/        → Datasources (Firestore), Models (serialization), Repositories
      domain/      → Entities, Repository interfaces
      presentation/→ Providers (Riverpod), Screens, Widgets
```

### 5.2 State Management

**Riverpod 2.x:**
- `Provider` for singletons (datasources, repositories)
- `FutureProvider` for async one-shot fetches (home data, product detail, orders)
- `StreamProvider` for realtime streams (auth state, cart, wishlist)
- `StateNotifierProvider` for mutable state (guest cart, paginated products)
- `StateProvider` for simple state (pending redirect, registration data)

### 5.3 Routing

**GoRouter** with:
- Auth-based redirect (protected routes → login, auth routes → home)
- ShellRoute for bottom navigation shell
- Custom transition builders (fade, slide, scale, no-transition)
- 20 registered routes

### 5.4 Data Layer

| Layer | Technology |
|---|---|
| Authentication | Firebase Auth |
| Database | Cloud Firestore (NoSQL) |
| Storage | Firebase Storage (product images) |
| Cache | Firestore offline persistence (non-web, unlimited) |
| Connectivity | connectivity_plus |

### 5.5 Firestore Collections

| Collection | Subcollection | Purpose |
|---|---|---|
| `products` | `{id}/reviews` | Products + reviews |
| `categories` | — | Product categories |
| `banners` | — | Ad banners (with `zone` field: header/middle/bottom) |
| `orders` | — | Customer orders |
| `promoCodes` | — | Discount codes |
| `settings` → doc `shipping` | — | Shipping configuration |
| `users/{uid}` | `cart`, `addresses`, `wishlist` | User data |
| `_meta` → doc `__seed_version__` | — | Seeder version tracking |

---

## 6. User Flows

### 6.1 Browse & Purchase (Guest)
```
Home → Browse products → Product Detail → Add to Cart → (Login Required at Checkout)
  → Email/Password Register → Phone OTP Verify → Guest Cart Merged → Checkout → Order Success
```

### 6.2 Browse & Purchase (Logged In)
```
Home → Browse products → Product Detail → Add to Cart → Checkout → Order Success
```

### 6.3 Browse & Purchase (Google Sign-In)
```
Home → Browse products → Product Detail → Add to Cart → Login (Google) → Checkout → Order Success
```

### 6.4 Campaign Flow
```
Home → Tap Banner → Campaign Page (hero + products) → Tap Product → Product Detail
```

### 6.5 Admin Flow (Separate Dashboard)
```
Login (admin credentials) → Manage Products / Categories / Banners / Orders / PromoCodes
```

---

## 7. Data Model (Key Entities)

### 7.1 User (`users/{uid}`)
```
firstName, lastName, displayName, email, phoneNumber, phoneVerified, photoUrl, createdAt, isAdmin
```

### 7.2 Product (`products/{id}`)
```
nameAr, nameEn, descriptionAr, descriptionEn, categoryId, price, originalPrice, discountPercent,
images[], rating, reviewCount, stockQuantity, isFeatured, isExclusive, isBestSeller, isNew,
specs (Map), tags[], searchKeywords[], createdAt, updatedAt
```

### 7.3 Banner (`banners/{id}`)
```
imageUrl, titleAr, titleEn, subtitleAr?, subtitleEn?, targetType, targetId?, order, isActive, zone
```

### 7.4 Order (`orders/{id}`)
```
userId, items[{productId, nameAr, nameEn, image, price, quantity}], subtotal, shipping, total,
status (pending/confirmed/shipped/delivered/cancelled), shippingAddress, paymentMethod, discount,
promoCode?, createdAt
```

### 7.5 Promo Code (`promoCodes/{code}`)
```
code, discountPercent, maxUses, currentUses, expiresAt?, isActive
```

---

## 8. Routes & Navigation

| Route | Screen | Auth Required | Shell |
|---|---|---|---|
| `/splash` | SplashScreen | ❌ | ❌ |
| `/auth/login` | LoginScreen | ❌ | ❌ |
| `/auth/register` | RegisterScreen | ❌ | ❌ |
| `/auth/forgot-password` | ForgotPasswordScreen | ❌ | ❌ |
| `/phone-verification` | PhoneVerificationScreen | ✅ | ❌ |
| `/` (home) | HomeScreen | ❌ | ✅ |
| `/categories` | CategoriesScreen | ❌ | ✅ |
| `/wishlist` | WishlistScreen | ✅ | ✅ |
| `/cart` | CartScreen | ✅ | ✅ |
| `/profile` | ProfileScreen | ✅ | ✅ |
| `/products/:id` | ProductDetailScreen | ❌ | ❌ |
| `/search` | SearchScreen | ❌ | ❌ |
| `/checkout` | CheckoutScreen | ✅ | ❌ |
| `/order-success/:id` | OrderSuccessScreen | ✅ | ❌ |
| `/orders` | OrdersScreen | ✅ | ❌ |
| `/orders/:id` | OrderDetailScreen | ✅ | ❌ |
| `/notifications` | NotificationsScreen | ❌ | ❌ |
| `/profile/edit` | EditProfileScreen | ✅ | ❌ |
| `/profile/addresses` | AddressesScreen | ✅ | ❌ |
| `/campaign/:bannerId` | CampaignScreen | ❌ | ❌ |

---

## 9. Dependencies (pubspec.yaml — Key Packages)

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `go_router` | Navigation + routing + auth redirect |
| `firebase_core` + `_auth`, `_firestore`, `_storage` | Firebase backend |
| `google_sign_in` | Google authentication |
| `cached_network_image` | Image loading + caching |
| `flutter_animate` | Animations |
| `flutter_localizations` + `intl` | Localization (ARB) |
| `connectivity_plus` | Network status |
| `shared_preferences` | Locale persistence |
| `flutter_google_maps` | Map in checkout address |

---

## 10. Admin Dashboard (electronik-clean)

| Repo Path | `C:\Users\VICTUS\OneDrive - Egyptian E-Learning University\Desktop\electronik-clean` |
|---|---|
| **Tech** | HTML, Bootstrap, Vanilla Firebase JS SDK |
| **Features** | Product CRUD, Categories, Banners, Orders Management, Promo Codes, Store Config |
| **Auth** | Firebase Auth (email/password) with admin check via Firestore `users/{uid}.isAdmin` |
| **Note** | Separate repo, not part of Flutter codebase |

---

## 11. Known Issues & Future Improvements

### 11.1 Issues
- **Phone OTP redirect bug**: ~~User goes to home instead of phone verification after registration~~ ✅ Fixed
- **SEO**: Flutter Web content not indexable by search engines
- **Payment**: Only COD available (Card/Wallet marked as "Coming Soon")
- **Notifications**: Placeholder only, no real-time push notifications
- **Email verification**: Not enforced (users can use app without verifying email)
- **Admin dashboard settings**: `_meta/store_config` vs `settings/shipping` misalignment

### 11.2 Future Scope
- [ ] Payment gateway integration (KNET, card, wallet)
- [ ] Real-time push notifications (FCM)
- [ ] Email verification enforcement
- [ ] Order reviews + ratings after delivery
- [ ] Product variants (size, color, storage)
- [ ] Wishlist share / social features
- [ ] Dark mode
- [ ] Analytics + Crashlytics
- [ ] Unit + widget tests
- [ ] SSR for SEO (landing page)
- [ ] API key restrictions (Firestore, Maps)
- [ ] Guest checkout (order without account)

---

## 12. Glossary

| Term | Meaning |
|---|---|
| COD | Cash on Delivery (الدفع عند الاستلام) |
| OTP | One-Time Password (رمز تحقق لمرة واحدة) |
| RTL | Right-to-Left (اتجاه الكتابة من اليمين لليسار للعربية) |
| KWD | Kuwaiti Dinar (الدينار الكويتي) |
| ARB | Application Resource Bundle (ملفات الترجمة في Flutter) |
| L10n | Localization (الترجمة والتكييف المحلي) |
| SSR | Server-Side Rendering |
| FCM | Firebase Cloud Messaging |
