// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/category.dart';
import '../models/category_list.dart';
import '../models/category_match.dart';
import '../models/create_category_body.dart';
import '../models/update_category_body.dart';

part 'categories_client.g.dart';

@RestApi()
abstract class CategoriesClient {
  factory CategoriesClient(Dio dio, {String? baseUrl}) = _CategoriesClient;

  /// List categories.
  ///
  /// Categories sort downloads into directories when the autoCategorize setting is on; the first matching one wins.
  @GET('/v1/categories')
  Future<CategoryList> listCategories();

  /// Create a category.
  ///
  /// Adds a category at the end of the order.
  @POST('/v1/categories')
  Future<Category> createCategory({@Body() required CreateCategoryBody body});

  /// Find the category of a file.
  ///
  /// Returns the category a file with this name and MIME type would be sorted into.
  ///
  /// [name] - File name.
  ///
  /// [mimeType] - MIME type.
  @GET('/v1/categories/match')
  Future<CategoryMatch> matchCategory({
    @Query('name') String? name,
    @Query('mimeType') String? mimeType,
  });

  /// Delete a category.
  ///
  /// Deletes a category. Files already sorted by it stay where they are.
  ///
  /// [id] - Category ID.
  @DELETE('/v1/categories/{id}')
  Future<void> deleteCategory({@Path('id') required String id});

  /// Get a category.
  ///
  /// [id] - Category ID.
  @GET('/v1/categories/{id}')
  Future<Category> getCategory({@Path('id') required String id});

  /// Update a category.
  ///
  /// [id] - Category ID.
  @PATCH('/v1/categories/{id}')
  Future<Category> updateCategory({
    @Path('id') required String id,
    @Body() required UpdateCategoryBody body,
  });
}
