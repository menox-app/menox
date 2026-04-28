import 'package:flutter_core/core/apis/app/client/crud.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';

class PostApiClient extends AppCrudApiClient<Post> {
  PostApiClient() : super(resource: "posts");

  @override
  Post fromJson(Map<String, dynamic> json) => Post.fromJson(json);
}
