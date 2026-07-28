import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:capture_the_flag/core/messages.dart';
import 'package:capture_the_flag/network/tcp_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TcpClient', () {
    test('connect and receive welcome', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;

      server.listen((socket) {
        socket.write(
          '{"type":"welcome",'
          '"player_id":"p1",'
          '"config":{'
          '"map_size":1000,'
          '"circle_radius":300,'
          '"player_radius":15,'
          '"interact_radius":40,'
          '"speed":200,'
          '"tick_rate":20'
          '}}\n',
        );
      });

      final client = TcpClient(host: '127.0.0.1', port: port);
      await client.connect();

      final message = await client.messages.first;
      expect(message, isA<Welcome>());
      final welcome = message as Welcome;
      expect(welcome.playerId, 'p1');
      expect(welcome.config.mapSize, 1000);

      await client.close();
      await server.close();
    });

    test('send join and receive response', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;

      server.listen((socket) {
        socket.listen((data) {
          // Once we receive the join, echo back a welcome.
          socket.write(
            '{"type":"welcome",'
            '"player_id":"p2",'
            '"config":{'
            '"map_size":500,'
            '"circle_radius":200,'
            '"player_radius":10,'
            '"interact_radius":30,'
            '"speed":150,'
            '"tick_rate":10'
            '}}\n',
          );
        });
      });

      final client = TcpClient(host: '127.0.0.1', port: port);
      await client.connect();

      client.send(ClientMessage.join(v: 1, name: 'test'));

      final message = await client.messages.first;
      expect(message, isA<Welcome>());
      final welcome = message as Welcome;
      expect(welcome.playerId, 'p2');

      await client.close();
      await server.close();
    });

    test('send input - server receives correct JSON', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;
      final received = Completer<String>();

      server.listen((socket) {
        socket.listen((data) {
          if (!received.isCompleted) {
            received.complete(utf8.decode(data));
          }
        });
      });

      final client = TcpClient(host: '127.0.0.1', port: port);
      await client.connect();

      client.send(ClientMessage.input(dir: Dir(x: 1, y: 0)));

      final data = await received.future.timeout(const Duration(seconds: 3));
      expect(data.endsWith('\n'), isTrue);

      final parsed = jsonDecode(data) as Map<String, dynamic>;
      expect(parsed['type'], 'input');
      expect(parsed['dir'], {'x': 1, 'y': 0});

      await client.close();
      await server.close();
    });

    test('send interact - server receives correct JSON', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;
      final received = Completer<String>();

      server.listen((socket) {
        socket.listen((data) {
          if (!received.isCompleted) {
            received.complete(utf8.decode(data));
          }
        });
      });

      final client = TcpClient(host: '127.0.0.1', port: port);
      await client.connect();

      client.send(ClientMessage.interact());

      final data = await received.future.timeout(const Duration(seconds: 3));
      expect(data.endsWith('\n'), isTrue);

      final parsed = jsonDecode(data) as Map<String, dynamic>;
      expect(parsed['type'], 'interact');

      await client.close();
      await server.close();
    });

    test('multiple messages in sequence', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;

      server.listen((socket) {
        socket.write(
          '{"type":"welcome","player_id":"p3",'
          '"config":{'
          '"map_size":1000,"circle_radius":300,"player_radius":15,'
          '"interact_radius":40,"speed":200,"tick_rate":20'
          '}}\n',
        );
        socket.write('{"type":"lobby","players":[]}\n');
        socket.write('{"type":"countdown","seconds":5}\n');
      });

      final client = TcpClient(host: '127.0.0.1', port: port);
      await client.connect();

      final messages = await client.messages.take(3).toList();

      expect(messages, hasLength(3));
      expect(messages[0], isA<Welcome>());
      expect(messages[1], isA<Lobby>());
      expect(messages[2], isA<Countdown>());

      await client.close();
      await server.close();
    });

    test('server disconnects - stream completes without error', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;

      server.listen((socket) async {
        // Close the socket immediately after accepting it.
        await socket.close();
      });

      final client = TcpClient(host: '127.0.0.1', port: port);
      await client.connect();

      final completer = Completer<bool>();
      Object? streamError;

      final sub = client.messages.listen(
        (_) {},
        onError: (e) {
          streamError = e;
          if (!completer.isCompleted) completer.complete(false);
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete(true);
        },
      );

      final completedCleanly = await completer.future.timeout(
        const Duration(seconds: 3),
      );
      expect(completedCleanly, isTrue);
      expect(streamError, isNull);

      await sub.cancel();
      await client.close();
      await server.close();
    });

    test('close reentrant safe', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;

      server.listen((socket) {
        // Accept and do nothing — let the client manage closing.
      });

      final client = TcpClient(host: '127.0.0.1', port: port);
      await client.connect();

      // First close.
      await client.close();
      // Second close should not throw.
      await client.close();

      await server.close();
    });
  });
}
