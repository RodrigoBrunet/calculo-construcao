import 'package:flutter/foundation.dart';

/// Base dos presenters: guarda um estado imutável e avisa a view quando ele muda.
///
/// Presenters não importam `material.dart`; a view escuta com `ListenableBuilder`.
abstract class BasePresenter<S> extends ChangeNotifier {
  BasePresenter(this._state);

  S _state;
  bool _disposed = false;

  S get state => _state;

  @protected
  void emit(S novoEstado) {
    if (_disposed) return;
    _state = novoEstado;
    notifyListeners();
  }

  /// Troca o estado sem redesenhar a view (ex.: limpar um aviso já mostrado).
  @protected
  void emitSilencioso(S novoEstado) {
    if (_disposed) return;
    _state = novoEstado;
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
