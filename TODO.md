# TODO: Make All Screens Responsive for Web and Mobile

## Overview
Add responsive design to all screens in lib/screens/ that do not already have MediaQuery-based sizing. Use MediaQuery.of(context).size.width to adjust font sizes, paddings, margins, and layout dimensions based on screen width (e.g., >600 for tablets, else mobile).

## Screens Already Responsive
- lib/screens/add_availability_screen.dart
- lib/screens/vendor_dashboard_screen.dart
- lib/screens/home_screen.dart
- lib/screens/signup_screen.dart

## Screens to Make Responsive
1. lib/screens/add_event_screen.dart
2. lib/screens/add_guest_screen.dart
3. lib/screens/add_packages_page.dart
4. lib/screens/add_service_page.dart
5. lib/screens/add_sub_task_screen.dart
6. lib/screens/add_task_screen.dart
7. lib/screens/after_filled_invitation.dart
8. lib/screens/availability_calendar.dart
9. lib/screens/booked_vendors_screen.dart
10. lib/screens/booking_details_screen.dart
11. lib/screens/budget_allocation_page.dart
12. lib/screens/change_password_page.dart
13. lib/screens/chat_detail_screen.dart
14. lib/screens/checklist_screen.dart
15. lib/screens/choose_category_screen.dart
16. lib/screens/edit_email_screen.dart
17. lib/screens/edit_name_page.dart
18. lib/screens/edit_phone_screen.dart
19. lib/screens/edit_vendor_services_page.dart
20. lib/screens/fill_invitation_details_screen.dart
21. lib/screens/forgot_password_screen.dart
22. lib/screens/guest_list_screen.dart
23. lib/screens/help_support_page.dart
24. lib/screens/invitation_template_screen.dart
25. lib/screens/logout_page.dart
26. lib/screens/message_screen.dart
27. lib/screens/my_events_screen.dart
28. lib/screens/notification_screen.dart
29. lib/screens/onboarding_page.dart
30. lib/screens/payment_page.dart
31. lib/screens/planning_screen.dart
32. lib/screens/Privacy_and_Policy.dart
33. lib/screens/profile_screen.dart
34. lib/screens/select_guests_for_invitation_screen.dart
35. lib/screens/select_package_page.dart
36. lib/screens/select_screen.dart
37. lib/screens/select_time_page.dart
38. lib/screens/set_invitation_screen.dart
39. lib/screens/shortlisted_vendors_screen.dart
40. lib/screens/show_task_page.dart
41. lib/screens/signin_Screen.dart
42. lib/screens/Terms_and_Conditions.dart
43. lib/screens/update_event_screen.dart
44. lib/screens/vendor_chats_screen.dart
45. lib/screens/vendor_directory_screen.dart
46. lib/screens/vendor_order_page.dart
47. lib/screens/vendor_profile_screen.dart
48. lib/screens/vendor_profile_setup_screen.dart
49. lib/screens/vendor_search_page.dart
50. lib/screens/vendor_services_page.dart
51. lib/screens/vendor_upcoming_page.dart
52. lib/screens/vendor-packages.dart
53. lib/screens/wedding_vendor_page.dart
54. lib/screens/wendor_review_page.dart

## Steps for Each Screen
1. Add `final screenWidth = MediaQuery.of(context).size.width;` in the build method.
2. Replace fixed padding, margins, font sizes, container widths/heights with conditional values based on screenWidth.
3. For example: fontSize: screenWidth > 600 ? 24 : 20, padding: EdgeInsets.all(screenWidth > 600 ? 32 : 16)
4. Adjust GridView/ListView item sizes and counts if applicable.
5. Test on different screen sizes.

## Progress
- [ ] Create responsive utility helper (optional for consistency)
- [ ] checklist_screen.dart
- [ ] ... (add each screen as completed)
