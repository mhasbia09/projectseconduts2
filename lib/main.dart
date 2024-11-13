import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'service/pexels_service.dart';
import 'models/image_models.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ImageModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pexels API Integration',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PexelsService pexelsService = PexelsService();
  late ImageModel _imageModel;

  @override
  void initState() {
    super.initState();
    _imageModel = Provider.of<ImageModel>(context, listen: false);
  }

  void _searchImages(String query) async {
    _imageModel.setSearchQuery(query);
    _imageModel.setLoading(true);
    //Menangani loading dan error
    try {
      final result =
          await pexelsService.fetchImages(query, _imageModel.currentPage);
      _imageModel.addImages(result);
      _imageModel.setLoading(false);
      _imageModel.setHasMore(result.isNotEmpty);
    } catch (e) {
      _imageModel.setLoading(false);
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  void _loadMoreImages() async {
    if (_imageModel.isLoading || !_imageModel.hasMore) return;
    _imageModel.setLoading(true);
    _imageModel.nextPage();

    try {
      final result = await pexelsService.fetchImages(
          _imageModel.searchQuery, _imageModel.currentPage);
      _imageModel.addImages(result);
      _imageModel.setHasMore(result.isNotEmpty);
      _imageModel.setLoading(false);
    } catch (e) {
      _imageModel.setLoading(false);
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

// Halaman Pencarian
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pexels API Integration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for images...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: _searchImages,
            ),
            SizedBox(height: 20),

            // Menampilkan gambar
            Expanded(
              child: Consumer<ImageModel>(
                builder: (context, model, child) {
                  // Membuat infinite scrolling
                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollEndNotification &&
                          scrollNotification.metrics.extentAfter == 0) {
                        _loadMoreImages();
                      }
                      return true;
                    },
                    child: ListView.builder(
                      itemCount: model.images.length + 1,
                      itemBuilder: (context, index) {
                        if (index == model.images.length) {
                          return model.isLoading
                              ? Center(child: CircularProgressIndicator())
                              : SizedBox();
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailPage(imageUrl: model.images[index]),
                              ),
                            );
                          },
                          child: Image.network(model.images[index]),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Fungsi melihat detail gambar
class DetailPage extends StatelessWidget {
  final String imageUrl;

  DetailPage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Detail')),
      body: Center(
        child: Image.network(imageUrl),
      ),
    );
  }
}
