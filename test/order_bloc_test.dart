import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goban/core/constants/enums.dart';
import 'package:goban/features/orders/bloc/order_bloc.dart';
import 'package:goban/features/orders/bloc/order_event.dart';
import 'package:goban/services/database_service.dart';
import 'package:goban/services/notification_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('creates an order for the customer who placed it', () async {
    dotenv.testLoad(fileInput: 'NTFY_BASE_URL=https://invalid.local');
    final database = DatabaseService.forTesting(databaseFactoryFfi);
    await database.initialize();
    await database.execute(
      '''INSERT INTO users (id, email, full_name, role, password_hash)
         VALUES (?, ?, ?, ?, ?)''',
      [
        'other-customer',
        'other@example.com',
        'Other Customer',
        'customer',
        'hash'
      ],
    );
    await database.execute(
      '''INSERT INTO users (id, email, full_name, role, password_hash)
         VALUES (?, ?, ?, ?, ?)''',
      ['customer-1', 'customer@example.com', 'Customer', 'customer', 'hash'],
    );
    await database.execute(
      '''INSERT INTO users (id, email, full_name, role, password_hash)
         VALUES (?, ?, ?, ?, ?)''',
      [
        'technician-1',
        'technician@example.com',
        'Technician',
        'technician',
        'hash'
      ],
    );
    await database.execute(
      '''INSERT INTO technician_profiles (id, lat, lng, services)
         VALUES (?, ?, ?, ?)''',
      ['technician-1', -6.2, 106.8, '[]'],
    );

    final bloc = OrderBloc(
      db: database,
      notifications: NotificationService(db: database),
    );
    bloc.add(const OrderCreate(
      customerId: 'customer-1',
      technicianId: 'technician-1',
      serviceType: 'tambal_ban',
      customerLat: -6.21,
      customerLng: 106.81,
      paymentMethod: PaymentMethod.cash,
    ));

    await bloc.stream.firstWhere((state) => state is OrderCreated);
    final orders = await database.query('SELECT customer_id FROM orders');

    expect(orders, [
      {'customer_id': 'customer-1'},
    ]);

    await bloc.close();
    await database.close();
  });

  test('stores one review and recalculates the technician rating', () async {
    final database = DatabaseService.forTesting(databaseFactoryFfi);
    await database.initialize();
    await database.execute(
      '''INSERT INTO users (id, email, full_name, role, password_hash)
         VALUES (?, ?, ?, ?, ?)''',
      ['customer-1', 'customer@example.com', 'Customer', 'customer', 'hash'],
    );
    await database.execute(
      '''INSERT INTO users (id, email, full_name, role, password_hash)
         VALUES (?, ?, ?, ?, ?)''',
      [
        'technician-1',
        'technician@example.com',
        'Technician',
        'technician',
        'hash'
      ],
    );
    await database.execute(
      '''INSERT INTO technician_profiles (id, lat, lng, services, rating_avg)
         VALUES (?, ?, ?, ?, ?)''',
      ['technician-1', -6.2, 106.8, '[]', 4.0],
    );
    await database.execute(
      '''INSERT INTO orders (
           id, customer_id, technician_id, service_type, status,
           customer_lat, customer_lng, created_at
         ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
      [
        'order-1',
        'customer-1',
        'technician-1',
        'tambal_ban',
        'completed',
        -6.21,
        106.81,
        DateTime.now().toIso8601String(),
      ],
    );

    final bloc = OrderBloc(db: database);
    bloc.add(const OrderSubmitReview(
      orderId: 'order-1',
      reviewerId: 'customer-1',
      rating: 5,
      comment: 'Cepat dan rapi',
    ));

    await bloc.stream.firstWhere((state) => state is OrderReviewSubmitted);
    final reviews = await database.query('SELECT rating, comment FROM reviews');
    final profiles = await database.query(
      'SELECT rating_avg FROM technician_profiles WHERE id = ?',
      ['technician-1'],
    );

    expect(reviews, [
      {'rating': 5, 'comment': 'Cepat dan rapi'},
    ]);
    expect(profiles.single['rating_avg'], 5.0);

    await bloc.close();
    await database.close();
  });
}
