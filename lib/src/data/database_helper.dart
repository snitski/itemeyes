import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'receipt_database.db'),
      onCreate: (db, version) async {
        // Create your tables here...
        await db.execute('''
          CREATE TABLE People (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            venmo TEXT
          );
        ''');

        // Create Receipts table
        await db.execute('''
          CREATE TABLE Receipts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT
          );
        ''');

        // Create ReceiptItems table
        await db.execute('''
          CREATE TABLE ReceiptItems (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            receipt_id INTEGER,
            name TEXT,
            cost REAL,
            FOREIGN KEY (receipt_id) REFERENCES Receipts(id)
          );
        ''');

        // Create ReceiptAvailablePeople junction table
        await db.execute('''
          CREATE TABLE ReceiptAvailablePeople (
            receipt_id INTEGER,
            person_id INTEGER,
            PRIMARY KEY (receipt_id, person_id),
            FOREIGN KEY (receipt_id) REFERENCES Receipts(id),
            FOREIGN KEY (person_id) REFERENCES People(id)
          );
        ''');

        // Create ReceiptItemSplits junction table
        await db.execute('''
          CREATE TABLE ReceiptItemSplits (
            receipt_item_id INTEGER,
            person_id INTEGER,
            PRIMARY KEY (receipt_item_id, person_id),
            FOREIGN KEY (receipt_item_id) REFERENCES ReceiptItems(id),
            FOREIGN KEY (person_id) REFERENCES People(id)
          );
        ''');
      },
      version: 1,
    );
  }
}
