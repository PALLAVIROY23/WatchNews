import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:newsroom/NewsApi.Model.dart';

class ArticleDetailPage extends ConsumerWidget {
  final Article article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Article Detail',style: TextStyle(color: Colors.white),),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back_ios,color: Colors.white,)),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: 20.w,vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.urlToImage != null)
              Image.network(
                article.urlToImage!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/newsTemplate.jpg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              Image.asset(
                'assets/images/newsTemplate.jpg',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
             SizedBox(height: 8.h),
            Text(
              article.title ?? 'No Title',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
                color: Colors.white
              ),
            ),
             SizedBox(height: 8.h),
            Text(
              article.description ?? 'No Description',
              style: const TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
             SizedBox(height: 16.h),
            Text(
              article.content ?? 'No Content Available',
              style:  TextStyle(fontSize: 14.sp,color: Colors.white)
            ),
          ],
        ),
      ),
    );
  }
}
