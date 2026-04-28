import 'package:dio/dio.dart';
import 'package:flutter_core/core/apis/app/client/crud.dart';
import 'package:flutter_core/core/apis/base/interfaces/request.dart';
import 'package:flutter_core/core/apis/base/interfaces/response.dart';
import 'package:flutter_core/core/apis/app/interfaces/pokemon.dart';

class PokemonApiClient extends AppCrudApiClient<Pokemon> {
  PokemonApiClient() : super(resource: "pokemon");

  @override
  Pokemon fromJson(Map<String, dynamic> json) => Pokemon.fromJson(json);

  @override
  Future<BasePaginationResponse<Pokemon>> getAll(
    BasePaginationRequest request,
  ) async {
    final page = request.page ?? 1;
    final limit = request.limit ?? 20;
    final offset = (page - 1) * limit;

    final response = await client.get(
      '',
      queryParameters: {
        'offset': offset,
        'limit': limit,
        if (request.extraParams is String &&
            (request.extraParams as String).isNotEmpty)
          'search': request.extraParams,
      },
    );

    // Do có Interceptor bọc data dư thừa cấp Base nên cần lấy từ field 'data'
    final rawData = response.data['data'] as Map<String, dynamic>;
    final List<dynamic> results = rawData['results'] ?? [];
    final int count = rawData['count'] ?? 0;

    return BasePaginationResponse<Pokemon>(
      data: results.map((e) => fromJson(e)).toList(),
      status: 'success',
      statusCode: response.statusCode ?? 200,
      pagination: PaginationInfo(
        page: page,
        limit: limit,
        total: count,
        pages: (count / limit).ceil(),
        totalDocs: count,
        totalPages: (count / limit).ceil(),
      ),
    );
  }

  @override
  BaseResponse<Pokemon> mapToResponse(Response response) {
    // Do có Interceptor bọc data dư thừa cấp Base nên cần lấy từ field 'data'
    return BaseResponse<Pokemon>(
      data: fromJson(response.data['data']),
      status: 'success',
      statusCode: response.statusCode ?? 200,
    );
  }
}
