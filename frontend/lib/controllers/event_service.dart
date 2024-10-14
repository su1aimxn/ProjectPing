import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/models/event_model.dart';
import 'package:frontend/varibles.dart';

class EventService {
  // Get the access token from shared preferences
  Future<String> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    // print('Access Token: $token');  // Print the access token
    return token;
  }

  // Handle API request errors
  void _handleApiError(http.Response response) {
    String errorMessage;
    try {
      final responseBody = jsonDecode(response.body);
      errorMessage = responseBody['message'] ?? 'Unknown error occurred';
    } catch (e) {
      errorMessage = 'Failed to parse error message';
    }
    throw Exception(errorMessage);
  }

Future<List<EventModel>> getEvents() async {
  try {
    final token = await _getAccessToken();
    final response = await http.get(
      Uri.parse("$apiURL/api/events"),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include token if required
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => EventModel.fromJson(json)).toList();
    } else {
      _handleApiError(response); // Handle errors for non-200 status codes
    }
  } catch (e) {
    print('Error fetching events: $e'); // Print detailed error information
    throw Exception('Failed to load events'); // Ensure method always throws an exception or returns a value
  }
  // Ensure that the function always returns or throws an exception
  throw Exception('Failed to load events');
}

  // Get a single event by ID
  Future<EventModel?> getEvent(String id) async {
    try {
      final token = await _getAccessToken();
      final response = await http.get(
        Uri.parse("$apiURL/api/events/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include token if required
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EventModel.fromJson(data);
      } else {
        _handleApiError(response);
      }
    } catch (e) {
      print('Error fetching event: $e');
      throw Exception('Failed to load event');
    }
  }

  // Create a new event
  Future<void> createEvent(String eventName, String description, DateTime eventDate, String startTime, String endTime) async {
    try {
      final token = await _getAccessToken();
      final response = await http.post(
        Uri.parse("$apiURL/api/events"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include token if required
        },
        body: jsonEncode(<String, dynamic>{
          'eventName': eventName,
          'description': description,
          'eventDate': eventDate.toIso8601String(),
          'startTime': startTime,
          'endTime': endTime,
        }),
      );

      if (response.statusCode == 201) {
        print('Event created successfully');
      } else {
        _handleApiError(response);
      }
    } catch (e) {
      print('Error creating event: $e');
      throw Exception('Failed to create event');
    }
  }

  // Update an existing event
  Future<void> updateEvent(String id, String eventName, String description, DateTime eventDate, String startTime, String endTime) async {
    try {
      final token = await _getAccessToken();
      final response = await http.put(
        Uri.parse("$apiURL/api/events/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include token if required
        },
        body: jsonEncode(<String, dynamic>{
          'eventName': eventName,
          'description': description,
          'eventDate': eventDate.toIso8601String(),
          'startTime': startTime,
          'endTime': endTime,
        }),
      );

      if (response.statusCode == 200) {
        print('Event updated successfully');
      } else {
        _handleApiError(response);
      }
    } catch (e) {
      print('Error updating event: $e');
      throw Exception('Failed to update event');
    }
  }

  // Delete an event by ID
  Future<void> deleteEvent(String id) async {
    try {
      final token = await _getAccessToken();
      final response = await http.delete(
        Uri.parse("$apiURL/api/events/$id"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Include token if required
        },
      );

      if (response.statusCode == 200) {
        print('Event deleted successfully');
      } else {
        _handleApiError(response);
      }
    } catch (e) {
      print('Error deleting event: $e');
      throw Exception('Failed to delete event');
    }
  }
}
