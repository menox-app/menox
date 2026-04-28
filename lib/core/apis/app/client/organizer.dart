import 'package:flutter_core/core/apis/app/client/crud.dart';
import 'package:flutter_core/core/apis/app/interfaces/organizer.dart';
import 'package:flutter_core/core/apis/base/interfaces/response.dart';

class OrganizerApiClient extends AppCrudApiClient<Organizer> {
  OrganizerApiClient() : super(resource: "orgs");

  @override
  Organizer fromJson(Map<String, dynamic> json) => Organizer.fromJson(json);

  // Custom Method: getCurrent
  Future<BaseResponse<Organizer>> getCurrent() async {
    final response = await client.get("/current");
    return mapToResponse(response);
  }
}
