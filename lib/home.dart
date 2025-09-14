// lib/home.dart
import 'dart:convert';
import 'package:alpha_news/category.dart';
import 'package:alpha_news/model.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:alpha_news/NewsView.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController searchController = TextEditingController();
  final List<NewsQueryModel> newsModelList = <NewsQueryModel>[];
  final List<NewsQueryModel> newsModelListCarousel = <NewsQueryModel>[];

  final List<String> navBarItem = [
    "Top News",
    "United States",
    "World",
    "Finance",
    "Health",
    "Business",
    "Sports",
  ];

  bool isLoading = true;

  // Helper to safely display a network image with error placeholder
  Widget _buildNetworkImage(String? url, {double? height}) {
    if (url == null || url.isEmpty) {
      return Container(
        height: height,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.broken_image_outlined, size: 48)),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      height: height,
      width: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.broken_image_outlined, size: 48),
          ),
        );
      },
    );
  }

  Future<void> getNewsByQuery(String query) async {
    // Keep the list fresh
    newsModelList.clear();
    setState(() {
      isLoading = true;
    });

    final String apiKey =
        "71c3867107c5466e809a1c0a1465be2a"; // consider moving to secure storage
    final String url =
        "https://newsapi.org/v2/everything?q=${Uri.encodeQueryComponent(query)}&sortBy=publishedAt&language=en&apiKey=$apiKey";

    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        // Non-200 - treat as empty result (you can show a toast/snack if you want)
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final articles = data['articles'] as List<dynamic>?;

      if (articles == null || articles.isEmpty) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      int limit = 15;
      for (var element in articles) {
        if (element == null) continue;
        try {
          final model = NewsQueryModel.fromMap(
            Map<String, dynamic>.from(element),
          );
          // Basic sanity checks to avoid models with null url or head
          if ((model.newsUrl == null || model.newsUrl.isEmpty) &&
              (model.newsHead == null || model.newsHead.isEmpty)) {
            continue;
          }
          newsModelList.add(model);
          if (newsModelList.length >= limit) break;
        } catch (e) {
          // ignore malformed article
          continue;
        }
      }
    } catch (e) {
      // network or decoding error - keep UI stable
      print("getNewsByQuery error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> getNewsofIndia() async {
    newsModelListCarousel.clear();
    setState(() {
      isLoading = true;
    });

    final String apiKey = "71c3867107c5466e809a1c0a1465be2a";
    final String url =
        "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=$apiKey";

    try {
      final http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final articles = data['articles'] as List<dynamic>?;

      if (articles == null || articles.isEmpty) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      int limit = 5; // show fewer items in carousel
      for (var element in articles) {
        if (element == null) continue;
        try {
          final model = NewsQueryModel.fromMap(
            Map<String, dynamic>.from(element),
          );
          // keep only articles with at least an image or headline
          if ((model.newsImg == null || model.newsImg.isEmpty) &&
              (model.newsHead == null || model.newsHead.isEmpty)) {
            continue;
          }
          newsModelListCarousel.add(model);
          if (newsModelListCarousel.length >= limit) break;
        } catch (e) {
          continue;
        }
      }
    } catch (e) {
      print("getNewsofIndia error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // initial load
    getNewsByQuery("corona");
    getNewsofIndia();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // important for gradient
      appBar: AppBar(title: const Text("ALPHA NEWS"), centerTitle: true),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFfbc2eb), // pink
              Color(0xFFa6c1ee), // blue
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),

        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                // Search container
                padding: const EdgeInsets.symmetric(horizontal: 8),
                margin: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final text = searchController.text.trim();
                        if (text.isEmpty) {
                          // do nothing on blank
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Category(Query: text),
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(3, 0, 7, 0),
                        child: const Icon(
                          Icons.search,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          final text = value.trim();
                          if (text.isEmpty) {
                            // blank - ignore
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Category(Query: text),
                              ),
                            );
                          }
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search News ",
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // nav bar items
              SizedBox(
                height: 50,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: navBarItem.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Category(Query: navBarItem[index]),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            navBarItem[index],
                            style: const TextStyle(
                              fontSize: 19,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // carousel
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15),
                child: isLoading && newsModelListCarousel.isEmpty
                    ? const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : (newsModelListCarousel.isEmpty
                          ? const SizedBox()
                          : CarouselSlider(
                              options: CarouselOptions(
                                height: 200,
                                autoPlay: true,
                                enlargeCenterPage: true,
                              ),
                              items: newsModelListCarousel.map((instance) {
                                final img = instance.newsImg;
                                final head = instance.newsHead ?? "";
                                final url = instance.newsUrl ?? "";
                                return Builder(
                                  builder: (BuildContext context) {
                                    return GestureDetector(
                                      onTap: () {
                                        if (url.isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  NewsView(url),
                                            ),
                                          );
                                        }
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Stack(
                                          children: [
                                            _buildNetworkImage(
                                              img,
                                              height: 200,
                                            ),
                                            Positioned(
                                              left: 0,
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.black12
                                                          .withOpacity(0),
                                                      Colors.black,
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 12,
                                                    ),
                                                child: Text(
                                                  head,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            )),
              ),

              // latest news header + list
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(15, 25, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: const [
                        Text(
                          "LATEST NEWS ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ],
                    ),
                  ),

                  isLoading && newsModelList.isEmpty
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height - 450,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: newsModelList.length,
                          itemBuilder: (context, index) {
                            final item = newsModelList[index];
                            final img = item.newsImg;
                            final head = item.newsHead ?? "";
                            final desc = item.newsDes ?? "";
                            final url = item.newsUrl ?? "";

                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: InkWell(
                                onTap: () {
                                  if (url.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NewsView(url),
                                      ),
                                    );
                                  }
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 1.0,
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    children: [
                                      _buildNetworkImage(img, height: 230),
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.black12.withOpacity(0),
                                                Colors.black,
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                          ),
                                          padding: const EdgeInsets.fromLTRB(
                                            15,
                                            15,
                                            10,
                                            8,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                head,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                desc.length > 55
                                                    ? "${desc.substring(0, 55)}...."
                                                    : desc,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Category(Query: "Technology"),
                              ),
                            );
                          },
                          child: const Text("SHOW MORE"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
