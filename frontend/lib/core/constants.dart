class AppConstants {
  // Change this to your deployed backend URL
  static const String baseUrl = 'http://localhost:8000'; // Web / Chrome

  // Style categories
  static const List<String> styleCategories = [
    'minimalist', 'old_money', 'smart_casual',
    'streetwear', 'formal', 'athleisure', 'vintage',
  ];

  static const List<String> wardrobeCategories = [
    'tops', 'bottoms', 'footwear', 'accessories', 'outerwear',
  ];

  static const List<String> occasions = [
    'casual', 'work', 'formal', 'date', 'party', 'vacation', 'interview', 'wedding',
  ];

  static const List<String> seasons = ['spring', 'summer', 'fall', 'winter'];

  static const List<String> colors = [
    'white', 'black', 'grey', 'navy', 'beige', 'brown',
    'blue', 'red', 'green', 'yellow', 'pink', 'purple',
    'olive', 'cream', 'camel', 'burgundy', 'orange',
  ];

  static const List<String> fitOptions = ['slim', 'regular', 'relaxed', 'oversized'];

  static const List<String> fashionGoals = [
    'Look More Professional',
    'Build Confidence',
    'Dress Better For College',
    'Build a Capsule Wardrobe',
    'Event Styling',
    'Express Personal Style',
  ];

  static const List<String> eventTypes = [
    'interview', 'wedding', 'presentation', 'party', 'vacation',
    'date', 'casual', 'work',
  ];
}
