import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:newsroom/NewsApi.Model.dart';
import 'package:newsroom/Article_Detail_Page.dart';
import 'package:newsroom/loginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final newsProvider = FutureProvider<NewsApi?>((ref) async {
  final apiService = ApiService();
  return apiService.fetchTopHeadlines();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsyncValue = ref.watch(newsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Image(
          image: AssetImage("assets/images/logo.png"),
          height: 280.h,
          width: 180.w,
        ),
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context, ref),
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: newsAsyncValue.when(
        data: (newsApi) {
          if (newsApi == null || newsApi.articles == null || newsApi.articles!.isEmpty) {
            return const Center(child: Text('No articles available'));
          }
          return ListView.builder(
            itemCount: newsApi.articles!.length,
            itemBuilder: (context, index) {
              final article = newsApi.articles![index];
              return Column(
                children: [
                  Card(
                    margin: EdgeInsets.symmetric(vertical: 5.h, horizontal: 30.w),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleDetailPage(article: article),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (article.urlToImage != null)
                              Image.network(
                                article.urlToImage!,
                                width: double.infinity,
                                height: 200.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/images/newsTemplate.jpg',
                                  width: double.infinity,
                                  height: 200.h,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Image.asset(
                                'assets/images/newsTemplate.jpg',
                                width: double.infinity,
                                height: 200.h,
                                fit: BoxFit.cover,
                              ),
                            SizedBox(height: 18.h),
                            Text(
                              article.title ?? 'No Title',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18.0,
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );

  }
}

void _showLogoutDialog(BuildContext context, WidgetRef ref) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: const Text("Do you want to exit the App?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout(context, ref);
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

Future<void> _logout(BuildContext context, WidgetRef ref) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');


    await FirebaseAuth.instance.signOut();


    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );

    EasyLoading.showSuccess("Logged out successfully");
  } catch (e) {
    EasyLoading.showError("Logout failed: $e");
  }
}


class ApiService {
  final Dio _dio = Dio();

  Future<NewsApi?> fetchTopHeadlines() async {
    try {
      final response = await _dio.request(
        'https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=5fa2471179aa41d3ab630158977248e0',
        options: Options(
          method: 'GET',
        ),
      );

      if (response.statusCode == 200) {
        return NewsApi.fromJson(response.data);
      } else {
        print('Failed to load data: ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      print('Error occurred: $e');
      return null;
    }
  }
}
