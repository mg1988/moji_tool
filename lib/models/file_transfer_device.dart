class FileTransferDevice {
  final String id;
  final String name;
  final String ip;
  final int port;
  final String type; // mobile, desktop, laptop
  final DateTime lastSeen;

  const FileTransferDevice({
    required this.id,
    required this.name,
    required this.ip,
    required this.port,
    required this.type,
    required this.lastSeen,
  });

  factory FileTransferDevice.fromJson(Map<String, dynamic> json) {
    return FileTransferDevice(
      id: json['id'] as String,
      name: json['name'] as String,
      ip: json['ip'] as String,
      port: json['port'] as int,
      type: json['type'] as String,
      lastSeen: DateTime.fromMillisecondsSinceEpoch(json['lastSeen'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ip': ip,
      'port': port,
      'type': type,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'FileTransferDevice(id: $id, name: $name, ip: $ip, port: $port, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileTransferDevice && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}