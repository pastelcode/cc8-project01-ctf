import 'package:logger/logger.dart';

/// Application-wide logger instance.
///
/// In release mode only warnings and above are shown. In debug mode all
/// levels are visible via the pretty-printer.
final appLogger = Logger(
  filter: ProductionFilter(),
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: false,
  ),
  output: ConsoleOutput(),
);

/// Log every sent and received protocol message in debug mode.
///
/// Called from `TcpClient` and `TcpServer` on each serialized message.
void logMessage(String direction, String rawJson) {
  appLogger.d('$direction | $rawJson');
}
