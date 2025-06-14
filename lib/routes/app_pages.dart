// lib/routes/app_pages.dart
import 'package:get/get.dart';
import 'package:kosan_euy/screens/owner/dashboard_owner_screen.dart';
import 'package:kosan_euy/screens/home_screen.dart';
import 'package:kosan_euy/screens/owner/daftar_kos_screen.dart';
import 'package:kosan_euy/screens/owner/penghuni_screen.dart';
import 'package:kosan_euy/screens/owner/add_penghuni_screen.dart';
import 'package:kosan_euy/screens/owner/edit_penghuni_screen.dart';
import 'package:kosan_euy/screens/owner/reservasi/reservasi_screen.dart';
import 'package:kosan_euy/screens/owner/makanan/layanan_makanan/makanan_screen.dart';
import 'package:kosan_euy/screens/settings/setting_screen.dart';
import 'package:kosan_euy/screens/settings/notification_screen.dart';
import 'package:kosan_euy/screens/settings/edit_profile_screen.dart';
import 'package:kosan_euy/screens/settings/change_password_screen.dart';
import 'package:kosan_euy/widgets/success_screen.dart';
import 'package:kosan_euy/screens/owner/reservasi/delete_user.dart';
import 'package:kosan_euy/screens/owner/reservasi/edit_user.dart';
import 'package:kosan_euy/screens/owner/reservasi/form_edit_penghuni.dart';
import 'package:kosan_euy/screens/owner/reservasi/home_reservasi_owner.dart';
import 'package:kosan_euy/screens/owner/reservasi/edit_kos.dart';
import 'package:kosan_euy/screens/owner/reservasi/validasi_reservasi_screen.dart'; // NEW
import 'package:kosan_euy/screens/owner/pembayaran/qris_payment_screen.dart'; // NEW
import 'package:kosan_euy/screens/owner/laundry/layanan_laundry_screen.dart';
// Admin imports
import 'package:kosan_euy/screens/admin/dashboard_admin.dart';
import 'package:kosan_euy/screens/admin/pengelola_detail_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.home;

  static final routes = [
    GetPage(name: Routes.dashboardOwner, page: () => DashboardOwnerScreen()),
    GetPage(name: Routes.home, page: () => HomeScreenPage()),
    GetPage(name: Routes.daftarKos, page: () => DaftarKosScreen()),
    GetPage(name: Routes.penghuni, page: () => PenghuniScreen()),
    GetPage(name: Routes.addPenghuni, page: () => AddPenghuniScreen()),
    GetPage(name: Routes.editPenghuni, page: () => EditPenghuniScreen()),
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
    GetPage(name: Routes.deleteUser, page: () => DeleteUserScreen()),
    GetPage(name: Routes.editUser, page: () => EditUserScreen()),
    GetPage(
      name: Routes.formEditPenghuni,
      page: () => FormEditPenghuniScreen(),
    ),
    GetPage(name: Routes.homeReservasiOwner, page: () => HomeReservasiOwner()),
    GetPage(name: Routes.editKos, page: () => EditKosScreen()),
    // NEW ROUTES
    GetPage(
      name: Routes.validasiReservasi,
      page: () => ValidasiReservasiScreen(),
    ),
    GetPage(name: Routes.qrisPayment, page: () => QrisPaymentScreen()),
    GetPage(name: Routes.layananLaundry, page: () => LayananLaundryScreen()),

    // Admin routes
    GetPage(name: Routes.dashboardAdmin, page: () => DashboardAdminScreen()),
    GetPage(
      name: Routes.penggelolaDetail,
      page: () => PenggelolaDetailScreen(pengelola: Get.arguments ?? {}),
    ),
  ];
}
