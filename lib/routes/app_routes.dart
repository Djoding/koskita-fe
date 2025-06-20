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
  static const setting = '/setting';
  static const notification = '/notification';
  static const editProfile = '/edit-profile';
  static const changePassword = '/change-password';
  static const success = '/success';
  static const dashboardTenant = '/dashboard-tenant';
  static const deleteUser = '/delete-user';
  static const editUser = '/edit-user';
  static const formEditPenghuni = '/form-edit-penghuni';
  static const homeReservasiOwner = '/home-reservasi-owner';
  static const notifikasiLaundry = '/notifikasi-laundry';
  static const validasiReservasi = '/validasi-reservasi'; // NEW
  static const qrisPayment = '/qris-payment'; // NEW
  static const layananLaundry = '/layanan-laundry'; // NEW

  // Admin routes
  static const dashboardAdmin = '/dashboard-admin';
  static const penggelolaDetail = '/pengelola-detail';

  static const kostDetail = '/kost-detail';
  static const editKost = '/edit-kost';
  // NEW Catering Routes
  static const layananMakanan = '/layanan-makanan'; // Dashboard Catering
  static const foodListScreen =
      '/catering-menu-list'; // Daftar Menu Makanan/Minuman
  static const addCateringMenu = '/add-catering-menu'; // Tambah Menu
  static const editCateringMenu = '/edit-catering-menu'; // Edit Menu
  static const cateringOrders = '/catering-orders'; // Daftar Pesanan Masuk
  static const cateringOrderDetail = '/catering-order-detail'; // Detail Pesanan
  static const cateringOrderStatus = '/catering-order-status'; // Status Pesanan
  static const editCateringOrderStatus =
      '/edit-catering-order-status'; // Edit Status Pesanan
  static const cateringPaymentMethods =
      '/catering-payment-methods'; // Daftar Metode Pembayaran
  static const addCateringPaymentMethod =
      '/add-catering-payment-method'; // Tambah Metode Pembayaran
  static const editCateringPaymentMethod =
      '/edit-catering-payment-method'; // Edit Metode Pembayaran
}
