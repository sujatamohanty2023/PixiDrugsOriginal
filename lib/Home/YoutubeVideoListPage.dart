import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../constant/all.dart';

class YoutubeVideoListPage extends StatefulWidget {
  const YoutubeVideoListPage({Key? key}) : super(key: key);

  @override
  State<YoutubeVideoListPage> createState() => _YoutubeVideoListPageState();
}

class _YoutubeVideoListPageState extends State<YoutubeVideoListPage> {
  final String apiKey = "AIzaSyA5UKTy06p-RZI_5VT4TTcjgQHOQJRhpsg";
  final String channelId = "UCHny84f3WLbyF2AJ-yLxRLQ";
  final int maxResults = 20;

  YoutubePlayerController? _constantVideoController;
  String? constantVideoId;

  List<Map<String, dynamic>> videos = [];
  bool isLoading = true;
  String? errorMessage;
  String? channelProfileUrl;
  String channelTitle = "";
  String subscriberCount = "";
  String videoCount = "";

  @override
  void initState() {
    super.initState();
    _initFetch();
  }

  Future<void> _initFetch() async {
    await fetchChannelDetails();
    await fetchFirstVideoAndOthers();
  }

  @override
  void dispose() {
    _constantVideoController?.dispose();
    super.dispose();
  }

  Future<void> fetchChannelDetails() async {
    if (apiKey.isEmpty) {
      setState(() {
        errorMessage = 'Missing API key. Make sure to configure .env.';
        isLoading = false;
      });
      return;
    }

    try {
      final url =
          'https://www.googleapis.com/youtube/v3/channels?part=snippet,statistics&id=$channelId&key=$apiKey';
      final response = await Dio().get(url);

      final data = response.data as Map<String, dynamic>;
      final channel = data['items'][0] as Map<String, dynamic>;

      setState(() {
        channelProfileUrl = channel['snippet']['thumbnails']['default']['url'];
        channelTitle = channel['snippet']['title'];
        subscriberCount = channel['statistics']['subscriberCount'] ?? 'N/A';
        videoCount = channel['statistics']['videoCount'] ?? 'N/A';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching channel info: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchFirstVideoAndOthers() async {
    try {
      final uploadsUrl =
          'https://www.googleapis.com/youtube/v3/channels?part=contentDetails&id=$channelId&key=$apiKey';
      final uploadsRes = await Dio().get(uploadsUrl);
      final uploadsData = uploadsRes.data as Map<String, dynamic>;
      final uploadsPlaylistId = uploadsData['items'][0]['contentDetails']
      ?['relatedPlaylists']?['uploads'];

      if (uploadsPlaylistId == null) {
        throw Exception('Uploads playlist not found.');
      }

      String? nextPageToken;
      final List<Map<String, dynamic>> allVideos = [];

      do {
        final playlistUrl = Uri.https(
          'www.googleapis.com',
          '/youtube/v3/playlistItems',
          {
            'part': 'snippet,contentDetails',
            'playlistId': uploadsPlaylistId,
            'maxResults': maxResults.toString(),
            'pageToken': nextPageToken ?? '',
            'key': apiKey,
          },
        ).toString();

        final playlistRes = await Dio().get(playlistUrl);
        final playlistData = playlistRes.data as Map<String, dynamic>;
        final items = (playlistData['items'] as List)
            .cast<Map<String, dynamic>>();

        allVideos.addAll(items);
        nextPageToken = playlistData['nextPageToken'] as String?;
      } while (nextPageToken != null && allVideos.length < 100);

      if (allVideos.isEmpty) {
        throw Exception('No videos found.');
      }

      final firstVideo = allVideos.last;
      final firstVideoId =
      firstVideo['snippet']?['resourceId']?['videoId'] as String?;

      if (firstVideoId == null) {
        throw Exception('Video ID missing.');
      }

      setState(() {
        constantVideoId = firstVideoId;
        _constantVideoController = YoutubePlayerController(
          initialVideoId: constantVideoId!,
          flags: const YoutubePlayerFlags(autoPlay: false),
        );
      });

      final remaining = allVideos
          .where((v) =>
      v['snippet']?['resourceId']?['videoId'] != constantVideoId)
          .toList();

      setState(() {
        videos = allVideos;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading videos: $e';
        isLoading = false;
      });
    }
  }

  void playVideo(String videoId) {
    if (_constantVideoController != null) {
      _constantVideoController!.load(videoId);
    }
  }

  String _getTimeAgo(String publishedAt) {
    final date = DateTime.tryParse(publishedAt);
    if (date == null) return "";
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays >= 1) return "${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago";
    if (diff.inHours >= 1) return "${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago";
    if (diff.inMinutes >= 1) return "${diff.inMinutes} min ago";
    return "just now";
  }

  Future<void> _openYouTubeChannel() async {
    final url = Uri.parse("https://www.youtube.com/channel/$channelId");

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // Opens YouTube app or browser
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open YouTube channel")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || constantVideoId == null || _constantVideoController == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.kPrimary,)));
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("YouTube Channel Videos")),
        body: Center(child: Text(errorMessage!)),
      );
    }
    return Scaffold(
      body: YoutubePlayerBuilder(
        player: YoutubePlayer(controller: _constantVideoController!),
        builder: (context, player) {
          return Container(
            decoration: BoxDecoration(
                gradient: AppColors.myGradient
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Stack(
                  children: [
                  player,
                  Positioned(
                    top: 5,
                    left: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          _constantVideoController?.pause();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  ],
                              ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: channelProfileUrl != null
                            ? NetworkImage(channelProfileUrl!)
                            : null,
                        radius: 25,
                        child: channelProfileUrl == null ? const Icon(Icons.person) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(channelTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("$subscriberCount subscribers • $videoCount videos", style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _openYouTubeChannel,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kPrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        child: const Text("Subscribe", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ),
                const Divider(color: Colors.black12),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: videos.length,
                          itemBuilder: (context, index) {
                            final video = videos[index];
                            final snippet = video['snippet'] as Map<String, dynamic>?;

                            if (snippet == null) return const SizedBox();

                            final resourceId = snippet['resourceId'] as Map<String, dynamic>?;
                            final vid = resourceId?['videoId'] as String?;
                            if (vid == null) return const SizedBox();

                            final title = snippet['title'] as String? ?? 'No title';
                            final thumbnail = snippet['thumbnails']?['medium']?['url'] as String?;
                            final publishedAt = snippet['publishedAt'] as String? ?? '';
                            final timeAgo = _getTimeAgo(publishedAt);

                            return ListTile(
                              onTap: () => playVideo(vid),
                              leading: thumbnail != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(thumbnail, width: 120, height: 70, fit: BoxFit.cover),
                              )
                                  : null,
                              title: Text(title, style: const TextStyle(fontSize: 14)),
                              subtitle: Text("$timeAgo", style: const TextStyle(fontSize: 12)),
                              trailing: const Icon(Icons.more_vert),
                            );
                          },
                        ),
                      ),
                      Divider(color:AppColors.kPrimaryDark),
                      videos.length>=5?Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ElevatedButton(
                          onPressed: _openYouTubeChannel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kPrimary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("More Videos on YouTube"),
                        ),
                      ):SizedBox()
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class YoutubePlayerScreen extends StatelessWidget {
  final String videoId;

  const YoutubePlayerScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: true),
    );

    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: controller),
      builder: (context, player) {
        return Scaffold(
          body: Column(
            children: [
              Stack(
                children: [
                  player,
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text("Now Playing", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Video ID: $videoId", style: const TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }
}
