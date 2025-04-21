import 'package:flutter/material.dart';

class DashboardTenantScreen extends StatefulWidget {
  const DashboardTenantScreen({super.key});

  @override
  State<DashboardTenantScreen> createState() => _DashboardTenantScreenState();
}

class _DashboardTenantScreenState extends State<DashboardTenantScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
            child: Text("Dashboard tenant"),
          ),
      )
    );
  }
}
