import 'package:flutter/material.dart';
import 'package:Project_Kururin_Exhibition/models/users.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userHome.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userBookingList.dart';
import 'package:Project_Kururin_Exhibition/pages/user/userProfile.dart';

void onUserDestinationSelected(BuildContext context, int index, User user) {
  Widget page;
  switch (index) {
    case 0:
      page = UserHomePage(user: user);
      break;
    case 1:
      page = BookingListPage(user: user);
      break;
    case 2:
      page = ProfilePage(user: user);
      break;
    default:
      return;
  }
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation1, animation2) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    ),
  );
}
