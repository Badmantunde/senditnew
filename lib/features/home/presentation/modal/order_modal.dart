import 'dart:io';

class Order {
  final String itemName;
  final String quantity;
  final String description;
  final String receiverAddress;
  final String status;
  final String? imagePath;
  final File? imageFile; // Add support for File objects
  final String? trackingId; // Add tracking ID for navigation
  final Map<String, dynamic>? senderDetails; // Add sender details
  final Map<String, dynamic>? receiverDetails; // Add receiver details
  final String? amount; // Add amount
  final String? payer; // Add payer info

  Order({
    required this.itemName,
    required this.quantity,
    required this.description,
    required this.receiverAddress,
    required this.status,
    this.imagePath,
    this.imageFile,
    this.trackingId,
    this.senderDetails,
    this.receiverDetails,
    this.amount,
    this.payer,
  });

  Map<String, dynamic> toJson() => {
    'itemName': itemName,
    'quantity': quantity,
    'description': description,
    'receiverAddress': receiverAddress,
    'status': status,
    'imagePath': imagePath,
    'imageFilePath': imageFile?.absolute.path, // Store absolute file path instead of relative path
    'trackingId': trackingId,
    'senderDetails': senderDetails,
    'receiverDetails': receiverDetails,
    'amount': amount,
    'payer': payer,
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    itemName: json['itemName'] ?? '',
    quantity: json['quantity'] ?? '',
    description: json['description'] ?? '',
    receiverAddress: json['receiverAddress'] ?? '',
    status: json['status'] ?? 'Unpaid',
    imagePath: json['imagePath'],
    imageFile: json['imageFilePath'] != null ? File(json['imageFilePath']) : null, // Recreate File from path
    trackingId: json['trackingId'],
    senderDetails: json['senderDetails'],
    receiverDetails: json['receiverDetails'],
    amount: json['amount'],
    payer: json['payer'],
  );
}
