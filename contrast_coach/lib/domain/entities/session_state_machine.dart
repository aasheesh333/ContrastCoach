import 'package:contrast_coach/domain/entities/session_state.dart';

enum SessionEvent {
  chooseProtocol,
  start,
  pause,
  resume,
  end,
  save,
  discard,
  syncComplete,
  errorOccurred,
  reset,
}

class SessionStateMachine {
  SessionState _state = SessionState.idle;
  SessionState get state => _state;

  static const Map<SessionState, Set<SessionEvent>> _allowed = {
    SessionState.idle: {SessionEvent.chooseProtocol, SessionEvent.reset, SessionEvent.errorOccurred},
    SessionState.setup: {SessionEvent.start, SessionEvent.reset, SessionEvent.errorOccurred},
    SessionState.active: {SessionEvent.pause, SessionEvent.end, SessionEvent.errorOccurred},
    SessionState.paused: {SessionEvent.resume, SessionEvent.end, SessionEvent.errorOccurred},
    SessionState.summary: {SessionEvent.save, SessionEvent.discard, SessionEvent.errorOccurred},
    SessionState.syncing: {SessionEvent.syncComplete, SessionEvent.errorOccurred},
    SessionState.error: {SessionEvent.reset},
  };

  static const Map<SessionEvent, SessionState> _transitions = {
    SessionEvent.chooseProtocol: SessionState.setup,
    SessionEvent.start: SessionState.active,
    SessionEvent.pause: SessionState.paused,
    SessionEvent.resume: SessionState.active,
    SessionEvent.end: SessionState.summary,
    SessionEvent.save: SessionState.syncing,
    SessionEvent.syncComplete: SessionState.idle,
    SessionEvent.discard: SessionState.idle,
    SessionEvent.errorOccurred: SessionState.error,
    SessionEvent.reset: SessionState.idle,
  };

  bool dispatch(SessionEvent event) {
    if (!(_allowed[_state]?.contains(event) ?? false)) {
      return false;
    }
    _state = _transitions[event]!;
    return true;
  }
}
