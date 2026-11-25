# KẾ HOẠCH CHI TIẾT DỰ ÁN PHÁT TRIỂN ỨNG DỤNG BÁN SÁCH ONLINE TRÊN ANDROID (FLUTTER)
**Học phần:** CT484 - Phát triển ứng dụng di động  
**Giảng viên phụ trách:** ThS. Bùi Võ Quốc Bảo  
**Học kỳ:** HK1, Năm học 2026 - 2027  
**Quy mô:** Nhóm 2 sinh viên (SV1 & SV2)  
**Công nghệ:** Flutter (Dart) - Android Target  

---

## 1. TỔNG QUAN ĐỀ TÀI & KHẢO SÁT ỨNG DỤNG THỰC TẾ

### 1.1. Tên đề tài & Ý tưởng
- **Tên dự án:** **BookVerse** - Ứng dụng mua bán sách và khám phá tri thức online.
- **Ý tưởng cốt lõi:** Kết hợp trải nghiệm mua sách tiện lợi của **Tiki / Fahasa** với trải nghiệm đọc thử, xem mục lục của **Amazon Kindle** và hệ thống gợi ý danh mục thông minh.

### 1.2. Khảo sát nghiệp vụ các App sách hàng đầu (Tiki, Fahasa, Amazon Kindle)
Qua phân tích thực tế các app thương mại điện tử chuyên ngành sách, ứng dụng cần giải quyết các bài toán logic quan trọng:
1. **Tìm kiếm & Phân loại đa tầng:** Sách phân chia theo thể loại (Văn học, Kinh tế, Công nghệ, Kỹ năng sống, Truyện tranh...), theo tác giả, NXB, mức giá, và xếp hạng đánh giá sao.
2. **Trang chi tiết sách (Book Detail):** Thông số chi tiết (số trang, ngày xuất bản, loại bìa, kích thước), xem ảnh bìa bằng Hero Animation, **tính năng đọc thử (Book Sample/Preview)** trích đoạn chương 1 để tăng tỷ lệ chốt đơn.
3. **Giỏ hàng thông minh (Smart Cart):** Thêm vào giỏ với số lượng, cập nhật tồn kho (kiểm tra `stock_quantity`), tích chọn sản phẩm cần thanh toán, nhập mã giảm giá (Coupon/Voucher code) tính chiết khấu trực tiếp.
4. **Quy trình đặt hàng (Checkout Workflow):** Chọn địa chỉ nhận hàng, chọn phương thức thanh toán (COD / Giả lập chuyển khoản ngân hàng qua mã QR VietQR / Momo Sandbox), tính toán tổng tiền và phí ship tự động.
5. **Theo dõi đơn hàng (Order Tracking Timeline):** Quản lý trạng thái 4 bước: `Chờ xác nhận (Pending)` -> `Đang đóng gói (Processing)` -> `Đang vận chuyển (Shipping)` -> `Giao thành công (Delivered)` / `Đã hủy (Cancelled)`.
6. **Tương tác độc giả:** Đánh giá & bình luận sao (1-5 sao + nhận xét), danh sách yêu thích (Wishlist) lưu trữ offline/online.
7. **Phân quyền Quản trị (Admin Portal):** Quản lý kho sách (Thêm/Sửa/Xóa sách, cập nhật số lượng tồn kho) và cập nhật trạng thái đơn hàng của khách để tạo thành chu trình nghiệp vụ khép kín.

---

## 2. MA TRẬN ĐÁNH GIÁ & ĐỐI CHIẾU TIÊU CHUẨN ĐỒ ÁN (RUBRIC 10/10 ĐIỂM)

Bảng đối chiếu đảm bảo thỏa mãn 100% (Mức 5 - 100% số điểm) của từng tiêu chí trong slide môn học:

| Tiêu chí đánh giá (Slide) | Điểm tối đa | Yêu cầu chuẩn trong Slide | Giải pháp kỹ thuật trong dự án BookVerse | Mức dự kiến |
| :--- | :---: | :--- | :--- | :---: |
| **1. Sử dụng Widget thiết kế giao diện** | **3.0đ** | - Số trang $\ge$ 6 trang, đúng quy trình.<br>- Đa dạng: `ListView`, `GridView`, hình ảnh, icon, pub.dev.<br>- Hỗ trợ **Local notifications** hoặc Push.<br>- **Responsive layout** cơ bản. | - Thiết kế **10+ màn hình** hoàn chỉnh.<br>- Sử dụng `GridView.builder` (kệ sách), `ListView.separated`, `CarouselSlider`, `CachedNetworkImage`, `Shimmer` hiệu ứng tải trang.<br>- Tích hợp `flutter_local_notifications` bắn thông báo khi đặt hàng thành công, đổi trạng thái đơn, và nhắc nhở đọc sách.<br>- Dùng `LayoutBuilder`, `MediaQuery` co giãn 2 cột (điện thoại) / 3-4 cột (màn hình ngang/tablet). | **3.0 / 3.0** (100%) |
| **2. Điều hướng giữa các trang (Routing)** | **2.0đ** | - Dùng thư viện `go_router` (kết hợp Navigator API).<br>- Truyền và nhận dữ liệu.<br>- Tùy biến hiệu ứng khi điều hướng. | - Cấu hình `GoRouter` với ShellRoute (Bottom Navigation Bar).<br>- Truyền `pathParameters` (bookId), `extra` (Book object, Order object, Filter params).<br>- Custom Transition Page: `CustomTransitionPage` tạo hiệu ứng Slide/Fade + `Hero` animation bìa sách cực mượt. | **2.0 / 2.0** (100%) |
| **3. Quản lý trạng thái & Kiến trúc** | **2.0đ** | - Quản lý trạng thái: Provider / Bloc / Cubit / get_it...<br>- Kiến trúc phần mềm rõ ràng, nhất quán. | - Sử dụng **Flutter BLoC / Cubit** (chuẩn mực công nghiệp cao cấp nhất).<br>- Kiến trúc chuẩn **Clean Architecture / Feature-First**: Phân tách rõ `presentation/`, `domain/`, `data/`, tách biệt State, Event, Repository, DataSource. | **2.0 / 2.0** (100%) |
| **4. Cập nhật, lưu trữ trạng thái & Dữ liệu** | **2.0đ** | - Lưu trạng thái qua các lần chạy: Dữ liệu chính dùng **SQLite** (local) hoặc **PocketBase / Tự viết REST API** (server).<br>- Tương tác cập nhật dữ liệu (CRUD: Thêm/Sửa/Xóa). | - **Backend/Cloud Server:** Sử dụng **PocketBase** (hoặc Node.js REST API) lưu User, Book catalog, Orders, Reviews.<br>- **Local Storage:** Sử dụng **SQLite (sqflite)** lưu Giỏ hàng offline (Cart Items), Lịch sử tìm kiếm, Danh sách yêu thích (Wishlist).<br>- CRUD đầy đủ: Thêm/sửa/xóa giỏ hàng, đặt hàng/hủy đơn, thêm/sửa/xóa địa chỉ, viết/sửa/xóa review, Admin CRUD sách. | **2.0 / 2.0** (100%) |
| **5. Tùy biến và Triển khai ứng dụng** | **1.0đ** | - Đổi tên app, đổi app icon, thêm splash screen.<br>- Triển khai trên thiết bị thật hoặc Store. | - Đổi tên thành **BookVerse** trong `AndroidManifest.xml` & `strings.xml`.<br>- Dùng `flutter_launcher_icons` tạo bộ icon chuyên nghiệp.<br>- Dùng `flutter_native_splash` màn hình khởi động mượt mà.<br>- Build APK Release (`flutter build apk --release`), cài đặt test 100% trên điện thoại Android thật, quay video demo. | **1.0 / 1.0** (100%) |
| **TỔNG ĐIỂM** | **10.0đ** | **Đầy đủ 5 trụ cột, không sao chép nguyên mẫu từ youtube/blog** | **Dự án tự xây dựng hoàn chỉnh, có cam kết bản quyền, phân chia commit GitHub đều đặn** | **10 / 10** |

---

## 3. DANH SÁCH 10+ MÀN HÌNH & QUY TRÌNH NGHIỆP VỤ (VƯỢT CHỈ TIÊU $\ge$ 6 TRANG)

1. **Màn hình Khởi động & Đăng nhập/Đăng ký (`SplashScreen`, `LoginScreen`, `RegisterScreen`):**
   - Splash screen hiển thị logo hiệu ứng mượt.
   - Đăng nhập, đăng ký tài khoản độc giả / tài khoản quản trị (Admin/Customer role) kết nối PocketBase/REST API.
2. **Màn hình Trang chủ (`HomeScreen`):**
   - Header: Thanh tìm kiếm nhanh, icon thông báo, icon giỏ hàng có Badge số lượng.
   - Banner quảng cáo lướt tự động (`carousel_slider`).
   - Danh mục thể loại ngang (`ListView.horizontal`).
   - Khối "Sách Bán Chạy" & "Sách Mới Phát Hành" dạng lưới (`GridView.builder`).
3. **Màn hình Tìm kiếm & Bộ lọc nâng cao (`SearchFilterScreen`):**
   - Search bar tức thì (Debounce search).
   - Chip lọc thể loại, thanh trượt khoảng giá (`RangeSlider`), sắp xếp theo giá tăng/giảm hoặc số sao đánh giá.
   - Lịch sử tìm kiếm lưu trong SQLite.
4. **Màn hình Chi tiết Sách (`BookDetailScreen`):**
   - Hero animation ảnh bìa sách.
   - Thông tin tác giả, NXB, năm xuất bản, giá bán, giá bìa, % giảm giá, số lượng còn trong kho.
   - Nút "Đọc thử trích đoạn" (Sample preview pop-up modal).
   - Đánh giá từ người dùng (Rating Bar & Danh sách review).
   - Nút cố định bên dưới: "Thêm vào giỏ" & "Mua ngay".
5. **Màn hình Giỏ hàng (`CartScreen`):**
   - Hiển thị danh sách sách đã chọn từ SQLite / Cloud DB.
   - Tăng/giảm số lượng, xóa sản phẩm khỏi giỏ (CRUD).
   - Ô nhập mã Voucher giảm giá (áp dụng mã BOOK10, FREESHIP...).
   - Hiển thị tổng tiền tạm tính, số tiền giảm và nút "Tiến hành đặt hàng".
6. **Màn hình Thanh toán & Đặt hàng (`CheckoutScreen`):**
   - Chọn địa chỉ giao hàng (mở modal hoặc sang màn hình chọn địa chỉ).
   - Chọn phương thức thanh toán: COD hoặc Chuyển khoản QR.
   - Xem lại tóm tắt đơn hàng, nhấn "Xác nhận đặt hàng" -> Kích hoạt `flutter_local_notifications` thông báo tức thì lên thanh trạng thái Android.
7. **Màn hình Quản lý Đơn hàng (`OrderHistoryScreen` & `OrderDetailScreen`):**
   - Tab phân loại đơn: *Tất cả*, *Chờ xử lý*, *Đang giao*, *Đã giao*, *Đã hủy*.
   - Chi tiết đơn hàng: Mã đơn, ngày đặt, địa chỉ, danh sách món, trạng thái đơn, nút "Hủy đơn" (nếu chưa giao) hoặc "Đánh giá sách" (nếu đã giao).
8. **Màn hình Sách Yêu Thích (`WishlistScreen`):**
   - Danh sách sách độc giả đã bấm icon tim lưu lại để đọc sau (Lưu SQLite offline).
9. **Màn hình Quản lý Sổ Địa chỉ (`AddressManagementScreen` - CRUD):**
   - Thêm địa chỉ mới, chỉnh sửa thông tin, đặt làm mặc định, xóa địa chỉ.
10. **Màn hình Cá nhân & Cài đặt (`ProfileScreen`):**
    - Cập nhật thông tin người dùng, đổi mật khẩu.
    - Chuyển đổi Dark Mode / Light Mode (`ThemeCubit` lưu `SharedPreferences`).
    - Nút Đăng xuất.
11. **Màn hình Dành cho Quản trị viên (`AdminBookManageScreen` - Điểm cộng đồ án):**
    - Quản lý danh mục sách: Thêm sách mới, sửa giá/số lượng tồn, xóa sách khỏi kệ.
    - Cập nhật trạng thái đơn hàng của khách hàng (Pending -> Shipping -> Delivered).

---

## 4. PHÂN CHIA CÔNG VIỆC CHO NHÓM 2 NGƯỜI (SV1 & SV2)

Để đảm bảo yêu cầu của slide: **"Các thành viên trong nhóm đều phải tham gia viết code (có lịch sử commit trên GitHub)"**, công việc được phân chia công bằng, chuyên môn hóa nhưng bổ trợ cho nhau:

### 👤 SINH VIÊN 1 (SV1): Trưởng nhóm Frontend, UI/UX & Routing
- **Trách nhiệm chính:**
  1. Khởi tạo cấu trúc dự án (Architecture), Color Scheme, Typography, Themes (Light/Dark Mode).
  2. Cấu hình hệ thống điều hướng toàn diện bằng `go_router` với `ShellRoute`, `CustomTransitionPage` và truyền nhận dữ liệu (`extra`, `params`).
  3. Cài đặt các màn hình phía Client:
     - `HomeScreen`, `BookDetailScreen` (kèm Hero animation, Dialog đọc thử).
     - `SearchFilterScreen` (Logic debounce search, bộ lọc nhiều tiêu chí).
     - `WishlistScreen` & `ProfileScreen` (Giao diện cài đặt, đổi giao diện).
  4. Đảm bảo giao diện Responsive (`LayoutBuilder`, co giãn mượt từ màn hình dọc sang ngang và tablet).
  5. Đóng góp vào Báo cáo tiến độ (Tuần 6) và Báo cáo hoàn chỉnh (Tuần 10): Soạn thảo phần Phân tích yêu cầu, Thiết kế giao diện Wireframe/Figma, Sơ đồ luồng điều hướng màn hình.
- **Quy chuẩn Git Commit của SV1:** Commit các message tiền tố `feat(ui): ...`, `feat(router): ...`, `style: ...`, `refactor(screen): ...`.

### 👤 SINH VIÊN 2 (SV2): Trưởng nhóm Backend/Data, State Management & Triển khai
- **Trách nhiệm chính:**
  1. Thiết lập Backend (PocketBase hoặc NodeJS REST API) & Cài đặt Database SQLite nội bộ (`sqflite`).
  2. Xây dựng Data Models, Repository Pattern, API Service (Dio/Http) và SQLite Helper.
  3. Quản lý trạng thái bằng **Bloc / Cubit**:
     - `AuthBloc` (Đăng nhập, đăng ký, phiên làm việc).
     - `CartBloc` & `OrderBloc` (Logic tính tiền, thêm bớt giỏ hàng, áp mã voucher, tạo đơn hàng).
     - `AdminBookBloc` (CRUD quản lý sách dành cho admin).
  4. Cài đặt các màn hình có logic giao dịch phức tạp:
     - `LoginScreen`, `RegisterScreen`.
     - `CartScreen`, `CheckoutScreen`, `OrderHistoryScreen`, `OrderDetailScreen`.
     - `AddressManagementScreen` & `AdminBookManageScreen` (CRUD).
  5. Cài đặt `flutter_local_notifications` hiển thị thông báo Android khi đặt hàng thành công và cập nhật trạng thái đơn.
  6. Tùy biến triển khai: Đổi App Name, App Icon (`flutter_launcher_icons`), Splash Screen (`flutter_native_splash`), Build file APK Release test trên điện thoại thật.
  7. Đóng góp vào Báo cáo: Sơ đồ CSDL (ERD), Kiến trúc phần mềm, Thiết kế API/SQLite, Hướng dẫn cài đặt và triển khai.
- **Quy chuẩn Git Commit của SV2:** Commit các message tiền tố `feat(data): ...`, `feat(bloc): ...`, `feat(db): ...`, `feat(notify): ...`, `chore(deploy): ...`.

---

## 5. KẾ HOẠCH THEO TỪNG GIAI ĐOẠN & PROMPT MẪU CHO AI

Kế hoạch bám sát chính xác từng tuần theo yêu cầu môn học CT484 (Tuần 1 - Tuần 11).

```
Tuần 01-02: Khởi tạo đề tài & Kiến trúc
   │
Tuần 03-06: Thiết kế Giao diện & Điều hướng Router (Nộp Báo cáo Tiến độ Tuần 6)
   │
Tuần 07-10: Cài đặt Dữ liệu (PocketBase/SQLite), BLoC & Nghiệp vụ (Nộp Báo cáo Hoàn chỉnh Tuần 10)
   │
Tuần 11:    Build APK, Tùy biến App Icon/Splash, Vấn đáp bảo vệ dự án
```

---

### GIAI ĐOẠN 1: TUẦN 01 - 02 (KHỞI TẠO, PHÂN TÍCH & THIẾT KẾ CƠ SỞ)
- **Mục tiêu:** Thống nhất đề tài BookVerse, thiết kế cấu trúc thư mục Feature-First, xác định cấu trúc dữ liệu Entity và khởi tạo Git repository.
- **Phân công tuần 1-2:**
  - **SV1:** Phác thảo Wireframe màn hình trên giấy/Figma, thiết kế Theme ứng dụng (bảng màu HSL hài hòa, Material 3), tạo khung thư mục `lib/`.
  - **SV2:** Thiết kế cấu trúc bảng CSDL (Books, Categories, Users, Carts, Orders, Reviews, Addresses), cấu hình file `pubspec.yaml` với các thư viện cần thiết.

#### 🤖 PROMPT MẪU CHO AI - GIAI ĐOẠN 1:
```text
[MỤC TIÊU]: Khởi tạo kiến trúc dự án Flutter App bán sách online "BookVerse" theo mô hình Feature-First Clean Architecture.
[YÊU CẦU CÔNG NGHỆ]:
- Flutter SDK ^3.13, Dart, Material 3, Android target.
- Quản lý trạng thái: flutter_bloc.
- Điều hướng: go_router.
- Lưu trữ: sqflite, path_provider, shared_preferences, pocketbase (hoặc http).
- Thông báo: flutter_local_notifications.
- UI phụ trợ: cached_network_image, flutter_rating_bar, carousel_slider, intl.

[NHIỆM VỤ CỦA BẠN]:
1. Viết nội dung file pubspec.yaml hoàn chỉnh với tất cả các dependencies trên, giải thích công dụng từng thư viện.
2. Thiết kế cây thư mục dự án theo chuẩn Feature-First (tách rõ: core/theme, core/router, core/database, features/auth, features/books, features/cart, features/orders, features/admin).
3. Định nghĩa các Dart Data Models cơ bản: Book, Category, CartItem, Order, User, Review với các hàm fromJson, toJson, toMap (cho SQLite).
```

---

### GIAI ĐOẠN 2: TUẦN 03 - 06 (XÂY DỰNG GIAO DIỆN, WIDGETS & ROUTER)
- **Mục tiêu:** Cài đặt toàn bộ 10+ giao diện bằng các Widget đa dạng (`ListView`, `GridView`, `Card`, `Hero`), thiết lập `go_router` với Custom Transition, đạt điều kiện nộp Báo cáo Tiến độ cuối tuần 6.
- **Phân công tuần 3-6:**
  - **SV1 (Chủ lực):**
    - Cài đặt `AppRouter` sử dụng `go_router` (bao gồm `StatefulShellRoute` cho Bottom Navigation Bar gồm: Trang chủ, Khám phá/Tìm kiếm, Yêu thích, Đơn hàng, Cá nhân).
    - Viết mã nguồn cho `HomeScreen`, `BookDetailScreen` (kèm Hero animation bìa sách, modal trích đoạn đọc thử), `SearchFilterScreen`, `WishlistScreen`.
    - Thêm tính năng co giãn giao diện Responsive cơ bản (`LayoutBuilder`).
    - Viết phần thiết kế giao diện trong Báo cáo tiến độ Tuần 6.
  - **SV2:**
    - Viết mã nguồn giao diện cho các trang nghiệp vụ: `CartScreen`, `CheckoutScreen`, `OrderHistoryScreen`, `OrderDetailScreen`, `AddressManagementScreen`, `AdminBookManageScreen`.
    - Viết giao diện `LoginScreen` & `RegisterScreen` có validate form nhập liệu chặt chẽ.
    - Soạn thảo nội dung Báo cáo tiến độ Tuần 6 (Mô tả chức năng, tiến độ hoàn thành các màn hình, ảnh chụp minh chứng).

#### 🤖 PROMPT MẪU CHO AI - GIAI ĐOẠN 2:
```text
[MỤC TIÊU]: Xây dựng hệ thống Navigation bằng go_router và giao diện HomeScreen + BookDetailScreen cho app BookVerse.
[YÊU CẦU KỸ THUẬT]:
- Sử dụng go_router: cấu hình BottomNavigationBar qua ShellRoute (Home, Search, Wishlist, Orders, Profile).
- Trang BookDetailScreen nhận tham số bookId qua pathParameters và đối tượng Book qua extra.
- Tùy biến chuyển trang CustomTransitionPage với hiệu ứng Fade/Slide.
- Áp dụng Hero widget giữa ảnh bìa sách ở HomeScreen và BookDetailScreen.
- HomeScreen có: CarouselSlider banner khuyến mãi, ListView horizontal cho Thể loại, GridView.builder 2 cột cho danh sách sách (hiển thị ảnh, tiêu đề, tác giả, giá tiền, badge giảm giá, số sao).
- BookDetailScreen có: Hero image, thanh thông số (NXB, số trang, năm XB), mô tả rút gọn/mở rộng, nút "Đọc thử trích đoạn" mở BottomSheet, thanh bottom bar cố định có nút "Thêm vào giỏ" và "Mua ngay".

[NHIỆM VỤ CỦA BẠN]:
Viết code hoàn chỉnh cho:
1. lib/core/router/app_router.dart (cấu hình GoRouter chi tiết).
2. lib/features/books/presentation/screens/home_screen.dart.
3. lib/features/books/presentation/screens/book_detail_screen.dart.
4. lib/features/books/presentation/widgets/sample_read_modal.dart (modal trích đoạn đọc thử).
Đảm bảo code chạy không lỗi, không dùng placeholder bừa bãi, giao diện bắt mắt chuẩn Material 3.
```

---

### GIAI ĐOẠN 3: TUẦN 07 - 10 (CÀI ĐẶT DỮ LIỆU SQLITE/BACKEND, BLoC & LOCAL NOTIFICATIONS)
- **Mục tiêu:** Hoàn thiện 100% logic ứng dụng, lưu trữ dữ liệu qua SQLite và PocketBase/API, CRUD giỏ hàng/địa chỉ/sách, tích hợp Local Notifications, nộp Báo cáo hoàn chỉnh cuối tuần 10.
- **Phân công tuần 7-10:**
  - **SV1:**
    - Cài đặt `SearchBloc` (tính năng tìm kiếm tức thì theo từ khóa, lọc theo khoảng giá, thể loại).
    - Cài đặt `WishlistBloc` kết nối lưu trữ SQLite cục bộ.
    - Cài đặt tính năng Review/Đánh giá sách (Độc giả cho sao và bình luận).
    - Chuẩn bị phần kết quả thử nghiệm và chụp ảnh toàn bộ các luồng ứng dụng vào Báo cáo hoàn chỉnh.
  - **SV2 (Chủ lực):**
    - Cài đặt SQLite Database Helper (`DatabaseHelper`) tạo các bảng: `cart_items`, `wishlist`, `addresses`, `search_history`.
    - Kết nối Backend PocketBase (hoặc Mock REST API) cho dữ liệu Sách và Đơn hàng.
    - Xây dựng `CartBloc` (Xử lý CRUD giỏ hàng: thêm, cập nhật số lượng, xóa sản phẩm, tính tổng tiền, giảm giá voucher).
    - Xây dựng `OrderBloc` (Đặt hàng, lưu đơn vào CSDL, hủy đơn hàng).
    - Tích hợp `flutter_local_notifications`: Khởi tạo NotificationService, kích hoạt thông báo Android khi đặt hàng thành công và khi chuyển trạng thái đơn hàng.
    - Xây dựng chức năng Admin CRUD: Thêm sách mới, sửa giá/kho, xóa sách.
    - Tổng hợp Báo cáo hoàn chỉnh cuối tuần 10.

#### 🤖 PROMPT MẪU CHO AI - GIAI ĐOẠN 3 (PHẦN DATABASE & CART BLoC):
```text
[MỤC TIÊU]: Cài đặt SQLite Local Database và CartBloc quản lý trạng thái giỏ hàng cho BookVerse.
[YÊU CẦU NGHIỆP VỤ]:
- Dữ liệu giỏ hàng được lưu bền vững qua các lần chạy app bằng SQLite (sqflite).
- Hỗ trợ đầy đủ tương tác CRUD:
  + Thêm sách vào giỏ (nếu đã có thì tăng số lượng).
  + Sửa: Tăng/giảm số lượng (nếu số lượng về 0 thì hỏi xác nhận xóa).
  + Xóa: Xóa từng mục hoặc xóa toàn bộ giỏ hàng sau khi đặt thành công.
  + Tính toán: Tạm tính, tiền giảm giá khi áp voucher (ví dụ: 'BOOK10' giảm 10%, 'FREESHIP' giảm 30k ship), tổng thanh toán.

[NHIỆM VỤ CỦA BẠN]:
1. Viết file database_helper.dart quản lý mở DB, tạo bảng cart_items, thực thi các hàm CRUD (insert, update, delete, getCartItems).
2. Viết CartBloc, CartEvent, CartState với các sự kiện: LoadCart, AddToCart, UpdateCartQuantity, RemoveFromCart, ApplyVoucher, ClearCart.
3. Viết CartScreen hoàn chỉnh hiển thị danh sách từ CartBloc, cho phép người dùng thao tác trực tiếp và cập nhật UI tức thì.
```

#### 🤖 PROMPT MẪU CHO AI - GIAI ĐOẠN 3 (PHẦN LOCAL NOTIFICATIONS & CHECKOUT):
```text
[MỤC TIÊU]: Xây dựng quy trình Checkout và kích hoạt Android Local Notifications khi đặt hàng thành công.
[YÊU CẦU KỸ THUẬT]:
- Sử dụng thư viện flutter_local_notifications (cấu hình AndroidNotificationDetails với Importance.max, Priority.high).
- Khi người dùng bấm "Xác nhận đặt hàng" ở CheckoutScreen:
  1. Kiểm tra giỏ hàng và địa chỉ nhận hàng.
  2. Tạo bản ghi Đơn hàng mới vào CSDL.
  3. Xóa giỏ hàng hiện tại.
  4. Bắn một Local Notification hiển thị ngay trên thanh thông báo Android: "Đặt hàng thành công! Đơn hàng #BK[Mã] đang được chuẩn bị và sẽ sớm giao đến bạn."
  5. Điều hướng người dùng sang OrderDetailScreen hoặc OrderHistoryScreen bằng go_router.

[NHIỆM VỤ CỦA BẠN]:
1. Viết lib/core/services/notification_service.dart đóng gói logic khởi tạo và hàm showOrderSuccessNotification({required String orderId, required double totalAmount}).
2. Cập nhật AndroidManifest.xml với các quyền: POST_NOTIFICATIONS, VIBRATE.
3. Viết code hoàn chỉnh cho CheckoutScreen kết nối OrderBloc và NotificationService.
```

---

### GIAI ĐOẠN 4: TUẦN 11 (TÙY BIẾN, TRIỂN KHAI THIẾT BỊ THẬT & BÁO CÁO VẤN ĐÁP)
- **Mục tiêu:** Tùy biến biểu tượng ứng dụng, màn hình khởi động (Splash screen), đổi tên app, đóng gói file APK Release, cài đặt và chạy thử nghiệm mượt mà trên thiết bị Android thật, bảo vệ vấn đáp đạt điểm tối đa.
- **Phân công tuần 11:**
  - **SV1:** Thiết kế logo app chuyên nghiệp dạng vector/png, cấu hình `flutter_launcher_icons` và `flutter_native_splash`, chuẩn bị slide thuyết trình (Canva/PowerPoint), kịch bản demo sản phẩm trên máy thật.
  - **SV2:** Cấu hình `android/app/build.gradle` (signing config, minSdk, targetSdk), đổi tên hiển thị app thành "BookVerse" trong `AndroidManifest.xml`, build file `app-release.apk`, kiểm tra các lỗi crash trên điện thoại thật, chuẩn bị câu trả lời vấn đáp kỹ thuật (về go_router, Bloc lifecycle, SQLite query).

#### 🤖 PROMPT MẪU CHO AI - GIAI ĐOẠN 4:
```text
[MỤC TIÊU]: Hướng dẫn tùy biến định danh app và build file APK Release chạy trên điện thoại thật Android cho dự án BookVerse.
[YÊU CẦU]:
1. Cấu hình file pubspec.yaml cho 2 gói: flutter_launcher_icons và flutter_native_splash (chỉ rõ đường dẫn icon, màu nền, cấu hình Android 12 adaptive icon).
2. Hướng dẫn các bước chạy lệnh terminal để tạo icon và splash screen tự động.
3. Hướng dẫn đổi tên hiển thị của ứng dụng trên màn hình điện thoại Android thành "BookVerse".
4. Câu lệnh build APK Release tối ưu (flutter build apk --release --split-per-abi).
5. Tổng hợp bộ 10 câu hỏi vấn đáp thường gặp nhất của Giảng viên môn CT484 (về go_router, BLoC, SQLite, Local Notification, vòng đời ứng dụng) và câu trả lời mẫu xuất sắc nhất để nhóm đạt điểm A+.
```

---

## 6. THIẾT KẾ CƠ SỞ DỮ LIỆU (DATABASE SCHEMA)

Dự án kết hợp **Cloud Database (PocketBase/REST)** cho kho sách & tài khoản, và **SQLite (Local Database)** cho giỏ hàng, địa chỉ và sách yêu thích:

### 6.1. Bảng SQLite Cục Bộ (Device Local Storage)
```sql
-- 1. Bảng Giỏ hàng (Cart)
CREATE TABLE cart_items (
    id TEXT PRIMARY KEY,
    book_id TEXT NOT NULL,
    title TEXT NOT NULL,
    price REAL NOT NULL,
    image_url TEXT,
    quantity INTEGER NOT NULL,
    stock_quantity INTEGER NOT NULL
);

-- 2. Bảng Sách yêu thích (Wishlist)
CREATE TABLE wishlist (
    book_id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    price REAL NOT NULL,
    image_url TEXT,
    rating REAL,
    added_at TEXT NOT NULL
);

-- 3. Bảng Sổ địa chỉ nhận hàng (Addresses - CRUD)
CREATE TABLE addresses (
    id TEXT PRIMARY KEY,
    recipient_name TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    street_address TEXT NOT NULL,
    ward TEXT NOT NULL,
    district TEXT NOT NULL,
    city TEXT NOT NULL,
    is_default INTEGER DEFAULT 0
);

-- 4. Bảng Lịch sử tìm kiếm (Search History)
CREATE TABLE search_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    query_text TEXT UNIQUE NOT NULL,
    searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 6.2. Thực thể Sách & Đơn hàng (PocketBase / REST Cloud Entities)
```json
// Entity Book
{
  "id": "book_001",
  "title": "Đắc Nhân Tâm",
  "author": "Dale Carnegie",
  "category": "Kỹ năng sống",
  "price": 86000,
  "original_price": 108000,
  "discount_percent": 20,
  "rating": 4.8,
  "review_count": 342,
  "stock_quantity": 45,
  "publisher": "NXB Tổng Hợp TP.HCM",
  "publish_year": 2023,
  "page_count": 320,
  "cover_image": "https://...",
  "sample_content": "Chương 1: Nếu muốn lấy mật thì đừng phá tổ ong...",
  "description": "Cuốn sách kinh điển về nghệ thuật đối nhân xử thế..."
}

// Entity Order
{
  "id": "ORD_20261018_001",
  "user_id": "user_123",
  "order_date": "2026-10-18T18:00:00Z",
  "items": [
    {"book_id": "book_001", "title": "Đắc Nhân Tâm", "quantity": 2, "price": 86000}
  ],
  "shipping_fee": 15000,
  "discount_amount": 10000,
  "total_amount": 177000,
  "payment_method": "COD",
  "status": "Processing", // Pending, Processing, Shipping, Delivered, Cancelled
  "shipping_address": "Khu 2, ĐH Cần Thơ, Đường 3/2, Q. Ninh Kiều, Cần Thơ"
}
```

---

## 7. CẤU TRÚC MÃ NGUỒN CHUẨN (PROJECT DIRECTORY TREE)

```text
lib/
├── main.dart                          # Khởi tạo App, SQLite, NotificationService, MultiBlocProvider
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Bảng màu thương hiệu hiện đại
│   │   ├── app_constants.dart         # Chuỗi cố định, keys
│   │   └── app_typography.dart        # Phông chữ Material 3
│   ├── database/
│   │   └── database_helper.dart       # SQLite Database Helper (CRUD cart, wishlist, address)
│   ├── network/
│   │   └── api_client.dart            # Kết nối PocketBase / HTTP REST API
│   ├── router/
│   │   └── app_router.dart            # Cấu hình GoRouter, ShellRoute, TransitionPage
│   ├── services/
│   │   └── notification_service.dart  # Flutter Local Notifications (bắn thông báo đơn hàng)
│   └── utils/
│       └── currency_formatter.dart    # Format tiền tệ VNĐ (ví dụ: 120.000 đ)
├── features/
│   ├── auth/                          # Đăng ký, Đăng nhập, Profile
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── bloc/auth_bloc.dart
│   │       └── screens/login_screen.dart, register_screen.dart, profile_screen.dart
│   ├── books/                         # Khám phá, Trang chủ, Chi tiết, Đọc thử
│   │   ├── data/
│   │   │   ├── models/book_model.dart, category_model.dart
│   │   │   └── repositories/book_repository.dart
│   │   ├── domain/
│   │   └── presentation/
│   │       ├── bloc/book_bloc.dart, search_bloc.dart
│   │       ├── screens/home_screen.dart, book_detail_screen.dart, search_screen.dart
│   │       └── widgets/book_card.dart, sample_preview_dialog.dart, banner_slider.dart
│   ├── cart/                          # Giỏ hàng & Voucher
│   │   ├── data/
│   │   │   ├── models/cart_item_model.dart
│   │   │   └── repositories/cart_repository.dart
│   │   └── presentation/
│   │       ├── bloc/cart_bloc.dart
│   │       ├── screens/cart_screen.dart
│   │       └── widgets/cart_item_tile.dart, voucher_bottom_sheet.dart
│   ├── orders/                        # Thanh toán, Lịch sử đơn hàng, Tracking
│   │   ├── data/
│   │   │   ├── models/order_model.dart
│   │   │   └── repositories/order_repository.dart
│   │   └── presentation/
│   │       ├── bloc/order_bloc.dart
│   │       ├── screens/checkout_screen.dart, order_history_screen.dart, order_detail_screen.dart
│   │       └── widgets/order_status_timeline.dart
│   └── admin/                         # Phân hệ Quản trị viên (Điểm cộng)
│       └── presentation/
│           ├── bloc/admin_book_bloc.dart
│           └── screens/admin_book_list_screen.dart, admin_add_edit_book_screen.dart
```

---

## 8. NGUYÊN TẮC PHỐI HỢP GIT & COMMIT ĐẠT ĐIỂM TỐI ĐA

Giảng viên nhấn mạnh: **"Các thành viên trong nhóm đều phải tham gia viết code (có lịch sử commit trên GitHub)"**. Để tránh việc 1 người commit 90% còn người kia 10%:

1. **Quy tắc phân nhánh (Branching):**
   - Nhánh `main`: Mã nguồn ổn định nhất, chỉ merge khi tính năng đã kiểm tra chạy mượt.
   - Nhánh `feature/ui-screens-sv1`: SV1 làm việc với các màn hình Home, Detail, Search, Router.
   - Nhánh `feature/data-cart-checkout-sv2`: SV2 làm việc với Database SQLite, BLoC, Cart, Checkout, Notifications.
2. **Quy tắc tạo Pull Request & Review:**
   - Khi hoàn thành 1 cụm tính năng, SV1 tạo PR mời SV2 review & ngược lại.
   - Luân phiên commit các file tài liệu báo cáo Markdown.
3. **Mục tiêu phân bổ Commit:**
   - Tổng commit dự án khoảng 40 - 60 commits trong suốt 11 tuần.
   - Tỷ lệ đóng góp commit giữa SV1 và SV2 duy trì mức **48% - 52%** hoặc **50% - 50%**.
   - Mỗi commit kèm thông điệp rõ ràng theo chuẩn Conventional Commits (ví dụ: `feat: add sample read modal with custom bottom sheet`, `feat: implement SQLite cart repository with CRUD operations`).

---

## 9. CHECKLIST BẢO VỆ VẤN ĐÁP TRƯỚC GIẢNG VIÊN (TUẦN 11)

- [ ] Cả 2 sinh viên nắm vững vị trí từng dòng code quan trọng của mình và đồng đội.
- [ ] Trình bày rõ tại sao chọn kiến trúc Feature-First và quản lý trạng thái bằng BLoC/Cubit.
- [ ] Demo trực tiếp trên điện thoại Android thật:
  1. Thao tác lướt Home, mở xem chi tiết sách (Hero Animation mượt).
  2. Mở tính năng Đọc thử trích đoạn sách.
  3. Thêm sách vào giỏ hàng, cập nhật số lượng, xóa sản phẩm khỏi giỏ hàng.
  4. Nhập mã giảm giá voucher, bấm Đặt hàng.
  5. Xem thông báo cục bộ Android hiển thị ngay lập tức trên màn hình.
  6. Vào mục Đơn hàng kiểm tra đơn mới tạo ở trạng thái Chờ xử lý.
  7. Tắt ứng dụng, mở lại -> Dữ liệu giỏ hàng và danh sách đơn hàng vẫn được lưu trữ nguyên vẹn (chứng minh lưu trữ SQLite/Cloud bền vững qua các lần chạy).
  8. Vào tài khoản Admin thêm 1 cuốn sách mới -> Quay lại Home thấy sách mới xuất hiện ngay lập tức.
