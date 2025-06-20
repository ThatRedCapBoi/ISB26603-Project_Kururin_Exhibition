import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/admin.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminHome.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminDashboard.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminBooking.dart';
import 'package:Project_Kururin_Exhibition/pages/admin/adminProfile.dart';

void onAdminDestinationSelected(BuildContext context, int index, Admin admin) {
  Widget page;
  switch (index) {
    case 0:
      page = AdminHomePage(admin: admin);
      break;
    case 1:
      page = AdminDashboard(admin: admin);
      break;
    case 2:
      page = AdminBookingPage(admin: admin);
      break;
    case 3:
      page = AdminProfilePage(admin: admin);
      break;
    default:
      return;
  }
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}
