part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const dashboardOwner = '/dashboard-owner';
  static const home = '/home';
  static const login = '/login';
  static const forgetPassword = '/forget-password';
  static const daftarKos = '/daftar-kos';
  static const penghuni = '/penghuni';
  static const addPenghuni = '/add-penghuni';
  static const editPenghuni = '/edit-penghuni';
  static const notificationOwner = '/notification-owner';
  static const notificationReservasi = '/notification-reservasi';
  static const notificationReservasiDetail = '/notification-reservasi-detail';
  static const reservasi = '/reservasi';
  static const foodList = '/food-list';
  static const setting = '/setting';
  static const notification = '/notification';
  static const editProfile = '/edit-profile';
  static const changePassword = '/change-password';
  static const success = '/success';
  static const dashboardTenant = '/dashboard-tenant';
  // Tambahkan route lain sesuai kebutuhan
}
