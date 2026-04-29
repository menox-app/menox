import 'package:flutter_core/core/apis/app/client/crud.dart';
import 'package:flutter_core/core/apis/app/interfaces/comment.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/apis/base/interfaces/response.dart';

class PostApiClient extends AppCrudApiClient<Post> {
  PostApiClient() : super(resource: "posts");

  @override
  Post fromJson(Map<String, dynamic> json) => Post.fromJson(json);

  Future<BasePaginationResponse<Comment>> getComments(
    IGetCommentsRequest request,
  ) async {
    final response = await client.get(
      "/${request.pathParams?['id']}/comments",
      queryParameters: request.params,
    );

    return mapToCustomPaginationResponse<Comment>(response, Comment.fromJson);
  }
}
