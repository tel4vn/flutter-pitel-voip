import '../event_manager/event_manager.dart';
import '../event_manager/internal_events.dart';
import '../logger.dart';
import '../sip_message.dart';
import '../transport.dart';
import '../ua.dart';
import '../utils.dart';
import 'transaction_base.dart';

class AckClientTransaction extends TransactionBase {
  AckClientTransaction(PitelUA ua, Transport transport, OutgoingRequest request,
      EventManager eventHandlers) {
    id = 'z9hG4bK${Math.floor(Math.random() * 10000000)}';
    this.transport = transport;
    this.request = request;
    _eventHandlers = eventHandlers;

    String via = 'SIP/2.0/${transport.via_transport}';

    via += ' ${ua.configuration!.via_host};branch=$id';

    request.setHeader('via', via);
  }

  late EventManager _eventHandlers;

  @override
  void send() {
    if (!transport!.send(request)) {
      onTransportError();
    }
  }

  @override
  void onTransportError() {
    logger.debug('transport error occurred for transaction $id');
    _eventHandlers.emit(EventOnTransportError());
  }
}
