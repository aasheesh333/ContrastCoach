import 'package:contrast_coach/domain/entities/session_state.dart';
import 'package:contrast_coach/domain/entities/session_state_machine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionStateMachine', () {
    test('idle -> setup on chooseProtocol', () {
      final sm = SessionStateMachine();
      sm.dispatch(SessionEvent.chooseProtocol);
      expect(sm.state, SessionState.setup);
    });

    test('setup -> active on start', () {
      final sm = SessionStateMachine()..dispatch(SessionEvent.chooseProtocol);
      sm.dispatch(SessionEvent.start);
      expect(sm.state, SessionState.active);
    });

    test('active -> paused on pause', () {
      final sm = SessionStateMachine()
        ..dispatch(SessionEvent.chooseProtocol)
        ..dispatch(SessionEvent.start);
      sm.dispatch(SessionEvent.pause);
      expect(sm.state, SessionState.paused);
    });

    test('paused -> active on resume', () {
      final sm = SessionStateMachine()
        ..dispatch(SessionEvent.chooseProtocol)
        ..dispatch(SessionEvent.start)
        ..dispatch(SessionEvent.pause);
      sm.dispatch(SessionEvent.resume);
      expect(sm.state, SessionState.active);
    });

    test('active -> summary on end', () {
      final sm = SessionStateMachine()
        ..dispatch(SessionEvent.chooseProtocol)
        ..dispatch(SessionEvent.start);
      sm.dispatch(SessionEvent.end);
      expect(sm.state, SessionState.summary);
    });

    test('summary -> syncing on save', () {
      final sm = SessionStateMachine()
        ..dispatch(SessionEvent.chooseProtocol)
        ..dispatch(SessionEvent.start)
        ..dispatch(SessionEvent.end);
      sm.dispatch(SessionEvent.save);
      expect(sm.state, SessionState.syncing);
    });

    test('syncing -> idle on syncComplete', () {
      final sm = SessionStateMachine()
        ..dispatch(SessionEvent.chooseProtocol)
        ..dispatch(SessionEvent.start)
        ..dispatch(SessionEvent.end)
        ..dispatch(SessionEvent.save);
      sm.dispatch(SessionEvent.syncComplete);
      expect(sm.state, SessionState.idle);
    });

    test('summary -> idle on discard', () {
      final sm = SessionStateMachine()
        ..dispatch(SessionEvent.chooseProtocol)
        ..dispatch(SessionEvent.start)
        ..dispatch(SessionEvent.end);
      sm.dispatch(SessionEvent.discard);
      expect(sm.state, SessionState.idle);
    });

    test('any -> error on errorOccurred', () {
      final sm = SessionStateMachine()..dispatch(SessionEvent.chooseProtocol);
      sm.dispatch(SessionEvent.errorOccurred);
      expect(sm.state, SessionState.error);
    });

    test('error -> idle on reset', () {
      final sm = SessionStateMachine()
        ..dispatch(SessionEvent.chooseProtocol)
        ..dispatch(SessionEvent.errorOccurred);
      sm.dispatch(SessionEvent.reset);
      expect(sm.state, SessionState.idle);
    });

    test('start without chooseProtocol is invalid (state unchanged)', () {
      final sm = SessionStateMachine();
      sm.dispatch(SessionEvent.start);
      expect(sm.state, SessionState.idle);
    });
  });
}
