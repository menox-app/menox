import 'package:flutter_core/core/apis/app/client/crud.dart';
import 'package:flutter_core/core/apis/app/interfaces/comment.dart';

class CommentApiClient extends AppCrudApiClient<Comment> {
  CommentApiClient() : super(resource: "comments");

  @override
  Comment fromJson(Map<String, dynamic> json) => Comment.fromJson(json);
}
