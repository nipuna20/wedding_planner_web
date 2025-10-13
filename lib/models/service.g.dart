// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServiceAdapter extends TypeAdapter<Service> {
  @override
  final int typeId = 0;

  @override
  Service read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Service(
      id: fields[0] as String,
      serviceName: fields[1] as String,
      serviceType: fields[2] as String,
      description: fields[3] as String,
      paymentPolicy: fields[4] as String,
      mediaUrls: (fields[5] as List).cast<String>(),
      averageRating: fields[6] as double,
      reviewCount: fields[7] as int,
      basePrice: fields[8] as double,
      vendorId: fields[9] as String,
      vendorName: fields[10] as String,
      phone: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Service obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.serviceName)
      ..writeByte(2)
      ..write(obj.serviceType)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.paymentPolicy)
      ..writeByte(5)
      ..write(obj.mediaUrls)
      ..writeByte(6)
      ..write(obj.averageRating)
      ..writeByte(7)
      ..write(obj.reviewCount)
      ..writeByte(8)
      ..write(obj.basePrice)
      ..writeByte(9)
      ..write(obj.vendorId)
      ..writeByte(10)
      ..write(obj.vendorName)
      ..writeByte(11)
      ..write(obj.phone);
  }
}
