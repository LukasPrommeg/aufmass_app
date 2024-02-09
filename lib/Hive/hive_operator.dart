import 'package:hive/hive.dart';

class HiveOperator {
  final String path = "lib/Hive";
  final String baustellenBoxString = "baustellenBox";
  final String roomBoxString = "roomBox";

  //FACTORY [
  static final HiveOperator _instance = HiveOperator._internal();

  // Private constructor for the singleton
  HiveOperator._internal();

  // Factory constructor to return the existing instance
  factory HiveOperator() {
    return _instance;
  }
  // ]

  Future<List<T>> getListFromHive<T>(String boxName) async {
    final box = await Hive.openBox<T>(boxName, path: path);
    //final box = Hive.box<T>(boxName);
    try {
      return box.values.toList();
    } finally {
      await box.close();
    }
  }

  Future<T?> getObjectFromHive<T>(dynamic key, String boxName) async {
    final box = await Hive.openBox<T>(boxName, path: path);
    try {
      T? object = box.get(key);
      if(object != null) {
        return object;
      }
      else {
        return null;
      }
    }
    finally {
      await box.close();
    }
  }

  Future<void> addToHive<HiveObject>(HiveObject object, String boxName) async {
    final box = await Hive.openBox<HiveObject>(boxName, path: path);
    try {
      await box.add(object);
    } finally {
      await box.close();
    }
    await box.close();
  }

  Future<void> changeInHive<T>(T newObject, dynamic oldObjectKey, String boxName) async {
    final box = await Hive.openBox<T>(boxName, path: path);
    try {
      await box.put(oldObjectKey, newObject);
    }
    finally {
      await box.close();
    }
  }

  Future<void> deleteFromHive<T>(dynamic objectKey, String boxName) async {
    final box = await Hive.openBox<T>(boxName, path: path);
    try {
      await box.delete(objectKey);
    }
    finally {
      await box.close();
    }
  }

  Future<void> deleteAllObjectsWithKeyFromHive<T extends HiveObject>(dynamic parameterKey, String boxName) async {
    final box = await Hive.openBox<T>(boxName, path: path);

    try {
      // Get a list of keys to delete
      List<dynamic> keysToDelete = [];
      for (T t in box.values) {
        if (t.key == parameterKey) {
          keysToDelete.add(t.key);
        }
      }

      // Delete objects using their keys
      for (dynamic key in keysToDelete) {
        await box.delete(key);
      }
    }
    finally {
      await box.close();
    }
  }
}
