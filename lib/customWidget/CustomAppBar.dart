import '../../constant/all.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showSearch;
  final bool showCartButton;
  final bool showFilterButton;
  final TextEditingController? searchController;
  final String? searchHint;
  final VoidCallback? onBackPressed;
  final VoidCallback? onCartPressed;
  final VoidCallback? onFilterPressed;
  final VoidCallback? onSearchClear;
  final ValueChanged<String>? onSearchChanged;
  final Color? backgroundColor;
  final Color? titleColor;
  final List<Widget>? additionalActions;
  final double height;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.showSearch = false,
    this.showCartButton = false,
    this.showFilterButton = false,
    this.searchController,
    this.searchHint,
    this.onBackPressed,
    this.onCartPressed,
    this.onFilterPressed,
    this.onSearchClear,
    this.onSearchChanged,
    this.backgroundColor,
    this.titleColor,
    this.additionalActions,
    this.height = 110.0,
  }) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _CustomAppBarState extends State<CustomAppBar> {

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.kPrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Main app bar row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  // Back button
                  if (widget.showBackButton)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
                    ),

                  // Title
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: widget.showBackButton ? 0 : 16),
                      child: MyTextfield.textStyle_w600(
                        widget.title,
                        18,
                        widget.titleColor ?? Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: widget.onFilterPressed,
                  )

                ],
              ),
            ),

            // Search bar (expandable)
            if (widget.showSearch)
              Container(
                padding: EdgeInsets.only(left: screenWidth * 0.03,right: screenWidth * 0.03,bottom:screenWidth * 0.03 ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: widget.searchController,
                    onChanged: widget.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: widget.searchHint ?? 'Search...',
                      hintStyle: MyTextfield.textStyle(
                          16, Colors.grey, FontWeight.w300),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      suffixIcon: widget.searchController?.text.isNotEmpty == true
                          ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey.shade500,
                          size: 20,
                        ),
                        onPressed: () {
                          widget.searchController?.clear();
                          widget.onSearchClear?.call();
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Factory methods for CustomAppBar (keeping backward compatibility)
class CustomAppBarFactory {
  /// Create app bar for product list screens
  static CustomAppBar productListAppBar({
    required String title,
    required int flag,
    required TextEditingController searchController,
    required VoidCallback onSearchClear,
    required ValueChanged<String> onSearchChanged,
    VoidCallback? onFilterPressed,
    VoidCallback? onCartPressed,
  }) {
    if (flag == 4) {
      return CustomAppBar(
        title: title,
        showSearch: true,
        searchController: searchController,
        searchHint: 'Search Product/Stockiest Name...',
        onSearchClear: onSearchClear,
        onSearchChanged: onSearchChanged,
        showCartButton: true,
        onCartPressed: onCartPressed,
      );
    } else {
      return CustomAppBar(
        title: title,
        showSearch: true,
        searchController: searchController,
        searchHint: 'Search Product/Stockiest Name...',
        showBackButton: flag == 2 || flag == 3,
        onSearchClear: onSearchClear,
        onSearchChanged: onSearchChanged,
        showFilterButton: flag == 1,
        onFilterPressed: flag == 1 ? onFilterPressed : null,
      );
    }
  }

  /// Create app bar for report screens
  static CustomAppBar reportAppBar({
    required String title,
    required TextEditingController searchController,
    required VoidCallback onSearchClear,
    required ValueChanged<String> onSearchChanged,
    VoidCallback? onFilterPressed,
    String? searchHint,
  }) {
    return CustomAppBar(
      title: title,
      showSearch: true,
      searchController: searchController,
      searchHint: searchHint ?? 'Search reports...',
      onSearchClear: onSearchClear,
      onSearchChanged: onSearchChanged,
      showFilterButton: onFilterPressed != null,
      onFilterPressed: onFilterPressed,
    );
  }

  /// Create app bar for scan screens
  static CustomAppBar scanAppBar({
    required String title,
    required VoidCallback onCartPressed,
  }) {
    return CustomAppBar(
      title: title,
      showCartButton: true,
      onCartPressed: onCartPressed,
      backgroundColor: Colors.black,
    );
  }
}

/// Extension for easy AppBar usage with context
extension AppBarExtension on BuildContext {
  /// Show standard app bar
  PreferredSizeWidget standardAppBar(String title, {List<Widget>? actions}) {
    return CustomAppBarFactory.productListAppBar(
      title: title,
      flag: 0,
      searchController: TextEditingController(),
      onSearchClear: () {},
      onSearchChanged: (value) {},
    );
  }

  /// Show search app bar
  PreferredSizeWidget searchAppBar(String title, VoidCallback onSearch) {
    return CustomAppBarFactory.reportAppBar(
      title: title,
      searchController: TextEditingController(),
      onSearchClear: () {},
      onSearchChanged: (value) {},
    );
  }

  /// Show transparent app bar
  PreferredSizeWidget transparentAppBar({String? title, List<Widget>? actions}) {
    return CustomAppBar(
      title: title ?? '',
      backgroundColor: Colors.transparent,
      height: 56,
    );
  }
}

/// App bar action buttons for common functionality
class AppBarActions {
  /// More options menu button
  static Widget moreOptionsButton({
    required BuildContext context,
    required List<PopupMenuEntry> menuItems,
  }) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      itemBuilder: (context) => menuItems,
    );
  }

  /// Notification bell with badge
  static Widget notificationButton({
    required VoidCallback onPressed,
    int count = 0,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: onPressed,
        ),
        if (count > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Share button
  static Widget shareButton({required VoidCallback onPressed}) {
    return IconButton(
      icon: const Icon(Icons.share, color: Colors.white),
      onPressed: onPressed,
    );
  }

  /// Settings button
  static Widget settingsButton({required VoidCallback onPressed}) {
    return IconButton(
      icon: const Icon(Icons.settings, color: Colors.white),
      onPressed: onPressed,
    );
  }

  /// Help button
  static Widget helpButton({required VoidCallback onPressed}) {
    return IconButton(
      icon: const Icon(Icons.help_outline, color: Colors.white),
      onPressed: onPressed,
    );
  }
}