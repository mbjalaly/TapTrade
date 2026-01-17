import 'package:flutter/material.dart';
import 'package:taptrade/Const/apiEndPoint.dart';
import 'package:taptrade/Models/ChatModels/matchModel.dart';
import 'package:taptrade/Models/ChatModels/messageModel.dart';
import 'package:taptrade/Services/ApiServices/apiServices.dart';
import 'package:taptrade/Services/logService.dart';

/// Service for handling match and chat API calls
class ChatService {
  /// Create a match when mutual like is detected
  /// Called from the like/dislike feedback to check for mutual match
  static Future<CreateMatchResponseModel?> createMatch({
    required BuildContext context,
    required String likerUserId,
    required int likerProductId,
    required String likedUserId,
    required int likedProductId,
  }) async {
    try {
      final body = {
        'liker_user_id': likerUserId,
        'liker_product_id': likerProductId,
        'liked_user_id': likedUserId,
        'liked_product_id': likedProductId,
      };

      final response = await ApiService.postRequestData(
        ApiEndPoint.createMatch,
        body,
        context,
        sendToken: true,
      );

      if (response != null) {
        return CreateMatchResponseModel.fromJson(response);
      }
    } catch (e) {
      printLog('ChatService.createMatch error: $e');
    }
    return null;
  }

  /// Get all matches for the current user
  static Future<MatchesResponseModel?> getMatches({
    required BuildContext context,
  }) async {
    try {
      final response = await ApiService.getRequestData(
        ApiEndPoint.getMatches,
        context,
        useToken: true,
      );

      if (response != null) {
        return MatchesResponseModel.fromJson(response);
      }
    } catch (e) {
      printLog('ChatService.getMatches error: $e');
    }
    return null;
  }

  /// Get messages for a specific match
  static Future<MessagesResponseModel?> getMessages({
    required BuildContext context,
    required int matchId,
    int? limit,
    int? offset,
  }) async {
    try {
      String url = ApiEndPoint.getMatchMessages(matchId);

      // Add pagination params if provided
      List<String> params = [];
      if (limit != null) params.add('limit=$limit');
      if (offset != null) params.add('offset=$offset');
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await ApiService.getRequestData(
        url,
        context,
        useToken: true,
      );

      if (response != null) {
        return MessagesResponseModel.fromJson(response);
      }
    } catch (e) {
      printLog('ChatService.getMessages error: $e');
    }
    return null;
  }

  /// Send a message in a match chat
  static Future<SendMessageResponseModel?> sendMessage({
    required BuildContext context,
    required int matchId,
    required String receiverId,
    required String messageText,
  }) async {
    try {
      final body = {
        'receiver_id': receiverId,
        'message_text': messageText,
      };

      final response = await ApiService.postRequestData(
        ApiEndPoint.sendMatchMessage(matchId),
        body,
        context,
        sendToken: true,
      );

      if (response != null) {
        return SendMessageResponseModel.fromJson(response);
      }
    } catch (e) {
      printLog('ChatService.sendMessage error: $e');
    }
    return null;
  }

  /// Mark all messages in a match as read
  static Future<bool> markMessagesAsRead({
    required BuildContext context,
    required int matchId,
  }) async {
    try {
      final response = await ApiService.putRequestData(
        ApiEndPoint.markMatchRead(matchId),
        {},
        context,
        sendToken: true,
      );

      return response != null && response['success'] == true;
    } catch (e) {
      printLog('ChatService.markMessagesAsRead error: $e');
    }
    return false;
  }
}
