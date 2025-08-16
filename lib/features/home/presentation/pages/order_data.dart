class Order {
  final String? trackingId;
  final String senderName;
  final String receiverName;
  final String receiverPhone;
  final String receiverEmail;
  final String senderAddress;
  final String receiverAddress;
  final String itemName;
  final String weight;
  final int quantity;
  final String? amount;
  final String status;
  final String? imagePath;
  final String? createdDate;
  final String? createdTime;

  Order({
    required this.trackingId,
    required this.senderName,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverEmail,
    required this.senderAddress,
    required this.receiverAddress,
    required this.itemName,
    required this.weight,
    required this.quantity,
    required this.amount,
    required this.status,
    required this.imagePath,
    required this.createdDate,
    required this.createdTime,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      trackingId: json['trackingId'],
      senderName: json['senderName'],
      receiverName: json['receiverName'],
      receiverPhone: json['receiverPhone'],
      receiverEmail: json['receiverEmail'],
      senderAddress: json['senderAddress'],
      receiverAddress: json['receiverAddress'],
      itemName: json['itemName'],
      weight: json['weight'],
      quantity: json['quantity'] ?? 1,
      amount: json['amount'],
      status: json['status'],
      imagePath: json['imagePath'],
      createdDate: json['createdDate'],
      createdTime: json['createdTime'],
    );
  }

  Map<String, dynamic> toJson() => {
    'trackingId': trackingId,
    'senderName': senderName,
    'receiverName': receiverName,
    'receiverPhone': receiverPhone,
    'receiverEmail': receiverEmail,
    'senderAddress': senderAddress,
    'receiverAddress': receiverAddress,
    'itemName': itemName,
    'weight': weight,
    'quantity': quantity,
    'amount': amount,
    'status': status,
    'imagePath': imagePath,
    'createdDate': createdDate,
    'createdTime': createdTime,
  };
}
