/// Represents the data needed to print a single label.
class PrintData {
  const PrintData({
    required this.templateName,
    required this.data,
    this.copies = 1,
  });

  final String templateName;
  final Map<String, String> data;
  final int copies;
}
