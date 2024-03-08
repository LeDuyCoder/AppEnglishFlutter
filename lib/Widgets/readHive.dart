import 'package:hive/hive.dart';

class ReadHive{
  void read(path, box) async{
    // Khởi tạo Hive với đường dẫn được cung cấp
    Hive.init(path);
    var dataUserLocal = await Hive.openBox(box);

    for (var key in dataUserLocal.keys) {
      print('$key : ${dataUserLocal.get(key)}');
    }
  }
}