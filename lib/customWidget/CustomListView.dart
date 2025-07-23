

import 'package:PixiDrugs/constant/all.dart';

class CustomListView<T> extends StatefulWidget {
  final List<T> data;
  final Function(T) onTap;
  final Widget Function(T) itemBuilder;
  final bool scroll_horizantal;
  final VoidCallback? loadMore;
  final ScrollPhysics? physics;

  CustomListView({
    this.physics,
    this.scroll_horizantal = false,
    required this.data,
    required this.onTap,
    required this.itemBuilder,
    ScrollController? controller,
    this.loadMore,
  });

  @override
  _CustomListViewState<T> createState() => _CustomListViewState<T>();
}

class _CustomListViewState<T> extends State<CustomListView<T>> {
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Trigger the loadMore callback when the user scrolls to the bottom
        if (widget.loadMore != null) {
          widget.loadMore!();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: widget.physics ?? ClampingScrollPhysics(),
      controller: _scrollController,
      scrollDirection:
          widget.scroll_horizantal ? Axis.horizontal : Axis.vertical,
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => widget.onTap(widget.data[index]),
          child: widget.itemBuilder(widget.data[index]),
        );
      },
    );
  }
}
