import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Shares [text] with the browser's share sheet (phones, some desktops).
/// False when the browser has none or the player closed it, so the caller
/// copies the text instead. Not share_plus: its web fallback opens an email.
Future<bool> webShareText(String text) async {
  final navigator = globalContext['navigator'] as JSObject?;
  if (navigator == null || !navigator.has('share')) return false;
  final data = JSObject()..['text'] = text.toJS;
  try {
    await navigator.callMethod<JSPromise>('share'.toJS, data).toDart;
    return true;
  } catch (_) {
    return false;
  }
}
