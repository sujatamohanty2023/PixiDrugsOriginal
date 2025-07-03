import 'package:pixidrugs/constant/all.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: AppColors.kPrimary,
        width: double.infinity,
        padding: EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 16, left: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(
                      "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shaidul Store',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Free plan',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    SizedBox(height: 10),
                    _buildMenuItem(Icons.person, "My Profile", Colors.blue),
                    _buildMenuItem(Icons.card_giftcard, "Your Package", Colors.orange),
                    _buildMenuItem(Icons.dashboard, "Dashboard", Colors.pink),
                    _buildMenuItem(Icons.settings, "Setting", Colors.lightBlue),
                    _buildMenuItem(Icons.print, "Invoice Print", Colors.blueAccent),
                    _buildMenuItem(Icons.description, "Terms & Conditions", Colors.purple),
                    _buildMenuItem(Icons.info, "About Us", Colors.cyan),
                    _buildMenuItem(Icons.logout, "Log Out", Colors.deepOrange),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color iconBgColor) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconBgColor, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.kPrimaryDark),
          ],
        ),
        SizedBox(height: 6),
        Padding(
          padding: EdgeInsets.only(left: 56), // Align divider after icon
          child: Divider(color: AppColors.kPrimaryLight,thickness:1,),
        ),
      ],
    );
  }
}