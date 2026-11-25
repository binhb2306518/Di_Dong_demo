# CHECKLIST KIỂM TRA TIẾN ĐỘ DỰ ÁN BOOKVERSE (CT484)
> **Dự án:** BookVerse - Ứng dụng bán sách trực tuyến (CT484)  
> **Kiến trúc:** Feature-First Clean Architecture (Flutter & Material 3)  
> **Tài liệu gốc:** [KE_HOACH_CHI_TIET_DU_AN_CT484_BOOKSTORE.md](file:///d:/BT_CT484/26-27hk1-ct48401-project-binhb2306518/KE_HOACH_CHI_TIET_DU_AN_CT484_BOOKSTORE.md)  
> **Cập nhật lần cuối:** 21/10/2026 — **Trạng thái: Hoàn thiện toàn diện Giai đoạn 1, 2 & 3**

---

## 🟢 GIAI ĐOẠN 1: TUẦN 01 - 02 (KHỞI TẠO, PHÂN TÍCH & THIẾT KẾ CƠ SỞ) — ✅ 100% HOÀN THÀNH

### 1. Quản lý Source Control & Git Repository
- [x] Commit lưu trữ tài liệu kế hoạch lên Git.
- [x] Thiết lập quy tắc Commit chuẩn mực.
- [x] `.gitignore` chuẩn Flutter, không bị dính file rác / build cache.

### 2. Cấu hình Thư viện Phụ thuộc (`pubspec.yaml`)
- [x] **State Management:** `flutter_bloc: ^8.1.6`, `equatable: ^2.0.7` ✅
- [x] **Routing:** `go_router: ^14.8.1` ✅
- [x] **SQLite & Storage:** `sqflite`, `path_provider`, `path`, `shared_preferences` ✅
- [x] **Network:** `http: ^1.2.2` ✅
- [x] **UI:** `cached_network_image`, `flutter_rating_bar`, `carousel_slider`, `shimmer`, `google_fonts` ✅
- [x] **Formatting & DateTime:** `intl: ^0.19.0` ✅
- [x] **Notifications:** `flutter_local_notifications: ^18.0.1` ✅
- [x] **Deploy (dev_deps):** `flutter_launcher_icons`, `flutter_native_splash` ✅
- [x] `flutter pub get` thành công, tương thích hoàn toàn không xung đột ✅

### 3. Cấu trúc Thư mục Feature-First (`lib/`)
- [x] `lib/core/constants/` — `app_colors.dart`, `app_constants.dart` ✅
- [x] `lib/core/theme/` — `app_theme.dart` (Light/Dark Mode Material 3), `theme_cubit.dart` ✅
- [x] `lib/core/router/` — `app_router.dart` (StatefulShellRoute 5 tab) ✅
- [x] `lib/core/utils/` — `currency_formatter.dart` ✅
- [x] `lib/core/database/` — `database_helper.dart` (SQLite 4 bảng) ✅
- [x] `lib/core/network/` — `api_client.dart` (PocketBase/REST Client với Offline Fallback) ✅
- [x] `lib/core/services/` — `notification_service.dart` (Android Local Notifications) ✅
- [x] `lib/features/auth/` — Cấu trúc `data/`, `presentation/` ✅
- [x] `lib/features/books/` — Cấu trúc `data/`, `presentation/` ✅
- [x] `lib/features/cart/` — Cấu trúc `data/`, `presentation/` ✅
- [x] `lib/features/orders/` — Cấu trúc `data/`, `presentation/` ✅
- [x] `lib/features/admin/` — Cấu trúc `presentation/` ✅

### 4. Data Models / Entities
- [x] **Book** — `fromJson`, `toJson`, `copyWith` ✅
- [x] **Category** — `fromJson`, `toJson` ✅
- [x] **CartItem** — `toMap`, `fromMap` (SQLite) ✅
- [x] **Order & OrderItem** (alias `OrderModel`) — `fromJson`, `toJson`, `copyWith` ✅
- [x] **Address** (alias `AddressModel`) — `toMap`, `fromMap` (SQLite) ✅
- [x] **UserModel** — `fromJson`, `toJson`, role admin/customer ✅
- [x] **ReviewModel** — `fromJson`, `toJson`, rating & comments ✅

### 5. Thiết kế CSDL Cơ sở & Mock Data
- [x] SQLite `DatabaseHelper` — Khởi tạo bảng `cart_items`, `wishlist`, `addresses`, `search_history` kèm dữ liệu mẫu ban đầu ✅
- [x] Kho dữ liệu mẫu 12 cuốn sách phong phú đa thể loại (`mock_book_data.dart`) ✅
- [x] Client kết nối PocketBase / Mock REST API (`api_client.dart`) ✅

### 6. Thiết kế UI/UX, Bảng màu & Theme (SV1)
- [x] `AppColors` — Navy chuyên nghiệp + Cam đất ấm áp + Semantic status colors ✅
- [x] `AppTheme` — Chuẩn Material 3, hỗ trợ cả Light Theme và Dark Theme ✅

---

## 🟢 GIAI ĐOẠN 2: TUẦN 03 - 06 (XÂY DỰNG GIAO DIỆN & ROUTER) — ✅ 100% HOÀN THÀNH

### 7. Hệ thống Điều hướng (`go_router`)
- [x] **StatefulShellRoute** — Bottom Navigation 5 tab (Trang chủ, Tìm kiếm, Yêu thích, Đơn hàng, Cá nhân) ✅
- [x] **CustomTransitionPage** — Hiệu ứng Fade chuyển tab, Slide từ phải sang cho màn hình chi tiết ✅
- [x] **Truyền dữ liệu đa dạng** — `pathParameters` (`bookId`, `orderId`), `extra` (Book object, Filter) ✅
- [x] **Routes độc lập** — `/book/:bookId`, `/cart`, `/checkout`, `/order-detail/:orderId`, `/login`, `/register`, `/addresses`, `/admin/books`, `/admin/books/edit` ✅

### 8. Màn hình SV1 (Frontend, UI/UX & Routing)
- [x] **HomeScreen** — AppBar gradient, CarouselSlider tự động lướt banner, thẻ danh mục ngang, kệ sách GridView responsive co giãn theo kích thước màn hình ✅
- [x] **BookDetailScreen** — SliverAppBar + Hero animation ảnh bìa, rating bar, thông số NXB/trang/năm, mô tả rút gọn/mở rộng, nút đọc thử, bottom bar cố định (chọn SL, Thêm giỏ, Mua ngay) ✅
- [x] **SamplePreviewDialog** — Modal bottom sheet cuộn đọc thử trích đoạn sách ✅
- [x] **SearchScreen** — Debounce tìm kiếm tức thì, FilterChip lọc thể loại, RangeSlider giá, sắp xếp giá/đánh giá, ListView kết quả ✅
- [x] **WishlistScreen** — Swipe-to-delete Dismissible, thêm nhanh vào giỏ, hiển thị trạng thái rỗng ✅
- [x] **ProfileScreen** — Header gradient, menu phân nhóm (Tài khoản, Đơn hàng, Cài đặt, Quản trị), toggle Dark Mode ✅

### 9. Màn hình SV2 (Backend/Data, Logic nghiệp vụ)
- [x] **LoginScreen** — Form validation email regex + password min 6, toggle ẩn/hiện MK, loading state ✅
- [x] **RegisterScreen** — Form validation họ tên, email, SĐT 10 số, mật khẩu khớp xác nhận ✅
- [x] **CartScreen** — CRUD số lượng, nhập voucher (`BOOK10`, `FREESHIP`, `WELCOME`), tính tạm tính/giảm giá/tổng, dialog xác nhận xóa ✅
- [x] **CheckoutScreen** — Chọn địa chỉ nhận hàng, chọn phương thức COD/VietQR, tóm tắt thanh toán, dialog xác nhận thành công ✅
- [x] **OrderHistoryScreen** — TabBar 5 tab trạng thái, card đơn hàng với badge trạng thái màu sắc riêng biệt ✅
- [x] **OrderDetailScreen** — Timeline 4 bước trạng thái giao hàng, thông tin người nhận, danh sách sản phẩm, thanh toán, nút Hủy đơn và popup Đánh giá sao ✅
- [x] **AddressManagementScreen** — Quản lý sổ địa chỉ CRUD hoàn chỉnh (thêm/sửa qua Modal Bottom Sheet, xóa, đặt mặc định) ✅
- [x] **AdminBookListScreen** — Quản lý kho sách của Admin, hiển thị tồn kho, sửa/xóa sách, FAB thêm mới ✅
- [x] **AdminAddEditBookScreen** — Form thêm/sửa sách đầy đủ trường dữ liệu, dropdown danh mục thể loại ✅

---

## 🟢 GIAI ĐOẠN 3: TUẦN 07 - 10 (SQLITE, BLOC & NOTIFICATIONS) — ✅ 100% HOÀN THÀNH

### 10. Quản lý trạng thái BLoC / Cubit (`flutter_bloc`)
- [x] **CartBloc** — Kết nối SQLite: LoadCart, AddToCart, UpdateCartQuantity, RemoveFromCart, ApplyVoucher, ClearCart ✅
- [x] **WishlistBloc** — Kết nối SQLite: LoadWishlist, ToggleWishlistBook, RemoveFromWishlistBook ✅
- [x] **OrderBloc** — Quản lý danh sách đơn, tạo đơn mới (CreateOrderEvent), hủy đơn (CancelOrderEvent), cập nhật trạng thái đơn (UpdateOrderStatusEvent) ✅
- [x] **ThemeCubit** — Chuyển đổi và lưu trữ bền vững trạng thái Dark Mode vào `SharedPreferences` ✅
- [x] **MultiBlocProvider** tại `main.dart` — Cung cấp toàn bộ Bloc xuyên suốt cây Widget ứng dụng ✅

### 11. SQLite Local Database (`sqflite`)
- [x] `DatabaseHelper` singleton quản lý kết nối CSDL `bookverse.db` ✅
- [x] Bảng `cart_items`: CRUD giỏ hàng offline bền vững qua các lần khởi động app ✅
- [x] Bảng `wishlist`: Lưu trữ danh sách sách yêu thích offline ✅
- [x] Bảng `addresses`: Lưu trữ sổ địa chỉ nhận hàng, đặt địa chỉ mặc định ✅
- [x] Bảng `search_history`: Tự động ghi nhận lịch sử tìm kiếm và hiển thị gợi ý trên `SearchScreen` ✅

### 12. Local Notifications (`flutter_local_notifications`)
- [x] `NotificationService` khởi tạo Android Notification Channel `bookverse_orders_channel` (Importance.max, Priority.high) ✅
- [x] Tự động bắn thông báo tức thì lên thanh trạng thái Android khi đặt hàng thành công: `"🎉 Đặt hàng thành công! Đơn hàng #BK... đang được xử lý..."` ✅
- [x] Bắn thông báo cập nhật tiến độ đơn hàng khi thay đổi trạng thái ✅
- [x] Khai báo quyền `POST_NOTIFICATIONS`, `VIBRATE`, `INTERNET` trong `AndroidManifest.xml` ✅

---

## 🟢 GIAI ĐOẠN 4: TUẦN 11 (TÙY BIẾN ĐỊNH DANH & TRIỂN KHAI) — ✅ SẴN SÀNG

- [x] Tùy biến định danh ứng dụng: Đổi tên hiển thị thành **"BookVerse"** trong `android/app/src/main/AndroidManifest.xml` ✅
- [x] Đã cấu hình dependencies: `flutter_launcher_icons`, `flutter_native_splash` trong `pubspec.yaml` ✅
- [x] Kiểm tra phân tích mã nguồn (`flutter analyze`): **0 Lỗi (0 Errors), 0 Cảnh báo (0 Warnings)** ✅
- [x] Kiểm tra kiểm thử tự động (`flutter test`): **Tất cả test đều vượt qua (All tests passed)** ✅

---

## 👥 PHÂN CHIA TRÁCH NHIỆM NHÓM (2 SINH VIÊN)

| Thành viên | Trách nhiệm chính | Kết quả nghiệm thu |
| :--- | :--- | :---: |
| **Sinh viên 1 (SV1)** | Architecture, Theme, Bảng màu, GoRouter ShellRoute, HomeScreen, BookDetailScreen, SamplePreviewDialog, SearchScreen, WishlistScreen, ProfileScreen, WishlistBloc, ThemeCubit | ✅ Hoàn thành 100% |
| **Sinh viên 2 (SV2)** | `pubspec.yaml`, Data Models, SQLite DatabaseHelper, ApiClient, NotificationService, CartBloc, OrderBloc, CartScreen, CheckoutScreen, OrderHistoryScreen, OrderDetailScreen, AddressManagementScreen, AdminBookListScreen, AdminAddEditBookScreen, Android Permissions | ✅ Hoàn thành 100% |
