import 'package:get/get.dart';
import 'package:kosan_euy/screens/owner/dashboard_owner_screen.dart';
import 'package:kosan_euy/screens/home_screen.dart';
import 'package:kosan_euy/screens/login_screen.dart';
import 'package:kosan_euy/screens/forgetpassword_screen.dart';
import 'package:kosan_euy/screens/owner/daftar_kos_screen.dart';
import 'package:kosan_euy/screens/owner/penghuni_screen.dart';
import 'package:kosan_euy/screens/owner/add_penghuni_screen.dart';
import 'package:kosan_euy/screens/owner/edit_penghuni_screen.dart';
import 'package:kosan_euy/screens/owner/notification/notification_owner.dart';
import 'package:kosan_euy/screens/owner/notification/notification_reservasi.dart';
import 'package:kosan_euy/screens/owner/notification/notification_reservasi_detail.dart';
import 'package:kosan_euy/screens/owner/reservasi/reservasi_screen.dart';
import 'package:kosan_euy/screens/makanan/makanan_screen.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/screens/settings/notification_screen.dart';
import 'package:kosan_euy/screens/settings/edit_profile_screen.dart';
import 'package:kosan_euy/screens/settings/change_password_screen.dart';
import 'package:kosan_euy/widgets/success_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.dashboardOwner;

  static final routes = [
    GetPage(name: Routes.dashboardOwner, page: () => DashboardOwnerScreen()),
    GetPage(name: Routes.home, page: () => HomeScreenPage()),
    GetPage(name: Routes.login, page: () => LoginScreen()),
    GetPage(name: Routes.forgetPassword, page: () => ForgetPasswordScreen()),
    GetPage(name: Routes.daftarKos, page: () => DaftarKosScreen()),
    GetPage(name: Routes.penghuni, page: () => PenghuniScreen()),
    GetPage(name: Routes.addPenghuni, page: () => AddPenghuniScreen()),
    GetPage(name: Routes.editPenghuni, page: () => EditPenghuniScreen()),
    GetPage(name: Routes.notificationOwner, page: () => NotificationOwner()),
    GetPage(
      name: Routes.notificationReservasi,
      page: () => NotificationReservasiScreen(),
    ),
    GetPage(
      name: Routes.notificationReservasiDetail,
      page: () => NotificationReservasiDetail(),
    ),
    GetPage(name: Routes.reservasi, page: () => ReservasiScreen()),
    GetPage(name: Routes.foodList, page: () => FoodListScreen()),
    GetPage(name: Routes.setting, page: () => SettingScreen()),
    GetPage(name: Routes.notification, page: () => NotificationScreen()),
    GetPage(name: Routes.editProfile, page: () => EditProfileScreen()),
    GetPage(name: Routes.changePassword, page: () => ChangePasswordScreen()),
    GetPage(
      name: Routes.success,
      page:
          () => SuccessScreen(
            title: 'Berhasil',
            subtitle: 'Aksi berhasil dilakukan',
          ),
    ),
    // Tambahkan GetPage lain sesuai kebutuhan
  ];
}
