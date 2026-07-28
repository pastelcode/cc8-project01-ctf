import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:capture_the_flag/core/messages.dart';
import 'package:capture_the_flag/network/udp_discovery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UdpDiscovery', () {
    late List<StreamSubscription<dynamic>> subscriptions;
    late RawDatagramSocket sender;

    setUp(() async {
      subscriptions = [];
      // One persistent sender socket for the whole test to avoid
      // fire-and-close races on the loopback interface.
      sender = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    });

    tearDown(() async {
      sender.close();
      for (final sub in subscriptions) {
        await sub.cancel();
      }
      // Give lingering sockets time to fully release their ports.
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });

    /// Sends a raw UDP payload to 127.0.0.1:8888.
    void sendRaw(List<int> bytes) {
      sender.send(bytes, InternetAddress('127.0.0.1'), 8888);
    }

    /// Sends a JSON-encoded map to 127.0.0.1:8888.
    void sendJson(Map<String, dynamic> json) {
      sendRaw(utf8.encode(jsonEncode(json)));
    }

    // -----------------------------------------------------------------------
    // listenForDiscovery  (server-side)
    // -----------------------------------------------------------------------

    test(
      'listenForDiscovery yields source address for valid discover',
      () async {
        final stream = UdpDiscovery.listenForDiscovery();
        final completer = Completer<InternetAddress>();

        final sub = stream.listen(
          (addr) {
            if (!completer.isCompleted) completer.complete(addr);
          },
          onError: (e) {
            if (!completer.isCompleted) completer.completeError(e);
          },
        );
        subscriptions.add(sub);

        // Wait for the underlying socket to bind.
        await Future<void>.delayed(const Duration(milliseconds: 300));
        sendJson({'type': 'discover', 'v': 1});

        final addr = await completer.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () => fail('Timed out waiting for discover'),
        );

        expect(addr.address, '127.0.0.1');
      },
    );

    test('listenForDiscovery discards wrong version (v != 1)', () async {
      final stream = UdpDiscovery.listenForDiscovery();
      final received = <InternetAddress>[];
      final sub = stream.listen(received.add);
      subscriptions.add(sub);

      await Future<void>.delayed(const Duration(milliseconds: 300));

      // v=2 — should be silently discarded.
      sendJson({'type': 'discover', 'v': 2});
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(received, isEmpty, reason: 'v=2 discover should be discarded');

      // Valid v=1 to confirm the stream is still alive.
      sendJson({'type': 'discover', 'v': 1});
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(received, hasLength(1));
      expect(received[0].address, '127.0.0.1');
    });

    test('listenForDiscovery discards non-JSON datagrams', () async {
      final stream = UdpDiscovery.listenForDiscovery();
      final received = <InternetAddress>[];
      final sub = stream.listen(received.add);
      subscriptions.add(sub);

      await Future<void>.delayed(const Duration(milliseconds: 300));

      // Garbage bytes.
      sendRaw(utf8.encode('not valid json at all'));
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(received, isEmpty, reason: 'non-JSON should be discarded');

      // Valid discover to confirm the stream is alive.
      sendJson({'type': 'discover', 'v': 1});
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(received, hasLength(1));
      expect(received[0].address, '127.0.0.1');
    });

    // -----------------------------------------------------------------------
    // listen  (client-side)
    // -----------------------------------------------------------------------

    test('listen yields ServerInfo for valid server_info response', () async {
      final stream = UdpDiscovery.listen();
      final completer = Completer<ServerInfo>();

      final sub = stream.listen(
        (info) {
          if (!completer.isCompleted) completer.complete(info);
        },
        onError: (e) {
          if (!completer.isCompleted) completer.completeError(e);
        },
      );
      subscriptions.add(sub);

      await Future<void>.delayed(const Duration(milliseconds: 300));
      sendJson({
        'type': 'server_info',
        'v': 1,
        'name': 'TestServer',
        'tcp_port': 8889,
        'state': 'lobby',
        'players': 3,
      });

      final info = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => fail('Timed out waiting for server_info'),
      );

      expect(info.name, 'TestServer');
      expect(info.tcpPort, 8889);
      expect(info.state, ServerState.lobby);
      expect(info.players, 3);
      expect(info.v, 1);
    });

    test('listen discards non-server_info types and garbage', () async {
      final stream = UdpDiscovery.listen();
      final received = <ServerInfo>[];
      final sub = stream.listen(received.add);
      subscriptions.add(sub);

      await Future<void>.delayed(const Duration(milliseconds: 300));

      // Discover — client listen() should ignore this.
      sendJson({'type': 'discover', 'v': 1});
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(
        received,
        isEmpty,
        reason: 'discover on client listen should be discarded',
      );

      // Garbage bytes.
      sendRaw(utf8.encode('garbage'));
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(received, isEmpty, reason: 'non-JSON should be discarded');

      // Valid server_info to confirm the stream still works.
      sendJson({
        'type': 'server_info',
        'v': 1,
        'name': 'ValidServer',
        'tcp_port': 9000,
        'state': 'playing',
        'players': 5,
      });
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(received, hasLength(1));
      expect(received[0].name, 'ValidServer');
      expect(received[0].tcpPort, 9000);
      expect(received[0].state, ServerState.playing);
      expect(received[0].players, 5);
    });

    test('listen discards server_info with wrong version (v != 1)', () async {
      final stream = UdpDiscovery.listen();
      final received = <ServerInfo>[];
      final sub = stream.listen(received.add);
      subscriptions.add(sub);

      await Future<void>.delayed(const Duration(milliseconds: 300));

      // v=2 server_info — should be discarded.
      sendJson({
        'type': 'server_info',
        'v': 2,
        'name': 'OldServer',
        'tcp_port': 8889,
        'state': 'lobby',
        'players': 1,
      });
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(received, isEmpty, reason: 'v=2 server_info should be discarded');

      // Valid v=1 to confirm the stream is alive.
      sendJson({
        'type': 'server_info',
        'v': 1,
        'name': 'CurrentServer',
        'tcp_port': 9999,
        'state': 'lobby',
        'players': 2,
      });
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(received, hasLength(1));
      expect(received[0].name, 'CurrentServer');
    });

    // -----------------------------------------------------------------------
    // sendDiscoverUnicast
    // -----------------------------------------------------------------------

    test(
      'sendDiscoverUnicast reaches listenForDiscovery on same host',
      () async {
        final stream = UdpDiscovery.listenForDiscovery();
        final completer = Completer<InternetAddress>();

        final sub = stream.listen(
          (addr) {
            if (!completer.isCompleted) completer.complete(addr);
          },
          onError: (e) {
            if (!completer.isCompleted) completer.completeError(e);
          },
        );
        subscriptions.add(sub);

        await Future<void>.delayed(const Duration(milliseconds: 300));
        await UdpDiscovery.sendDiscoverUnicast('127.0.0.1');

        final addr = await completer.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () => fail('Timed out waiting for discover via unicast'),
        );

        expect(addr.address, '127.0.0.1');
      },
    );

    // -----------------------------------------------------------------------
    // sendDiscover (broadcast)
    // -----------------------------------------------------------------------

    test('sendDiscover reaches listenForDiscovery on localhost', () async {
      final stream = UdpDiscovery.listenForDiscovery();
      final completer = Completer<InternetAddress>();

      final sub = stream.listen(
        (addr) {
          if (!completer.isCompleted) completer.complete(addr);
        },
        onError: (e) {
          if (!completer.isCompleted) completer.completeError(e);
        },
      );
      subscriptions.add(sub);

      await Future<void>.delayed(const Duration(milliseconds: 300));
      await UdpDiscovery.sendDiscover();

      final addr = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => fail('Timed out waiting for broadcast discover'),
      );

      // On localhost the loopback interface address is 127.0.0.1.
      expect(addr.address, anyOf('127.0.0.1', contains('.')));
    });
  });
}
