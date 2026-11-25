import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../features/cart/data/models/cart_item_model.dart';
import '../../features/auth/data/models/address_model.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/books/data/models/book_model.dart';

/// Quản lý SQLite cục bộ cho ứng dụng BookVerse
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bookverse.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Bảng Giỏ hàng
    await db.execute('''
      CREATE TABLE cart_items (
        id TEXT PRIMARY KEY,
        book_id TEXT NOT NULL,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        image_url TEXT,
        quantity INTEGER NOT NULL,
        stock_quantity INTEGER NOT NULL
      )
    ''');

    // 2. Bảng Sách yêu thích (Wishlist)
    await db.execute('''
      CREATE TABLE wishlist (
        book_id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        price REAL NOT NULL,
        image_url TEXT,
        rating REAL,
        added_at TEXT NOT NULL
      )
    ''');

    // 3. Bảng Sổ địa chỉ
    await db.execute('''
      CREATE TABLE addresses (
        id TEXT PRIMARY KEY,
        recipient_name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        street_address TEXT NOT NULL,
        ward TEXT NOT NULL,
        district TEXT NOT NULL,
        city TEXT NOT NULL,
        is_default INTEGER DEFAULT 0
      )
    ''');

    // 4. Bảng Lịch sử tìm kiếm
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query_text TEXT UNIQUE NOT NULL,
        searched_at TEXT NOT NULL
      )
    ''');

    // 5. Bảng Sách (Books) - Quản lý kho sách động từ SQLite
    await _createBooksTable(db);

    // 6. Bảng Người dùng (Users) - Phân quyền 'admin' / 'user'
    await _createUsersTable(db);

    // Khởi tạo một số địa chỉ mẫu ban đầu
    await db.insert('addresses', {
      'id': 'addr_01',
      'recipient_name': 'Nguyễn Văn A',
      'phone_number': '0901234567',
      'street_address': 'Khu II, Đ. 3/2, P. Xuân Khánh',
      'ward': 'Phường Xuân Khánh',
      'district': 'Quận Ninh Kiều',
      'city': 'TP. Cần Thơ',
      'is_default': 1,
    });
  }

  Future<void> _createBooksTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS books (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        original_price REAL NOT NULL,
        discount_percent INTEGER DEFAULT 0,
        rating REAL DEFAULT 0.0,
        review_count INTEGER DEFAULT 0,
        stock_quantity INTEGER NOT NULL DEFAULT 0,
        publisher TEXT,
        publish_year INTEGER DEFAULT 2024,
        page_count INTEGER DEFAULT 0,
        cover_image TEXT,
        sample_content TEXT,
        description TEXT
      )
    ''');
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        avatar_url TEXT,
        role TEXT NOT NULL DEFAULT 'user'
      )
    ''');

    // Tạo sẵn tài khoản Admin mặc định: admin@gmail.com / 123456
    await db.insert(
      'users',
      {
        'id': 'usr_admin',
        'email': 'admin@gmail.com',
        'password': '123456',
        'name': 'Quản Trị Viên',
        'phone': '0909999999',
        'avatar_url': '',
        'role': 'admin',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Tạo sẵn tài khoản Khách hàng thông thường: user@gmail.com / 123456
    await db.insert(
      'users',
      {
        'id': 'usr_user',
        'email': 'user@gmail.com',
        'password': '123456',
        'name': 'Nguyễn Văn A',
        'phone': '0901234567',
        'avatar_url': '',
        'role': 'user',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createBooksTable(db);
      await _createUsersTable(db);

      // Xóa các sản phẩm mẫu cũ trong cart / wishlist nếu có
      await db.delete('cart_items',
          where: 'book_id IN (?, ?, ?)',
          whereArgs: ['book_001', 'book_002', 'book_004']);
      await db.delete('wishlist', where: 'book_id = ?', whereArgs: ['book_002']);
    }
  }

  // ================= BOOKS CRUD OPERATIONS =================
  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final maps = await db.query('books', orderBy: 'rowid DESC');
    return maps.map((e) => Book.fromJson(e)).toList();
  }

  Future<Book?> getBookById(String id) async {
    final db = await database;
    final maps = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Book.fromJson(maps.first);
    }
    return null;
  }

  Future<int> insertBook(Book book) async {
    final db = await database;
    return await db.insert(
      'books',
      book.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateBook(Book book) async {
    final db = await database;
    return await db.update(
      'books',
      book.toJson(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> deleteBook(String id) async {
    final db = await database;
    return await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= USERS / AUTH OPERATIONS =================
  Future<UserModel?> login(String email, String password) async {
    final db = await database;
    // Đảm bảo bảng users tồn tại
    await _createUsersTable(db);

    final res = await db.query(
      'users',
      where: 'LOWER(email) = ? AND password = ?',
      whereArgs: [email.toLowerCase().trim(), password],
    );
    if (res.isNotEmpty) {
      return UserModel.fromJson(res.first);
    }
    return null;
  }

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    String phone = '',
    String role = 'user',
  }) async {
    final db = await database;
    await _createUsersTable(db);

    final existing = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    if (existing.isNotEmpty) {
      return false; // Email đã tồn tại
    }

    await db.insert('users', {
      'id': 'usr_${DateTime.now().millisecondsSinceEpoch}',
      'email': email.toLowerCase().trim(),
      'password': password,
      'name': name.trim(),
      'phone': phone.trim(),
      'avatar_url': '',
      'role': role,
    });
    return true;
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (res.isNotEmpty) {
      return UserModel.fromJson(res.first);
    }
    return null;
  }

  // ================= CART OPERATIONS =================
  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final maps = await db.query('cart_items');
    return maps.map((e) => CartItem.fromMap(e)).toList();
  }

  Future<void> insertOrUpdateCart(CartItem item) async {
    final db = await database;
    final existing = await db.query(
      'cart_items',
      where: 'book_id = ?',
      whereArgs: [item.bookId],
    );

    if (existing.isNotEmpty) {
      final existingItem = CartItem.fromMap(existing.first);
      final newQty = existingItem.quantity + item.quantity;
      await db.update(
        'cart_items',
        {'quantity': newQty.clamp(1, item.stockQuantity)},
        where: 'id = ?',
        whereArgs: [existingItem.id],
      );
    } else {
      await db.insert('cart_items', item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> updateCartQuantity(String id, int quantity) async {
    final db = await database;
    if (quantity <= 0) {
      await deleteCartItem(id);
    } else {
      await db.update(
        'cart_items',
        {'quantity': quantity},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> deleteCartItem(String id) async {
    final db = await database;
    await db.delete('cart_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  // ================= WISHLIST OPERATIONS =================
  Future<List<Map<String, dynamic>>> getWishlist() async {
    final db = await database;
    return await db.query('wishlist', orderBy: 'added_at DESC');
  }

  Future<bool> isWishlisted(String bookId) async {
    final db = await database;
    final res = await db.query(
      'wishlist',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
    return res.isNotEmpty;
  }

  Future<void> addToWishlist(Map<String, dynamic> bookMap) async {
    final db = await database;
    await db.insert(
      'wishlist',
      {
        'book_id': bookMap['book_id'] ?? bookMap['id'],
        'title': bookMap['title'],
        'author': bookMap['author'] ?? '',
        'price': bookMap['price'],
        'image_url': bookMap['image_url'] ?? bookMap['coverImage'],
        'rating': bookMap['rating'] ?? 5.0,
        'added_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFromWishlist(String bookId) async {
    final db = await database;
    await db.delete('wishlist', where: 'book_id = ?', whereArgs: [bookId]);
  }

  // ================= ADDRESS OPERATIONS =================
  Future<List<AddressModel>> getAddresses() async {
    final db = await database;
    final maps = await db.query('addresses', orderBy: 'is_default DESC');
    return maps.map((e) => AddressModel.fromMap(e)).toList();
  }

  Future<void> insertAddress(AddressModel address) async {
    final db = await database;
    if (address.isDefault) {
      await db.update('addresses', {'is_default': 0});
    }
    await db.insert('addresses', address.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateAddress(AddressModel address) async {
    final db = await database;
    if (address.isDefault) {
      await db.update('addresses', {'is_default': 0});
    }
    await db.update('addresses', address.toMap(),
        where: 'id = ?', whereArgs: [address.id]);
  }

  Future<void> deleteAddress(String id) async {
    final db = await database;
    await db.delete('addresses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setDefaultAddress(String id) async {
    final db = await database;
    await db.update('addresses', {'is_default': 0});
    await db.update('addresses', {'is_default': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  // ================= SEARCH HISTORY =================
  Future<List<String>> getSearchHistory() async {
    final db = await database;
    final res = await db.query('search_history',
        orderBy: 'searched_at DESC', limit: 10);
    return res.map((e) => e['query_text'] as String).toList();
  }

  Future<void> addSearchQuery(String query) async {
    if (query.trim().isEmpty) return;
    final db = await database;
    await db.insert(
      'search_history',
      {
        'query_text': query.trim(),
        'searched_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearSearchHistory() async {
    final db = await database;
    await db.delete('search_history');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
