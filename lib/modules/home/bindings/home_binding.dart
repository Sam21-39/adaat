import 'package:get/get.dart';
import '../../../core/services/database_service.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure database is initialized
    Get.put(DatabaseService(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
