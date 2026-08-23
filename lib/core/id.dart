import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Genera un nuovo identificatore univoco (UUID v4) per le chiavi primarie.
String newId() => _uuid.v4();
