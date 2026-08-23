// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'language_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('it'),
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<UnitSystem, String> unitSystem =
      GeneratedColumn<String>(
        'unit_system',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(UnitSystem.metric.name),
      ).withConverter<UnitSystem>($AppSettingsTable.$converterunitSystem);
  static const VerificationMeta _defaultFuelConsumptionMeta =
      const VerificationMeta('defaultFuelConsumption');
  @override
  late final GeneratedColumn<double> defaultFuelConsumption =
      GeneratedColumn<double>(
        'default_fuel_consumption',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(6.5),
      );
  static const VerificationMeta _defaultFuelPriceCentsMeta =
      const VerificationMeta('defaultFuelPriceCents');
  @override
  late final GeneratedColumn<int> defaultFuelPriceCents = GeneratedColumn<int>(
    'default_fuel_price_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(185),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FuelType, String>
  defaultFuelType = GeneratedColumn<String>(
    'default_fuel_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(FuelType.petrol.name),
  ).withConverter<FuelType>($AppSettingsTable.$converterdefaultFuelType);
  static const VerificationMeta _modeChosenMeta = const VerificationMeta(
    'modeChosen',
  );
  @override
  late final GeneratedColumn<bool> modeChosen = GeneratedColumn<bool>(
    'mode_chosen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("mode_chosen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AppMode, String> appMode =
      GeneratedColumn<String>(
        'app_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(AppMode.local.name),
      ).withConverter<AppMode>($AppSettingsTable.$converterappMode);
  static const VerificationMeta _serverUrlMeta = const VerificationMeta(
    'serverUrl',
  );
  @override
  late final GeneratedColumn<String> serverUrl = GeneratedColumn<String>(
    'server_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteUsernameMeta = const VerificationMeta(
    'remoteUsername',
  );
  @override
  late final GeneratedColumn<String> remoteUsername = GeneratedColumn<String>(
    'remote_username',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authTokenMeta = const VerificationMeta(
    'authToken',
  );
  @override
  late final GeneratedColumn<String> authToken = GeneratedColumn<String>(
    'auth_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta(
    'lastSyncAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    languageCode,
    currencyCode,
    unitSystem,
    defaultFuelConsumption,
    defaultFuelPriceCents,
    defaultFuelType,
    modeChosen,
    appMode,
    serverUrl,
    remoteUsername,
    authToken,
    lastSyncAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('language_code')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['language_code']!,
          _languageCodeMeta,
        ),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('default_fuel_consumption')) {
      context.handle(
        _defaultFuelConsumptionMeta,
        defaultFuelConsumption.isAcceptableOrUnknown(
          data['default_fuel_consumption']!,
          _defaultFuelConsumptionMeta,
        ),
      );
    }
    if (data.containsKey('default_fuel_price_cents')) {
      context.handle(
        _defaultFuelPriceCentsMeta,
        defaultFuelPriceCents.isAcceptableOrUnknown(
          data['default_fuel_price_cents']!,
          _defaultFuelPriceCentsMeta,
        ),
      );
    }
    if (data.containsKey('mode_chosen')) {
      context.handle(
        _modeChosenMeta,
        modeChosen.isAcceptableOrUnknown(data['mode_chosen']!, _modeChosenMeta),
      );
    }
    if (data.containsKey('server_url')) {
      context.handle(
        _serverUrlMeta,
        serverUrl.isAcceptableOrUnknown(data['server_url']!, _serverUrlMeta),
      );
    }
    if (data.containsKey('remote_username')) {
      context.handle(
        _remoteUsernameMeta,
        remoteUsername.isAcceptableOrUnknown(
          data['remote_username']!,
          _remoteUsernameMeta,
        ),
      );
    }
    if (data.containsKey('auth_token')) {
      context.handle(
        _authTokenMeta,
        authToken.isAcceptableOrUnknown(data['auth_token']!, _authTokenMeta),
      );
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(
          data['last_sync_at']!,
          _lastSyncAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      languageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_code'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      unitSystem: $AppSettingsTable.$converterunitSystem.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unit_system'],
        )!,
      ),
      defaultFuelConsumption: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_fuel_consumption'],
      )!,
      defaultFuelPriceCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_fuel_price_cents'],
      )!,
      defaultFuelType: $AppSettingsTable.$converterdefaultFuelType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}default_fuel_type'],
        )!,
      ),
      modeChosen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}mode_chosen'],
      )!,
      appMode: $AppSettingsTable.$converterappMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}app_mode'],
        )!,
      ),
      serverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_url'],
      ),
      remoteUsername: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_username'],
      ),
      authToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auth_token'],
      ),
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<UnitSystem, String, String> $converterunitSystem =
      const EnumNameConverter<UnitSystem>(UnitSystem.values);
  static JsonTypeConverter2<FuelType, String, String>
  $converterdefaultFuelType = const EnumNameConverter<FuelType>(
    FuelType.values,
  );
  static JsonTypeConverter2<AppMode, String, String> $converterappMode =
      const EnumNameConverter<AppMode>(AppMode.values);
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final String languageCode;
  final String currencyCode;
  final UnitSystem unitSystem;
  final double defaultFuelConsumption;
  final int defaultFuelPriceCents;
  final FuelType defaultFuelType;

  /// L'utente ha gia' scelto la modalita' all'avvio?
  final bool modeChosen;
  final AppMode appMode;
  final String? serverUrl;
  final String? remoteUsername;
  final String? authToken;
  final DateTime? lastSyncAt;
  const AppSetting({
    required this.id,
    required this.languageCode,
    required this.currencyCode,
    required this.unitSystem,
    required this.defaultFuelConsumption,
    required this.defaultFuelPriceCents,
    required this.defaultFuelType,
    required this.modeChosen,
    required this.appMode,
    this.serverUrl,
    this.remoteUsername,
    this.authToken,
    this.lastSyncAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['language_code'] = Variable<String>(languageCode);
    map['currency_code'] = Variable<String>(currencyCode);
    {
      map['unit_system'] = Variable<String>(
        $AppSettingsTable.$converterunitSystem.toSql(unitSystem),
      );
    }
    map['default_fuel_consumption'] = Variable<double>(defaultFuelConsumption);
    map['default_fuel_price_cents'] = Variable<int>(defaultFuelPriceCents);
    {
      map['default_fuel_type'] = Variable<String>(
        $AppSettingsTable.$converterdefaultFuelType.toSql(defaultFuelType),
      );
    }
    map['mode_chosen'] = Variable<bool>(modeChosen);
    {
      map['app_mode'] = Variable<String>(
        $AppSettingsTable.$converterappMode.toSql(appMode),
      );
    }
    if (!nullToAbsent || serverUrl != null) {
      map['server_url'] = Variable<String>(serverUrl);
    }
    if (!nullToAbsent || remoteUsername != null) {
      map['remote_username'] = Variable<String>(remoteUsername);
    }
    if (!nullToAbsent || authToken != null) {
      map['auth_token'] = Variable<String>(authToken);
    }
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      languageCode: Value(languageCode),
      currencyCode: Value(currencyCode),
      unitSystem: Value(unitSystem),
      defaultFuelConsumption: Value(defaultFuelConsumption),
      defaultFuelPriceCents: Value(defaultFuelPriceCents),
      defaultFuelType: Value(defaultFuelType),
      modeChosen: Value(modeChosen),
      appMode: Value(appMode),
      serverUrl: serverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(serverUrl),
      remoteUsername: remoteUsername == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUsername),
      authToken: authToken == null && nullToAbsent
          ? const Value.absent()
          : Value(authToken),
      lastSyncAt: lastSyncAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      unitSystem: $AppSettingsTable.$converterunitSystem.fromJson(
        serializer.fromJson<String>(json['unitSystem']),
      ),
      defaultFuelConsumption: serializer.fromJson<double>(
        json['defaultFuelConsumption'],
      ),
      defaultFuelPriceCents: serializer.fromJson<int>(
        json['defaultFuelPriceCents'],
      ),
      defaultFuelType: $AppSettingsTable.$converterdefaultFuelType.fromJson(
        serializer.fromJson<String>(json['defaultFuelType']),
      ),
      modeChosen: serializer.fromJson<bool>(json['modeChosen']),
      appMode: $AppSettingsTable.$converterappMode.fromJson(
        serializer.fromJson<String>(json['appMode']),
      ),
      serverUrl: serializer.fromJson<String?>(json['serverUrl']),
      remoteUsername: serializer.fromJson<String?>(json['remoteUsername']),
      authToken: serializer.fromJson<String?>(json['authToken']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'languageCode': serializer.toJson<String>(languageCode),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'unitSystem': serializer.toJson<String>(
        $AppSettingsTable.$converterunitSystem.toJson(unitSystem),
      ),
      'defaultFuelConsumption': serializer.toJson<double>(
        defaultFuelConsumption,
      ),
      'defaultFuelPriceCents': serializer.toJson<int>(defaultFuelPriceCents),
      'defaultFuelType': serializer.toJson<String>(
        $AppSettingsTable.$converterdefaultFuelType.toJson(defaultFuelType),
      ),
      'modeChosen': serializer.toJson<bool>(modeChosen),
      'appMode': serializer.toJson<String>(
        $AppSettingsTable.$converterappMode.toJson(appMode),
      ),
      'serverUrl': serializer.toJson<String?>(serverUrl),
      'remoteUsername': serializer.toJson<String?>(remoteUsername),
      'authToken': serializer.toJson<String?>(authToken),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
    };
  }

  AppSetting copyWith({
    int? id,
    String? languageCode,
    String? currencyCode,
    UnitSystem? unitSystem,
    double? defaultFuelConsumption,
    int? defaultFuelPriceCents,
    FuelType? defaultFuelType,
    bool? modeChosen,
    AppMode? appMode,
    Value<String?> serverUrl = const Value.absent(),
    Value<String?> remoteUsername = const Value.absent(),
    Value<String?> authToken = const Value.absent(),
    Value<DateTime?> lastSyncAt = const Value.absent(),
  }) => AppSetting(
    id: id ?? this.id,
    languageCode: languageCode ?? this.languageCode,
    currencyCode: currencyCode ?? this.currencyCode,
    unitSystem: unitSystem ?? this.unitSystem,
    defaultFuelConsumption:
        defaultFuelConsumption ?? this.defaultFuelConsumption,
    defaultFuelPriceCents: defaultFuelPriceCents ?? this.defaultFuelPriceCents,
    defaultFuelType: defaultFuelType ?? this.defaultFuelType,
    modeChosen: modeChosen ?? this.modeChosen,
    appMode: appMode ?? this.appMode,
    serverUrl: serverUrl.present ? serverUrl.value : this.serverUrl,
    remoteUsername: remoteUsername.present
        ? remoteUsername.value
        : this.remoteUsername,
    authToken: authToken.present ? authToken.value : this.authToken,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      unitSystem: data.unitSystem.present
          ? data.unitSystem.value
          : this.unitSystem,
      defaultFuelConsumption: data.defaultFuelConsumption.present
          ? data.defaultFuelConsumption.value
          : this.defaultFuelConsumption,
      defaultFuelPriceCents: data.defaultFuelPriceCents.present
          ? data.defaultFuelPriceCents.value
          : this.defaultFuelPriceCents,
      defaultFuelType: data.defaultFuelType.present
          ? data.defaultFuelType.value
          : this.defaultFuelType,
      modeChosen: data.modeChosen.present
          ? data.modeChosen.value
          : this.modeChosen,
      appMode: data.appMode.present ? data.appMode.value : this.appMode,
      serverUrl: data.serverUrl.present ? data.serverUrl.value : this.serverUrl,
      remoteUsername: data.remoteUsername.present
          ? data.remoteUsername.value
          : this.remoteUsername,
      authToken: data.authToken.present ? data.authToken.value : this.authToken,
      lastSyncAt: data.lastSyncAt.present
          ? data.lastSyncAt.value
          : this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('languageCode: $languageCode, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('defaultFuelConsumption: $defaultFuelConsumption, ')
          ..write('defaultFuelPriceCents: $defaultFuelPriceCents, ')
          ..write('defaultFuelType: $defaultFuelType, ')
          ..write('modeChosen: $modeChosen, ')
          ..write('appMode: $appMode, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('remoteUsername: $remoteUsername, ')
          ..write('authToken: $authToken, ')
          ..write('lastSyncAt: $lastSyncAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    languageCode,
    currencyCode,
    unitSystem,
    defaultFuelConsumption,
    defaultFuelPriceCents,
    defaultFuelType,
    modeChosen,
    appMode,
    serverUrl,
    remoteUsername,
    authToken,
    lastSyncAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.languageCode == this.languageCode &&
          other.currencyCode == this.currencyCode &&
          other.unitSystem == this.unitSystem &&
          other.defaultFuelConsumption == this.defaultFuelConsumption &&
          other.defaultFuelPriceCents == this.defaultFuelPriceCents &&
          other.defaultFuelType == this.defaultFuelType &&
          other.modeChosen == this.modeChosen &&
          other.appMode == this.appMode &&
          other.serverUrl == this.serverUrl &&
          other.remoteUsername == this.remoteUsername &&
          other.authToken == this.authToken &&
          other.lastSyncAt == this.lastSyncAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<String> languageCode;
  final Value<String> currencyCode;
  final Value<UnitSystem> unitSystem;
  final Value<double> defaultFuelConsumption;
  final Value<int> defaultFuelPriceCents;
  final Value<FuelType> defaultFuelType;
  final Value<bool> modeChosen;
  final Value<AppMode> appMode;
  final Value<String?> serverUrl;
  final Value<String?> remoteUsername;
  final Value<String?> authToken;
  final Value<DateTime?> lastSyncAt;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.unitSystem = const Value.absent(),
    this.defaultFuelConsumption = const Value.absent(),
    this.defaultFuelPriceCents = const Value.absent(),
    this.defaultFuelType = const Value.absent(),
    this.modeChosen = const Value.absent(),
    this.appMode = const Value.absent(),
    this.serverUrl = const Value.absent(),
    this.remoteUsername = const Value.absent(),
    this.authToken = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.unitSystem = const Value.absent(),
    this.defaultFuelConsumption = const Value.absent(),
    this.defaultFuelPriceCents = const Value.absent(),
    this.defaultFuelType = const Value.absent(),
    this.modeChosen = const Value.absent(),
    this.appMode = const Value.absent(),
    this.serverUrl = const Value.absent(),
    this.remoteUsername = const Value.absent(),
    this.authToken = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<String>? languageCode,
    Expression<String>? currencyCode,
    Expression<String>? unitSystem,
    Expression<double>? defaultFuelConsumption,
    Expression<int>? defaultFuelPriceCents,
    Expression<String>? defaultFuelType,
    Expression<bool>? modeChosen,
    Expression<String>? appMode,
    Expression<String>? serverUrl,
    Expression<String>? remoteUsername,
    Expression<String>? authToken,
    Expression<DateTime>? lastSyncAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (languageCode != null) 'language_code': languageCode,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (unitSystem != null) 'unit_system': unitSystem,
      if (defaultFuelConsumption != null)
        'default_fuel_consumption': defaultFuelConsumption,
      if (defaultFuelPriceCents != null)
        'default_fuel_price_cents': defaultFuelPriceCents,
      if (defaultFuelType != null) 'default_fuel_type': defaultFuelType,
      if (modeChosen != null) 'mode_chosen': modeChosen,
      if (appMode != null) 'app_mode': appMode,
      if (serverUrl != null) 'server_url': serverUrl,
      if (remoteUsername != null) 'remote_username': remoteUsername,
      if (authToken != null) 'auth_token': authToken,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? languageCode,
    Value<String>? currencyCode,
    Value<UnitSystem>? unitSystem,
    Value<double>? defaultFuelConsumption,
    Value<int>? defaultFuelPriceCents,
    Value<FuelType>? defaultFuelType,
    Value<bool>? modeChosen,
    Value<AppMode>? appMode,
    Value<String?>? serverUrl,
    Value<String?>? remoteUsername,
    Value<String?>? authToken,
    Value<DateTime?>? lastSyncAt,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      languageCode: languageCode ?? this.languageCode,
      currencyCode: currencyCode ?? this.currencyCode,
      unitSystem: unitSystem ?? this.unitSystem,
      defaultFuelConsumption:
          defaultFuelConsumption ?? this.defaultFuelConsumption,
      defaultFuelPriceCents:
          defaultFuelPriceCents ?? this.defaultFuelPriceCents,
      defaultFuelType: defaultFuelType ?? this.defaultFuelType,
      modeChosen: modeChosen ?? this.modeChosen,
      appMode: appMode ?? this.appMode,
      serverUrl: serverUrl ?? this.serverUrl,
      remoteUsername: remoteUsername ?? this.remoteUsername,
      authToken: authToken ?? this.authToken,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (unitSystem.present) {
      map['unit_system'] = Variable<String>(
        $AppSettingsTable.$converterunitSystem.toSql(unitSystem.value),
      );
    }
    if (defaultFuelConsumption.present) {
      map['default_fuel_consumption'] = Variable<double>(
        defaultFuelConsumption.value,
      );
    }
    if (defaultFuelPriceCents.present) {
      map['default_fuel_price_cents'] = Variable<int>(
        defaultFuelPriceCents.value,
      );
    }
    if (defaultFuelType.present) {
      map['default_fuel_type'] = Variable<String>(
        $AppSettingsTable.$converterdefaultFuelType.toSql(
          defaultFuelType.value,
        ),
      );
    }
    if (modeChosen.present) {
      map['mode_chosen'] = Variable<bool>(modeChosen.value);
    }
    if (appMode.present) {
      map['app_mode'] = Variable<String>(
        $AppSettingsTable.$converterappMode.toSql(appMode.value),
      );
    }
    if (serverUrl.present) {
      map['server_url'] = Variable<String>(serverUrl.value);
    }
    if (remoteUsername.present) {
      map['remote_username'] = Variable<String>(remoteUsername.value);
    }
    if (authToken.present) {
      map['auth_token'] = Variable<String>(authToken.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('languageCode: $languageCode, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('unitSystem: $unitSystem, ')
          ..write('defaultFuelConsumption: $defaultFuelConsumption, ')
          ..write('defaultFuelPriceCents: $defaultFuelPriceCents, ')
          ..write('defaultFuelType: $defaultFuelType, ')
          ..write('modeChosen: $modeChosen, ')
          ..write('appMode: $appMode, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('remoteUsername: $remoteUsername, ')
          ..write('authToken: $authToken, ')
          ..write('lastSyncAt: $lastSyncAt')
          ..write(')'))
        .toString();
  }
}

class $TripsTable extends Trips with TableInfo<$TripsTable, Trip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _destinationMeta = const VerificationMeta(
    'destination',
  );
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
    'destination',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TripType, String> tripType =
      GeneratedColumn<String>(
        'trip_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(TripType.generic.name),
      ).withConverter<TripType>($TripsTable.$convertertripType);
  @override
  late final GeneratedColumnWithTypeConverter<Climate, String> climate =
      GeneratedColumn<String>(
        'climate',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(Climate.temperate.name),
      ).withConverter<Climate>($TripsTable.$converterclimate);
  static const VerificationMeta _travelerCountMeta = const VerificationMeta(
    'travelerCount',
  );
  @override
  late final GeneratedColumn<int> travelerCount = GeneratedColumn<int>(
    'traveler_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _homeCurrencyMeta = const VerificationMeta(
    'homeCurrency',
  );
  @override
  late final GeneratedColumn<String> homeCurrency = GeneratedColumn<String>(
    'home_currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  static const VerificationMeta _coverImagePathMeta = const VerificationMeta(
    'coverImagePath',
  );
  @override
  late final GeneratedColumn<String> coverImagePath = GeneratedColumn<String>(
    'cover_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TripStyle?, String> themeStyle =
      GeneratedColumn<String>(
        'theme_style',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<TripStyle?>($TripsTable.$converterthemeStylen);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    destination,
    country,
    startDate,
    endDate,
    tripType,
    climate,
    travelerCount,
    homeCurrency,
    coverImagePath,
    themeStyle,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(
    Insertable<Trip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('destination')) {
      context.handle(
        _destinationMeta,
        destination.isAcceptableOrUnknown(
          data['destination']!,
          _destinationMeta,
        ),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('traveler_count')) {
      context.handle(
        _travelerCountMeta,
        travelerCount.isAcceptableOrUnknown(
          data['traveler_count']!,
          _travelerCountMeta,
        ),
      );
    }
    if (data.containsKey('home_currency')) {
      context.handle(
        _homeCurrencyMeta,
        homeCurrency.isAcceptableOrUnknown(
          data['home_currency']!,
          _homeCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('cover_image_path')) {
      context.handle(
        _coverImagePathMeta,
        coverImagePath.isAcceptableOrUnknown(
          data['cover_image_path']!,
          _coverImagePathMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      destination: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
      tripType: $TripsTable.$convertertripType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}trip_type'],
        )!,
      ),
      climate: $TripsTable.$converterclimate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}climate'],
        )!,
      ),
      travelerCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}traveler_count'],
      )!,
      homeCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_currency'],
      )!,
      coverImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_image_path'],
      ),
      themeStyle: $TripsTable.$converterthemeStylen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}theme_style'],
        ),
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TripType, String, String> $convertertripType =
      const EnumNameConverter<TripType>(TripType.values);
  static JsonTypeConverter2<Climate, String, String> $converterclimate =
      const EnumNameConverter<Climate>(Climate.values);
  static JsonTypeConverter2<TripStyle, String, String> $converterthemeStyle =
      const EnumNameConverter<TripStyle>(TripStyle.values);
  static JsonTypeConverter2<TripStyle?, String?, String?>
  $converterthemeStylen = JsonTypeConverter2.asNullable($converterthemeStyle);
}

class Trip extends DataClass implements Insertable<Trip> {
  final String id;
  final String name;
  final String? destination;
  final String? country;
  final DateTime? startDate;
  final DateTime? endDate;
  final TripType tripType;
  final Climate climate;
  final int travelerCount;
  final String homeCurrency;
  final String? coverImagePath;

  /// Stile visivo del viaggio; null = automatico (dedotto dal tipo). Nullable
  /// per retrocompatibilita' con i backup/sync precedenti alla v3.
  final TripStyle? themeStyle;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Trip({
    required this.id,
    required this.name,
    this.destination,
    this.country,
    this.startDate,
    this.endDate,
    required this.tripType,
    required this.climate,
    required this.travelerCount,
    required this.homeCurrency,
    this.coverImagePath,
    this.themeStyle,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || destination != null) {
      map['destination'] = Variable<String>(destination);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    {
      map['trip_type'] = Variable<String>(
        $TripsTable.$convertertripType.toSql(tripType),
      );
    }
    {
      map['climate'] = Variable<String>(
        $TripsTable.$converterclimate.toSql(climate),
      );
    }
    map['traveler_count'] = Variable<int>(travelerCount);
    map['home_currency'] = Variable<String>(homeCurrency);
    if (!nullToAbsent || coverImagePath != null) {
      map['cover_image_path'] = Variable<String>(coverImagePath);
    }
    if (!nullToAbsent || themeStyle != null) {
      map['theme_style'] = Variable<String>(
        $TripsTable.$converterthemeStylen.toSql(themeStyle),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      name: Value(name),
      destination: destination == null && nullToAbsent
          ? const Value.absent()
          : Value(destination),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      tripType: Value(tripType),
      climate: Value(climate),
      travelerCount: Value(travelerCount),
      homeCurrency: Value(homeCurrency),
      coverImagePath: coverImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImagePath),
      themeStyle: themeStyle == null && nullToAbsent
          ? const Value.absent()
          : Value(themeStyle),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Trip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trip(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      destination: serializer.fromJson<String?>(json['destination']),
      country: serializer.fromJson<String?>(json['country']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      tripType: $TripsTable.$convertertripType.fromJson(
        serializer.fromJson<String>(json['tripType']),
      ),
      climate: $TripsTable.$converterclimate.fromJson(
        serializer.fromJson<String>(json['climate']),
      ),
      travelerCount: serializer.fromJson<int>(json['travelerCount']),
      homeCurrency: serializer.fromJson<String>(json['homeCurrency']),
      coverImagePath: serializer.fromJson<String?>(json['coverImagePath']),
      themeStyle: $TripsTable.$converterthemeStylen.fromJson(
        serializer.fromJson<String?>(json['themeStyle']),
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'destination': serializer.toJson<String?>(destination),
      'country': serializer.toJson<String?>(country),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'tripType': serializer.toJson<String>(
        $TripsTable.$convertertripType.toJson(tripType),
      ),
      'climate': serializer.toJson<String>(
        $TripsTable.$converterclimate.toJson(climate),
      ),
      'travelerCount': serializer.toJson<int>(travelerCount),
      'homeCurrency': serializer.toJson<String>(homeCurrency),
      'coverImagePath': serializer.toJson<String?>(coverImagePath),
      'themeStyle': serializer.toJson<String?>(
        $TripsTable.$converterthemeStylen.toJson(themeStyle),
      ),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Trip copyWith({
    String? id,
    String? name,
    Value<String?> destination = const Value.absent(),
    Value<String?> country = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    TripType? tripType,
    Climate? climate,
    int? travelerCount,
    String? homeCurrency,
    Value<String?> coverImagePath = const Value.absent(),
    Value<TripStyle?> themeStyle = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Trip(
    id: id ?? this.id,
    name: name ?? this.name,
    destination: destination.present ? destination.value : this.destination,
    country: country.present ? country.value : this.country,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    tripType: tripType ?? this.tripType,
    climate: climate ?? this.climate,
    travelerCount: travelerCount ?? this.travelerCount,
    homeCurrency: homeCurrency ?? this.homeCurrency,
    coverImagePath: coverImagePath.present
        ? coverImagePath.value
        : this.coverImagePath,
    themeStyle: themeStyle.present ? themeStyle.value : this.themeStyle,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Trip copyWithCompanion(TripsCompanion data) {
    return Trip(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      destination: data.destination.present
          ? data.destination.value
          : this.destination,
      country: data.country.present ? data.country.value : this.country,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      tripType: data.tripType.present ? data.tripType.value : this.tripType,
      climate: data.climate.present ? data.climate.value : this.climate,
      travelerCount: data.travelerCount.present
          ? data.travelerCount.value
          : this.travelerCount,
      homeCurrency: data.homeCurrency.present
          ? data.homeCurrency.value
          : this.homeCurrency,
      coverImagePath: data.coverImagePath.present
          ? data.coverImagePath.value
          : this.coverImagePath,
      themeStyle: data.themeStyle.present
          ? data.themeStyle.value
          : this.themeStyle,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trip(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('destination: $destination, ')
          ..write('country: $country, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('tripType: $tripType, ')
          ..write('climate: $climate, ')
          ..write('travelerCount: $travelerCount, ')
          ..write('homeCurrency: $homeCurrency, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('themeStyle: $themeStyle, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    destination,
    country,
    startDate,
    endDate,
    tripType,
    climate,
    travelerCount,
    homeCurrency,
    coverImagePath,
    themeStyle,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trip &&
          other.id == this.id &&
          other.name == this.name &&
          other.destination == this.destination &&
          other.country == this.country &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.tripType == this.tripType &&
          other.climate == this.climate &&
          other.travelerCount == this.travelerCount &&
          other.homeCurrency == this.homeCurrency &&
          other.coverImagePath == this.coverImagePath &&
          other.themeStyle == this.themeStyle &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TripsCompanion extends UpdateCompanion<Trip> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> destination;
  final Value<String?> country;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<TripType> tripType;
  final Value<Climate> climate;
  final Value<int> travelerCount;
  final Value<String> homeCurrency;
  final Value<String?> coverImagePath;
  final Value<TripStyle?> themeStyle;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.destination = const Value.absent(),
    this.country = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.tripType = const Value.absent(),
    this.climate = const Value.absent(),
    this.travelerCount = const Value.absent(),
    this.homeCurrency = const Value.absent(),
    this.coverImagePath = const Value.absent(),
    this.themeStyle = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    required String name,
    this.destination = const Value.absent(),
    this.country = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.tripType = const Value.absent(),
    this.climate = const Value.absent(),
    this.travelerCount = const Value.absent(),
    this.homeCurrency = const Value.absent(),
    this.coverImagePath = const Value.absent(),
    this.themeStyle = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Trip> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? destination,
    Expression<String>? country,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? tripType,
    Expression<String>? climate,
    Expression<int>? travelerCount,
    Expression<String>? homeCurrency,
    Expression<String>? coverImagePath,
    Expression<String>? themeStyle,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (destination != null) 'destination': destination,
      if (country != null) 'country': country,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (tripType != null) 'trip_type': tripType,
      if (climate != null) 'climate': climate,
      if (travelerCount != null) 'traveler_count': travelerCount,
      if (homeCurrency != null) 'home_currency': homeCurrency,
      if (coverImagePath != null) 'cover_image_path': coverImagePath,
      if (themeStyle != null) 'theme_style': themeStyle,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? destination,
    Value<String?>? country,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<TripType>? tripType,
    Value<Climate>? climate,
    Value<int>? travelerCount,
    Value<String>? homeCurrency,
    Value<String?>? coverImagePath,
    Value<TripStyle?>? themeStyle,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      destination: destination ?? this.destination,
      country: country ?? this.country,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      tripType: tripType ?? this.tripType,
      climate: climate ?? this.climate,
      travelerCount: travelerCount ?? this.travelerCount,
      homeCurrency: homeCurrency ?? this.homeCurrency,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      themeStyle: themeStyle ?? this.themeStyle,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (tripType.present) {
      map['trip_type'] = Variable<String>(
        $TripsTable.$convertertripType.toSql(tripType.value),
      );
    }
    if (climate.present) {
      map['climate'] = Variable<String>(
        $TripsTable.$converterclimate.toSql(climate.value),
      );
    }
    if (travelerCount.present) {
      map['traveler_count'] = Variable<int>(travelerCount.value);
    }
    if (homeCurrency.present) {
      map['home_currency'] = Variable<String>(homeCurrency.value);
    }
    if (coverImagePath.present) {
      map['cover_image_path'] = Variable<String>(coverImagePath.value);
    }
    if (themeStyle.present) {
      map['theme_style'] = Variable<String>(
        $TripsTable.$converterthemeStylen.toSql(themeStyle.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('destination: $destination, ')
          ..write('country: $country, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('tripType: $tripType, ')
          ..write('climate: $climate, ')
          ..write('travelerCount: $travelerCount, ')
          ..write('homeCurrency: $homeCurrency, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('themeStyle: $themeStyle, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TravelersTable extends Travelers
    with TableInfo<$TravelersTable, Traveler> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TravelersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shareWeightMeta = const VerificationMeta(
    'shareWeight',
  );
  @override
  late final GeneratedColumn<double> shareWeight = GeneratedColumn<double>(
    'share_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSelfUserMeta = const VerificationMeta(
    'isSelfUser',
  );
  @override
  late final GeneratedColumn<bool> isSelfUser = GeneratedColumn<bool>(
    'is_self_user',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_self_user" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    name,
    shareWeight,
    colorHex,
    isSelfUser,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'travelers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Traveler> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('share_weight')) {
      context.handle(
        _shareWeightMeta,
        shareWeight.isAcceptableOrUnknown(
          data['share_weight']!,
          _shareWeightMeta,
        ),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('is_self_user')) {
      context.handle(
        _isSelfUserMeta,
        isSelfUser.isAcceptableOrUnknown(
          data['is_self_user']!,
          _isSelfUserMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Traveler map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Traveler(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      shareWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}share_weight'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      ),
      isSelfUser: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_self_user'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $TravelersTable createAlias(String alias) {
    return $TravelersTable(attachedDatabase, alias);
  }
}

class Traveler extends DataClass implements Insertable<Traveler> {
  final String id;
  final String tripId;
  final String name;
  final double shareWeight;
  final String? colorHex;
  final bool isSelfUser;
  final int sortOrder;
  const Traveler({
    required this.id,
    required this.tripId,
    required this.name,
    required this.shareWeight,
    this.colorHex,
    required this.isSelfUser,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['name'] = Variable<String>(name);
    map['share_weight'] = Variable<double>(shareWeight);
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<String>(colorHex);
    }
    map['is_self_user'] = Variable<bool>(isSelfUser);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  TravelersCompanion toCompanion(bool nullToAbsent) {
    return TravelersCompanion(
      id: Value(id),
      tripId: Value(tripId),
      name: Value(name),
      shareWeight: Value(shareWeight),
      colorHex: colorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(colorHex),
      isSelfUser: Value(isSelfUser),
      sortOrder: Value(sortOrder),
    );
  }

  factory Traveler.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Traveler(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      name: serializer.fromJson<String>(json['name']),
      shareWeight: serializer.fromJson<double>(json['shareWeight']),
      colorHex: serializer.fromJson<String?>(json['colorHex']),
      isSelfUser: serializer.fromJson<bool>(json['isSelfUser']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'name': serializer.toJson<String>(name),
      'shareWeight': serializer.toJson<double>(shareWeight),
      'colorHex': serializer.toJson<String?>(colorHex),
      'isSelfUser': serializer.toJson<bool>(isSelfUser),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Traveler copyWith({
    String? id,
    String? tripId,
    String? name,
    double? shareWeight,
    Value<String?> colorHex = const Value.absent(),
    bool? isSelfUser,
    int? sortOrder,
  }) => Traveler(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    name: name ?? this.name,
    shareWeight: shareWeight ?? this.shareWeight,
    colorHex: colorHex.present ? colorHex.value : this.colorHex,
    isSelfUser: isSelfUser ?? this.isSelfUser,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Traveler copyWithCompanion(TravelersCompanion data) {
    return Traveler(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      name: data.name.present ? data.name.value : this.name,
      shareWeight: data.shareWeight.present
          ? data.shareWeight.value
          : this.shareWeight,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      isSelfUser: data.isSelfUser.present
          ? data.isSelfUser.value
          : this.isSelfUser,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Traveler(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('shareWeight: $shareWeight, ')
          ..write('colorHex: $colorHex, ')
          ..write('isSelfUser: $isSelfUser, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    name,
    shareWeight,
    colorHex,
    isSelfUser,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Traveler &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.name == this.name &&
          other.shareWeight == this.shareWeight &&
          other.colorHex == this.colorHex &&
          other.isSelfUser == this.isSelfUser &&
          other.sortOrder == this.sortOrder);
}

class TravelersCompanion extends UpdateCompanion<Traveler> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> name;
  final Value<double> shareWeight;
  final Value<String?> colorHex;
  final Value<bool> isSelfUser;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const TravelersCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.name = const Value.absent(),
    this.shareWeight = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isSelfUser = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TravelersCompanion.insert({
    required String id,
    required String tripId,
    required String name,
    this.shareWeight = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isSelfUser = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       name = Value(name);
  static Insertable<Traveler> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? name,
    Expression<double>? shareWeight,
    Expression<String>? colorHex,
    Expression<bool>? isSelfUser,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (name != null) 'name': name,
      if (shareWeight != null) 'share_weight': shareWeight,
      if (colorHex != null) 'color_hex': colorHex,
      if (isSelfUser != null) 'is_self_user': isSelfUser,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TravelersCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? name,
    Value<double>? shareWeight,
    Value<String?>? colorHex,
    Value<bool>? isSelfUser,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return TravelersCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      shareWeight: shareWeight ?? this.shareWeight,
      colorHex: colorHex ?? this.colorHex,
      isSelfUser: isSelfUser ?? this.isSelfUser,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (shareWeight.present) {
      map['share_weight'] = Variable<double>(shareWeight.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (isSelfUser.present) {
      map['is_self_user'] = Variable<bool>(isSelfUser.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TravelersCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('shareWeight: $shareWeight, ')
          ..write('colorHex: $colorHex, ')
          ..write('isSelfUser: $isSelfUser, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PackingCategoriesTable extends PackingCategories
    with TableInfo<$PackingCategoriesTable, PackingCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PackingCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('category'),
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconKey,
    colorHex,
    isSystem,
    isHidden,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'packing_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<PackingCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PackingCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PackingCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      ),
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $PackingCategoriesTable createAlias(String alias) {
    return $PackingCategoriesTable(attachedDatabase, alias);
  }
}

class PackingCategory extends DataClass implements Insertable<PackingCategory> {
  final String id;
  final String name;
  final String iconKey;
  final String? colorHex;
  final bool isSystem;
  final bool isHidden;
  final int sortOrder;
  const PackingCategory({
    required this.id,
    required this.name,
    required this.iconKey,
    this.colorHex,
    required this.isSystem,
    required this.isHidden,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_key'] = Variable<String>(iconKey);
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<String>(colorHex);
    }
    map['is_system'] = Variable<bool>(isSystem);
    map['is_hidden'] = Variable<bool>(isHidden);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PackingCategoriesCompanion toCompanion(bool nullToAbsent) {
    return PackingCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      iconKey: Value(iconKey),
      colorHex: colorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(colorHex),
      isSystem: Value(isSystem),
      isHidden: Value(isHidden),
      sortOrder: Value(sortOrder),
    );
  }

  factory PackingCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PackingCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      colorHex: serializer.fromJson<String?>(json['colorHex']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconKey': serializer.toJson<String>(iconKey),
      'colorHex': serializer.toJson<String?>(colorHex),
      'isSystem': serializer.toJson<bool>(isSystem),
      'isHidden': serializer.toJson<bool>(isHidden),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  PackingCategory copyWith({
    String? id,
    String? name,
    String? iconKey,
    Value<String?> colorHex = const Value.absent(),
    bool? isSystem,
    bool? isHidden,
    int? sortOrder,
  }) => PackingCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    iconKey: iconKey ?? this.iconKey,
    colorHex: colorHex.present ? colorHex.value : this.colorHex,
    isSystem: isSystem ?? this.isSystem,
    isHidden: isHidden ?? this.isHidden,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  PackingCategory copyWithCompanion(PackingCategoriesCompanion data) {
    return PackingCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PackingCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorHex: $colorHex, ')
          ..write('isSystem: $isSystem, ')
          ..write('isHidden: $isHidden, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, iconKey, colorHex, isSystem, isHidden, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PackingCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconKey == this.iconKey &&
          other.colorHex == this.colorHex &&
          other.isSystem == this.isSystem &&
          other.isHidden == this.isHidden &&
          other.sortOrder == this.sortOrder);
}

class PackingCategoriesCompanion extends UpdateCompanion<PackingCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconKey;
  final Value<String?> colorHex;
  final Value<bool> isSystem;
  final Value<bool> isHidden;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const PackingCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PackingCategoriesCompanion.insert({
    required String id,
    required String name,
    this.iconKey = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<PackingCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconKey,
    Expression<String>? colorHex,
    Expression<bool>? isSystem,
    Expression<bool>? isHidden,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconKey != null) 'icon_key': iconKey,
      if (colorHex != null) 'color_hex': colorHex,
      if (isSystem != null) 'is_system': isSystem,
      if (isHidden != null) 'is_hidden': isHidden,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PackingCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? iconKey,
    Value<String?>? colorHex,
    Value<bool>? isSystem,
    Value<bool>? isHidden,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return PackingCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorHex: colorHex ?? this.colorHex,
      isSystem: isSystem ?? this.isSystem,
      isHidden: isHidden ?? this.isHidden,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PackingCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorHex: $colorHex, ')
          ..write('isSystem: $isSystem, ')
          ..write('isHidden: $isHidden, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BagsTable extends Bags with TableInfo<$BagsTable, Bag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BagType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(BagType.hold.name),
      ).withConverter<BagType>($BagsTable.$convertertype);
  static const VerificationMeta _tareWeightGramsMeta = const VerificationMeta(
    'tareWeightGrams',
  );
  @override
  late final GeneratedColumn<int> tareWeightGrams = GeneratedColumn<int>(
    'tare_weight_grams',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxWeightGramsMeta = const VerificationMeta(
    'maxWeightGrams',
  );
  @override
  late final GeneratedColumn<int> maxWeightGrams = GeneratedColumn<int>(
    'max_weight_grams',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    name,
    type,
    tareWeightGrams,
    maxWeightGrams,
    colorHex,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('tare_weight_grams')) {
      context.handle(
        _tareWeightGramsMeta,
        tareWeightGrams.isAcceptableOrUnknown(
          data['tare_weight_grams']!,
          _tareWeightGramsMeta,
        ),
      );
    }
    if (data.containsKey('max_weight_grams')) {
      context.handle(
        _maxWeightGramsMeta,
        maxWeightGrams.isAcceptableOrUnknown(
          data['max_weight_grams']!,
          _maxWeightGramsMeta,
        ),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $BagsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      tareWeightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tare_weight_grams'],
      )!,
      maxWeightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_weight_grams'],
      ),
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $BagsTable createAlias(String alias) {
    return $BagsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BagType, String, String> $convertertype =
      const EnumNameConverter<BagType>(BagType.values);
}

class Bag extends DataClass implements Insertable<Bag> {
  final String id;
  final String tripId;
  final String name;
  final BagType type;
  final int tareWeightGrams;
  final int? maxWeightGrams;
  final String? colorHex;
  final int sortOrder;
  const Bag({
    required this.id,
    required this.tripId,
    required this.name,
    required this.type,
    required this.tareWeightGrams,
    this.maxWeightGrams,
    this.colorHex,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>($BagsTable.$convertertype.toSql(type));
    }
    map['tare_weight_grams'] = Variable<int>(tareWeightGrams);
    if (!nullToAbsent || maxWeightGrams != null) {
      map['max_weight_grams'] = Variable<int>(maxWeightGrams);
    }
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<String>(colorHex);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  BagsCompanion toCompanion(bool nullToAbsent) {
    return BagsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      name: Value(name),
      type: Value(type),
      tareWeightGrams: Value(tareWeightGrams),
      maxWeightGrams: maxWeightGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(maxWeightGrams),
      colorHex: colorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(colorHex),
      sortOrder: Value(sortOrder),
    );
  }

  factory Bag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bag(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      name: serializer.fromJson<String>(json['name']),
      type: $BagsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      tareWeightGrams: serializer.fromJson<int>(json['tareWeightGrams']),
      maxWeightGrams: serializer.fromJson<int?>(json['maxWeightGrams']),
      colorHex: serializer.fromJson<String?>(json['colorHex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>($BagsTable.$convertertype.toJson(type)),
      'tareWeightGrams': serializer.toJson<int>(tareWeightGrams),
      'maxWeightGrams': serializer.toJson<int?>(maxWeightGrams),
      'colorHex': serializer.toJson<String?>(colorHex),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Bag copyWith({
    String? id,
    String? tripId,
    String? name,
    BagType? type,
    int? tareWeightGrams,
    Value<int?> maxWeightGrams = const Value.absent(),
    Value<String?> colorHex = const Value.absent(),
    int? sortOrder,
  }) => Bag(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    name: name ?? this.name,
    type: type ?? this.type,
    tareWeightGrams: tareWeightGrams ?? this.tareWeightGrams,
    maxWeightGrams: maxWeightGrams.present
        ? maxWeightGrams.value
        : this.maxWeightGrams,
    colorHex: colorHex.present ? colorHex.value : this.colorHex,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Bag copyWithCompanion(BagsCompanion data) {
    return Bag(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      tareWeightGrams: data.tareWeightGrams.present
          ? data.tareWeightGrams.value
          : this.tareWeightGrams,
      maxWeightGrams: data.maxWeightGrams.present
          ? data.maxWeightGrams.value
          : this.maxWeightGrams,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bag(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('tareWeightGrams: $tareWeightGrams, ')
          ..write('maxWeightGrams: $maxWeightGrams, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    name,
    type,
    tareWeightGrams,
    maxWeightGrams,
    colorHex,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bag &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.name == this.name &&
          other.type == this.type &&
          other.tareWeightGrams == this.tareWeightGrams &&
          other.maxWeightGrams == this.maxWeightGrams &&
          other.colorHex == this.colorHex &&
          other.sortOrder == this.sortOrder);
}

class BagsCompanion extends UpdateCompanion<Bag> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> name;
  final Value<BagType> type;
  final Value<int> tareWeightGrams;
  final Value<int?> maxWeightGrams;
  final Value<String?> colorHex;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const BagsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.tareWeightGrams = const Value.absent(),
    this.maxWeightGrams = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BagsCompanion.insert({
    required String id,
    required String tripId,
    required String name,
    this.type = const Value.absent(),
    this.tareWeightGrams = const Value.absent(),
    this.maxWeightGrams = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       name = Value(name);
  static Insertable<Bag> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? tareWeightGrams,
    Expression<int>? maxWeightGrams,
    Expression<String>? colorHex,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (tareWeightGrams != null) 'tare_weight_grams': tareWeightGrams,
      if (maxWeightGrams != null) 'max_weight_grams': maxWeightGrams,
      if (colorHex != null) 'color_hex': colorHex,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BagsCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? name,
    Value<BagType>? type,
    Value<int>? tareWeightGrams,
    Value<int?>? maxWeightGrams,
    Value<String?>? colorHex,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return BagsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      name: name ?? this.name,
      type: type ?? this.type,
      tareWeightGrams: tareWeightGrams ?? this.tareWeightGrams,
      maxWeightGrams: maxWeightGrams ?? this.maxWeightGrams,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $BagsTable.$convertertype.toSql(type.value),
      );
    }
    if (tareWeightGrams.present) {
      map['tare_weight_grams'] = Variable<int>(tareWeightGrams.value);
    }
    if (maxWeightGrams.present) {
      map['max_weight_grams'] = Variable<int>(maxWeightGrams.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BagsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('tareWeightGrams: $tareWeightGrams, ')
          ..write('maxWeightGrams: $maxWeightGrams, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PackingItemsTable extends PackingItems
    with TableInfo<$PackingItemsTable, PackingItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PackingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES packing_categories (id)',
    ),
  );
  static const VerificationMeta _bagIdMeta = const VerificationMeta('bagId');
  @override
  late final GeneratedColumn<String> bagId = GeneratedColumn<String>(
    'bag_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bags (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _packedCountMeta = const VerificationMeta(
    'packedCount',
  );
  @override
  late final GeneratedColumn<int> packedCount = GeneratedColumn<int>(
    'packed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _unitWeightGramsMeta = const VerificationMeta(
    'unitWeightGrams',
  );
  @override
  late final GeneratedColumn<int> unitWeightGrams = GeneratedColumn<int>(
    'unit_weight_grams',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEssentialMeta = const VerificationMeta(
    'isEssential',
  );
  @override
  late final GeneratedColumn<bool> isEssential = GeneratedColumn<bool>(
    'is_essential',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_essential" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    categoryId,
    bagId,
    name,
    quantity,
    packedCount,
    unitWeightGrams,
    isEssential,
    notes,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'packing_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PackingItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('bag_id')) {
      context.handle(
        _bagIdMeta,
        bagId.isAcceptableOrUnknown(data['bag_id']!, _bagIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('packed_count')) {
      context.handle(
        _packedCountMeta,
        packedCount.isAcceptableOrUnknown(
          data['packed_count']!,
          _packedCountMeta,
        ),
      );
    }
    if (data.containsKey('unit_weight_grams')) {
      context.handle(
        _unitWeightGramsMeta,
        unitWeightGrams.isAcceptableOrUnknown(
          data['unit_weight_grams']!,
          _unitWeightGramsMeta,
        ),
      );
    }
    if (data.containsKey('is_essential')) {
      context.handle(
        _isEssentialMeta,
        isEssential.isAcceptableOrUnknown(
          data['is_essential']!,
          _isEssentialMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PackingItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PackingItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      bagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bag_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      packedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}packed_count'],
      )!,
      unitWeightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_weight_grams'],
      ),
      isEssential: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_essential'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PackingItemsTable createAlias(String alias) {
    return $PackingItemsTable(attachedDatabase, alias);
  }
}

class PackingItem extends DataClass implements Insertable<PackingItem> {
  final String id;
  final String tripId;
  final String categoryId;
  final String? bagId;
  final String name;
  final int quantity;
  final int packedCount;
  final int? unitWeightGrams;
  final bool isEssential;
  final String? notes;
  final int sortOrder;
  final DateTime createdAt;
  const PackingItem({
    required this.id,
    required this.tripId,
    required this.categoryId,
    this.bagId,
    required this.name,
    required this.quantity,
    required this.packedCount,
    this.unitWeightGrams,
    required this.isEssential,
    this.notes,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || bagId != null) {
      map['bag_id'] = Variable<String>(bagId);
    }
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<int>(quantity);
    map['packed_count'] = Variable<int>(packedCount);
    if (!nullToAbsent || unitWeightGrams != null) {
      map['unit_weight_grams'] = Variable<int>(unitWeightGrams);
    }
    map['is_essential'] = Variable<bool>(isEssential);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PackingItemsCompanion toCompanion(bool nullToAbsent) {
    return PackingItemsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      categoryId: Value(categoryId),
      bagId: bagId == null && nullToAbsent
          ? const Value.absent()
          : Value(bagId),
      name: Value(name),
      quantity: Value(quantity),
      packedCount: Value(packedCount),
      unitWeightGrams: unitWeightGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(unitWeightGrams),
      isEssential: Value(isEssential),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory PackingItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PackingItem(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      bagId: serializer.fromJson<String?>(json['bagId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<int>(json['quantity']),
      packedCount: serializer.fromJson<int>(json['packedCount']),
      unitWeightGrams: serializer.fromJson<int?>(json['unitWeightGrams']),
      isEssential: serializer.fromJson<bool>(json['isEssential']),
      notes: serializer.fromJson<String?>(json['notes']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'categoryId': serializer.toJson<String>(categoryId),
      'bagId': serializer.toJson<String?>(bagId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<int>(quantity),
      'packedCount': serializer.toJson<int>(packedCount),
      'unitWeightGrams': serializer.toJson<int?>(unitWeightGrams),
      'isEssential': serializer.toJson<bool>(isEssential),
      'notes': serializer.toJson<String?>(notes),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PackingItem copyWith({
    String? id,
    String? tripId,
    String? categoryId,
    Value<String?> bagId = const Value.absent(),
    String? name,
    int? quantity,
    int? packedCount,
    Value<int?> unitWeightGrams = const Value.absent(),
    bool? isEssential,
    Value<String?> notes = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
  }) => PackingItem(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    categoryId: categoryId ?? this.categoryId,
    bagId: bagId.present ? bagId.value : this.bagId,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    packedCount: packedCount ?? this.packedCount,
    unitWeightGrams: unitWeightGrams.present
        ? unitWeightGrams.value
        : this.unitWeightGrams,
    isEssential: isEssential ?? this.isEssential,
    notes: notes.present ? notes.value : this.notes,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  PackingItem copyWithCompanion(PackingItemsCompanion data) {
    return PackingItem(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      bagId: data.bagId.present ? data.bagId.value : this.bagId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      packedCount: data.packedCount.present
          ? data.packedCount.value
          : this.packedCount,
      unitWeightGrams: data.unitWeightGrams.present
          ? data.unitWeightGrams.value
          : this.unitWeightGrams,
      isEssential: data.isEssential.present
          ? data.isEssential.value
          : this.isEssential,
      notes: data.notes.present ? data.notes.value : this.notes,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PackingItem(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('categoryId: $categoryId, ')
          ..write('bagId: $bagId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('packedCount: $packedCount, ')
          ..write('unitWeightGrams: $unitWeightGrams, ')
          ..write('isEssential: $isEssential, ')
          ..write('notes: $notes, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    categoryId,
    bagId,
    name,
    quantity,
    packedCount,
    unitWeightGrams,
    isEssential,
    notes,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PackingItem &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.categoryId == this.categoryId &&
          other.bagId == this.bagId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.packedCount == this.packedCount &&
          other.unitWeightGrams == this.unitWeightGrams &&
          other.isEssential == this.isEssential &&
          other.notes == this.notes &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class PackingItemsCompanion extends UpdateCompanion<PackingItem> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> categoryId;
  final Value<String?> bagId;
  final Value<String> name;
  final Value<int> quantity;
  final Value<int> packedCount;
  final Value<int?> unitWeightGrams;
  final Value<bool> isEssential;
  final Value<String?> notes;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PackingItemsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.bagId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.packedCount = const Value.absent(),
    this.unitWeightGrams = const Value.absent(),
    this.isEssential = const Value.absent(),
    this.notes = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PackingItemsCompanion.insert({
    required String id,
    required String tripId,
    required String categoryId,
    this.bagId = const Value.absent(),
    required String name,
    this.quantity = const Value.absent(),
    this.packedCount = const Value.absent(),
    this.unitWeightGrams = const Value.absent(),
    this.isEssential = const Value.absent(),
    this.notes = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       categoryId = Value(categoryId),
       name = Value(name);
  static Insertable<PackingItem> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? categoryId,
    Expression<String>? bagId,
    Expression<String>? name,
    Expression<int>? quantity,
    Expression<int>? packedCount,
    Expression<int>? unitWeightGrams,
    Expression<bool>? isEssential,
    Expression<String>? notes,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (categoryId != null) 'category_id': categoryId,
      if (bagId != null) 'bag_id': bagId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (packedCount != null) 'packed_count': packedCount,
      if (unitWeightGrams != null) 'unit_weight_grams': unitWeightGrams,
      if (isEssential != null) 'is_essential': isEssential,
      if (notes != null) 'notes': notes,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PackingItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? categoryId,
    Value<String?>? bagId,
    Value<String>? name,
    Value<int>? quantity,
    Value<int>? packedCount,
    Value<int?>? unitWeightGrams,
    Value<bool>? isEssential,
    Value<String?>? notes,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PackingItemsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      categoryId: categoryId ?? this.categoryId,
      bagId: bagId ?? this.bagId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      packedCount: packedCount ?? this.packedCount,
      unitWeightGrams: unitWeightGrams ?? this.unitWeightGrams,
      isEssential: isEssential ?? this.isEssential,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (bagId.present) {
      map['bag_id'] = Variable<String>(bagId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (packedCount.present) {
      map['packed_count'] = Variable<int>(packedCount.value);
    }
    if (unitWeightGrams.present) {
      map['unit_weight_grams'] = Variable<int>(unitWeightGrams.value);
    }
    if (isEssential.present) {
      map['is_essential'] = Variable<bool>(isEssential.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PackingItemsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('categoryId: $categoryId, ')
          ..write('bagId: $bagId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('packedCount: $packedCount, ')
          ..write('unitWeightGrams: $unitWeightGrams, ')
          ..write('isEssential: $isEssential, ')
          ..write('notes: $notes, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PackingTemplatesTable extends PackingTemplates
    with TableInfo<$PackingTemplatesTable, PackingTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PackingTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TripType?, String> tripType =
      GeneratedColumn<String>(
        'trip_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<TripType?>($PackingTemplatesTable.$convertertripTypen);
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    tripType,
    isBuiltIn,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'packing_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<PackingTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PackingTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PackingTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      tripType: $PackingTemplatesTable.$convertertripTypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}trip_type'],
        ),
      ),
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PackingTemplatesTable createAlias(String alias) {
    return $PackingTemplatesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TripType, String, String> $convertertripType =
      const EnumNameConverter<TripType>(TripType.values);
  static JsonTypeConverter2<TripType?, String?, String?> $convertertripTypen =
      JsonTypeConverter2.asNullable($convertertripType);
}

class PackingTemplate extends DataClass implements Insertable<PackingTemplate> {
  final String id;
  final String name;
  final String? description;
  final TripType? tripType;
  final bool isBuiltIn;
  final DateTime createdAt;
  const PackingTemplate({
    required this.id,
    required this.name,
    this.description,
    this.tripType,
    required this.isBuiltIn,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || tripType != null) {
      map['trip_type'] = Variable<String>(
        $PackingTemplatesTable.$convertertripTypen.toSql(tripType),
      );
    }
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PackingTemplatesCompanion toCompanion(bool nullToAbsent) {
    return PackingTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      tripType: tripType == null && nullToAbsent
          ? const Value.absent()
          : Value(tripType),
      isBuiltIn: Value(isBuiltIn),
      createdAt: Value(createdAt),
    );
  }

  factory PackingTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PackingTemplate(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      tripType: $PackingTemplatesTable.$convertertripTypen.fromJson(
        serializer.fromJson<String?>(json['tripType']),
      ),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'tripType': serializer.toJson<String?>(
        $PackingTemplatesTable.$convertertripTypen.toJson(tripType),
      ),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PackingTemplate copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<TripType?> tripType = const Value.absent(),
    bool? isBuiltIn,
    DateTime? createdAt,
  }) => PackingTemplate(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    tripType: tripType.present ? tripType.value : this.tripType,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    createdAt: createdAt ?? this.createdAt,
  );
  PackingTemplate copyWithCompanion(PackingTemplatesCompanion data) {
    return PackingTemplate(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      tripType: data.tripType.present ? data.tripType.value : this.tripType,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PackingTemplate(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('tripType: $tripType, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, tripType, isBuiltIn, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PackingTemplate &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.tripType == this.tripType &&
          other.isBuiltIn == this.isBuiltIn &&
          other.createdAt == this.createdAt);
}

class PackingTemplatesCompanion extends UpdateCompanion<PackingTemplate> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<TripType?> tripType;
  final Value<bool> isBuiltIn;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PackingTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.tripType = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PackingTemplatesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.tripType = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<PackingTemplate> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? tripType,
    Expression<bool>? isBuiltIn,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (tripType != null) 'trip_type': tripType,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PackingTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<TripType?>? tripType,
    Value<bool>? isBuiltIn,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PackingTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tripType: tripType ?? this.tripType,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (tripType.present) {
      map['trip_type'] = Variable<String>(
        $PackingTemplatesTable.$convertertripTypen.toSql(tripType.value),
      );
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PackingTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('tripType: $tripType, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PackingTemplateItemsTable extends PackingTemplateItems
    with TableInfo<$PackingTemplateItemsTable, PackingTemplateItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PackingTemplateItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES packing_templates (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseQuantityMeta = const VerificationMeta(
    'baseQuantity',
  );
  @override
  late final GeneratedColumn<int> baseQuantity = GeneratedColumn<int>(
    'base_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _unitWeightGramsMeta = const VerificationMeta(
    'unitWeightGrams',
  );
  @override
  late final GeneratedColumn<int> unitWeightGrams = GeneratedColumn<int>(
    'unit_weight_grams',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEssentialMeta = const VerificationMeta(
    'isEssential',
  );
  @override
  late final GeneratedColumn<bool> isEssential = GeneratedColumn<bool>(
    'is_essential',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_essential" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateId,
    categoryName,
    name,
    baseQuantity,
    unitWeightGrams,
    isEssential,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'packing_template_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PackingTemplateItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryNameMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('base_quantity')) {
      context.handle(
        _baseQuantityMeta,
        baseQuantity.isAcceptableOrUnknown(
          data['base_quantity']!,
          _baseQuantityMeta,
        ),
      );
    }
    if (data.containsKey('unit_weight_grams')) {
      context.handle(
        _unitWeightGramsMeta,
        unitWeightGrams.isAcceptableOrUnknown(
          data['unit_weight_grams']!,
          _unitWeightGramsMeta,
        ),
      );
    }
    if (data.containsKey('is_essential')) {
      context.handle(
        _isEssentialMeta,
        isEssential.isAcceptableOrUnknown(
          data['is_essential']!,
          _isEssentialMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PackingTemplateItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PackingTemplateItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      baseQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_quantity'],
      )!,
      unitWeightGrams: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_weight_grams'],
      ),
      isEssential: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_essential'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $PackingTemplateItemsTable createAlias(String alias) {
    return $PackingTemplateItemsTable(attachedDatabase, alias);
  }
}

class PackingTemplateItem extends DataClass
    implements Insertable<PackingTemplateItem> {
  final String id;
  final String templateId;
  final String categoryName;
  final String name;
  final int baseQuantity;
  final int? unitWeightGrams;
  final bool isEssential;
  final int sortOrder;
  const PackingTemplateItem({
    required this.id,
    required this.templateId,
    required this.categoryName,
    required this.name,
    required this.baseQuantity,
    this.unitWeightGrams,
    required this.isEssential,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['category_name'] = Variable<String>(categoryName);
    map['name'] = Variable<String>(name);
    map['base_quantity'] = Variable<int>(baseQuantity);
    if (!nullToAbsent || unitWeightGrams != null) {
      map['unit_weight_grams'] = Variable<int>(unitWeightGrams);
    }
    map['is_essential'] = Variable<bool>(isEssential);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PackingTemplateItemsCompanion toCompanion(bool nullToAbsent) {
    return PackingTemplateItemsCompanion(
      id: Value(id),
      templateId: Value(templateId),
      categoryName: Value(categoryName),
      name: Value(name),
      baseQuantity: Value(baseQuantity),
      unitWeightGrams: unitWeightGrams == null && nullToAbsent
          ? const Value.absent()
          : Value(unitWeightGrams),
      isEssential: Value(isEssential),
      sortOrder: Value(sortOrder),
    );
  }

  factory PackingTemplateItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PackingTemplateItem(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      categoryName: serializer.fromJson<String>(json['categoryName']),
      name: serializer.fromJson<String>(json['name']),
      baseQuantity: serializer.fromJson<int>(json['baseQuantity']),
      unitWeightGrams: serializer.fromJson<int?>(json['unitWeightGrams']),
      isEssential: serializer.fromJson<bool>(json['isEssential']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'categoryName': serializer.toJson<String>(categoryName),
      'name': serializer.toJson<String>(name),
      'baseQuantity': serializer.toJson<int>(baseQuantity),
      'unitWeightGrams': serializer.toJson<int?>(unitWeightGrams),
      'isEssential': serializer.toJson<bool>(isEssential),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  PackingTemplateItem copyWith({
    String? id,
    String? templateId,
    String? categoryName,
    String? name,
    int? baseQuantity,
    Value<int?> unitWeightGrams = const Value.absent(),
    bool? isEssential,
    int? sortOrder,
  }) => PackingTemplateItem(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    categoryName: categoryName ?? this.categoryName,
    name: name ?? this.name,
    baseQuantity: baseQuantity ?? this.baseQuantity,
    unitWeightGrams: unitWeightGrams.present
        ? unitWeightGrams.value
        : this.unitWeightGrams,
    isEssential: isEssential ?? this.isEssential,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  PackingTemplateItem copyWithCompanion(PackingTemplateItemsCompanion data) {
    return PackingTemplateItem(
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      name: data.name.present ? data.name.value : this.name,
      baseQuantity: data.baseQuantity.present
          ? data.baseQuantity.value
          : this.baseQuantity,
      unitWeightGrams: data.unitWeightGrams.present
          ? data.unitWeightGrams.value
          : this.unitWeightGrams,
      isEssential: data.isEssential.present
          ? data.isEssential.value
          : this.isEssential,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PackingTemplateItem(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('categoryName: $categoryName, ')
          ..write('name: $name, ')
          ..write('baseQuantity: $baseQuantity, ')
          ..write('unitWeightGrams: $unitWeightGrams, ')
          ..write('isEssential: $isEssential, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    templateId,
    categoryName,
    name,
    baseQuantity,
    unitWeightGrams,
    isEssential,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PackingTemplateItem &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.categoryName == this.categoryName &&
          other.name == this.name &&
          other.baseQuantity == this.baseQuantity &&
          other.unitWeightGrams == this.unitWeightGrams &&
          other.isEssential == this.isEssential &&
          other.sortOrder == this.sortOrder);
}

class PackingTemplateItemsCompanion
    extends UpdateCompanion<PackingTemplateItem> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<String> categoryName;
  final Value<String> name;
  final Value<int> baseQuantity;
  final Value<int?> unitWeightGrams;
  final Value<bool> isEssential;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const PackingTemplateItemsCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.name = const Value.absent(),
    this.baseQuantity = const Value.absent(),
    this.unitWeightGrams = const Value.absent(),
    this.isEssential = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PackingTemplateItemsCompanion.insert({
    required String id,
    required String templateId,
    required String categoryName,
    required String name,
    this.baseQuantity = const Value.absent(),
    this.unitWeightGrams = const Value.absent(),
    this.isEssential = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       templateId = Value(templateId),
       categoryName = Value(categoryName),
       name = Value(name);
  static Insertable<PackingTemplateItem> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? categoryName,
    Expression<String>? name,
    Expression<int>? baseQuantity,
    Expression<int>? unitWeightGrams,
    Expression<bool>? isEssential,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (categoryName != null) 'category_name': categoryName,
      if (name != null) 'name': name,
      if (baseQuantity != null) 'base_quantity': baseQuantity,
      if (unitWeightGrams != null) 'unit_weight_grams': unitWeightGrams,
      if (isEssential != null) 'is_essential': isEssential,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PackingTemplateItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? templateId,
    Value<String>? categoryName,
    Value<String>? name,
    Value<int>? baseQuantity,
    Value<int?>? unitWeightGrams,
    Value<bool>? isEssential,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return PackingTemplateItemsCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      categoryName: categoryName ?? this.categoryName,
      name: name ?? this.name,
      baseQuantity: baseQuantity ?? this.baseQuantity,
      unitWeightGrams: unitWeightGrams ?? this.unitWeightGrams,
      isEssential: isEssential ?? this.isEssential,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (baseQuantity.present) {
      map['base_quantity'] = Variable<int>(baseQuantity.value);
    }
    if (unitWeightGrams.present) {
      map['unit_weight_grams'] = Variable<int>(unitWeightGrams.value);
    }
    if (isEssential.present) {
      map['is_essential'] = Variable<bool>(isEssential.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PackingTemplateItemsCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('categoryName: $categoryName, ')
          ..write('name: $name, ')
          ..write('baseQuantity: $baseQuantity, ')
          ..write('unitWeightGrams: $unitWeightGrams, ')
          ..write('isEssential: $isEssential, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FuelType, String> fuelType =
      GeneratedColumn<String>(
        'fuel_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(FuelType.petrol.name),
      ).withConverter<FuelType>($VehiclesTable.$converterfuelType);
  static const VerificationMeta _consumptionValueMeta = const VerificationMeta(
    'consumptionValue',
  );
  @override
  late final GeneratedColumn<double> consumptionValue = GeneratedColumn<double>(
    'consumption_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(6.5),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ConsumptionUnit, String>
  consumptionUnit = GeneratedColumn<String>(
    'consumption_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(ConsumptionUnit.lPer100km.name),
  ).withConverter<ConsumptionUnit>($VehiclesTable.$converterconsumptionUnit);
  static const VerificationMeta _tankCapacityMeta = const VerificationMeta(
    'tankCapacity',
  );
  @override
  late final GeneratedColumn<double> tankCapacity = GeneratedColumn<double>(
    'tank_capacity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plateMeta = const VerificationMeta('plate');
  @override
  late final GeneratedColumn<String> plate = GeneratedColumn<String>(
    'plate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    fuelType,
    consumptionValue,
    consumptionUnit,
    tankCapacity,
    plate,
    isDefault,
    isArchived,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vehicle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('consumption_value')) {
      context.handle(
        _consumptionValueMeta,
        consumptionValue.isAcceptableOrUnknown(
          data['consumption_value']!,
          _consumptionValueMeta,
        ),
      );
    }
    if (data.containsKey('tank_capacity')) {
      context.handle(
        _tankCapacityMeta,
        tankCapacity.isAcceptableOrUnknown(
          data['tank_capacity']!,
          _tankCapacityMeta,
        ),
      );
    }
    if (data.containsKey('plate')) {
      context.handle(
        _plateMeta,
        plate.isAcceptableOrUnknown(data['plate']!, _plateMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fuelType: $VehiclesTable.$converterfuelType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fuel_type'],
        )!,
      ),
      consumptionValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}consumption_value'],
      )!,
      consumptionUnit: $VehiclesTable.$converterconsumptionUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}consumption_unit'],
        )!,
      ),
      tankCapacity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tank_capacity'],
      ),
      plate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plate'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FuelType, String, String> $converterfuelType =
      const EnumNameConverter<FuelType>(FuelType.values);
  static JsonTypeConverter2<ConsumptionUnit, String, String>
  $converterconsumptionUnit = const EnumNameConverter<ConsumptionUnit>(
    ConsumptionUnit.values,
  );
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  final String id;
  final String name;
  final FuelType fuelType;
  final double consumptionValue;
  final ConsumptionUnit consumptionUnit;
  final double? tankCapacity;
  final String? plate;
  final bool isDefault;
  final bool isArchived;
  final DateTime createdAt;
  const Vehicle({
    required this.id,
    required this.name,
    required this.fuelType,
    required this.consumptionValue,
    required this.consumptionUnit,
    this.tankCapacity,
    this.plate,
    required this.isDefault,
    required this.isArchived,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['fuel_type'] = Variable<String>(
        $VehiclesTable.$converterfuelType.toSql(fuelType),
      );
    }
    map['consumption_value'] = Variable<double>(consumptionValue);
    {
      map['consumption_unit'] = Variable<String>(
        $VehiclesTable.$converterconsumptionUnit.toSql(consumptionUnit),
      );
    }
    if (!nullToAbsent || tankCapacity != null) {
      map['tank_capacity'] = Variable<double>(tankCapacity);
    }
    if (!nullToAbsent || plate != null) {
      map['plate'] = Variable<String>(plate);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      name: Value(name),
      fuelType: Value(fuelType),
      consumptionValue: Value(consumptionValue),
      consumptionUnit: Value(consumptionUnit),
      tankCapacity: tankCapacity == null && nullToAbsent
          ? const Value.absent()
          : Value(tankCapacity),
      plate: plate == null && nullToAbsent
          ? const Value.absent()
          : Value(plate),
      isDefault: Value(isDefault),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
    );
  }

  factory Vehicle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fuelType: $VehiclesTable.$converterfuelType.fromJson(
        serializer.fromJson<String>(json['fuelType']),
      ),
      consumptionValue: serializer.fromJson<double>(json['consumptionValue']),
      consumptionUnit: $VehiclesTable.$converterconsumptionUnit.fromJson(
        serializer.fromJson<String>(json['consumptionUnit']),
      ),
      tankCapacity: serializer.fromJson<double?>(json['tankCapacity']),
      plate: serializer.fromJson<String?>(json['plate']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'fuelType': serializer.toJson<String>(
        $VehiclesTable.$converterfuelType.toJson(fuelType),
      ),
      'consumptionValue': serializer.toJson<double>(consumptionValue),
      'consumptionUnit': serializer.toJson<String>(
        $VehiclesTable.$converterconsumptionUnit.toJson(consumptionUnit),
      ),
      'tankCapacity': serializer.toJson<double?>(tankCapacity),
      'plate': serializer.toJson<String?>(plate),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Vehicle copyWith({
    String? id,
    String? name,
    FuelType? fuelType,
    double? consumptionValue,
    ConsumptionUnit? consumptionUnit,
    Value<double?> tankCapacity = const Value.absent(),
    Value<String?> plate = const Value.absent(),
    bool? isDefault,
    bool? isArchived,
    DateTime? createdAt,
  }) => Vehicle(
    id: id ?? this.id,
    name: name ?? this.name,
    fuelType: fuelType ?? this.fuelType,
    consumptionValue: consumptionValue ?? this.consumptionValue,
    consumptionUnit: consumptionUnit ?? this.consumptionUnit,
    tankCapacity: tankCapacity.present ? tankCapacity.value : this.tankCapacity,
    plate: plate.present ? plate.value : this.plate,
    isDefault: isDefault ?? this.isDefault,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
  );
  Vehicle copyWithCompanion(VehiclesCompanion data) {
    return Vehicle(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fuelType: data.fuelType.present ? data.fuelType.value : this.fuelType,
      consumptionValue: data.consumptionValue.present
          ? data.consumptionValue.value
          : this.consumptionValue,
      consumptionUnit: data.consumptionUnit.present
          ? data.consumptionUnit.value
          : this.consumptionUnit,
      tankCapacity: data.tankCapacity.present
          ? data.tankCapacity.value
          : this.tankCapacity,
      plate: data.plate.present ? data.plate.value : this.plate,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fuelType: $fuelType, ')
          ..write('consumptionValue: $consumptionValue, ')
          ..write('consumptionUnit: $consumptionUnit, ')
          ..write('tankCapacity: $tankCapacity, ')
          ..write('plate: $plate, ')
          ..write('isDefault: $isDefault, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    fuelType,
    consumptionValue,
    consumptionUnit,
    tankCapacity,
    plate,
    isDefault,
    isArchived,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.id == this.id &&
          other.name == this.name &&
          other.fuelType == this.fuelType &&
          other.consumptionValue == this.consumptionValue &&
          other.consumptionUnit == this.consumptionUnit &&
          other.tankCapacity == this.tankCapacity &&
          other.plate == this.plate &&
          other.isDefault == this.isDefault &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<String> id;
  final Value<String> name;
  final Value<FuelType> fuelType;
  final Value<double> consumptionValue;
  final Value<ConsumptionUnit> consumptionUnit;
  final Value<double?> tankCapacity;
  final Value<String?> plate;
  final Value<bool> isDefault;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.consumptionValue = const Value.absent(),
    this.consumptionUnit = const Value.absent(),
    this.tankCapacity = const Value.absent(),
    this.plate = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehiclesCompanion.insert({
    required String id,
    required String name,
    this.fuelType = const Value.absent(),
    this.consumptionValue = const Value.absent(),
    this.consumptionUnit = const Value.absent(),
    this.tankCapacity = const Value.absent(),
    this.plate = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Vehicle> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? fuelType,
    Expression<double>? consumptionValue,
    Expression<String>? consumptionUnit,
    Expression<double>? tankCapacity,
    Expression<String>? plate,
    Expression<bool>? isDefault,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fuelType != null) 'fuel_type': fuelType,
      if (consumptionValue != null) 'consumption_value': consumptionValue,
      if (consumptionUnit != null) 'consumption_unit': consumptionUnit,
      if (tankCapacity != null) 'tank_capacity': tankCapacity,
      if (plate != null) 'plate': plate,
      if (isDefault != null) 'is_default': isDefault,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehiclesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<FuelType>? fuelType,
    Value<double>? consumptionValue,
    Value<ConsumptionUnit>? consumptionUnit,
    Value<double?>? tankCapacity,
    Value<String?>? plate,
    Value<bool>? isDefault,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fuelType: fuelType ?? this.fuelType,
      consumptionValue: consumptionValue ?? this.consumptionValue,
      consumptionUnit: consumptionUnit ?? this.consumptionUnit,
      tankCapacity: tankCapacity ?? this.tankCapacity,
      plate: plate ?? this.plate,
      isDefault: isDefault ?? this.isDefault,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fuelType.present) {
      map['fuel_type'] = Variable<String>(
        $VehiclesTable.$converterfuelType.toSql(fuelType.value),
      );
    }
    if (consumptionValue.present) {
      map['consumption_value'] = Variable<double>(consumptionValue.value);
    }
    if (consumptionUnit.present) {
      map['consumption_unit'] = Variable<String>(
        $VehiclesTable.$converterconsumptionUnit.toSql(consumptionUnit.value),
      );
    }
    if (tankCapacity.present) {
      map['tank_capacity'] = Variable<double>(tankCapacity.value);
    }
    if (plate.present) {
      map['plate'] = Variable<String>(plate.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fuelType: $fuelType, ')
          ..write('consumptionValue: $consumptionValue, ')
          ..write('consumptionUnit: $consumptionUnit, ')
          ..write('tankCapacity: $tankCapacity, ')
          ..write('plate: $plate, ')
          ..write('isDefault: $isDefault, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransportSegmentsTable extends TransportSegments
    with TableInfo<$TransportSegmentsTable, TransportSegment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransportSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sequenceIndexMeta = const VerificationMeta(
    'sequenceIndex',
  );
  @override
  late final GeneratedColumn<int> sequenceIndex = GeneratedColumn<int>(
    'sequence_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TransportMode, String> mode =
      GeneratedColumn<String>(
        'mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(TransportMode.car.name),
      ).withConverter<TransportMode>($TransportSegmentsTable.$convertermode);
  static const VerificationMeta _originLabelMeta = const VerificationMeta(
    'originLabel',
  );
  @override
  late final GeneratedColumn<String> originLabel = GeneratedColumn<String>(
    'origin_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _originLatMeta = const VerificationMeta(
    'originLat',
  );
  @override
  late final GeneratedColumn<double> originLat = GeneratedColumn<double>(
    'origin_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originLngMeta = const VerificationMeta(
    'originLng',
  );
  @override
  late final GeneratedColumn<double> originLng = GeneratedColumn<double>(
    'origin_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _destinationLabelMeta = const VerificationMeta(
    'destinationLabel',
  );
  @override
  late final GeneratedColumn<String> destinationLabel = GeneratedColumn<String>(
    'destination_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _destinationLatMeta = const VerificationMeta(
    'destinationLat',
  );
  @override
  late final GeneratedColumn<double> destinationLat = GeneratedColumn<double>(
    'destination_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _destinationLngMeta = const VerificationMeta(
    'destinationLng',
  );
  @override
  late final GeneratedColumn<double> destinationLng = GeneratedColumn<double>(
    'destination_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceKmMeta = const VerificationMeta(
    'distanceKm',
  );
  @override
  late final GeneratedColumn<double> distanceKm = GeneratedColumn<double>(
    'distance_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DistanceSource, String>
  distanceSource =
      GeneratedColumn<String>(
        'distance_source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(DistanceSource.manual.name),
      ).withConverter<DistanceSource>(
        $TransportSegmentsTable.$converterdistanceSource,
      );
  static const VerificationMeta _detourFactorMeta = const VerificationMeta(
    'detourFactor',
  );
  @override
  late final GeneratedColumn<double> detourFactor = GeneratedColumn<double>(
    'detour_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.3),
  );
  static const VerificationMeta _isRoundTripMeta = const VerificationMeta(
    'isRoundTrip',
  );
  @override
  late final GeneratedColumn<bool> isRoundTrip = GeneratedColumn<bool>(
    'is_round_trip',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_round_trip" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _departureAtMeta = const VerificationMeta(
    'departureAt',
  );
  @override
  late final GeneratedColumn<DateTime> departureAt = GeneratedColumn<DateTime>(
    'departure_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arrivalAtMeta = const VerificationMeta(
    'arrivalAt',
  );
  @override
  late final GeneratedColumn<DateTime> arrivalAt = GeneratedColumn<DateTime>(
    'arrival_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _consumptionSnapshotMeta =
      const VerificationMeta('consumptionSnapshot');
  @override
  late final GeneratedColumn<double> consumptionSnapshot =
      GeneratedColumn<double>(
        'consumption_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<ConsumptionUnit?, String>
  consumptionUnitSnapshot =
      GeneratedColumn<String>(
        'consumption_unit_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<ConsumptionUnit?>(
        $TransportSegmentsTable.$converterconsumptionUnitSnapshotn,
      );
  static const VerificationMeta _fuelPriceCentsSnapshotMeta =
      const VerificationMeta('fuelPriceCentsSnapshot');
  @override
  late final GeneratedColumn<int> fuelPriceCentsSnapshot = GeneratedColumn<int>(
    'fuel_price_cents_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _manualCostCentsMeta = const VerificationMeta(
    'manualCostCents',
  );
  @override
  late final GeneratedColumn<int> manualCostCents = GeneratedColumn<int>(
    'manual_cost_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _providerMeta = const VerificationMeta(
    'provider',
  );
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
    'provider',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookingRefMeta = const VerificationMeta(
    'bookingRef',
  );
  @override
  late final GeneratedColumn<String> bookingRef = GeneratedColumn<String>(
    'booking_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seatInfoMeta = const VerificationMeta(
    'seatInfo',
  );
  @override
  late final GeneratedColumn<String> seatInfo = GeneratedColumn<String>(
    'seat_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    sequenceIndex,
    mode,
    originLabel,
    originLat,
    originLng,
    destinationLabel,
    destinationLat,
    destinationLng,
    distanceKm,
    distanceSource,
    detourFactor,
    isRoundTrip,
    departureAt,
    arrivalAt,
    vehicleId,
    consumptionSnapshot,
    consumptionUnitSnapshot,
    fuelPriceCentsSnapshot,
    manualCostCents,
    provider,
    bookingRef,
    seatInfo,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transport_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransportSegment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('sequence_index')) {
      context.handle(
        _sequenceIndexMeta,
        sequenceIndex.isAcceptableOrUnknown(
          data['sequence_index']!,
          _sequenceIndexMeta,
        ),
      );
    }
    if (data.containsKey('origin_label')) {
      context.handle(
        _originLabelMeta,
        originLabel.isAcceptableOrUnknown(
          data['origin_label']!,
          _originLabelMeta,
        ),
      );
    }
    if (data.containsKey('origin_lat')) {
      context.handle(
        _originLatMeta,
        originLat.isAcceptableOrUnknown(data['origin_lat']!, _originLatMeta),
      );
    }
    if (data.containsKey('origin_lng')) {
      context.handle(
        _originLngMeta,
        originLng.isAcceptableOrUnknown(data['origin_lng']!, _originLngMeta),
      );
    }
    if (data.containsKey('destination_label')) {
      context.handle(
        _destinationLabelMeta,
        destinationLabel.isAcceptableOrUnknown(
          data['destination_label']!,
          _destinationLabelMeta,
        ),
      );
    }
    if (data.containsKey('destination_lat')) {
      context.handle(
        _destinationLatMeta,
        destinationLat.isAcceptableOrUnknown(
          data['destination_lat']!,
          _destinationLatMeta,
        ),
      );
    }
    if (data.containsKey('destination_lng')) {
      context.handle(
        _destinationLngMeta,
        destinationLng.isAcceptableOrUnknown(
          data['destination_lng']!,
          _destinationLngMeta,
        ),
      );
    }
    if (data.containsKey('distance_km')) {
      context.handle(
        _distanceKmMeta,
        distanceKm.isAcceptableOrUnknown(data['distance_km']!, _distanceKmMeta),
      );
    }
    if (data.containsKey('detour_factor')) {
      context.handle(
        _detourFactorMeta,
        detourFactor.isAcceptableOrUnknown(
          data['detour_factor']!,
          _detourFactorMeta,
        ),
      );
    }
    if (data.containsKey('is_round_trip')) {
      context.handle(
        _isRoundTripMeta,
        isRoundTrip.isAcceptableOrUnknown(
          data['is_round_trip']!,
          _isRoundTripMeta,
        ),
      );
    }
    if (data.containsKey('departure_at')) {
      context.handle(
        _departureAtMeta,
        departureAt.isAcceptableOrUnknown(
          data['departure_at']!,
          _departureAtMeta,
        ),
      );
    }
    if (data.containsKey('arrival_at')) {
      context.handle(
        _arrivalAtMeta,
        arrivalAt.isAcceptableOrUnknown(data['arrival_at']!, _arrivalAtMeta),
      );
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    }
    if (data.containsKey('consumption_snapshot')) {
      context.handle(
        _consumptionSnapshotMeta,
        consumptionSnapshot.isAcceptableOrUnknown(
          data['consumption_snapshot']!,
          _consumptionSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('fuel_price_cents_snapshot')) {
      context.handle(
        _fuelPriceCentsSnapshotMeta,
        fuelPriceCentsSnapshot.isAcceptableOrUnknown(
          data['fuel_price_cents_snapshot']!,
          _fuelPriceCentsSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('manual_cost_cents')) {
      context.handle(
        _manualCostCentsMeta,
        manualCostCents.isAcceptableOrUnknown(
          data['manual_cost_cents']!,
          _manualCostCentsMeta,
        ),
      );
    }
    if (data.containsKey('provider')) {
      context.handle(
        _providerMeta,
        provider.isAcceptableOrUnknown(data['provider']!, _providerMeta),
      );
    }
    if (data.containsKey('booking_ref')) {
      context.handle(
        _bookingRefMeta,
        bookingRef.isAcceptableOrUnknown(data['booking_ref']!, _bookingRefMeta),
      );
    }
    if (data.containsKey('seat_info')) {
      context.handle(
        _seatInfoMeta,
        seatInfo.isAcceptableOrUnknown(data['seat_info']!, _seatInfoMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransportSegment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransportSegment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      sequenceIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_index'],
      )!,
      mode: $TransportSegmentsTable.$convertermode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}mode'],
        )!,
      ),
      originLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_label'],
      )!,
      originLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}origin_lat'],
      ),
      originLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}origin_lng'],
      ),
      destinationLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination_label'],
      )!,
      destinationLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}destination_lat'],
      ),
      destinationLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}destination_lng'],
      ),
      distanceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_km'],
      ),
      distanceSource: $TransportSegmentsTable.$converterdistanceSource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}distance_source'],
        )!,
      ),
      detourFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}detour_factor'],
      )!,
      isRoundTrip: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_round_trip'],
      )!,
      departureAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}departure_at'],
      ),
      arrivalAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}arrival_at'],
      ),
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      ),
      consumptionSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}consumption_snapshot'],
      ),
      consumptionUnitSnapshot: $TransportSegmentsTable
          .$converterconsumptionUnitSnapshotn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}consumption_unit_snapshot'],
            ),
          ),
      fuelPriceCentsSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fuel_price_cents_snapshot'],
      ),
      manualCostCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manual_cost_cents'],
      ),
      provider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider'],
      ),
      bookingRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}booking_ref'],
      ),
      seatInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seat_info'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $TransportSegmentsTable createAlias(String alias) {
    return $TransportSegmentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransportMode, String, String> $convertermode =
      const EnumNameConverter<TransportMode>(TransportMode.values);
  static JsonTypeConverter2<DistanceSource, String, String>
  $converterdistanceSource = const EnumNameConverter<DistanceSource>(
    DistanceSource.values,
  );
  static JsonTypeConverter2<ConsumptionUnit, String, String>
  $converterconsumptionUnitSnapshot = const EnumNameConverter<ConsumptionUnit>(
    ConsumptionUnit.values,
  );
  static JsonTypeConverter2<ConsumptionUnit?, String?, String?>
  $converterconsumptionUnitSnapshotn = JsonTypeConverter2.asNullable(
    $converterconsumptionUnitSnapshot,
  );
}

class TransportSegment extends DataClass
    implements Insertable<TransportSegment> {
  final String id;
  final String tripId;
  final int sequenceIndex;
  final TransportMode mode;
  final String originLabel;
  final double? originLat;
  final double? originLng;
  final String destinationLabel;
  final double? destinationLat;
  final double? destinationLng;
  final double? distanceKm;
  final DistanceSource distanceSource;
  final double detourFactor;
  final bool isRoundTrip;
  final DateTime? departureAt;
  final DateTime? arrivalAt;
  final String? vehicleId;
  final double? consumptionSnapshot;
  final ConsumptionUnit? consumptionUnitSnapshot;
  final int? fuelPriceCentsSnapshot;
  final int? manualCostCents;
  final String? provider;
  final String? bookingRef;
  final String? seatInfo;
  final String? notes;
  const TransportSegment({
    required this.id,
    required this.tripId,
    required this.sequenceIndex,
    required this.mode,
    required this.originLabel,
    this.originLat,
    this.originLng,
    required this.destinationLabel,
    this.destinationLat,
    this.destinationLng,
    this.distanceKm,
    required this.distanceSource,
    required this.detourFactor,
    required this.isRoundTrip,
    this.departureAt,
    this.arrivalAt,
    this.vehicleId,
    this.consumptionSnapshot,
    this.consumptionUnitSnapshot,
    this.fuelPriceCentsSnapshot,
    this.manualCostCents,
    this.provider,
    this.bookingRef,
    this.seatInfo,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['sequence_index'] = Variable<int>(sequenceIndex);
    {
      map['mode'] = Variable<String>(
        $TransportSegmentsTable.$convertermode.toSql(mode),
      );
    }
    map['origin_label'] = Variable<String>(originLabel);
    if (!nullToAbsent || originLat != null) {
      map['origin_lat'] = Variable<double>(originLat);
    }
    if (!nullToAbsent || originLng != null) {
      map['origin_lng'] = Variable<double>(originLng);
    }
    map['destination_label'] = Variable<String>(destinationLabel);
    if (!nullToAbsent || destinationLat != null) {
      map['destination_lat'] = Variable<double>(destinationLat);
    }
    if (!nullToAbsent || destinationLng != null) {
      map['destination_lng'] = Variable<double>(destinationLng);
    }
    if (!nullToAbsent || distanceKm != null) {
      map['distance_km'] = Variable<double>(distanceKm);
    }
    {
      map['distance_source'] = Variable<String>(
        $TransportSegmentsTable.$converterdistanceSource.toSql(distanceSource),
      );
    }
    map['detour_factor'] = Variable<double>(detourFactor);
    map['is_round_trip'] = Variable<bool>(isRoundTrip);
    if (!nullToAbsent || departureAt != null) {
      map['departure_at'] = Variable<DateTime>(departureAt);
    }
    if (!nullToAbsent || arrivalAt != null) {
      map['arrival_at'] = Variable<DateTime>(arrivalAt);
    }
    if (!nullToAbsent || vehicleId != null) {
      map['vehicle_id'] = Variable<String>(vehicleId);
    }
    if (!nullToAbsent || consumptionSnapshot != null) {
      map['consumption_snapshot'] = Variable<double>(consumptionSnapshot);
    }
    if (!nullToAbsent || consumptionUnitSnapshot != null) {
      map['consumption_unit_snapshot'] = Variable<String>(
        $TransportSegmentsTable.$converterconsumptionUnitSnapshotn.toSql(
          consumptionUnitSnapshot,
        ),
      );
    }
    if (!nullToAbsent || fuelPriceCentsSnapshot != null) {
      map['fuel_price_cents_snapshot'] = Variable<int>(fuelPriceCentsSnapshot);
    }
    if (!nullToAbsent || manualCostCents != null) {
      map['manual_cost_cents'] = Variable<int>(manualCostCents);
    }
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    if (!nullToAbsent || bookingRef != null) {
      map['booking_ref'] = Variable<String>(bookingRef);
    }
    if (!nullToAbsent || seatInfo != null) {
      map['seat_info'] = Variable<String>(seatInfo);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  TransportSegmentsCompanion toCompanion(bool nullToAbsent) {
    return TransportSegmentsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      sequenceIndex: Value(sequenceIndex),
      mode: Value(mode),
      originLabel: Value(originLabel),
      originLat: originLat == null && nullToAbsent
          ? const Value.absent()
          : Value(originLat),
      originLng: originLng == null && nullToAbsent
          ? const Value.absent()
          : Value(originLng),
      destinationLabel: Value(destinationLabel),
      destinationLat: destinationLat == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationLat),
      destinationLng: destinationLng == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationLng),
      distanceKm: distanceKm == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceKm),
      distanceSource: Value(distanceSource),
      detourFactor: Value(detourFactor),
      isRoundTrip: Value(isRoundTrip),
      departureAt: departureAt == null && nullToAbsent
          ? const Value.absent()
          : Value(departureAt),
      arrivalAt: arrivalAt == null && nullToAbsent
          ? const Value.absent()
          : Value(arrivalAt),
      vehicleId: vehicleId == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleId),
      consumptionSnapshot: consumptionSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(consumptionSnapshot),
      consumptionUnitSnapshot: consumptionUnitSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(consumptionUnitSnapshot),
      fuelPriceCentsSnapshot: fuelPriceCentsSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(fuelPriceCentsSnapshot),
      manualCostCents: manualCostCents == null && nullToAbsent
          ? const Value.absent()
          : Value(manualCostCents),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
      bookingRef: bookingRef == null && nullToAbsent
          ? const Value.absent()
          : Value(bookingRef),
      seatInfo: seatInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(seatInfo),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory TransportSegment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransportSegment(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      sequenceIndex: serializer.fromJson<int>(json['sequenceIndex']),
      mode: $TransportSegmentsTable.$convertermode.fromJson(
        serializer.fromJson<String>(json['mode']),
      ),
      originLabel: serializer.fromJson<String>(json['originLabel']),
      originLat: serializer.fromJson<double?>(json['originLat']),
      originLng: serializer.fromJson<double?>(json['originLng']),
      destinationLabel: serializer.fromJson<String>(json['destinationLabel']),
      destinationLat: serializer.fromJson<double?>(json['destinationLat']),
      destinationLng: serializer.fromJson<double?>(json['destinationLng']),
      distanceKm: serializer.fromJson<double?>(json['distanceKm']),
      distanceSource: $TransportSegmentsTable.$converterdistanceSource.fromJson(
        serializer.fromJson<String>(json['distanceSource']),
      ),
      detourFactor: serializer.fromJson<double>(json['detourFactor']),
      isRoundTrip: serializer.fromJson<bool>(json['isRoundTrip']),
      departureAt: serializer.fromJson<DateTime?>(json['departureAt']),
      arrivalAt: serializer.fromJson<DateTime?>(json['arrivalAt']),
      vehicleId: serializer.fromJson<String?>(json['vehicleId']),
      consumptionSnapshot: serializer.fromJson<double?>(
        json['consumptionSnapshot'],
      ),
      consumptionUnitSnapshot: $TransportSegmentsTable
          .$converterconsumptionUnitSnapshotn
          .fromJson(
            serializer.fromJson<String?>(json['consumptionUnitSnapshot']),
          ),
      fuelPriceCentsSnapshot: serializer.fromJson<int?>(
        json['fuelPriceCentsSnapshot'],
      ),
      manualCostCents: serializer.fromJson<int?>(json['manualCostCents']),
      provider: serializer.fromJson<String?>(json['provider']),
      bookingRef: serializer.fromJson<String?>(json['bookingRef']),
      seatInfo: serializer.fromJson<String?>(json['seatInfo']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'sequenceIndex': serializer.toJson<int>(sequenceIndex),
      'mode': serializer.toJson<String>(
        $TransportSegmentsTable.$convertermode.toJson(mode),
      ),
      'originLabel': serializer.toJson<String>(originLabel),
      'originLat': serializer.toJson<double?>(originLat),
      'originLng': serializer.toJson<double?>(originLng),
      'destinationLabel': serializer.toJson<String>(destinationLabel),
      'destinationLat': serializer.toJson<double?>(destinationLat),
      'destinationLng': serializer.toJson<double?>(destinationLng),
      'distanceKm': serializer.toJson<double?>(distanceKm),
      'distanceSource': serializer.toJson<String>(
        $TransportSegmentsTable.$converterdistanceSource.toJson(distanceSource),
      ),
      'detourFactor': serializer.toJson<double>(detourFactor),
      'isRoundTrip': serializer.toJson<bool>(isRoundTrip),
      'departureAt': serializer.toJson<DateTime?>(departureAt),
      'arrivalAt': serializer.toJson<DateTime?>(arrivalAt),
      'vehicleId': serializer.toJson<String?>(vehicleId),
      'consumptionSnapshot': serializer.toJson<double?>(consumptionSnapshot),
      'consumptionUnitSnapshot': serializer.toJson<String?>(
        $TransportSegmentsTable.$converterconsumptionUnitSnapshotn.toJson(
          consumptionUnitSnapshot,
        ),
      ),
      'fuelPriceCentsSnapshot': serializer.toJson<int?>(fuelPriceCentsSnapshot),
      'manualCostCents': serializer.toJson<int?>(manualCostCents),
      'provider': serializer.toJson<String?>(provider),
      'bookingRef': serializer.toJson<String?>(bookingRef),
      'seatInfo': serializer.toJson<String?>(seatInfo),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  TransportSegment copyWith({
    String? id,
    String? tripId,
    int? sequenceIndex,
    TransportMode? mode,
    String? originLabel,
    Value<double?> originLat = const Value.absent(),
    Value<double?> originLng = const Value.absent(),
    String? destinationLabel,
    Value<double?> destinationLat = const Value.absent(),
    Value<double?> destinationLng = const Value.absent(),
    Value<double?> distanceKm = const Value.absent(),
    DistanceSource? distanceSource,
    double? detourFactor,
    bool? isRoundTrip,
    Value<DateTime?> departureAt = const Value.absent(),
    Value<DateTime?> arrivalAt = const Value.absent(),
    Value<String?> vehicleId = const Value.absent(),
    Value<double?> consumptionSnapshot = const Value.absent(),
    Value<ConsumptionUnit?> consumptionUnitSnapshot = const Value.absent(),
    Value<int?> fuelPriceCentsSnapshot = const Value.absent(),
    Value<int?> manualCostCents = const Value.absent(),
    Value<String?> provider = const Value.absent(),
    Value<String?> bookingRef = const Value.absent(),
    Value<String?> seatInfo = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => TransportSegment(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    sequenceIndex: sequenceIndex ?? this.sequenceIndex,
    mode: mode ?? this.mode,
    originLabel: originLabel ?? this.originLabel,
    originLat: originLat.present ? originLat.value : this.originLat,
    originLng: originLng.present ? originLng.value : this.originLng,
    destinationLabel: destinationLabel ?? this.destinationLabel,
    destinationLat: destinationLat.present
        ? destinationLat.value
        : this.destinationLat,
    destinationLng: destinationLng.present
        ? destinationLng.value
        : this.destinationLng,
    distanceKm: distanceKm.present ? distanceKm.value : this.distanceKm,
    distanceSource: distanceSource ?? this.distanceSource,
    detourFactor: detourFactor ?? this.detourFactor,
    isRoundTrip: isRoundTrip ?? this.isRoundTrip,
    departureAt: departureAt.present ? departureAt.value : this.departureAt,
    arrivalAt: arrivalAt.present ? arrivalAt.value : this.arrivalAt,
    vehicleId: vehicleId.present ? vehicleId.value : this.vehicleId,
    consumptionSnapshot: consumptionSnapshot.present
        ? consumptionSnapshot.value
        : this.consumptionSnapshot,
    consumptionUnitSnapshot: consumptionUnitSnapshot.present
        ? consumptionUnitSnapshot.value
        : this.consumptionUnitSnapshot,
    fuelPriceCentsSnapshot: fuelPriceCentsSnapshot.present
        ? fuelPriceCentsSnapshot.value
        : this.fuelPriceCentsSnapshot,
    manualCostCents: manualCostCents.present
        ? manualCostCents.value
        : this.manualCostCents,
    provider: provider.present ? provider.value : this.provider,
    bookingRef: bookingRef.present ? bookingRef.value : this.bookingRef,
    seatInfo: seatInfo.present ? seatInfo.value : this.seatInfo,
    notes: notes.present ? notes.value : this.notes,
  );
  TransportSegment copyWithCompanion(TransportSegmentsCompanion data) {
    return TransportSegment(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      sequenceIndex: data.sequenceIndex.present
          ? data.sequenceIndex.value
          : this.sequenceIndex,
      mode: data.mode.present ? data.mode.value : this.mode,
      originLabel: data.originLabel.present
          ? data.originLabel.value
          : this.originLabel,
      originLat: data.originLat.present ? data.originLat.value : this.originLat,
      originLng: data.originLng.present ? data.originLng.value : this.originLng,
      destinationLabel: data.destinationLabel.present
          ? data.destinationLabel.value
          : this.destinationLabel,
      destinationLat: data.destinationLat.present
          ? data.destinationLat.value
          : this.destinationLat,
      destinationLng: data.destinationLng.present
          ? data.destinationLng.value
          : this.destinationLng,
      distanceKm: data.distanceKm.present
          ? data.distanceKm.value
          : this.distanceKm,
      distanceSource: data.distanceSource.present
          ? data.distanceSource.value
          : this.distanceSource,
      detourFactor: data.detourFactor.present
          ? data.detourFactor.value
          : this.detourFactor,
      isRoundTrip: data.isRoundTrip.present
          ? data.isRoundTrip.value
          : this.isRoundTrip,
      departureAt: data.departureAt.present
          ? data.departureAt.value
          : this.departureAt,
      arrivalAt: data.arrivalAt.present ? data.arrivalAt.value : this.arrivalAt,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      consumptionSnapshot: data.consumptionSnapshot.present
          ? data.consumptionSnapshot.value
          : this.consumptionSnapshot,
      consumptionUnitSnapshot: data.consumptionUnitSnapshot.present
          ? data.consumptionUnitSnapshot.value
          : this.consumptionUnitSnapshot,
      fuelPriceCentsSnapshot: data.fuelPriceCentsSnapshot.present
          ? data.fuelPriceCentsSnapshot.value
          : this.fuelPriceCentsSnapshot,
      manualCostCents: data.manualCostCents.present
          ? data.manualCostCents.value
          : this.manualCostCents,
      provider: data.provider.present ? data.provider.value : this.provider,
      bookingRef: data.bookingRef.present
          ? data.bookingRef.value
          : this.bookingRef,
      seatInfo: data.seatInfo.present ? data.seatInfo.value : this.seatInfo,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransportSegment(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('sequenceIndex: $sequenceIndex, ')
          ..write('mode: $mode, ')
          ..write('originLabel: $originLabel, ')
          ..write('originLat: $originLat, ')
          ..write('originLng: $originLng, ')
          ..write('destinationLabel: $destinationLabel, ')
          ..write('destinationLat: $destinationLat, ')
          ..write('destinationLng: $destinationLng, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('distanceSource: $distanceSource, ')
          ..write('detourFactor: $detourFactor, ')
          ..write('isRoundTrip: $isRoundTrip, ')
          ..write('departureAt: $departureAt, ')
          ..write('arrivalAt: $arrivalAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('consumptionSnapshot: $consumptionSnapshot, ')
          ..write('consumptionUnitSnapshot: $consumptionUnitSnapshot, ')
          ..write('fuelPriceCentsSnapshot: $fuelPriceCentsSnapshot, ')
          ..write('manualCostCents: $manualCostCents, ')
          ..write('provider: $provider, ')
          ..write('bookingRef: $bookingRef, ')
          ..write('seatInfo: $seatInfo, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    tripId,
    sequenceIndex,
    mode,
    originLabel,
    originLat,
    originLng,
    destinationLabel,
    destinationLat,
    destinationLng,
    distanceKm,
    distanceSource,
    detourFactor,
    isRoundTrip,
    departureAt,
    arrivalAt,
    vehicleId,
    consumptionSnapshot,
    consumptionUnitSnapshot,
    fuelPriceCentsSnapshot,
    manualCostCents,
    provider,
    bookingRef,
    seatInfo,
    notes,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransportSegment &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.sequenceIndex == this.sequenceIndex &&
          other.mode == this.mode &&
          other.originLabel == this.originLabel &&
          other.originLat == this.originLat &&
          other.originLng == this.originLng &&
          other.destinationLabel == this.destinationLabel &&
          other.destinationLat == this.destinationLat &&
          other.destinationLng == this.destinationLng &&
          other.distanceKm == this.distanceKm &&
          other.distanceSource == this.distanceSource &&
          other.detourFactor == this.detourFactor &&
          other.isRoundTrip == this.isRoundTrip &&
          other.departureAt == this.departureAt &&
          other.arrivalAt == this.arrivalAt &&
          other.vehicleId == this.vehicleId &&
          other.consumptionSnapshot == this.consumptionSnapshot &&
          other.consumptionUnitSnapshot == this.consumptionUnitSnapshot &&
          other.fuelPriceCentsSnapshot == this.fuelPriceCentsSnapshot &&
          other.manualCostCents == this.manualCostCents &&
          other.provider == this.provider &&
          other.bookingRef == this.bookingRef &&
          other.seatInfo == this.seatInfo &&
          other.notes == this.notes);
}

class TransportSegmentsCompanion extends UpdateCompanion<TransportSegment> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<int> sequenceIndex;
  final Value<TransportMode> mode;
  final Value<String> originLabel;
  final Value<double?> originLat;
  final Value<double?> originLng;
  final Value<String> destinationLabel;
  final Value<double?> destinationLat;
  final Value<double?> destinationLng;
  final Value<double?> distanceKm;
  final Value<DistanceSource> distanceSource;
  final Value<double> detourFactor;
  final Value<bool> isRoundTrip;
  final Value<DateTime?> departureAt;
  final Value<DateTime?> arrivalAt;
  final Value<String?> vehicleId;
  final Value<double?> consumptionSnapshot;
  final Value<ConsumptionUnit?> consumptionUnitSnapshot;
  final Value<int?> fuelPriceCentsSnapshot;
  final Value<int?> manualCostCents;
  final Value<String?> provider;
  final Value<String?> bookingRef;
  final Value<String?> seatInfo;
  final Value<String?> notes;
  final Value<int> rowid;
  const TransportSegmentsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.sequenceIndex = const Value.absent(),
    this.mode = const Value.absent(),
    this.originLabel = const Value.absent(),
    this.originLat = const Value.absent(),
    this.originLng = const Value.absent(),
    this.destinationLabel = const Value.absent(),
    this.destinationLat = const Value.absent(),
    this.destinationLng = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.distanceSource = const Value.absent(),
    this.detourFactor = const Value.absent(),
    this.isRoundTrip = const Value.absent(),
    this.departureAt = const Value.absent(),
    this.arrivalAt = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.consumptionSnapshot = const Value.absent(),
    this.consumptionUnitSnapshot = const Value.absent(),
    this.fuelPriceCentsSnapshot = const Value.absent(),
    this.manualCostCents = const Value.absent(),
    this.provider = const Value.absent(),
    this.bookingRef = const Value.absent(),
    this.seatInfo = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransportSegmentsCompanion.insert({
    required String id,
    required String tripId,
    this.sequenceIndex = const Value.absent(),
    this.mode = const Value.absent(),
    this.originLabel = const Value.absent(),
    this.originLat = const Value.absent(),
    this.originLng = const Value.absent(),
    this.destinationLabel = const Value.absent(),
    this.destinationLat = const Value.absent(),
    this.destinationLng = const Value.absent(),
    this.distanceKm = const Value.absent(),
    this.distanceSource = const Value.absent(),
    this.detourFactor = const Value.absent(),
    this.isRoundTrip = const Value.absent(),
    this.departureAt = const Value.absent(),
    this.arrivalAt = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.consumptionSnapshot = const Value.absent(),
    this.consumptionUnitSnapshot = const Value.absent(),
    this.fuelPriceCentsSnapshot = const Value.absent(),
    this.manualCostCents = const Value.absent(),
    this.provider = const Value.absent(),
    this.bookingRef = const Value.absent(),
    this.seatInfo = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId);
  static Insertable<TransportSegment> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<int>? sequenceIndex,
    Expression<String>? mode,
    Expression<String>? originLabel,
    Expression<double>? originLat,
    Expression<double>? originLng,
    Expression<String>? destinationLabel,
    Expression<double>? destinationLat,
    Expression<double>? destinationLng,
    Expression<double>? distanceKm,
    Expression<String>? distanceSource,
    Expression<double>? detourFactor,
    Expression<bool>? isRoundTrip,
    Expression<DateTime>? departureAt,
    Expression<DateTime>? arrivalAt,
    Expression<String>? vehicleId,
    Expression<double>? consumptionSnapshot,
    Expression<String>? consumptionUnitSnapshot,
    Expression<int>? fuelPriceCentsSnapshot,
    Expression<int>? manualCostCents,
    Expression<String>? provider,
    Expression<String>? bookingRef,
    Expression<String>? seatInfo,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (sequenceIndex != null) 'sequence_index': sequenceIndex,
      if (mode != null) 'mode': mode,
      if (originLabel != null) 'origin_label': originLabel,
      if (originLat != null) 'origin_lat': originLat,
      if (originLng != null) 'origin_lng': originLng,
      if (destinationLabel != null) 'destination_label': destinationLabel,
      if (destinationLat != null) 'destination_lat': destinationLat,
      if (destinationLng != null) 'destination_lng': destinationLng,
      if (distanceKm != null) 'distance_km': distanceKm,
      if (distanceSource != null) 'distance_source': distanceSource,
      if (detourFactor != null) 'detour_factor': detourFactor,
      if (isRoundTrip != null) 'is_round_trip': isRoundTrip,
      if (departureAt != null) 'departure_at': departureAt,
      if (arrivalAt != null) 'arrival_at': arrivalAt,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (consumptionSnapshot != null)
        'consumption_snapshot': consumptionSnapshot,
      if (consumptionUnitSnapshot != null)
        'consumption_unit_snapshot': consumptionUnitSnapshot,
      if (fuelPriceCentsSnapshot != null)
        'fuel_price_cents_snapshot': fuelPriceCentsSnapshot,
      if (manualCostCents != null) 'manual_cost_cents': manualCostCents,
      if (provider != null) 'provider': provider,
      if (bookingRef != null) 'booking_ref': bookingRef,
      if (seatInfo != null) 'seat_info': seatInfo,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransportSegmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<int>? sequenceIndex,
    Value<TransportMode>? mode,
    Value<String>? originLabel,
    Value<double?>? originLat,
    Value<double?>? originLng,
    Value<String>? destinationLabel,
    Value<double?>? destinationLat,
    Value<double?>? destinationLng,
    Value<double?>? distanceKm,
    Value<DistanceSource>? distanceSource,
    Value<double>? detourFactor,
    Value<bool>? isRoundTrip,
    Value<DateTime?>? departureAt,
    Value<DateTime?>? arrivalAt,
    Value<String?>? vehicleId,
    Value<double?>? consumptionSnapshot,
    Value<ConsumptionUnit?>? consumptionUnitSnapshot,
    Value<int?>? fuelPriceCentsSnapshot,
    Value<int?>? manualCostCents,
    Value<String?>? provider,
    Value<String?>? bookingRef,
    Value<String?>? seatInfo,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return TransportSegmentsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      sequenceIndex: sequenceIndex ?? this.sequenceIndex,
      mode: mode ?? this.mode,
      originLabel: originLabel ?? this.originLabel,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      destinationLabel: destinationLabel ?? this.destinationLabel,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      distanceKm: distanceKm ?? this.distanceKm,
      distanceSource: distanceSource ?? this.distanceSource,
      detourFactor: detourFactor ?? this.detourFactor,
      isRoundTrip: isRoundTrip ?? this.isRoundTrip,
      departureAt: departureAt ?? this.departureAt,
      arrivalAt: arrivalAt ?? this.arrivalAt,
      vehicleId: vehicleId ?? this.vehicleId,
      consumptionSnapshot: consumptionSnapshot ?? this.consumptionSnapshot,
      consumptionUnitSnapshot:
          consumptionUnitSnapshot ?? this.consumptionUnitSnapshot,
      fuelPriceCentsSnapshot:
          fuelPriceCentsSnapshot ?? this.fuelPriceCentsSnapshot,
      manualCostCents: manualCostCents ?? this.manualCostCents,
      provider: provider ?? this.provider,
      bookingRef: bookingRef ?? this.bookingRef,
      seatInfo: seatInfo ?? this.seatInfo,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (sequenceIndex.present) {
      map['sequence_index'] = Variable<int>(sequenceIndex.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(
        $TransportSegmentsTable.$convertermode.toSql(mode.value),
      );
    }
    if (originLabel.present) {
      map['origin_label'] = Variable<String>(originLabel.value);
    }
    if (originLat.present) {
      map['origin_lat'] = Variable<double>(originLat.value);
    }
    if (originLng.present) {
      map['origin_lng'] = Variable<double>(originLng.value);
    }
    if (destinationLabel.present) {
      map['destination_label'] = Variable<String>(destinationLabel.value);
    }
    if (destinationLat.present) {
      map['destination_lat'] = Variable<double>(destinationLat.value);
    }
    if (destinationLng.present) {
      map['destination_lng'] = Variable<double>(destinationLng.value);
    }
    if (distanceKm.present) {
      map['distance_km'] = Variable<double>(distanceKm.value);
    }
    if (distanceSource.present) {
      map['distance_source'] = Variable<String>(
        $TransportSegmentsTable.$converterdistanceSource.toSql(
          distanceSource.value,
        ),
      );
    }
    if (detourFactor.present) {
      map['detour_factor'] = Variable<double>(detourFactor.value);
    }
    if (isRoundTrip.present) {
      map['is_round_trip'] = Variable<bool>(isRoundTrip.value);
    }
    if (departureAt.present) {
      map['departure_at'] = Variable<DateTime>(departureAt.value);
    }
    if (arrivalAt.present) {
      map['arrival_at'] = Variable<DateTime>(arrivalAt.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (consumptionSnapshot.present) {
      map['consumption_snapshot'] = Variable<double>(consumptionSnapshot.value);
    }
    if (consumptionUnitSnapshot.present) {
      map['consumption_unit_snapshot'] = Variable<String>(
        $TransportSegmentsTable.$converterconsumptionUnitSnapshotn.toSql(
          consumptionUnitSnapshot.value,
        ),
      );
    }
    if (fuelPriceCentsSnapshot.present) {
      map['fuel_price_cents_snapshot'] = Variable<int>(
        fuelPriceCentsSnapshot.value,
      );
    }
    if (manualCostCents.present) {
      map['manual_cost_cents'] = Variable<int>(manualCostCents.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (bookingRef.present) {
      map['booking_ref'] = Variable<String>(bookingRef.value);
    }
    if (seatInfo.present) {
      map['seat_info'] = Variable<String>(seatInfo.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransportSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('sequenceIndex: $sequenceIndex, ')
          ..write('mode: $mode, ')
          ..write('originLabel: $originLabel, ')
          ..write('originLat: $originLat, ')
          ..write('originLng: $originLng, ')
          ..write('destinationLabel: $destinationLabel, ')
          ..write('destinationLat: $destinationLat, ')
          ..write('destinationLng: $destinationLng, ')
          ..write('distanceKm: $distanceKm, ')
          ..write('distanceSource: $distanceSource, ')
          ..write('detourFactor: $detourFactor, ')
          ..write('isRoundTrip: $isRoundTrip, ')
          ..write('departureAt: $departureAt, ')
          ..write('arrivalAt: $arrivalAt, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('consumptionSnapshot: $consumptionSnapshot, ')
          ..write('consumptionUnitSnapshot: $consumptionUnitSnapshot, ')
          ..write('fuelPriceCentsSnapshot: $fuelPriceCentsSnapshot, ')
          ..write('manualCostCents: $manualCostCents, ')
          ..write('provider: $provider, ')
          ..write('bookingRef: $bookingRef, ')
          ..write('seatInfo: $seatInfo, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CostItemsTable extends CostItems
    with TableInfo<$CostItemsTable, CostItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CostItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _segmentIdMeta = const VerificationMeta(
    'segmentId',
  );
  @override
  late final GeneratedColumn<String> segmentId = GeneratedColumn<String>(
    'segment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transport_segments (id) ON DELETE SET NULL',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CostCategory, String> category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(CostCategory.other.name),
      ).withConverter<CostCategory>($CostItemsTable.$convertercategory);
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CostStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(CostStatus.actual.name),
      ).withConverter<CostStatus>($CostItemsTable.$converterstatus);
  static const VerificationMeta _paidByTravelerIdMeta = const VerificationMeta(
    'paidByTravelerId',
  );
  @override
  late final GeneratedColumn<String> paidByTravelerId = GeneratedColumn<String>(
    'paid_by_traveler_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES travelers (id) ON DELETE SET NULL',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SplitMethod, String> splitMethod =
      GeneratedColumn<String>(
        'split_method',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SplitMethod.equal.name),
      ).withConverter<SplitMethod>($CostItemsTable.$convertersplitMethod);
  static const VerificationMeta _receiptPhotoPathMeta = const VerificationMeta(
    'receiptPhotoPath',
  );
  @override
  late final GeneratedColumn<String> receiptPhotoPath = GeneratedColumn<String>(
    'receipt_photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    segmentId,
    category,
    description,
    amountCents,
    currency,
    date,
    status,
    paidByTravelerId,
    splitMethod,
    receiptPhotoPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cost_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CostItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('segment_id')) {
      context.handle(
        _segmentIdMeta,
        segmentId.isAcceptableOrUnknown(data['segment_id']!, _segmentIdMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('paid_by_traveler_id')) {
      context.handle(
        _paidByTravelerIdMeta,
        paidByTravelerId.isAcceptableOrUnknown(
          data['paid_by_traveler_id']!,
          _paidByTravelerIdMeta,
        ),
      );
    }
    if (data.containsKey('receipt_photo_path')) {
      context.handle(
        _receiptPhotoPathMeta,
        receiptPhotoPath.isAcceptableOrUnknown(
          data['receipt_photo_path']!,
          _receiptPhotoPathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CostItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CostItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      segmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}segment_id'],
      ),
      category: $CostItemsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      ),
      status: $CostItemsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      paidByTravelerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_by_traveler_id'],
      ),
      splitMethod: $CostItemsTable.$convertersplitMethod.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}split_method'],
        )!,
      ),
      receiptPhotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_photo_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CostItemsTable createAlias(String alias) {
    return $CostItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CostCategory, String, String> $convertercategory =
      const EnumNameConverter<CostCategory>(CostCategory.values);
  static JsonTypeConverter2<CostStatus, String, String> $converterstatus =
      const EnumNameConverter<CostStatus>(CostStatus.values);
  static JsonTypeConverter2<SplitMethod, String, String> $convertersplitMethod =
      const EnumNameConverter<SplitMethod>(SplitMethod.values);
}

class CostItem extends DataClass implements Insertable<CostItem> {
  final String id;
  final String tripId;
  final String? segmentId;
  final CostCategory category;
  final String? description;
  final int amountCents;
  final String currency;
  final DateTime? date;
  final CostStatus status;
  final String? paidByTravelerId;
  final SplitMethod splitMethod;
  final String? receiptPhotoPath;
  final DateTime createdAt;
  const CostItem({
    required this.id,
    required this.tripId,
    this.segmentId,
    required this.category,
    this.description,
    required this.amountCents,
    required this.currency,
    this.date,
    required this.status,
    this.paidByTravelerId,
    required this.splitMethod,
    this.receiptPhotoPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    if (!nullToAbsent || segmentId != null) {
      map['segment_id'] = Variable<String>(segmentId);
    }
    {
      map['category'] = Variable<String>(
        $CostItemsTable.$convertercategory.toSql(category),
      );
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['amount_cents'] = Variable<int>(amountCents);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    {
      map['status'] = Variable<String>(
        $CostItemsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || paidByTravelerId != null) {
      map['paid_by_traveler_id'] = Variable<String>(paidByTravelerId);
    }
    {
      map['split_method'] = Variable<String>(
        $CostItemsTable.$convertersplitMethod.toSql(splitMethod),
      );
    }
    if (!nullToAbsent || receiptPhotoPath != null) {
      map['receipt_photo_path'] = Variable<String>(receiptPhotoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CostItemsCompanion toCompanion(bool nullToAbsent) {
    return CostItemsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      segmentId: segmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(segmentId),
      category: Value(category),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      amountCents: Value(amountCents),
      currency: Value(currency),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      status: Value(status),
      paidByTravelerId: paidByTravelerId == null && nullToAbsent
          ? const Value.absent()
          : Value(paidByTravelerId),
      splitMethod: Value(splitMethod),
      receiptPhotoPath: receiptPhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptPhotoPath),
      createdAt: Value(createdAt),
    );
  }

  factory CostItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CostItem(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      segmentId: serializer.fromJson<String?>(json['segmentId']),
      category: $CostItemsTable.$convertercategory.fromJson(
        serializer.fromJson<String>(json['category']),
      ),
      description: serializer.fromJson<String?>(json['description']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      currency: serializer.fromJson<String>(json['currency']),
      date: serializer.fromJson<DateTime?>(json['date']),
      status: $CostItemsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      paidByTravelerId: serializer.fromJson<String?>(json['paidByTravelerId']),
      splitMethod: $CostItemsTable.$convertersplitMethod.fromJson(
        serializer.fromJson<String>(json['splitMethod']),
      ),
      receiptPhotoPath: serializer.fromJson<String?>(json['receiptPhotoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'segmentId': serializer.toJson<String?>(segmentId),
      'category': serializer.toJson<String>(
        $CostItemsTable.$convertercategory.toJson(category),
      ),
      'description': serializer.toJson<String?>(description),
      'amountCents': serializer.toJson<int>(amountCents),
      'currency': serializer.toJson<String>(currency),
      'date': serializer.toJson<DateTime?>(date),
      'status': serializer.toJson<String>(
        $CostItemsTable.$converterstatus.toJson(status),
      ),
      'paidByTravelerId': serializer.toJson<String?>(paidByTravelerId),
      'splitMethod': serializer.toJson<String>(
        $CostItemsTable.$convertersplitMethod.toJson(splitMethod),
      ),
      'receiptPhotoPath': serializer.toJson<String?>(receiptPhotoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CostItem copyWith({
    String? id,
    String? tripId,
    Value<String?> segmentId = const Value.absent(),
    CostCategory? category,
    Value<String?> description = const Value.absent(),
    int? amountCents,
    String? currency,
    Value<DateTime?> date = const Value.absent(),
    CostStatus? status,
    Value<String?> paidByTravelerId = const Value.absent(),
    SplitMethod? splitMethod,
    Value<String?> receiptPhotoPath = const Value.absent(),
    DateTime? createdAt,
  }) => CostItem(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    segmentId: segmentId.present ? segmentId.value : this.segmentId,
    category: category ?? this.category,
    description: description.present ? description.value : this.description,
    amountCents: amountCents ?? this.amountCents,
    currency: currency ?? this.currency,
    date: date.present ? date.value : this.date,
    status: status ?? this.status,
    paidByTravelerId: paidByTravelerId.present
        ? paidByTravelerId.value
        : this.paidByTravelerId,
    splitMethod: splitMethod ?? this.splitMethod,
    receiptPhotoPath: receiptPhotoPath.present
        ? receiptPhotoPath.value
        : this.receiptPhotoPath,
    createdAt: createdAt ?? this.createdAt,
  );
  CostItem copyWithCompanion(CostItemsCompanion data) {
    return CostItem(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      segmentId: data.segmentId.present ? data.segmentId.value : this.segmentId,
      category: data.category.present ? data.category.value : this.category,
      description: data.description.present
          ? data.description.value
          : this.description,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      currency: data.currency.present ? data.currency.value : this.currency,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      paidByTravelerId: data.paidByTravelerId.present
          ? data.paidByTravelerId.value
          : this.paidByTravelerId,
      splitMethod: data.splitMethod.present
          ? data.splitMethod.value
          : this.splitMethod,
      receiptPhotoPath: data.receiptPhotoPath.present
          ? data.receiptPhotoPath.value
          : this.receiptPhotoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CostItem(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('segmentId: $segmentId, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('amountCents: $amountCents, ')
          ..write('currency: $currency, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('paidByTravelerId: $paidByTravelerId, ')
          ..write('splitMethod: $splitMethod, ')
          ..write('receiptPhotoPath: $receiptPhotoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    segmentId,
    category,
    description,
    amountCents,
    currency,
    date,
    status,
    paidByTravelerId,
    splitMethod,
    receiptPhotoPath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CostItem &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.segmentId == this.segmentId &&
          other.category == this.category &&
          other.description == this.description &&
          other.amountCents == this.amountCents &&
          other.currency == this.currency &&
          other.date == this.date &&
          other.status == this.status &&
          other.paidByTravelerId == this.paidByTravelerId &&
          other.splitMethod == this.splitMethod &&
          other.receiptPhotoPath == this.receiptPhotoPath &&
          other.createdAt == this.createdAt);
}

class CostItemsCompanion extends UpdateCompanion<CostItem> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String?> segmentId;
  final Value<CostCategory> category;
  final Value<String?> description;
  final Value<int> amountCents;
  final Value<String> currency;
  final Value<DateTime?> date;
  final Value<CostStatus> status;
  final Value<String?> paidByTravelerId;
  final Value<SplitMethod> splitMethod;
  final Value<String?> receiptPhotoPath;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CostItemsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.segmentId = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.paidByTravelerId = const Value.absent(),
    this.splitMethod = const Value.absent(),
    this.receiptPhotoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CostItemsCompanion.insert({
    required String id,
    required String tripId,
    this.segmentId = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.paidByTravelerId = const Value.absent(),
    this.splitMethod = const Value.absent(),
    this.receiptPhotoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId);
  static Insertable<CostItem> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? segmentId,
    Expression<String>? category,
    Expression<String>? description,
    Expression<int>? amountCents,
    Expression<String>? currency,
    Expression<DateTime>? date,
    Expression<String>? status,
    Expression<String>? paidByTravelerId,
    Expression<String>? splitMethod,
    Expression<String>? receiptPhotoPath,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (segmentId != null) 'segment_id': segmentId,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (amountCents != null) 'amount_cents': amountCents,
      if (currency != null) 'currency': currency,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (paidByTravelerId != null) 'paid_by_traveler_id': paidByTravelerId,
      if (splitMethod != null) 'split_method': splitMethod,
      if (receiptPhotoPath != null) 'receipt_photo_path': receiptPhotoPath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CostItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String?>? segmentId,
    Value<CostCategory>? category,
    Value<String?>? description,
    Value<int>? amountCents,
    Value<String>? currency,
    Value<DateTime?>? date,
    Value<CostStatus>? status,
    Value<String?>? paidByTravelerId,
    Value<SplitMethod>? splitMethod,
    Value<String?>? receiptPhotoPath,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CostItemsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      segmentId: segmentId ?? this.segmentId,
      category: category ?? this.category,
      description: description ?? this.description,
      amountCents: amountCents ?? this.amountCents,
      currency: currency ?? this.currency,
      date: date ?? this.date,
      status: status ?? this.status,
      paidByTravelerId: paidByTravelerId ?? this.paidByTravelerId,
      splitMethod: splitMethod ?? this.splitMethod,
      receiptPhotoPath: receiptPhotoPath ?? this.receiptPhotoPath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (segmentId.present) {
      map['segment_id'] = Variable<String>(segmentId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $CostItemsTable.$convertercategory.toSql(category.value),
      );
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $CostItemsTable.$converterstatus.toSql(status.value),
      );
    }
    if (paidByTravelerId.present) {
      map['paid_by_traveler_id'] = Variable<String>(paidByTravelerId.value);
    }
    if (splitMethod.present) {
      map['split_method'] = Variable<String>(
        $CostItemsTable.$convertersplitMethod.toSql(splitMethod.value),
      );
    }
    if (receiptPhotoPath.present) {
      map['receipt_photo_path'] = Variable<String>(receiptPhotoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CostItemsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('segmentId: $segmentId, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('amountCents: $amountCents, ')
          ..write('currency: $currency, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('paidByTravelerId: $paidByTravelerId, ')
          ..write('splitMethod: $splitMethod, ')
          ..write('receiptPhotoPath: $receiptPhotoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CostSplitsTable extends CostSplits
    with TableInfo<$CostSplitsTable, CostSplit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CostSplitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costItemIdMeta = const VerificationMeta(
    'costItemId',
  );
  @override
  late final GeneratedColumn<String> costItemId = GeneratedColumn<String>(
    'cost_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cost_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _travelerIdMeta = const VerificationMeta(
    'travelerId',
  );
  @override
  late final GeneratedColumn<String> travelerId = GeneratedColumn<String>(
    'traveler_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES travelers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _shareWeightMeta = const VerificationMeta(
    'shareWeight',
  );
  @override
  late final GeneratedColumn<double> shareWeight = GeneratedColumn<double>(
    'share_weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _shareAmountCentsMeta = const VerificationMeta(
    'shareAmountCents',
  );
  @override
  late final GeneratedColumn<int> shareAmountCents = GeneratedColumn<int>(
    'share_amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _settledMeta = const VerificationMeta(
    'settled',
  );
  @override
  late final GeneratedColumn<bool> settled = GeneratedColumn<bool>(
    'settled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("settled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    costItemId,
    travelerId,
    shareWeight,
    shareAmountCents,
    settled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cost_splits';
  @override
  VerificationContext validateIntegrity(
    Insertable<CostSplit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('cost_item_id')) {
      context.handle(
        _costItemIdMeta,
        costItemId.isAcceptableOrUnknown(
          data['cost_item_id']!,
          _costItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costItemIdMeta);
    }
    if (data.containsKey('traveler_id')) {
      context.handle(
        _travelerIdMeta,
        travelerId.isAcceptableOrUnknown(data['traveler_id']!, _travelerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_travelerIdMeta);
    }
    if (data.containsKey('share_weight')) {
      context.handle(
        _shareWeightMeta,
        shareWeight.isAcceptableOrUnknown(
          data['share_weight']!,
          _shareWeightMeta,
        ),
      );
    }
    if (data.containsKey('share_amount_cents')) {
      context.handle(
        _shareAmountCentsMeta,
        shareAmountCents.isAcceptableOrUnknown(
          data['share_amount_cents']!,
          _shareAmountCentsMeta,
        ),
      );
    }
    if (data.containsKey('settled')) {
      context.handle(
        _settledMeta,
        settled.isAcceptableOrUnknown(data['settled']!, _settledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CostSplit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CostSplit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      costItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cost_item_id'],
      )!,
      travelerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}traveler_id'],
      )!,
      shareWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}share_weight'],
      )!,
      shareAmountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}share_amount_cents'],
      )!,
      settled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}settled'],
      )!,
    );
  }

  @override
  $CostSplitsTable createAlias(String alias) {
    return $CostSplitsTable(attachedDatabase, alias);
  }
}

class CostSplit extends DataClass implements Insertable<CostSplit> {
  final String id;
  final String costItemId;
  final String travelerId;
  final double shareWeight;
  final int shareAmountCents;
  final bool settled;
  const CostSplit({
    required this.id,
    required this.costItemId,
    required this.travelerId,
    required this.shareWeight,
    required this.shareAmountCents,
    required this.settled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['cost_item_id'] = Variable<String>(costItemId);
    map['traveler_id'] = Variable<String>(travelerId);
    map['share_weight'] = Variable<double>(shareWeight);
    map['share_amount_cents'] = Variable<int>(shareAmountCents);
    map['settled'] = Variable<bool>(settled);
    return map;
  }

  CostSplitsCompanion toCompanion(bool nullToAbsent) {
    return CostSplitsCompanion(
      id: Value(id),
      costItemId: Value(costItemId),
      travelerId: Value(travelerId),
      shareWeight: Value(shareWeight),
      shareAmountCents: Value(shareAmountCents),
      settled: Value(settled),
    );
  }

  factory CostSplit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CostSplit(
      id: serializer.fromJson<String>(json['id']),
      costItemId: serializer.fromJson<String>(json['costItemId']),
      travelerId: serializer.fromJson<String>(json['travelerId']),
      shareWeight: serializer.fromJson<double>(json['shareWeight']),
      shareAmountCents: serializer.fromJson<int>(json['shareAmountCents']),
      settled: serializer.fromJson<bool>(json['settled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'costItemId': serializer.toJson<String>(costItemId),
      'travelerId': serializer.toJson<String>(travelerId),
      'shareWeight': serializer.toJson<double>(shareWeight),
      'shareAmountCents': serializer.toJson<int>(shareAmountCents),
      'settled': serializer.toJson<bool>(settled),
    };
  }

  CostSplit copyWith({
    String? id,
    String? costItemId,
    String? travelerId,
    double? shareWeight,
    int? shareAmountCents,
    bool? settled,
  }) => CostSplit(
    id: id ?? this.id,
    costItemId: costItemId ?? this.costItemId,
    travelerId: travelerId ?? this.travelerId,
    shareWeight: shareWeight ?? this.shareWeight,
    shareAmountCents: shareAmountCents ?? this.shareAmountCents,
    settled: settled ?? this.settled,
  );
  CostSplit copyWithCompanion(CostSplitsCompanion data) {
    return CostSplit(
      id: data.id.present ? data.id.value : this.id,
      costItemId: data.costItemId.present
          ? data.costItemId.value
          : this.costItemId,
      travelerId: data.travelerId.present
          ? data.travelerId.value
          : this.travelerId,
      shareWeight: data.shareWeight.present
          ? data.shareWeight.value
          : this.shareWeight,
      shareAmountCents: data.shareAmountCents.present
          ? data.shareAmountCents.value
          : this.shareAmountCents,
      settled: data.settled.present ? data.settled.value : this.settled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CostSplit(')
          ..write('id: $id, ')
          ..write('costItemId: $costItemId, ')
          ..write('travelerId: $travelerId, ')
          ..write('shareWeight: $shareWeight, ')
          ..write('shareAmountCents: $shareAmountCents, ')
          ..write('settled: $settled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    costItemId,
    travelerId,
    shareWeight,
    shareAmountCents,
    settled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CostSplit &&
          other.id == this.id &&
          other.costItemId == this.costItemId &&
          other.travelerId == this.travelerId &&
          other.shareWeight == this.shareWeight &&
          other.shareAmountCents == this.shareAmountCents &&
          other.settled == this.settled);
}

class CostSplitsCompanion extends UpdateCompanion<CostSplit> {
  final Value<String> id;
  final Value<String> costItemId;
  final Value<String> travelerId;
  final Value<double> shareWeight;
  final Value<int> shareAmountCents;
  final Value<bool> settled;
  final Value<int> rowid;
  const CostSplitsCompanion({
    this.id = const Value.absent(),
    this.costItemId = const Value.absent(),
    this.travelerId = const Value.absent(),
    this.shareWeight = const Value.absent(),
    this.shareAmountCents = const Value.absent(),
    this.settled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CostSplitsCompanion.insert({
    required String id,
    required String costItemId,
    required String travelerId,
    this.shareWeight = const Value.absent(),
    this.shareAmountCents = const Value.absent(),
    this.settled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       costItemId = Value(costItemId),
       travelerId = Value(travelerId);
  static Insertable<CostSplit> custom({
    Expression<String>? id,
    Expression<String>? costItemId,
    Expression<String>? travelerId,
    Expression<double>? shareWeight,
    Expression<int>? shareAmountCents,
    Expression<bool>? settled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (costItemId != null) 'cost_item_id': costItemId,
      if (travelerId != null) 'traveler_id': travelerId,
      if (shareWeight != null) 'share_weight': shareWeight,
      if (shareAmountCents != null) 'share_amount_cents': shareAmountCents,
      if (settled != null) 'settled': settled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CostSplitsCompanion copyWith({
    Value<String>? id,
    Value<String>? costItemId,
    Value<String>? travelerId,
    Value<double>? shareWeight,
    Value<int>? shareAmountCents,
    Value<bool>? settled,
    Value<int>? rowid,
  }) {
    return CostSplitsCompanion(
      id: id ?? this.id,
      costItemId: costItemId ?? this.costItemId,
      travelerId: travelerId ?? this.travelerId,
      shareWeight: shareWeight ?? this.shareWeight,
      shareAmountCents: shareAmountCents ?? this.shareAmountCents,
      settled: settled ?? this.settled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (costItemId.present) {
      map['cost_item_id'] = Variable<String>(costItemId.value);
    }
    if (travelerId.present) {
      map['traveler_id'] = Variable<String>(travelerId.value);
    }
    if (shareWeight.present) {
      map['share_weight'] = Variable<double>(shareWeight.value);
    }
    if (shareAmountCents.present) {
      map['share_amount_cents'] = Variable<int>(shareAmountCents.value);
    }
    if (settled.present) {
      map['settled'] = Variable<bool>(settled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CostSplitsCompanion(')
          ..write('id: $id, ')
          ..write('costItemId: $costItemId, ')
          ..write('travelerId: $travelerId, ')
          ..write('shareWeight: $shareWeight, ')
          ..write('shareAmountCents: $shareAmountCents, ')
          ..write('settled: $settled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItineraryDaysTable extends ItineraryDays
    with TableInfo<$ItineraryDaysTable, ItineraryDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItineraryDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayIndexMeta = const VerificationMeta(
    'dayIndex',
  );
  @override
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>(
    'day_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    date,
    dayIndex,
    title,
    notes,
    sortIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'itinerary_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItineraryDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('day_index')) {
      context.handle(
        _dayIndexMeta,
        dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItineraryDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItineraryDay(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      ),
      dayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_index'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
    );
  }

  @override
  $ItineraryDaysTable createAlias(String alias) {
    return $ItineraryDaysTable(attachedDatabase, alias);
  }
}

class ItineraryDay extends DataClass implements Insertable<ItineraryDay> {
  final String id;
  final String tripId;
  final DateTime? date;
  final int dayIndex;
  final String? title;
  final String? notes;
  final int sortIndex;
  const ItineraryDay({
    required this.id,
    required this.tripId,
    this.date,
    required this.dayIndex,
    this.title,
    this.notes,
    required this.sortIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    map['day_index'] = Variable<int>(dayIndex);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['sort_index'] = Variable<int>(sortIndex);
    return map;
  }

  ItineraryDaysCompanion toCompanion(bool nullToAbsent) {
    return ItineraryDaysCompanion(
      id: Value(id),
      tripId: Value(tripId),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      dayIndex: Value(dayIndex),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      sortIndex: Value(sortIndex),
    );
  }

  factory ItineraryDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItineraryDay(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      date: serializer.fromJson<DateTime?>(json['date']),
      dayIndex: serializer.fromJson<int>(json['dayIndex']),
      title: serializer.fromJson<String?>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'date': serializer.toJson<DateTime?>(date),
      'dayIndex': serializer.toJson<int>(dayIndex),
      'title': serializer.toJson<String?>(title),
      'notes': serializer.toJson<String?>(notes),
      'sortIndex': serializer.toJson<int>(sortIndex),
    };
  }

  ItineraryDay copyWith({
    String? id,
    String? tripId,
    Value<DateTime?> date = const Value.absent(),
    int? dayIndex,
    Value<String?> title = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? sortIndex,
  }) => ItineraryDay(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    date: date.present ? date.value : this.date,
    dayIndex: dayIndex ?? this.dayIndex,
    title: title.present ? title.value : this.title,
    notes: notes.present ? notes.value : this.notes,
    sortIndex: sortIndex ?? this.sortIndex,
  );
  ItineraryDay copyWithCompanion(ItineraryDaysCompanion data) {
    return ItineraryDay(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      date: data.date.present ? data.date.value : this.date,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItineraryDay(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('date: $date, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tripId, date, dayIndex, title, notes, sortIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItineraryDay &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.date == this.date &&
          other.dayIndex == this.dayIndex &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.sortIndex == this.sortIndex);
}

class ItineraryDaysCompanion extends UpdateCompanion<ItineraryDay> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<DateTime?> date;
  final Value<int> dayIndex;
  final Value<String?> title;
  final Value<String?> notes;
  final Value<int> sortIndex;
  final Value<int> rowid;
  const ItineraryDaysCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.date = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItineraryDaysCompanion.insert({
    required String id,
    required String tripId,
    this.date = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId);
  static Insertable<ItineraryDay> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<DateTime>? date,
    Expression<int>? dayIndex,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<int>? sortIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (date != null) 'date': date,
      if (dayIndex != null) 'day_index': dayIndex,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItineraryDaysCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<DateTime?>? date,
    Value<int>? dayIndex,
    Value<String?>? title,
    Value<String?>? notes,
    Value<int>? sortIndex,
    Value<int>? rowid,
  }) {
    return ItineraryDaysCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      date: date ?? this.date,
      dayIndex: dayIndex ?? this.dayIndex,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      sortIndex: sortIndex ?? this.sortIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItineraryDaysCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('date: $date, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityCategoriesTable extends ActivityCategories
    with TableInfo<$ActivityCategoriesTable, ActivityCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('place'),
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconKey,
    colorHex,
    isSystem,
    sortIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      ),
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
    );
  }

  @override
  $ActivityCategoriesTable createAlias(String alias) {
    return $ActivityCategoriesTable(attachedDatabase, alias);
  }
}

class ActivityCategory extends DataClass
    implements Insertable<ActivityCategory> {
  final String id;
  final String name;
  final String iconKey;
  final String? colorHex;
  final bool isSystem;
  final int sortIndex;
  const ActivityCategory({
    required this.id,
    required this.name,
    required this.iconKey,
    this.colorHex,
    required this.isSystem,
    required this.sortIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_key'] = Variable<String>(iconKey);
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<String>(colorHex);
    }
    map['is_system'] = Variable<bool>(isSystem);
    map['sort_index'] = Variable<int>(sortIndex);
    return map;
  }

  ActivityCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ActivityCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      iconKey: Value(iconKey),
      colorHex: colorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(colorHex),
      isSystem: Value(isSystem),
      sortIndex: Value(sortIndex),
    );
  }

  factory ActivityCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      colorHex: serializer.fromJson<String?>(json['colorHex']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconKey': serializer.toJson<String>(iconKey),
      'colorHex': serializer.toJson<String?>(colorHex),
      'isSystem': serializer.toJson<bool>(isSystem),
      'sortIndex': serializer.toJson<int>(sortIndex),
    };
  }

  ActivityCategory copyWith({
    String? id,
    String? name,
    String? iconKey,
    Value<String?> colorHex = const Value.absent(),
    bool? isSystem,
    int? sortIndex,
  }) => ActivityCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    iconKey: iconKey ?? this.iconKey,
    colorHex: colorHex.present ? colorHex.value : this.colorHex,
    isSystem: isSystem ?? this.isSystem,
    sortIndex: sortIndex ?? this.sortIndex,
  );
  ActivityCategory copyWithCompanion(ActivityCategoriesCompanion data) {
    return ActivityCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorHex: $colorHex, ')
          ..write('isSystem: $isSystem, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, iconKey, colorHex, isSystem, sortIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconKey == this.iconKey &&
          other.colorHex == this.colorHex &&
          other.isSystem == this.isSystem &&
          other.sortIndex == this.sortIndex);
}

class ActivityCategoriesCompanion extends UpdateCompanion<ActivityCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconKey;
  final Value<String?> colorHex;
  final Value<bool> isSystem;
  final Value<int> sortIndex;
  final Value<int> rowid;
  const ActivityCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityCategoriesCompanion.insert({
    required String id,
    required String name,
    this.iconKey = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<ActivityCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconKey,
    Expression<String>? colorHex,
    Expression<bool>? isSystem,
    Expression<int>? sortIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconKey != null) 'icon_key': iconKey,
      if (colorHex != null) 'color_hex': colorHex,
      if (isSystem != null) 'is_system': isSystem,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? iconKey,
    Value<String?>? colorHex,
    Value<bool>? isSystem,
    Value<int>? sortIndex,
    Value<int>? rowid,
  }) {
    return ActivityCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorHex: colorHex ?? this.colorHex,
      isSystem: isSystem ?? this.isSystem,
      sortIndex: sortIndex ?? this.sortIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorHex: $colorHex, ')
          ..write('isSystem: $isSystem, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationsTable extends Locations
    with TableInfo<$LocationsTable, Location> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PlaceType?, String> placeType =
      GeneratedColumn<String>(
        'place_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<PlaceType?>($LocationsTable.$converterplaceTypen);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocationSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(LocationSource.manual.name),
      ).withConverter<LocationSource>($LocationsTable.$convertersource);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    label,
    address,
    latitude,
    longitude,
    placeType,
    notes,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Location> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Location map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Location(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      placeType: $LocationsTable.$converterplaceTypen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}place_type'],
        ),
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      source: $LocationsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
    );
  }

  @override
  $LocationsTable createAlias(String alias) {
    return $LocationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PlaceType, String, String> $converterplaceType =
      const EnumNameConverter<PlaceType>(PlaceType.values);
  static JsonTypeConverter2<PlaceType?, String?, String?> $converterplaceTypen =
      JsonTypeConverter2.asNullable($converterplaceType);
  static JsonTypeConverter2<LocationSource, String, String> $convertersource =
      const EnumNameConverter<LocationSource>(LocationSource.values);
}

class Location extends DataClass implements Insertable<Location> {
  final String id;
  final String tripId;
  final String label;
  final String? address;
  final double? latitude;
  final double? longitude;
  final PlaceType? placeType;
  final String? notes;
  final LocationSource source;
  const Location({
    required this.id,
    required this.tripId,
    required this.label,
    this.address,
    this.latitude,
    this.longitude,
    this.placeType,
    this.notes,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || placeType != null) {
      map['place_type'] = Variable<String>(
        $LocationsTable.$converterplaceTypen.toSql(placeType),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    {
      map['source'] = Variable<String>(
        $LocationsTable.$convertersource.toSql(source),
      );
    }
    return map;
  }

  LocationsCompanion toCompanion(bool nullToAbsent) {
    return LocationsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      label: Value(label),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      placeType: placeType == null && nullToAbsent
          ? const Value.absent()
          : Value(placeType),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      source: Value(source),
    );
  }

  factory Location.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Location(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      label: serializer.fromJson<String>(json['label']),
      address: serializer.fromJson<String?>(json['address']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      placeType: $LocationsTable.$converterplaceTypen.fromJson(
        serializer.fromJson<String?>(json['placeType']),
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      source: $LocationsTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'label': serializer.toJson<String>(label),
      'address': serializer.toJson<String?>(address),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'placeType': serializer.toJson<String?>(
        $LocationsTable.$converterplaceTypen.toJson(placeType),
      ),
      'notes': serializer.toJson<String?>(notes),
      'source': serializer.toJson<String>(
        $LocationsTable.$convertersource.toJson(source),
      ),
    };
  }

  Location copyWith({
    String? id,
    String? tripId,
    String? label,
    Value<String?> address = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<PlaceType?> placeType = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    LocationSource? source,
  }) => Location(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    label: label ?? this.label,
    address: address.present ? address.value : this.address,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    placeType: placeType.present ? placeType.value : this.placeType,
    notes: notes.present ? notes.value : this.notes,
    source: source ?? this.source,
  );
  Location copyWithCompanion(LocationsCompanion data) {
    return Location(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      label: data.label.present ? data.label.value : this.label,
      address: data.address.present ? data.address.value : this.address,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      placeType: data.placeType.present ? data.placeType.value : this.placeType,
      notes: data.notes.present ? data.notes.value : this.notes,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Location(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('label: $label, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('placeType: $placeType, ')
          ..write('notes: $notes, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    label,
    address,
    latitude,
    longitude,
    placeType,
    notes,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Location &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.label == this.label &&
          other.address == this.address &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.placeType == this.placeType &&
          other.notes == this.notes &&
          other.source == this.source);
}

class LocationsCompanion extends UpdateCompanion<Location> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> label;
  final Value<String?> address;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<PlaceType?> placeType;
  final Value<String?> notes;
  final Value<LocationSource> source;
  final Value<int> rowid;
  const LocationsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.label = const Value.absent(),
    this.address = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.placeType = const Value.absent(),
    this.notes = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationsCompanion.insert({
    required String id,
    required String tripId,
    required String label,
    this.address = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.placeType = const Value.absent(),
    this.notes = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       label = Value(label);
  static Insertable<Location> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? label,
    Expression<String>? address,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? placeType,
    Expression<String>? notes,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (label != null) 'label': label,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (placeType != null) 'place_type': placeType,
      if (notes != null) 'notes': notes,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationsCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? label,
    Value<String?>? address,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<PlaceType?>? placeType,
    Value<String?>? notes,
    Value<LocationSource>? source,
    Value<int>? rowid,
  }) {
    return LocationsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      label: label ?? this.label,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeType: placeType ?? this.placeType,
      notes: notes ?? this.notes,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (placeType.present) {
      map['place_type'] = Variable<String>(
        $LocationsTable.$converterplaceTypen.toSql(placeType.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $LocationsTable.$convertersource.toSql(source.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('label: $label, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('placeType: $placeType, ')
          ..write('notes: $notes, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivitiesTable extends Activities
    with TableInfo<$ActivitiesTable, Activity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<String> dayId = GeneratedColumn<String>(
    'day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES itinerary_days (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES activity_categories (id)',
    ),
  );
  static const VerificationMeta _startMinutesMeta = const VerificationMeta(
    'startMinutes',
  );
  @override
  late final GeneratedColumn<int> startMinutes = GeneratedColumn<int>(
    'start_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endMinutesMeta = const VerificationMeta(
    'endMinutes',
  );
  @override
  late final GeneratedColumn<int> endMinutes = GeneratedColumn<int>(
    'end_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAllDayMeta = const VerificationMeta(
    'isAllDay',
  );
  @override
  late final GeneratedColumn<bool> isAllDay = GeneratedColumn<bool>(
    'is_all_day',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_all_day" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
    'location_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES locations (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _costCentsMeta = const VerificationMeta(
    'costCents',
  );
  @override
  late final GeneratedColumn<int> costCents = GeneratedColumn<int>(
    'cost_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActivityStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(ActivityStatus.planned.name),
      ).withConverter<ActivityStatus>($ActivitiesTable.$converterstatus);
  static const VerificationMeta _ignoreConflictMeta = const VerificationMeta(
    'ignoreConflict',
  );
  @override
  late final GeneratedColumn<bool> ignoreConflict = GeneratedColumn<bool>(
    'ignore_conflict',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ignore_conflict" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookingRefMeta = const VerificationMeta(
    'bookingRef',
  );
  @override
  late final GeneratedColumn<String> bookingRef = GeneratedColumn<String>(
    'booking_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bookingUrlMeta = const VerificationMeta(
    'bookingUrl',
  );
  @override
  late final GeneratedColumn<String> bookingUrl = GeneratedColumn<String>(
    'booking_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dayId,
    tripId,
    title,
    categoryId,
    startMinutes,
    endMinutes,
    isAllDay,
    locationId,
    costCents,
    currency,
    status,
    ignoreConflict,
    notes,
    bookingRef,
    bookingUrl,
    sortIndex,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Activity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('start_minutes')) {
      context.handle(
        _startMinutesMeta,
        startMinutes.isAcceptableOrUnknown(
          data['start_minutes']!,
          _startMinutesMeta,
        ),
      );
    }
    if (data.containsKey('end_minutes')) {
      context.handle(
        _endMinutesMeta,
        endMinutes.isAcceptableOrUnknown(data['end_minutes']!, _endMinutesMeta),
      );
    }
    if (data.containsKey('is_all_day')) {
      context.handle(
        _isAllDayMeta,
        isAllDay.isAcceptableOrUnknown(data['is_all_day']!, _isAllDayMeta),
      );
    }
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    }
    if (data.containsKey('cost_cents')) {
      context.handle(
        _costCentsMeta,
        costCents.isAcceptableOrUnknown(data['cost_cents']!, _costCentsMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('ignore_conflict')) {
      context.handle(
        _ignoreConflictMeta,
        ignoreConflict.isAcceptableOrUnknown(
          data['ignore_conflict']!,
          _ignoreConflictMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('booking_ref')) {
      context.handle(
        _bookingRefMeta,
        bookingRef.isAcceptableOrUnknown(data['booking_ref']!, _bookingRefMeta),
      );
    }
    if (data.containsKey('booking_url')) {
      context.handle(
        _bookingUrlMeta,
        bookingUrl.isAcceptableOrUnknown(data['booking_url']!, _bookingUrlMeta),
      );
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Activity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Activity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      startMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minutes'],
      ),
      endMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minutes'],
      ),
      isAllDay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_all_day'],
      )!,
      locationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_id'],
      ),
      costCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost_cents'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      status: $ActivitiesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      ignoreConflict: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ignore_conflict'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      bookingRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}booking_ref'],
      ),
      bookingUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}booking_url'],
      ),
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ActivitiesTable createAlias(String alias) {
    return $ActivitiesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActivityStatus, String, String> $converterstatus =
      const EnumNameConverter<ActivityStatus>(ActivityStatus.values);
}

class Activity extends DataClass implements Insertable<Activity> {
  final String id;
  final String dayId;
  final String tripId;
  final String title;
  final String? categoryId;
  final int? startMinutes;
  final int? endMinutes;
  final bool isAllDay;
  final String? locationId;
  final int? costCents;
  final String currency;
  final ActivityStatus status;
  final bool ignoreConflict;
  final String? notes;
  final String? bookingRef;
  final String? bookingUrl;
  final int sortIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Activity({
    required this.id,
    required this.dayId,
    required this.tripId,
    required this.title,
    this.categoryId,
    this.startMinutes,
    this.endMinutes,
    required this.isAllDay,
    this.locationId,
    this.costCents,
    required this.currency,
    required this.status,
    required this.ignoreConflict,
    this.notes,
    this.bookingRef,
    this.bookingUrl,
    required this.sortIndex,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day_id'] = Variable<String>(dayId);
    map['trip_id'] = Variable<String>(tripId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || startMinutes != null) {
      map['start_minutes'] = Variable<int>(startMinutes);
    }
    if (!nullToAbsent || endMinutes != null) {
      map['end_minutes'] = Variable<int>(endMinutes);
    }
    map['is_all_day'] = Variable<bool>(isAllDay);
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<String>(locationId);
    }
    if (!nullToAbsent || costCents != null) {
      map['cost_cents'] = Variable<int>(costCents);
    }
    map['currency'] = Variable<String>(currency);
    {
      map['status'] = Variable<String>(
        $ActivitiesTable.$converterstatus.toSql(status),
      );
    }
    map['ignore_conflict'] = Variable<bool>(ignoreConflict);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || bookingRef != null) {
      map['booking_ref'] = Variable<String>(bookingRef);
    }
    if (!nullToAbsent || bookingUrl != null) {
      map['booking_url'] = Variable<String>(bookingUrl);
    }
    map['sort_index'] = Variable<int>(sortIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ActivitiesCompanion toCompanion(bool nullToAbsent) {
    return ActivitiesCompanion(
      id: Value(id),
      dayId: Value(dayId),
      tripId: Value(tripId),
      title: Value(title),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      startMinutes: startMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(startMinutes),
      endMinutes: endMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(endMinutes),
      isAllDay: Value(isAllDay),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      costCents: costCents == null && nullToAbsent
          ? const Value.absent()
          : Value(costCents),
      currency: Value(currency),
      status: Value(status),
      ignoreConflict: Value(ignoreConflict),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      bookingRef: bookingRef == null && nullToAbsent
          ? const Value.absent()
          : Value(bookingRef),
      bookingUrl: bookingUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(bookingUrl),
      sortIndex: Value(sortIndex),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Activity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Activity(
      id: serializer.fromJson<String>(json['id']),
      dayId: serializer.fromJson<String>(json['dayId']),
      tripId: serializer.fromJson<String>(json['tripId']),
      title: serializer.fromJson<String>(json['title']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      startMinutes: serializer.fromJson<int?>(json['startMinutes']),
      endMinutes: serializer.fromJson<int?>(json['endMinutes']),
      isAllDay: serializer.fromJson<bool>(json['isAllDay']),
      locationId: serializer.fromJson<String?>(json['locationId']),
      costCents: serializer.fromJson<int?>(json['costCents']),
      currency: serializer.fromJson<String>(json['currency']),
      status: $ActivitiesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      ignoreConflict: serializer.fromJson<bool>(json['ignoreConflict']),
      notes: serializer.fromJson<String?>(json['notes']),
      bookingRef: serializer.fromJson<String?>(json['bookingRef']),
      bookingUrl: serializer.fromJson<String?>(json['bookingUrl']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dayId': serializer.toJson<String>(dayId),
      'tripId': serializer.toJson<String>(tripId),
      'title': serializer.toJson<String>(title),
      'categoryId': serializer.toJson<String?>(categoryId),
      'startMinutes': serializer.toJson<int?>(startMinutes),
      'endMinutes': serializer.toJson<int?>(endMinutes),
      'isAllDay': serializer.toJson<bool>(isAllDay),
      'locationId': serializer.toJson<String?>(locationId),
      'costCents': serializer.toJson<int?>(costCents),
      'currency': serializer.toJson<String>(currency),
      'status': serializer.toJson<String>(
        $ActivitiesTable.$converterstatus.toJson(status),
      ),
      'ignoreConflict': serializer.toJson<bool>(ignoreConflict),
      'notes': serializer.toJson<String?>(notes),
      'bookingRef': serializer.toJson<String?>(bookingRef),
      'bookingUrl': serializer.toJson<String?>(bookingUrl),
      'sortIndex': serializer.toJson<int>(sortIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Activity copyWith({
    String? id,
    String? dayId,
    String? tripId,
    String? title,
    Value<String?> categoryId = const Value.absent(),
    Value<int?> startMinutes = const Value.absent(),
    Value<int?> endMinutes = const Value.absent(),
    bool? isAllDay,
    Value<String?> locationId = const Value.absent(),
    Value<int?> costCents = const Value.absent(),
    String? currency,
    ActivityStatus? status,
    bool? ignoreConflict,
    Value<String?> notes = const Value.absent(),
    Value<String?> bookingRef = const Value.absent(),
    Value<String?> bookingUrl = const Value.absent(),
    int? sortIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Activity(
    id: id ?? this.id,
    dayId: dayId ?? this.dayId,
    tripId: tripId ?? this.tripId,
    title: title ?? this.title,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    startMinutes: startMinutes.present ? startMinutes.value : this.startMinutes,
    endMinutes: endMinutes.present ? endMinutes.value : this.endMinutes,
    isAllDay: isAllDay ?? this.isAllDay,
    locationId: locationId.present ? locationId.value : this.locationId,
    costCents: costCents.present ? costCents.value : this.costCents,
    currency: currency ?? this.currency,
    status: status ?? this.status,
    ignoreConflict: ignoreConflict ?? this.ignoreConflict,
    notes: notes.present ? notes.value : this.notes,
    bookingRef: bookingRef.present ? bookingRef.value : this.bookingRef,
    bookingUrl: bookingUrl.present ? bookingUrl.value : this.bookingUrl,
    sortIndex: sortIndex ?? this.sortIndex,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Activity copyWithCompanion(ActivitiesCompanion data) {
    return Activity(
      id: data.id.present ? data.id.value : this.id,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      title: data.title.present ? data.title.value : this.title,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      startMinutes: data.startMinutes.present
          ? data.startMinutes.value
          : this.startMinutes,
      endMinutes: data.endMinutes.present
          ? data.endMinutes.value
          : this.endMinutes,
      isAllDay: data.isAllDay.present ? data.isAllDay.value : this.isAllDay,
      locationId: data.locationId.present
          ? data.locationId.value
          : this.locationId,
      costCents: data.costCents.present ? data.costCents.value : this.costCents,
      currency: data.currency.present ? data.currency.value : this.currency,
      status: data.status.present ? data.status.value : this.status,
      ignoreConflict: data.ignoreConflict.present
          ? data.ignoreConflict.value
          : this.ignoreConflict,
      notes: data.notes.present ? data.notes.value : this.notes,
      bookingRef: data.bookingRef.present
          ? data.bookingRef.value
          : this.bookingRef,
      bookingUrl: data.bookingUrl.present
          ? data.bookingUrl.value
          : this.bookingUrl,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Activity(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('tripId: $tripId, ')
          ..write('title: $title, ')
          ..write('categoryId: $categoryId, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('locationId: $locationId, ')
          ..write('costCents: $costCents, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('ignoreConflict: $ignoreConflict, ')
          ..write('notes: $notes, ')
          ..write('bookingRef: $bookingRef, ')
          ..write('bookingUrl: $bookingUrl, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dayId,
    tripId,
    title,
    categoryId,
    startMinutes,
    endMinutes,
    isAllDay,
    locationId,
    costCents,
    currency,
    status,
    ignoreConflict,
    notes,
    bookingRef,
    bookingUrl,
    sortIndex,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Activity &&
          other.id == this.id &&
          other.dayId == this.dayId &&
          other.tripId == this.tripId &&
          other.title == this.title &&
          other.categoryId == this.categoryId &&
          other.startMinutes == this.startMinutes &&
          other.endMinutes == this.endMinutes &&
          other.isAllDay == this.isAllDay &&
          other.locationId == this.locationId &&
          other.costCents == this.costCents &&
          other.currency == this.currency &&
          other.status == this.status &&
          other.ignoreConflict == this.ignoreConflict &&
          other.notes == this.notes &&
          other.bookingRef == this.bookingRef &&
          other.bookingUrl == this.bookingUrl &&
          other.sortIndex == this.sortIndex &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ActivitiesCompanion extends UpdateCompanion<Activity> {
  final Value<String> id;
  final Value<String> dayId;
  final Value<String> tripId;
  final Value<String> title;
  final Value<String?> categoryId;
  final Value<int?> startMinutes;
  final Value<int?> endMinutes;
  final Value<bool> isAllDay;
  final Value<String?> locationId;
  final Value<int?> costCents;
  final Value<String> currency;
  final Value<ActivityStatus> status;
  final Value<bool> ignoreConflict;
  final Value<String?> notes;
  final Value<String?> bookingRef;
  final Value<String?> bookingUrl;
  final Value<int> sortIndex;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ActivitiesCompanion({
    this.id = const Value.absent(),
    this.dayId = const Value.absent(),
    this.tripId = const Value.absent(),
    this.title = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.endMinutes = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.locationId = const Value.absent(),
    this.costCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.ignoreConflict = const Value.absent(),
    this.notes = const Value.absent(),
    this.bookingRef = const Value.absent(),
    this.bookingUrl = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivitiesCompanion.insert({
    required String id,
    required String dayId,
    required String tripId,
    required String title,
    this.categoryId = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.endMinutes = const Value.absent(),
    this.isAllDay = const Value.absent(),
    this.locationId = const Value.absent(),
    this.costCents = const Value.absent(),
    this.currency = const Value.absent(),
    this.status = const Value.absent(),
    this.ignoreConflict = const Value.absent(),
    this.notes = const Value.absent(),
    this.bookingRef = const Value.absent(),
    this.bookingUrl = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dayId = Value(dayId),
       tripId = Value(tripId),
       title = Value(title);
  static Insertable<Activity> custom({
    Expression<String>? id,
    Expression<String>? dayId,
    Expression<String>? tripId,
    Expression<String>? title,
    Expression<String>? categoryId,
    Expression<int>? startMinutes,
    Expression<int>? endMinutes,
    Expression<bool>? isAllDay,
    Expression<String>? locationId,
    Expression<int>? costCents,
    Expression<String>? currency,
    Expression<String>? status,
    Expression<bool>? ignoreConflict,
    Expression<String>? notes,
    Expression<String>? bookingRef,
    Expression<String>? bookingUrl,
    Expression<int>? sortIndex,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayId != null) 'day_id': dayId,
      if (tripId != null) 'trip_id': tripId,
      if (title != null) 'title': title,
      if (categoryId != null) 'category_id': categoryId,
      if (startMinutes != null) 'start_minutes': startMinutes,
      if (endMinutes != null) 'end_minutes': endMinutes,
      if (isAllDay != null) 'is_all_day': isAllDay,
      if (locationId != null) 'location_id': locationId,
      if (costCents != null) 'cost_cents': costCents,
      if (currency != null) 'currency': currency,
      if (status != null) 'status': status,
      if (ignoreConflict != null) 'ignore_conflict': ignoreConflict,
      if (notes != null) 'notes': notes,
      if (bookingRef != null) 'booking_ref': bookingRef,
      if (bookingUrl != null) 'booking_url': bookingUrl,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? dayId,
    Value<String>? tripId,
    Value<String>? title,
    Value<String?>? categoryId,
    Value<int?>? startMinutes,
    Value<int?>? endMinutes,
    Value<bool>? isAllDay,
    Value<String?>? locationId,
    Value<int?>? costCents,
    Value<String>? currency,
    Value<ActivityStatus>? status,
    Value<bool>? ignoreConflict,
    Value<String?>? notes,
    Value<String?>? bookingRef,
    Value<String?>? bookingUrl,
    Value<int>? sortIndex,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ActivitiesCompanion(
      id: id ?? this.id,
      dayId: dayId ?? this.dayId,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      isAllDay: isAllDay ?? this.isAllDay,
      locationId: locationId ?? this.locationId,
      costCents: costCents ?? this.costCents,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      ignoreConflict: ignoreConflict ?? this.ignoreConflict,
      notes: notes ?? this.notes,
      bookingRef: bookingRef ?? this.bookingRef,
      bookingUrl: bookingUrl ?? this.bookingUrl,
      sortIndex: sortIndex ?? this.sortIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<String>(dayId.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (startMinutes.present) {
      map['start_minutes'] = Variable<int>(startMinutes.value);
    }
    if (endMinutes.present) {
      map['end_minutes'] = Variable<int>(endMinutes.value);
    }
    if (isAllDay.present) {
      map['is_all_day'] = Variable<bool>(isAllDay.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (costCents.present) {
      map['cost_cents'] = Variable<int>(costCents.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ActivitiesTable.$converterstatus.toSql(status.value),
      );
    }
    if (ignoreConflict.present) {
      map['ignore_conflict'] = Variable<bool>(ignoreConflict.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (bookingRef.present) {
      map['booking_ref'] = Variable<String>(bookingRef.value);
    }
    if (bookingUrl.present) {
      map['booking_url'] = Variable<String>(bookingUrl.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('dayId: $dayId, ')
          ..write('tripId: $tripId, ')
          ..write('title: $title, ')
          ..write('categoryId: $categoryId, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('isAllDay: $isAllDay, ')
          ..write('locationId: $locationId, ')
          ..write('costCents: $costCents, ')
          ..write('currency: $currency, ')
          ..write('status: $status, ')
          ..write('ignoreConflict: $ignoreConflict, ')
          ..write('notes: $notes, ')
          ..write('bookingRef: $bookingRef, ')
          ..write('bookingUrl: $bookingUrl, ')
          ..write('sortIndex: $sortIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $TravelersTable travelers = $TravelersTable(this);
  late final $PackingCategoriesTable packingCategories =
      $PackingCategoriesTable(this);
  late final $BagsTable bags = $BagsTable(this);
  late final $PackingItemsTable packingItems = $PackingItemsTable(this);
  late final $PackingTemplatesTable packingTemplates = $PackingTemplatesTable(
    this,
  );
  late final $PackingTemplateItemsTable packingTemplateItems =
      $PackingTemplateItemsTable(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $TransportSegmentsTable transportSegments =
      $TransportSegmentsTable(this);
  late final $CostItemsTable costItems = $CostItemsTable(this);
  late final $CostSplitsTable costSplits = $CostSplitsTable(this);
  late final $ItineraryDaysTable itineraryDays = $ItineraryDaysTable(this);
  late final $ActivityCategoriesTable activityCategories =
      $ActivityCategoriesTable(this);
  late final $LocationsTable locations = $LocationsTable(this);
  late final $ActivitiesTable activities = $ActivitiesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettings,
    trips,
    travelers,
    packingCategories,
    bags,
    packingItems,
    packingTemplates,
    packingTemplateItems,
    vehicles,
    transportSegments,
    costItems,
    costSplits,
    itineraryDays,
    activityCategories,
    locations,
    activities,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('travelers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('bags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('packing_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('packing_items', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'packing_templates',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('packing_template_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transport_segments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transport_segments', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cost_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'transport_segments',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cost_items', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'travelers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cost_items', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cost_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cost_splits', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'travelers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cost_splits', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('itinerary_days', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('locations', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'itinerary_days',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('activities', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('activities', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'locations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('activities', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> languageCode,
      Value<String> currencyCode,
      Value<UnitSystem> unitSystem,
      Value<double> defaultFuelConsumption,
      Value<int> defaultFuelPriceCents,
      Value<FuelType> defaultFuelType,
      Value<bool> modeChosen,
      Value<AppMode> appMode,
      Value<String?> serverUrl,
      Value<String?> remoteUsername,
      Value<String?> authToken,
      Value<DateTime?> lastSyncAt,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<String> languageCode,
      Value<String> currencyCode,
      Value<UnitSystem> unitSystem,
      Value<double> defaultFuelConsumption,
      Value<int> defaultFuelPriceCents,
      Value<FuelType> defaultFuelType,
      Value<bool> modeChosen,
      Value<AppMode> appMode,
      Value<String?> serverUrl,
      Value<String?> remoteUsername,
      Value<String?> authToken,
      Value<DateTime?> lastSyncAt,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<UnitSystem, UnitSystem, String>
  get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get defaultFuelConsumption => $composableBuilder(
    column: $table.defaultFuelConsumption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultFuelPriceCents => $composableBuilder(
    column: $table.defaultFuelPriceCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FuelType, FuelType, String>
  get defaultFuelType => $composableBuilder(
    column: $table.defaultFuelType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get modeChosen => $composableBuilder(
    column: $table.modeChosen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AppMode, AppMode, String> get appMode =>
      $composableBuilder(
        column: $table.appMode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get serverUrl => $composableBuilder(
    column: $table.serverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUsername => $composableBuilder(
    column: $table.remoteUsername,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authToken => $composableBuilder(
    column: $table.authToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitSystem => $composableBuilder(
    column: $table.unitSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultFuelConsumption => $composableBuilder(
    column: $table.defaultFuelConsumption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultFuelPriceCents => $composableBuilder(
    column: $table.defaultFuelPriceCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultFuelType => $composableBuilder(
    column: $table.defaultFuelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get modeChosen => $composableBuilder(
    column: $table.modeChosen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appMode => $composableBuilder(
    column: $table.appMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverUrl => $composableBuilder(
    column: $table.serverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUsername => $composableBuilder(
    column: $table.remoteUsername,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authToken => $composableBuilder(
    column: $table.authToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<UnitSystem, String> get unitSystem =>
      $composableBuilder(
        column: $table.unitSystem,
        builder: (column) => column,
      );

  GeneratedColumn<double> get defaultFuelConsumption => $composableBuilder(
    column: $table.defaultFuelConsumption,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultFuelPriceCents => $composableBuilder(
    column: $table.defaultFuelPriceCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<FuelType, String> get defaultFuelType =>
      $composableBuilder(
        column: $table.defaultFuelType,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get modeChosen => $composableBuilder(
    column: $table.modeChosen,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AppMode, String> get appMode =>
      $composableBuilder(column: $table.appMode, builder: (column) => column);

  GeneratedColumn<String> get serverUrl =>
      $composableBuilder(column: $table.serverUrl, builder: (column) => column);

  GeneratedColumn<String> get remoteUsername => $composableBuilder(
    column: $table.remoteUsername,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authToken =>
      $composableBuilder(column: $table.authToken, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt => $composableBuilder(
    column: $table.lastSyncAt,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<UnitSystem> unitSystem = const Value.absent(),
                Value<double> defaultFuelConsumption = const Value.absent(),
                Value<int> defaultFuelPriceCents = const Value.absent(),
                Value<FuelType> defaultFuelType = const Value.absent(),
                Value<bool> modeChosen = const Value.absent(),
                Value<AppMode> appMode = const Value.absent(),
                Value<String?> serverUrl = const Value.absent(),
                Value<String?> remoteUsername = const Value.absent(),
                Value<String?> authToken = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                languageCode: languageCode,
                currencyCode: currencyCode,
                unitSystem: unitSystem,
                defaultFuelConsumption: defaultFuelConsumption,
                defaultFuelPriceCents: defaultFuelPriceCents,
                defaultFuelType: defaultFuelType,
                modeChosen: modeChosen,
                appMode: appMode,
                serverUrl: serverUrl,
                remoteUsername: remoteUsername,
                authToken: authToken,
                lastSyncAt: lastSyncAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<UnitSystem> unitSystem = const Value.absent(),
                Value<double> defaultFuelConsumption = const Value.absent(),
                Value<int> defaultFuelPriceCents = const Value.absent(),
                Value<FuelType> defaultFuelType = const Value.absent(),
                Value<bool> modeChosen = const Value.absent(),
                Value<AppMode> appMode = const Value.absent(),
                Value<String?> serverUrl = const Value.absent(),
                Value<String?> remoteUsername = const Value.absent(),
                Value<String?> authToken = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                languageCode: languageCode,
                currencyCode: currencyCode,
                unitSystem: unitSystem,
                defaultFuelConsumption: defaultFuelConsumption,
                defaultFuelPriceCents: defaultFuelPriceCents,
                defaultFuelType: defaultFuelType,
                modeChosen: modeChosen,
                appMode: appMode,
                serverUrl: serverUrl,
                remoteUsername: remoteUsername,
                authToken: authToken,
                lastSyncAt: lastSyncAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$TripsTableCreateCompanionBuilder =
    TripsCompanion Function({
      required String id,
      required String name,
      Value<String?> destination,
      Value<String?> country,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<TripType> tripType,
      Value<Climate> climate,
      Value<int> travelerCount,
      Value<String> homeCurrency,
      Value<String?> coverImagePath,
      Value<TripStyle?> themeStyle,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$TripsTableUpdateCompanionBuilder =
    TripsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> destination,
      Value<String?> country,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<TripType> tripType,
      Value<Climate> climate,
      Value<int> travelerCount,
      Value<String> homeCurrency,
      Value<String?> coverImagePath,
      Value<TripStyle?> themeStyle,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TripsTableReferences
    extends BaseReferences<_$AppDatabase, $TripsTable, Trip> {
  $$TripsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TravelersTable, List<Traveler>>
  _travelersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.travelers,
    aliasName: $_aliasNameGenerator(db.trips.id, db.travelers.tripId),
  );

  $$TravelersTableProcessedTableManager get travelersRefs {
    final manager = $$TravelersTableTableManager(
      $_db,
      $_db.travelers,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_travelersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BagsTable, List<Bag>> _bagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.bags,
    aliasName: $_aliasNameGenerator(db.trips.id, db.bags.tripId),
  );

  $$BagsTableProcessedTableManager get bagsRefs {
    final manager = $$BagsTableTableManager(
      $_db,
      $_db.bags,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PackingItemsTable, List<PackingItem>>
  _packingItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.packingItems,
    aliasName: $_aliasNameGenerator(db.trips.id, db.packingItems.tripId),
  );

  $$PackingItemsTableProcessedTableManager get packingItemsRefs {
    final manager = $$PackingItemsTableTableManager(
      $_db,
      $_db.packingItems,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_packingItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransportSegmentsTable, List<TransportSegment>>
  _transportSegmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transportSegments,
        aliasName: $_aliasNameGenerator(
          db.trips.id,
          db.transportSegments.tripId,
        ),
      );

  $$TransportSegmentsTableProcessedTableManager get transportSegmentsRefs {
    final manager = $$TransportSegmentsTableTableManager(
      $_db,
      $_db.transportSegments,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transportSegmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CostItemsTable, List<CostItem>>
  _costItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.costItems,
    aliasName: $_aliasNameGenerator(db.trips.id, db.costItems.tripId),
  );

  $$CostItemsTableProcessedTableManager get costItemsRefs {
    final manager = $$CostItemsTableTableManager(
      $_db,
      $_db.costItems,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_costItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ItineraryDaysTable, List<ItineraryDay>>
  _itineraryDaysRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.itineraryDays,
    aliasName: $_aliasNameGenerator(db.trips.id, db.itineraryDays.tripId),
  );

  $$ItineraryDaysTableProcessedTableManager get itineraryDaysRefs {
    final manager = $$ItineraryDaysTableTableManager(
      $_db,
      $_db.itineraryDays,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itineraryDaysRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LocationsTable, List<Location>>
  _locationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.locations,
    aliasName: $_aliasNameGenerator(db.trips.id, db.locations.tripId),
  );

  $$LocationsTableProcessedTableManager get locationsRefs {
    final manager = $$LocationsTableTableManager(
      $_db,
      $_db.locations,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_locationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActivitiesTable, List<Activity>>
  _activitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activities,
    aliasName: $_aliasNameGenerator(db.trips.id, db.activities.tripId),
  );

  $$ActivitiesTableProcessedTableManager get activitiesRefs {
    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TripType, TripType, String> get tripType =>
      $composableBuilder(
        column: $table.tripType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Climate, Climate, String> get climate =>
      $composableBuilder(
        column: $table.climate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get travelerCount => $composableBuilder(
    column: $table.travelerCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeCurrency => $composableBuilder(
    column: $table.homeCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TripStyle?, TripStyle, String>
  get themeStyle => $composableBuilder(
    column: $table.themeStyle,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> travelersRefs(
    Expression<bool> Function($$TravelersTableFilterComposer f) f,
  ) {
    final $$TravelersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.travelers,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TravelersTableFilterComposer(
            $db: $db,
            $table: $db.travelers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bagsRefs(
    Expression<bool> Function($$BagsTableFilterComposer f) f,
  ) {
    final $$BagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bags,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BagsTableFilterComposer(
            $db: $db,
            $table: $db.bags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> packingItemsRefs(
    Expression<bool> Function($$PackingItemsTableFilterComposer f) f,
  ) {
    final $$PackingItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.packingItems,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackingItemsTableFilterComposer(
            $db: $db,
            $table: $db.packingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transportSegmentsRefs(
    Expression<bool> Function($$TransportSegmentsTableFilterComposer f) f,
  ) {
    final $$TransportSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transportSegments,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransportSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.transportSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> costItemsRefs(
    Expression<bool> Function($$CostItemsTableFilterComposer f) f,
  ) {
    final $$CostItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.costItems,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostItemsTableFilterComposer(
            $db: $db,
            $table: $db.costItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> itineraryDaysRefs(
    Expression<bool> Function($$ItineraryDaysTableFilterComposer f) f,
  ) {
    final $$ItineraryDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itineraryDays,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItineraryDaysTableFilterComposer(
            $db: $db,
            $table: $db.itineraryDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> locationsRefs(
    Expression<bool> Function($$LocationsTableFilterComposer f) f,
  ) {
    final $$LocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableFilterComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> activitiesRefs(
    Expression<bool> Function($$ActivitiesTableFilterComposer f) f,
  ) {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripType => $composableBuilder(
    column: $table.tripType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get climate => $composableBuilder(
    column: $table.climate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get travelerCount => $composableBuilder(
    column: $table.travelerCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeCurrency => $composableBuilder(
    column: $table.homeCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeStyle => $composableBuilder(
    column: $table.themeStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => column,
  );

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TripType, String> get tripType =>
      $composableBuilder(column: $table.tripType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Climate, String> get climate =>
      $composableBuilder(column: $table.climate, builder: (column) => column);

  GeneratedColumn<int> get travelerCount => $composableBuilder(
    column: $table.travelerCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get homeCurrency => $composableBuilder(
    column: $table.homeCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TripStyle?, String> get themeStyle =>
      $composableBuilder(
        column: $table.themeStyle,
        builder: (column) => column,
      );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> travelersRefs<T extends Object>(
    Expression<T> Function($$TravelersTableAnnotationComposer a) f,
  ) {
    final $$TravelersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.travelers,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TravelersTableAnnotationComposer(
            $db: $db,
            $table: $db.travelers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bagsRefs<T extends Object>(
    Expression<T> Function($$BagsTableAnnotationComposer a) f,
  ) {
    final $$BagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bags,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BagsTableAnnotationComposer(
            $db: $db,
            $table: $db.bags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> packingItemsRefs<T extends Object>(
    Expression<T> Function($$PackingItemsTableAnnotationComposer a) f,
  ) {
    final $$PackingItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.packingItems,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackingItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.packingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transportSegmentsRefs<T extends Object>(
    Expression<T> Function($$TransportSegmentsTableAnnotationComposer a) f,
  ) {
    final $$TransportSegmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transportSegments,
          getReferencedColumn: (t) => t.tripId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransportSegmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.transportSegments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> costItemsRefs<T extends Object>(
    Expression<T> Function($$CostItemsTableAnnotationComposer a) f,
  ) {
    final $$CostItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.costItems,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.costItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> itineraryDaysRefs<T extends Object>(
    Expression<T> Function($$ItineraryDaysTableAnnotationComposer a) f,
  ) {
    final $$ItineraryDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itineraryDays,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItineraryDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.itineraryDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> locationsRefs<T extends Object>(
    Expression<T> Function($$LocationsTableAnnotationComposer a) f,
  ) {
    final $$LocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> activitiesRefs<T extends Object>(
    Expression<T> Function($$ActivitiesTableAnnotationComposer a) f,
  ) {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTable,
          Trip,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (Trip, $$TripsTableReferences),
          Trip,
          PrefetchHooks Function({
            bool travelersRefs,
            bool bagsRefs,
            bool packingItemsRefs,
            bool transportSegmentsRefs,
            bool costItemsRefs,
            bool itineraryDaysRefs,
            bool locationsRefs,
            bool activitiesRefs,
          })
        > {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> destination = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<TripType> tripType = const Value.absent(),
                Value<Climate> climate = const Value.absent(),
                Value<int> travelerCount = const Value.absent(),
                Value<String> homeCurrency = const Value.absent(),
                Value<String?> coverImagePath = const Value.absent(),
                Value<TripStyle?> themeStyle = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                name: name,
                destination: destination,
                country: country,
                startDate: startDate,
                endDate: endDate,
                tripType: tripType,
                climate: climate,
                travelerCount: travelerCount,
                homeCurrency: homeCurrency,
                coverImagePath: coverImagePath,
                themeStyle: themeStyle,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> destination = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<TripType> tripType = const Value.absent(),
                Value<Climate> climate = const Value.absent(),
                Value<int> travelerCount = const Value.absent(),
                Value<String> homeCurrency = const Value.absent(),
                Value<String?> coverImagePath = const Value.absent(),
                Value<TripStyle?> themeStyle = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                name: name,
                destination: destination,
                country: country,
                startDate: startDate,
                endDate: endDate,
                tripType: tripType,
                climate: climate,
                travelerCount: travelerCount,
                homeCurrency: homeCurrency,
                coverImagePath: coverImagePath,
                themeStyle: themeStyle,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TripsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                travelersRefs = false,
                bagsRefs = false,
                packingItemsRefs = false,
                transportSegmentsRefs = false,
                costItemsRefs = false,
                itineraryDaysRefs = false,
                locationsRefs = false,
                activitiesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (travelersRefs) db.travelers,
                    if (bagsRefs) db.bags,
                    if (packingItemsRefs) db.packingItems,
                    if (transportSegmentsRefs) db.transportSegments,
                    if (costItemsRefs) db.costItems,
                    if (itineraryDaysRefs) db.itineraryDays,
                    if (locationsRefs) db.locations,
                    if (activitiesRefs) db.activities,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (travelersRefs)
                        await $_getPrefetchedData<Trip, $TripsTable, Traveler>(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._travelersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).travelersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bagsRefs)
                        await $_getPrefetchedData<Trip, $TripsTable, Bag>(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._bagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(db, table, p0).bagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (packingItemsRefs)
                        await $_getPrefetchedData<
                          Trip,
                          $TripsTable,
                          PackingItem
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._packingItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).packingItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transportSegmentsRefs)
                        await $_getPrefetchedData<
                          Trip,
                          $TripsTable,
                          TransportSegment
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._transportSegmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).transportSegmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (costItemsRefs)
                        await $_getPrefetchedData<Trip, $TripsTable, CostItem>(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._costItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).costItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (itineraryDaysRefs)
                        await $_getPrefetchedData<
                          Trip,
                          $TripsTable,
                          ItineraryDay
                        >(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._itineraryDaysRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).itineraryDaysRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (locationsRefs)
                        await $_getPrefetchedData<Trip, $TripsTable, Location>(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._locationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).locationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (activitiesRefs)
                        await $_getPrefetchedData<Trip, $TripsTable, Activity>(
                          currentTable: table,
                          referencedTable: $$TripsTableReferences
                              ._activitiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TripsTableReferences(
                                db,
                                table,
                                p0,
                              ).activitiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tripId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTable,
      Trip,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (Trip, $$TripsTableReferences),
      Trip,
      PrefetchHooks Function({
        bool travelersRefs,
        bool bagsRefs,
        bool packingItemsRefs,
        bool transportSegmentsRefs,
        bool costItemsRefs,
        bool itineraryDaysRefs,
        bool locationsRefs,
        bool activitiesRefs,
      })
    >;
typedef $$TravelersTableCreateCompanionBuilder =
    TravelersCompanion Function({
      required String id,
      required String tripId,
      required String name,
      Value<double> shareWeight,
      Value<String?> colorHex,
      Value<bool> isSelfUser,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$TravelersTableUpdateCompanionBuilder =
    TravelersCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String> name,
      Value<double> shareWeight,
      Value<String?> colorHex,
      Value<bool> isSelfUser,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$TravelersTableReferences
    extends BaseReferences<_$AppDatabase, $TravelersTable, Traveler> {
  $$TravelersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) => db.trips.createAlias(
    $_aliasNameGenerator(db.travelers.tripId, db.trips.id),
  );

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CostItemsTable, List<CostItem>>
  _costItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.costItems,
    aliasName: $_aliasNameGenerator(
      db.travelers.id,
      db.costItems.paidByTravelerId,
    ),
  );

  $$CostItemsTableProcessedTableManager get costItemsRefs {
    final manager = $$CostItemsTableTableManager($_db, $_db.costItems).filter(
      (f) => f.paidByTravelerId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_costItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CostSplitsTable, List<CostSplit>>
  _costSplitsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.costSplits,
    aliasName: $_aliasNameGenerator(db.travelers.id, db.costSplits.travelerId),
  );

  $$CostSplitsTableProcessedTableManager get costSplitsRefs {
    final manager = $$CostSplitsTableTableManager(
      $_db,
      $_db.costSplits,
    ).filter((f) => f.travelerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_costSplitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TravelersTableFilterComposer
    extends Composer<_$AppDatabase, $TravelersTable> {
  $$TravelersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get shareWeight => $composableBuilder(
    column: $table.shareWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSelfUser => $composableBuilder(
    column: $table.isSelfUser,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> costItemsRefs(
    Expression<bool> Function($$CostItemsTableFilterComposer f) f,
  ) {
    final $$CostItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.costItems,
      getReferencedColumn: (t) => t.paidByTravelerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostItemsTableFilterComposer(
            $db: $db,
            $table: $db.costItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> costSplitsRefs(
    Expression<bool> Function($$CostSplitsTableFilterComposer f) f,
  ) {
    final $$CostSplitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.costSplits,
      getReferencedColumn: (t) => t.travelerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostSplitsTableFilterComposer(
            $db: $db,
            $table: $db.costSplits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TravelersTableOrderingComposer
    extends Composer<_$AppDatabase, $TravelersTable> {
  $$TravelersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get shareWeight => $composableBuilder(
    column: $table.shareWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSelfUser => $composableBuilder(
    column: $table.isSelfUser,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TravelersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TravelersTable> {
  $$TravelersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get shareWeight => $composableBuilder(
    column: $table.shareWeight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<bool> get isSelfUser => $composableBuilder(
    column: $table.isSelfUser,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> costItemsRefs<T extends Object>(
    Expression<T> Function($$CostItemsTableAnnotationComposer a) f,
  ) {
    final $$CostItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.costItems,
      getReferencedColumn: (t) => t.paidByTravelerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.costItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> costSplitsRefs<T extends Object>(
    Expression<T> Function($$CostSplitsTableAnnotationComposer a) f,
  ) {
    final $$CostSplitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.costSplits,
      getReferencedColumn: (t) => t.travelerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostSplitsTableAnnotationComposer(
            $db: $db,
            $table: $db.costSplits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TravelersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TravelersTable,
          Traveler,
          $$TravelersTableFilterComposer,
          $$TravelersTableOrderingComposer,
          $$TravelersTableAnnotationComposer,
          $$TravelersTableCreateCompanionBuilder,
          $$TravelersTableUpdateCompanionBuilder,
          (Traveler, $$TravelersTableReferences),
          Traveler,
          PrefetchHooks Function({
            bool tripId,
            bool costItemsRefs,
            bool costSplitsRefs,
          })
        > {
  $$TravelersTableTableManager(_$AppDatabase db, $TravelersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TravelersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TravelersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TravelersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> shareWeight = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<bool> isSelfUser = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TravelersCompanion(
                id: id,
                tripId: tripId,
                name: name,
                shareWeight: shareWeight,
                colorHex: colorHex,
                isSelfUser: isSelfUser,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String name,
                Value<double> shareWeight = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<bool> isSelfUser = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TravelersCompanion.insert(
                id: id,
                tripId: tripId,
                name: name,
                shareWeight: shareWeight,
                colorHex: colorHex,
                isSelfUser: isSelfUser,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TravelersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tripId = false,
                costItemsRefs = false,
                costSplitsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (costItemsRefs) db.costItems,
                    if (costSplitsRefs) db.costSplits,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tripId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tripId,
                                    referencedTable: $$TravelersTableReferences
                                        ._tripIdTable(db),
                                    referencedColumn: $$TravelersTableReferences
                                        ._tripIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (costItemsRefs)
                        await $_getPrefetchedData<
                          Traveler,
                          $TravelersTable,
                          CostItem
                        >(
                          currentTable: table,
                          referencedTable: $$TravelersTableReferences
                              ._costItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TravelersTableReferences(
                                db,
                                table,
                                p0,
                              ).costItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.paidByTravelerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (costSplitsRefs)
                        await $_getPrefetchedData<
                          Traveler,
                          $TravelersTable,
                          CostSplit
                        >(
                          currentTable: table,
                          referencedTable: $$TravelersTableReferences
                              ._costSplitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TravelersTableReferences(
                                db,
                                table,
                                p0,
                              ).costSplitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.travelerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TravelersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TravelersTable,
      Traveler,
      $$TravelersTableFilterComposer,
      $$TravelersTableOrderingComposer,
      $$TravelersTableAnnotationComposer,
      $$TravelersTableCreateCompanionBuilder,
      $$TravelersTableUpdateCompanionBuilder,
      (Traveler, $$TravelersTableReferences),
      Traveler,
      PrefetchHooks Function({
        bool tripId,
        bool costItemsRefs,
        bool costSplitsRefs,
      })
    >;
typedef $$PackingCategoriesTableCreateCompanionBuilder =
    PackingCategoriesCompanion Function({
      required String id,
      required String name,
      Value<String> iconKey,
      Value<String?> colorHex,
      Value<bool> isSystem,
      Value<bool> isHidden,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$PackingCategoriesTableUpdateCompanionBuilder =
    PackingCategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> iconKey,
      Value<String?> colorHex,
      Value<bool> isSystem,
      Value<bool> isHidden,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$PackingCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PackingCategoriesTable,
          PackingCategory
        > {
  $$PackingCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$PackingItemsTable, List<PackingItem>>
  _packingItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.packingItems,
    aliasName: $_aliasNameGenerator(
      db.packingCategories.id,
      db.packingItems.categoryId,
    ),
  );

  $$PackingItemsTableProcessedTableManager get packingItemsRefs {
    final manager = $$PackingItemsTableTableManager(
      $_db,
      $_db.packingItems,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_packingItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PackingCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $PackingCategoriesTable> {
  $$PackingCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> packingItemsRefs(
    Expression<bool> Function($$PackingItemsTableFilterComposer f) f,
  ) {
    final $$PackingItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.packingItems,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackingItemsTableFilterComposer(
            $db: $db,
            $table: $db.packingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PackingCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PackingCategoriesTable> {
  $$PackingCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PackingCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PackingCategoriesTable> {
  $$PackingCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> packingItemsRefs<T extends Object>(
    Expression<T> Function($$PackingItemsTableAnnotationComposer a) f,
  ) {
    final $$PackingItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.packingItems,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackingItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.packingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PackingCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PackingCategoriesTable,
          PackingCategory,
          $$PackingCategoriesTableFilterComposer,
          $$PackingCategoriesTableOrderingComposer,
          $$PackingCategoriesTableAnnotationComposer,
          $$PackingCategoriesTableCreateCompanionBuilder,
          $$PackingCategoriesTableUpdateCompanionBuilder,
          (PackingCategory, $$PackingCategoriesTableReferences),
          PackingCategory,
          PrefetchHooks Function({bool packingItemsRefs})
        > {
  $$PackingCategoriesTableTableManager(
    _$AppDatabase db,
    $PackingCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PackingCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PackingCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PackingCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PackingCategoriesCompanion(
                id: id,
                name: name,
                iconKey: iconKey,
                colorHex: colorHex,
                isSystem: isSystem,
                isHidden: isHidden,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> iconKey = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PackingCategoriesCompanion.insert(
                id: id,
                name: name,
                iconKey: iconKey,
                colorHex: colorHex,
                isSystem: isSystem,
                isHidden: isHidden,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PackingCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packingItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (packingItemsRefs) db.packingItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (packingItemsRefs)
                    await $_getPrefetchedData<
                      PackingCategory,
                      $PackingCategoriesTable,
                      PackingItem
                    >(
                      currentTable: table,
                      referencedTable: $$PackingCategoriesTableReferences
                          ._packingItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PackingCategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).packingItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PackingCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PackingCategoriesTable,
      PackingCategory,
      $$PackingCategoriesTableFilterComposer,
      $$PackingCategoriesTableOrderingComposer,
      $$PackingCategoriesTableAnnotationComposer,
      $$PackingCategoriesTableCreateCompanionBuilder,
      $$PackingCategoriesTableUpdateCompanionBuilder,
      (PackingCategory, $$PackingCategoriesTableReferences),
      PackingCategory,
      PrefetchHooks Function({bool packingItemsRefs})
    >;
typedef $$BagsTableCreateCompanionBuilder =
    BagsCompanion Function({
      required String id,
      required String tripId,
      required String name,
      Value<BagType> type,
      Value<int> tareWeightGrams,
      Value<int?> maxWeightGrams,
      Value<String?> colorHex,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$BagsTableUpdateCompanionBuilder =
    BagsCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String> name,
      Value<BagType> type,
      Value<int> tareWeightGrams,
      Value<int?> maxWeightGrams,
      Value<String?> colorHex,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$BagsTableReferences
    extends BaseReferences<_$AppDatabase, $BagsTable, Bag> {
  $$BagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias($_aliasNameGenerator(db.bags.tripId, db.trips.id));

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PackingItemsTable, List<PackingItem>>
  _packingItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.packingItems,
    aliasName: $_aliasNameGenerator(db.bags.id, db.packingItems.bagId),
  );

  $$PackingItemsTableProcessedTableManager get packingItemsRefs {
    final manager = $$PackingItemsTableTableManager(
      $_db,
      $_db.packingItems,
    ).filter((f) => f.bagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_packingItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BagsTableFilterComposer extends Composer<_$AppDatabase, $BagsTable> {
  $$BagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BagType, BagType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get tareWeightGrams => $composableBuilder(
    column: $table.tareWeightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxWeightGrams => $composableBuilder(
    column: $table.maxWeightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> packingItemsRefs(
    Expression<bool> Function($$PackingItemsTableFilterComposer f) f,
  ) {
    final $$PackingItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.packingItems,
      getReferencedColumn: (t) => t.bagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackingItemsTableFilterComposer(
            $db: $db,
            $table: $db.packingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BagsTableOrderingComposer extends Composer<_$AppDatabase, $BagsTable> {
  $$BagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tareWeightGrams => $composableBuilder(
    column: $table.tareWeightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxWeightGrams => $composableBuilder(
    column: $table.maxWeightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BagsTable> {
  $$BagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BagType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get tareWeightGrams => $composableBuilder(
    column: $table.tareWeightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxWeightGrams => $composableBuilder(
    column: $table.maxWeightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> packingItemsRefs<T extends Object>(
    Expression<T> Function($$PackingItemsTableAnnotationComposer a) f,
  ) {
    final $$PackingItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.packingItems,
      getReferencedColumn: (t) => t.bagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackingItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.packingItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BagsTable,
          Bag,
          $$BagsTableFilterComposer,
          $$BagsTableOrderingComposer,
          $$BagsTableAnnotationComposer,
          $$BagsTableCreateCompanionBuilder,
          $$BagsTableUpdateCompanionBuilder,
          (Bag, $$BagsTableReferences),
          Bag,
          PrefetchHooks Function({bool tripId, bool packingItemsRefs})
        > {
  $$BagsTableTableManager(_$AppDatabase db, $BagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<BagType> type = const Value.absent(),
                Value<int> tareWeightGrams = const Value.absent(),
                Value<int?> maxWeightGrams = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BagsCompanion(
                id: id,
                tripId: tripId,
                name: name,
                type: type,
                tareWeightGrams: tareWeightGrams,
                maxWeightGrams: maxWeightGrams,
                colorHex: colorHex,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String name,
                Value<BagType> type = const Value.absent(),
                Value<int> tareWeightGrams = const Value.absent(),
                Value<int?> maxWeightGrams = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BagsCompanion.insert(
                id: id,
                tripId: tripId,
                name: name,
                type: type,
                tareWeightGrams: tareWeightGrams,
                maxWeightGrams: maxWeightGrams,
                colorHex: colorHex,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({tripId = false, packingItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (packingItemsRefs) db.packingItems],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tripId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tripId,
                                referencedTable: $$BagsTableReferences
                                    ._tripIdTable(db),
                                referencedColumn: $$BagsTableReferences
                                    ._tripIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (packingItemsRefs)
                    await $_getPrefetchedData<Bag, $BagsTable, PackingItem>(
                      currentTable: table,
                      referencedTable: $$BagsTableReferences
                          ._packingItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BagsTableReferences(db, table, p0).packingItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.bagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BagsTable,
      Bag,
      $$BagsTableFilterComposer,
      $$BagsTableOrderingComposer,
      $$BagsTableAnnotationComposer,
      $$BagsTableCreateCompanionBuilder,
      $$BagsTableUpdateCompanionBuilder,
      (Bag, $$BagsTableReferences),
      Bag,
      PrefetchHooks Function({bool tripId, bool packingItemsRefs})
    >;
typedef $$PackingItemsTableCreateCompanionBuilder =
    PackingItemsCompanion Function({
      required String id,
      required String tripId,
      required String categoryId,
      Value<String?> bagId,
      required String name,
      Value<int> quantity,
      Value<int> packedCount,
      Value<int?> unitWeightGrams,
      Value<bool> isEssential,
      Value<String?> notes,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PackingItemsTableUpdateCompanionBuilder =
    PackingItemsCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String> categoryId,
      Value<String?> bagId,
      Value<String> name,
      Value<int> quantity,
      Value<int> packedCount,
      Value<int?> unitWeightGrams,
      Value<bool> isEssential,
      Value<String?> notes,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PackingItemsTableReferences
    extends BaseReferences<_$AppDatabase, $PackingItemsTable, PackingItem> {
  $$PackingItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) => db.trips.createAlias(
    $_aliasNameGenerator(db.packingItems.tripId, db.trips.id),
  );

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PackingCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.packingCategories.createAlias(
        $_aliasNameGenerator(
          db.packingItems.categoryId,
          db.packingCategories.id,
        ),
      );

  $$PackingCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$PackingCategoriesTableTableManager(
      $_db,
      $_db.packingCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BagsTable _bagIdTable(_$AppDatabase db) => db.bags.createAlias(
    $_aliasNameGenerator(db.packingItems.bagId, db.bags.id),
  );

  $$BagsTableProcessedTableManager? get bagId {
    final $_column = $_itemColumn<String>('bag_id');
    if ($_column == null) return null;
    final manager = $$BagsTableTableManager(
      $_db,
      $_db.bags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PackingItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PackingItemsTable> {
  $$PackingItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get packedCount => $composableBuilder(
    column: $table.packedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitWeightGrams => $composableBuilder(
    column: $table.unitWeightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEssential => $composableBuilder(
    column: $table.isEssential,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PackingCategoriesTableFilterComposer get categoryId {
    final $$PackingCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.packingCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackingCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.packingCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BagsTableFilterComposer get bagId {
    final $$BagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bagId,
      referencedTable: $db.bags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BagsTableFilterComposer(
            $db: $db,
            $table: $db.bags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PackingItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PackingItemsTable> {
  $$PackingItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get packedCount => $composableBuilder(
    column: $table.packedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitWeightGrams => $composableBuilder(
    column: $table.unitWeightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEssential => $composableBuilder(
    column: $table.isEssential,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PackingCategoriesTableOrderingComposer get categoryId {
    final $$PackingCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.packingCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackingCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.packingCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BagsTableOrderingComposer get bagId {
    final $$BagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bagId,
      referencedTable: $db.bags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BagsTableOrderingComposer(
            $db: $db,
            $table: $db.bags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PackingItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PackingItemsTable> {
  $$PackingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get packedCount => $composableBuilder(
    column: $table.packedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitWeightGrams => $composableBuilder(
    column: $table.unitWeightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEssential => $composableBuilder(
    column: $table.isEssential,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PackingCategoriesTableAnnotationComposer get categoryId {
    final $$PackingCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.packingCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PackingCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.packingCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$BagsTableAnnotationComposer get bagId {
    final $$BagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bagId,
      referencedTable: $db.bags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BagsTableAnnotationComposer(
            $db: $db,
            $table: $db.bags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PackingItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PackingItemsTable,
          PackingItem,
          $$PackingItemsTableFilterComposer,
          $$PackingItemsTableOrderingComposer,
          $$PackingItemsTableAnnotationComposer,
          $$PackingItemsTableCreateCompanionBuilder,
          $$PackingItemsTableUpdateCompanionBuilder,
          (PackingItem, $$PackingItemsTableReferences),
          PackingItem,
          PrefetchHooks Function({bool tripId, bool categoryId, bool bagId})
        > {
  $$PackingItemsTableTableManager(_$AppDatabase db, $PackingItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PackingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PackingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PackingItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> bagId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> packedCount = const Value.absent(),
                Value<int?> unitWeightGrams = const Value.absent(),
                Value<bool> isEssential = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PackingItemsCompanion(
                id: id,
                tripId: tripId,
                categoryId: categoryId,
                bagId: bagId,
                name: name,
                quantity: quantity,
                packedCount: packedCount,
                unitWeightGrams: unitWeightGrams,
                isEssential: isEssential,
                notes: notes,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String categoryId,
                Value<String?> bagId = const Value.absent(),
                required String name,
                Value<int> quantity = const Value.absent(),
                Value<int> packedCount = const Value.absent(),
                Value<int?> unitWeightGrams = const Value.absent(),
                Value<bool> isEssential = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PackingItemsCompanion.insert(
                id: id,
                tripId: tripId,
                categoryId: categoryId,
                bagId: bagId,
                name: name,
                quantity: quantity,
                packedCount: packedCount,
                unitWeightGrams: unitWeightGrams,
                isEssential: isEssential,
                notes: notes,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PackingItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tripId = false, categoryId = false, bagId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tripId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tripId,
                                    referencedTable:
                                        $$PackingItemsTableReferences
                                            ._tripIdTable(db),
                                    referencedColumn:
                                        $$PackingItemsTableReferences
                                            ._tripIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$PackingItemsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$PackingItemsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (bagId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.bagId,
                                    referencedTable:
                                        $$PackingItemsTableReferences
                                            ._bagIdTable(db),
                                    referencedColumn:
                                        $$PackingItemsTableReferences
                                            ._bagIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$PackingItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PackingItemsTable,
      PackingItem,
      $$PackingItemsTableFilterComposer,
      $$PackingItemsTableOrderingComposer,
      $$PackingItemsTableAnnotationComposer,
      $$PackingItemsTableCreateCompanionBuilder,
      $$PackingItemsTableUpdateCompanionBuilder,
      (PackingItem, $$PackingItemsTableReferences),
      PackingItem,
      PrefetchHooks Function({bool tripId, bool categoryId, bool bagId})
    >;
typedef $$PackingTemplatesTableCreateCompanionBuilder =
    PackingTemplatesCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<TripType?> tripType,
      Value<bool> isBuiltIn,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PackingTemplatesTableUpdateCompanionBuilder =
    PackingTemplatesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<TripType?> tripType,
      Value<bool> isBuiltIn,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PackingTemplatesTableReferences
    extends
        BaseReferences<_$AppDatabase, $PackingTemplatesTable, PackingTemplate> {
  $$PackingTemplatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $PackingTemplateItemsTable,
    List<PackingTemplateItem>
  >
  _packingTemplateItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.packingTemplateItems,
        aliasName: $_aliasNameGenerator(
          db.packingTemplates.id,
          db.packingTemplateItems.templateId,
        ),
      );

  $$PackingTemplateItemsTableProcessedTableManager
  get packingTemplateItemsRefs {
    final manager = $$PackingTemplateItemsTableTableManager(
      $_db,
      $_db.packingTemplateItems,
    ).filter((f) => f.templateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _packingTemplateItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PackingTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $PackingTemplatesTable> {
  $$PackingTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TripType?, TripType, String> get tripType =>
      $composableBuilder(
        column: $table.tripType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> packingTemplateItemsRefs(
    Expression<bool> Function($$PackingTemplateItemsTableFilterComposer f) f,
  ) {
    final $$PackingTemplateItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.packingTemplateItems,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackingTemplateItemsTableFilterComposer(
            $db: $db,
            $table: $db.packingTemplateItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PackingTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PackingTemplatesTable> {
  $$PackingTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripType => $composableBuilder(
    column: $table.tripType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PackingTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PackingTemplatesTable> {
  $$PackingTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TripType?, String> get tripType =>
      $composableBuilder(column: $table.tripType, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> packingTemplateItemsRefs<T extends Object>(
    Expression<T> Function($$PackingTemplateItemsTableAnnotationComposer a) f,
  ) {
    final $$PackingTemplateItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.packingTemplateItems,
          getReferencedColumn: (t) => t.templateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PackingTemplateItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.packingTemplateItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PackingTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PackingTemplatesTable,
          PackingTemplate,
          $$PackingTemplatesTableFilterComposer,
          $$PackingTemplatesTableOrderingComposer,
          $$PackingTemplatesTableAnnotationComposer,
          $$PackingTemplatesTableCreateCompanionBuilder,
          $$PackingTemplatesTableUpdateCompanionBuilder,
          (PackingTemplate, $$PackingTemplatesTableReferences),
          PackingTemplate,
          PrefetchHooks Function({bool packingTemplateItemsRefs})
        > {
  $$PackingTemplatesTableTableManager(
    _$AppDatabase db,
    $PackingTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PackingTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PackingTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PackingTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<TripType?> tripType = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PackingTemplatesCompanion(
                id: id,
                name: name,
                description: description,
                tripType: tripType,
                isBuiltIn: isBuiltIn,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<TripType?> tripType = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PackingTemplatesCompanion.insert(
                id: id,
                name: name,
                description: description,
                tripType: tripType,
                isBuiltIn: isBuiltIn,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PackingTemplatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packingTemplateItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (packingTemplateItemsRefs) db.packingTemplateItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (packingTemplateItemsRefs)
                    await $_getPrefetchedData<
                      PackingTemplate,
                      $PackingTemplatesTable,
                      PackingTemplateItem
                    >(
                      currentTable: table,
                      referencedTable: $$PackingTemplatesTableReferences
                          ._packingTemplateItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PackingTemplatesTableReferences(
                            db,
                            table,
                            p0,
                          ).packingTemplateItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.templateId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PackingTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PackingTemplatesTable,
      PackingTemplate,
      $$PackingTemplatesTableFilterComposer,
      $$PackingTemplatesTableOrderingComposer,
      $$PackingTemplatesTableAnnotationComposer,
      $$PackingTemplatesTableCreateCompanionBuilder,
      $$PackingTemplatesTableUpdateCompanionBuilder,
      (PackingTemplate, $$PackingTemplatesTableReferences),
      PackingTemplate,
      PrefetchHooks Function({bool packingTemplateItemsRefs})
    >;
typedef $$PackingTemplateItemsTableCreateCompanionBuilder =
    PackingTemplateItemsCompanion Function({
      required String id,
      required String templateId,
      required String categoryName,
      required String name,
      Value<int> baseQuantity,
      Value<int?> unitWeightGrams,
      Value<bool> isEssential,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$PackingTemplateItemsTableUpdateCompanionBuilder =
    PackingTemplateItemsCompanion Function({
      Value<String> id,
      Value<String> templateId,
      Value<String> categoryName,
      Value<String> name,
      Value<int> baseQuantity,
      Value<int?> unitWeightGrams,
      Value<bool> isEssential,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$PackingTemplateItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PackingTemplateItemsTable,
          PackingTemplateItem
        > {
  $$PackingTemplateItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PackingTemplatesTable _templateIdTable(_$AppDatabase db) =>
      db.packingTemplates.createAlias(
        $_aliasNameGenerator(
          db.packingTemplateItems.templateId,
          db.packingTemplates.id,
        ),
      );

  $$PackingTemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<String>('template_id')!;

    final manager = $$PackingTemplatesTableTableManager(
      $_db,
      $_db.packingTemplates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PackingTemplateItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PackingTemplateItemsTable> {
  $$PackingTemplateItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseQuantity => $composableBuilder(
    column: $table.baseQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitWeightGrams => $composableBuilder(
    column: $table.unitWeightGrams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEssential => $composableBuilder(
    column: $table.isEssential,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$PackingTemplatesTableFilterComposer get templateId {
    final $$PackingTemplatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.packingTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackingTemplatesTableFilterComposer(
            $db: $db,
            $table: $db.packingTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PackingTemplateItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PackingTemplateItemsTable> {
  $$PackingTemplateItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseQuantity => $composableBuilder(
    column: $table.baseQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitWeightGrams => $composableBuilder(
    column: $table.unitWeightGrams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEssential => $composableBuilder(
    column: $table.isEssential,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$PackingTemplatesTableOrderingComposer get templateId {
    final $$PackingTemplatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.packingTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackingTemplatesTableOrderingComposer(
            $db: $db,
            $table: $db.packingTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PackingTemplateItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PackingTemplateItemsTable> {
  $$PackingTemplateItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get baseQuantity => $composableBuilder(
    column: $table.baseQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unitWeightGrams => $composableBuilder(
    column: $table.unitWeightGrams,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEssential => $composableBuilder(
    column: $table.isEssential,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$PackingTemplatesTableAnnotationComposer get templateId {
    final $$PackingTemplatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.packingTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PackingTemplatesTableAnnotationComposer(
            $db: $db,
            $table: $db.packingTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PackingTemplateItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PackingTemplateItemsTable,
          PackingTemplateItem,
          $$PackingTemplateItemsTableFilterComposer,
          $$PackingTemplateItemsTableOrderingComposer,
          $$PackingTemplateItemsTableAnnotationComposer,
          $$PackingTemplateItemsTableCreateCompanionBuilder,
          $$PackingTemplateItemsTableUpdateCompanionBuilder,
          (PackingTemplateItem, $$PackingTemplateItemsTableReferences),
          PackingTemplateItem,
          PrefetchHooks Function({bool templateId})
        > {
  $$PackingTemplateItemsTableTableManager(
    _$AppDatabase db,
    $PackingTemplateItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PackingTemplateItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PackingTemplateItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PackingTemplateItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<String> categoryName = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> baseQuantity = const Value.absent(),
                Value<int?> unitWeightGrams = const Value.absent(),
                Value<bool> isEssential = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PackingTemplateItemsCompanion(
                id: id,
                templateId: templateId,
                categoryName: categoryName,
                name: name,
                baseQuantity: baseQuantity,
                unitWeightGrams: unitWeightGrams,
                isEssential: isEssential,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String templateId,
                required String categoryName,
                required String name,
                Value<int> baseQuantity = const Value.absent(),
                Value<int?> unitWeightGrams = const Value.absent(),
                Value<bool> isEssential = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PackingTemplateItemsCompanion.insert(
                id: id,
                templateId: templateId,
                categoryName: categoryName,
                name: name,
                baseQuantity: baseQuantity,
                unitWeightGrams: unitWeightGrams,
                isEssential: isEssential,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PackingTemplateItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({templateId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (templateId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.templateId,
                                referencedTable:
                                    $$PackingTemplateItemsTableReferences
                                        ._templateIdTable(db),
                                referencedColumn:
                                    $$PackingTemplateItemsTableReferences
                                        ._templateIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PackingTemplateItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PackingTemplateItemsTable,
      PackingTemplateItem,
      $$PackingTemplateItemsTableFilterComposer,
      $$PackingTemplateItemsTableOrderingComposer,
      $$PackingTemplateItemsTableAnnotationComposer,
      $$PackingTemplateItemsTableCreateCompanionBuilder,
      $$PackingTemplateItemsTableUpdateCompanionBuilder,
      (PackingTemplateItem, $$PackingTemplateItemsTableReferences),
      PackingTemplateItem,
      PrefetchHooks Function({bool templateId})
    >;
typedef $$VehiclesTableCreateCompanionBuilder =
    VehiclesCompanion Function({
      required String id,
      required String name,
      Value<FuelType> fuelType,
      Value<double> consumptionValue,
      Value<ConsumptionUnit> consumptionUnit,
      Value<double?> tankCapacity,
      Value<String?> plate,
      Value<bool> isDefault,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$VehiclesTableUpdateCompanionBuilder =
    VehiclesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<FuelType> fuelType,
      Value<double> consumptionValue,
      Value<ConsumptionUnit> consumptionUnit,
      Value<double?> tankCapacity,
      Value<String?> plate,
      Value<bool> isDefault,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TransportSegmentsTable, List<TransportSegment>>
  _transportSegmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.transportSegments,
        aliasName: $_aliasNameGenerator(
          db.vehicles.id,
          db.transportSegments.vehicleId,
        ),
      );

  $$TransportSegmentsTableProcessedTableManager get transportSegmentsRefs {
    final manager = $$TransportSegmentsTableTableManager(
      $_db,
      $_db.transportSegments,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _transportSegmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FuelType, FuelType, String> get fuelType =>
      $composableBuilder(
        column: $table.fuelType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get consumptionValue => $composableBuilder(
    column: $table.consumptionValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ConsumptionUnit, ConsumptionUnit, String>
  get consumptionUnit => $composableBuilder(
    column: $table.consumptionUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get tankCapacity => $composableBuilder(
    column: $table.tankCapacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plate => $composableBuilder(
    column: $table.plate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> transportSegmentsRefs(
    Expression<bool> Function($$TransportSegmentsTableFilterComposer f) f,
  ) {
    final $$TransportSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transportSegments,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransportSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.transportSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get consumptionValue => $composableBuilder(
    column: $table.consumptionValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consumptionUnit => $composableBuilder(
    column: $table.consumptionUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tankCapacity => $composableBuilder(
    column: $table.tankCapacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plate => $composableBuilder(
    column: $table.plate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FuelType, String> get fuelType =>
      $composableBuilder(column: $table.fuelType, builder: (column) => column);

  GeneratedColumn<double> get consumptionValue => $composableBuilder(
    column: $table.consumptionValue,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ConsumptionUnit, String>
  get consumptionUnit => $composableBuilder(
    column: $table.consumptionUnit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tankCapacity => $composableBuilder(
    column: $table.tankCapacity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get plate =>
      $composableBuilder(column: $table.plate, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> transportSegmentsRefs<T extends Object>(
    Expression<T> Function($$TransportSegmentsTableAnnotationComposer a) f,
  ) {
    final $$TransportSegmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.transportSegments,
          getReferencedColumn: (t) => t.vehicleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransportSegmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.transportSegments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          Vehicle,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (Vehicle, $$VehiclesTableReferences),
          Vehicle,
          PrefetchHooks Function({bool transportSegmentsRefs})
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<FuelType> fuelType = const Value.absent(),
                Value<double> consumptionValue = const Value.absent(),
                Value<ConsumptionUnit> consumptionUnit = const Value.absent(),
                Value<double?> tankCapacity = const Value.absent(),
                Value<String?> plate = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                name: name,
                fuelType: fuelType,
                consumptionValue: consumptionValue,
                consumptionUnit: consumptionUnit,
                tankCapacity: tankCapacity,
                plate: plate,
                isDefault: isDefault,
                isArchived: isArchived,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<FuelType> fuelType = const Value.absent(),
                Value<double> consumptionValue = const Value.absent(),
                Value<ConsumptionUnit> consumptionUnit = const Value.absent(),
                Value<double?> tankCapacity = const Value.absent(),
                Value<String?> plate = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                name: name,
                fuelType: fuelType,
                consumptionValue: consumptionValue,
                consumptionUnit: consumptionUnit,
                tankCapacity: tankCapacity,
                plate: plate,
                isDefault: isDefault,
                isArchived: isArchived,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehiclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transportSegmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (transportSegmentsRefs) db.transportSegments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (transportSegmentsRefs)
                    await $_getPrefetchedData<
                      Vehicle,
                      $VehiclesTable,
                      TransportSegment
                    >(
                      currentTable: table,
                      referencedTable: $$VehiclesTableReferences
                          ._transportSegmentsRefsTable(db),
                      managerFromTypedResult: (p0) => $$VehiclesTableReferences(
                        db,
                        table,
                        p0,
                      ).transportSegmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.vehicleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      Vehicle,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (Vehicle, $$VehiclesTableReferences),
      Vehicle,
      PrefetchHooks Function({bool transportSegmentsRefs})
    >;
typedef $$TransportSegmentsTableCreateCompanionBuilder =
    TransportSegmentsCompanion Function({
      required String id,
      required String tripId,
      Value<int> sequenceIndex,
      Value<TransportMode> mode,
      Value<String> originLabel,
      Value<double?> originLat,
      Value<double?> originLng,
      Value<String> destinationLabel,
      Value<double?> destinationLat,
      Value<double?> destinationLng,
      Value<double?> distanceKm,
      Value<DistanceSource> distanceSource,
      Value<double> detourFactor,
      Value<bool> isRoundTrip,
      Value<DateTime?> departureAt,
      Value<DateTime?> arrivalAt,
      Value<String?> vehicleId,
      Value<double?> consumptionSnapshot,
      Value<ConsumptionUnit?> consumptionUnitSnapshot,
      Value<int?> fuelPriceCentsSnapshot,
      Value<int?> manualCostCents,
      Value<String?> provider,
      Value<String?> bookingRef,
      Value<String?> seatInfo,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$TransportSegmentsTableUpdateCompanionBuilder =
    TransportSegmentsCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<int> sequenceIndex,
      Value<TransportMode> mode,
      Value<String> originLabel,
      Value<double?> originLat,
      Value<double?> originLng,
      Value<String> destinationLabel,
      Value<double?> destinationLat,
      Value<double?> destinationLng,
      Value<double?> distanceKm,
      Value<DistanceSource> distanceSource,
      Value<double> detourFactor,
      Value<bool> isRoundTrip,
      Value<DateTime?> departureAt,
      Value<DateTime?> arrivalAt,
      Value<String?> vehicleId,
      Value<double?> consumptionSnapshot,
      Value<ConsumptionUnit?> consumptionUnitSnapshot,
      Value<int?> fuelPriceCentsSnapshot,
      Value<int?> manualCostCents,
      Value<String?> provider,
      Value<String?> bookingRef,
      Value<String?> seatInfo,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$TransportSegmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransportSegmentsTable,
          TransportSegment
        > {
  $$TransportSegmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TripsTable _tripIdTable(_$AppDatabase db) => db.trips.createAlias(
    $_aliasNameGenerator(db.transportSegments.tripId, db.trips.id),
  );

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias(
        $_aliasNameGenerator(db.transportSegments.vehicleId, db.vehicles.id),
      );

  $$VehiclesTableProcessedTableManager? get vehicleId {
    final $_column = $_itemColumn<String>('vehicle_id');
    if ($_column == null) return null;
    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CostItemsTable, List<CostItem>>
  _costItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.costItems,
    aliasName: $_aliasNameGenerator(
      db.transportSegments.id,
      db.costItems.segmentId,
    ),
  );

  $$CostItemsTableProcessedTableManager get costItemsRefs {
    final manager = $$CostItemsTableTableManager(
      $_db,
      $_db.costItems,
    ).filter((f) => f.segmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_costItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TransportSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $TransportSegmentsTable> {
  $$TransportSegmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequenceIndex => $composableBuilder(
    column: $table.sequenceIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TransportMode, TransportMode, String>
  get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get originLabel => $composableBuilder(
    column: $table.originLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get originLat => $composableBuilder(
    column: $table.originLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get originLng => $composableBuilder(
    column: $table.originLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destinationLabel => $composableBuilder(
    column: $table.destinationLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get destinationLat => $composableBuilder(
    column: $table.destinationLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get destinationLng => $composableBuilder(
    column: $table.destinationLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DistanceSource, DistanceSource, String>
  get distanceSource => $composableBuilder(
    column: $table.distanceSource,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get detourFactor => $composableBuilder(
    column: $table.detourFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRoundTrip => $composableBuilder(
    column: $table.isRoundTrip,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get departureAt => $composableBuilder(
    column: $table.departureAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get arrivalAt => $composableBuilder(
    column: $table.arrivalAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get consumptionSnapshot => $composableBuilder(
    column: $table.consumptionSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ConsumptionUnit?, ConsumptionUnit, String>
  get consumptionUnitSnapshot => $composableBuilder(
    column: $table.consumptionUnitSnapshot,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get fuelPriceCentsSnapshot => $composableBuilder(
    column: $table.fuelPriceCentsSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get manualCostCents => $composableBuilder(
    column: $table.manualCostCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookingRef => $composableBuilder(
    column: $table.bookingRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seatInfo => $composableBuilder(
    column: $table.seatInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> costItemsRefs(
    Expression<bool> Function($$CostItemsTableFilterComposer f) f,
  ) {
    final $$CostItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.costItems,
      getReferencedColumn: (t) => t.segmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostItemsTableFilterComposer(
            $db: $db,
            $table: $db.costItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransportSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransportSegmentsTable> {
  $$TransportSegmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequenceIndex => $composableBuilder(
    column: $table.sequenceIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originLabel => $composableBuilder(
    column: $table.originLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get originLat => $composableBuilder(
    column: $table.originLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get originLng => $composableBuilder(
    column: $table.originLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destinationLabel => $composableBuilder(
    column: $table.destinationLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get destinationLat => $composableBuilder(
    column: $table.destinationLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get destinationLng => $composableBuilder(
    column: $table.destinationLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get distanceSource => $composableBuilder(
    column: $table.distanceSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get detourFactor => $composableBuilder(
    column: $table.detourFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRoundTrip => $composableBuilder(
    column: $table.isRoundTrip,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get departureAt => $composableBuilder(
    column: $table.departureAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get arrivalAt => $composableBuilder(
    column: $table.arrivalAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get consumptionSnapshot => $composableBuilder(
    column: $table.consumptionSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consumptionUnitSnapshot => $composableBuilder(
    column: $table.consumptionUnitSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fuelPriceCentsSnapshot => $composableBuilder(
    column: $table.fuelPriceCentsSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get manualCostCents => $composableBuilder(
    column: $table.manualCostCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provider => $composableBuilder(
    column: $table.provider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookingRef => $composableBuilder(
    column: $table.bookingRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seatInfo => $composableBuilder(
    column: $table.seatInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransportSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransportSegmentsTable> {
  $$TransportSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sequenceIndex => $composableBuilder(
    column: $table.sequenceIndex,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TransportMode, String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get originLabel => $composableBuilder(
    column: $table.originLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get originLat =>
      $composableBuilder(column: $table.originLat, builder: (column) => column);

  GeneratedColumn<double> get originLng =>
      $composableBuilder(column: $table.originLng, builder: (column) => column);

  GeneratedColumn<String> get destinationLabel => $composableBuilder(
    column: $table.destinationLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get destinationLat => $composableBuilder(
    column: $table.destinationLat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get destinationLng => $composableBuilder(
    column: $table.destinationLng,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceKm => $composableBuilder(
    column: $table.distanceKm,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DistanceSource, String> get distanceSource =>
      $composableBuilder(
        column: $table.distanceSource,
        builder: (column) => column,
      );

  GeneratedColumn<double> get detourFactor => $composableBuilder(
    column: $table.detourFactor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRoundTrip => $composableBuilder(
    column: $table.isRoundTrip,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get departureAt => $composableBuilder(
    column: $table.departureAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get arrivalAt =>
      $composableBuilder(column: $table.arrivalAt, builder: (column) => column);

  GeneratedColumn<double> get consumptionSnapshot => $composableBuilder(
    column: $table.consumptionSnapshot,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ConsumptionUnit?, String>
  get consumptionUnitSnapshot => $composableBuilder(
    column: $table.consumptionUnitSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fuelPriceCentsSnapshot => $composableBuilder(
    column: $table.fuelPriceCentsSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get manualCostCents => $composableBuilder(
    column: $table.manualCostCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get bookingRef => $composableBuilder(
    column: $table.bookingRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get seatInfo =>
      $composableBuilder(column: $table.seatInfo, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> costItemsRefs<T extends Object>(
    Expression<T> Function($$CostItemsTableAnnotationComposer a) f,
  ) {
    final $$CostItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.costItems,
      getReferencedColumn: (t) => t.segmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.costItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TransportSegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransportSegmentsTable,
          TransportSegment,
          $$TransportSegmentsTableFilterComposer,
          $$TransportSegmentsTableOrderingComposer,
          $$TransportSegmentsTableAnnotationComposer,
          $$TransportSegmentsTableCreateCompanionBuilder,
          $$TransportSegmentsTableUpdateCompanionBuilder,
          (TransportSegment, $$TransportSegmentsTableReferences),
          TransportSegment,
          PrefetchHooks Function({
            bool tripId,
            bool vehicleId,
            bool costItemsRefs,
          })
        > {
  $$TransportSegmentsTableTableManager(
    _$AppDatabase db,
    $TransportSegmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransportSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransportSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransportSegmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<int> sequenceIndex = const Value.absent(),
                Value<TransportMode> mode = const Value.absent(),
                Value<String> originLabel = const Value.absent(),
                Value<double?> originLat = const Value.absent(),
                Value<double?> originLng = const Value.absent(),
                Value<String> destinationLabel = const Value.absent(),
                Value<double?> destinationLat = const Value.absent(),
                Value<double?> destinationLng = const Value.absent(),
                Value<double?> distanceKm = const Value.absent(),
                Value<DistanceSource> distanceSource = const Value.absent(),
                Value<double> detourFactor = const Value.absent(),
                Value<bool> isRoundTrip = const Value.absent(),
                Value<DateTime?> departureAt = const Value.absent(),
                Value<DateTime?> arrivalAt = const Value.absent(),
                Value<String?> vehicleId = const Value.absent(),
                Value<double?> consumptionSnapshot = const Value.absent(),
                Value<ConsumptionUnit?> consumptionUnitSnapshot =
                    const Value.absent(),
                Value<int?> fuelPriceCentsSnapshot = const Value.absent(),
                Value<int?> manualCostCents = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<String?> bookingRef = const Value.absent(),
                Value<String?> seatInfo = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransportSegmentsCompanion(
                id: id,
                tripId: tripId,
                sequenceIndex: sequenceIndex,
                mode: mode,
                originLabel: originLabel,
                originLat: originLat,
                originLng: originLng,
                destinationLabel: destinationLabel,
                destinationLat: destinationLat,
                destinationLng: destinationLng,
                distanceKm: distanceKm,
                distanceSource: distanceSource,
                detourFactor: detourFactor,
                isRoundTrip: isRoundTrip,
                departureAt: departureAt,
                arrivalAt: arrivalAt,
                vehicleId: vehicleId,
                consumptionSnapshot: consumptionSnapshot,
                consumptionUnitSnapshot: consumptionUnitSnapshot,
                fuelPriceCentsSnapshot: fuelPriceCentsSnapshot,
                manualCostCents: manualCostCents,
                provider: provider,
                bookingRef: bookingRef,
                seatInfo: seatInfo,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                Value<int> sequenceIndex = const Value.absent(),
                Value<TransportMode> mode = const Value.absent(),
                Value<String> originLabel = const Value.absent(),
                Value<double?> originLat = const Value.absent(),
                Value<double?> originLng = const Value.absent(),
                Value<String> destinationLabel = const Value.absent(),
                Value<double?> destinationLat = const Value.absent(),
                Value<double?> destinationLng = const Value.absent(),
                Value<double?> distanceKm = const Value.absent(),
                Value<DistanceSource> distanceSource = const Value.absent(),
                Value<double> detourFactor = const Value.absent(),
                Value<bool> isRoundTrip = const Value.absent(),
                Value<DateTime?> departureAt = const Value.absent(),
                Value<DateTime?> arrivalAt = const Value.absent(),
                Value<String?> vehicleId = const Value.absent(),
                Value<double?> consumptionSnapshot = const Value.absent(),
                Value<ConsumptionUnit?> consumptionUnitSnapshot =
                    const Value.absent(),
                Value<int?> fuelPriceCentsSnapshot = const Value.absent(),
                Value<int?> manualCostCents = const Value.absent(),
                Value<String?> provider = const Value.absent(),
                Value<String?> bookingRef = const Value.absent(),
                Value<String?> seatInfo = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransportSegmentsCompanion.insert(
                id: id,
                tripId: tripId,
                sequenceIndex: sequenceIndex,
                mode: mode,
                originLabel: originLabel,
                originLat: originLat,
                originLng: originLng,
                destinationLabel: destinationLabel,
                destinationLat: destinationLat,
                destinationLng: destinationLng,
                distanceKm: distanceKm,
                distanceSource: distanceSource,
                detourFactor: detourFactor,
                isRoundTrip: isRoundTrip,
                departureAt: departureAt,
                arrivalAt: arrivalAt,
                vehicleId: vehicleId,
                consumptionSnapshot: consumptionSnapshot,
                consumptionUnitSnapshot: consumptionUnitSnapshot,
                fuelPriceCentsSnapshot: fuelPriceCentsSnapshot,
                manualCostCents: manualCostCents,
                provider: provider,
                bookingRef: bookingRef,
                seatInfo: seatInfo,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransportSegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tripId = false, vehicleId = false, costItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (costItemsRefs) db.costItems],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tripId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tripId,
                                    referencedTable:
                                        $$TransportSegmentsTableReferences
                                            ._tripIdTable(db),
                                    referencedColumn:
                                        $$TransportSegmentsTableReferences
                                            ._tripIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (vehicleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.vehicleId,
                                    referencedTable:
                                        $$TransportSegmentsTableReferences
                                            ._vehicleIdTable(db),
                                    referencedColumn:
                                        $$TransportSegmentsTableReferences
                                            ._vehicleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (costItemsRefs)
                        await $_getPrefetchedData<
                          TransportSegment,
                          $TransportSegmentsTable,
                          CostItem
                        >(
                          currentTable: table,
                          referencedTable: $$TransportSegmentsTableReferences
                              ._costItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TransportSegmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).costItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.segmentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TransportSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransportSegmentsTable,
      TransportSegment,
      $$TransportSegmentsTableFilterComposer,
      $$TransportSegmentsTableOrderingComposer,
      $$TransportSegmentsTableAnnotationComposer,
      $$TransportSegmentsTableCreateCompanionBuilder,
      $$TransportSegmentsTableUpdateCompanionBuilder,
      (TransportSegment, $$TransportSegmentsTableReferences),
      TransportSegment,
      PrefetchHooks Function({bool tripId, bool vehicleId, bool costItemsRefs})
    >;
typedef $$CostItemsTableCreateCompanionBuilder =
    CostItemsCompanion Function({
      required String id,
      required String tripId,
      Value<String?> segmentId,
      Value<CostCategory> category,
      Value<String?> description,
      Value<int> amountCents,
      Value<String> currency,
      Value<DateTime?> date,
      Value<CostStatus> status,
      Value<String?> paidByTravelerId,
      Value<SplitMethod> splitMethod,
      Value<String?> receiptPhotoPath,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$CostItemsTableUpdateCompanionBuilder =
    CostItemsCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String?> segmentId,
      Value<CostCategory> category,
      Value<String?> description,
      Value<int> amountCents,
      Value<String> currency,
      Value<DateTime?> date,
      Value<CostStatus> status,
      Value<String?> paidByTravelerId,
      Value<SplitMethod> splitMethod,
      Value<String?> receiptPhotoPath,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CostItemsTableReferences
    extends BaseReferences<_$AppDatabase, $CostItemsTable, CostItem> {
  $$CostItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) => db.trips.createAlias(
    $_aliasNameGenerator(db.costItems.tripId, db.trips.id),
  );

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TransportSegmentsTable _segmentIdTable(_$AppDatabase db) =>
      db.transportSegments.createAlias(
        $_aliasNameGenerator(db.costItems.segmentId, db.transportSegments.id),
      );

  $$TransportSegmentsTableProcessedTableManager? get segmentId {
    final $_column = $_itemColumn<String>('segment_id');
    if ($_column == null) return null;
    final manager = $$TransportSegmentsTableTableManager(
      $_db,
      $_db.transportSegments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_segmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TravelersTable _paidByTravelerIdTable(_$AppDatabase db) =>
      db.travelers.createAlias(
        $_aliasNameGenerator(db.costItems.paidByTravelerId, db.travelers.id),
      );

  $$TravelersTableProcessedTableManager? get paidByTravelerId {
    final $_column = $_itemColumn<String>('paid_by_traveler_id');
    if ($_column == null) return null;
    final manager = $$TravelersTableTableManager(
      $_db,
      $_db.travelers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paidByTravelerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CostSplitsTable, List<CostSplit>>
  _costSplitsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.costSplits,
    aliasName: $_aliasNameGenerator(db.costItems.id, db.costSplits.costItemId),
  );

  $$CostSplitsTableProcessedTableManager get costSplitsRefs {
    final manager = $$CostSplitsTableTableManager(
      $_db,
      $_db.costSplits,
    ).filter((f) => f.costItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_costSplitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CostItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CostItemsTable> {
  $$CostItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CostCategory, CostCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CostStatus, CostStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<SplitMethod, SplitMethod, String>
  get splitMethod => $composableBuilder(
    column: $table.splitMethod,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get receiptPhotoPath => $composableBuilder(
    column: $table.receiptPhotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransportSegmentsTableFilterComposer get segmentId {
    final $$TransportSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.segmentId,
      referencedTable: $db.transportSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransportSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.transportSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TravelersTableFilterComposer get paidByTravelerId {
    final $$TravelersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paidByTravelerId,
      referencedTable: $db.travelers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TravelersTableFilterComposer(
            $db: $db,
            $table: $db.travelers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> costSplitsRefs(
    Expression<bool> Function($$CostSplitsTableFilterComposer f) f,
  ) {
    final $$CostSplitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.costSplits,
      getReferencedColumn: (t) => t.costItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostSplitsTableFilterComposer(
            $db: $db,
            $table: $db.costSplits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CostItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CostItemsTable> {
  $$CostItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get splitMethod => $composableBuilder(
    column: $table.splitMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptPhotoPath => $composableBuilder(
    column: $table.receiptPhotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransportSegmentsTableOrderingComposer get segmentId {
    final $$TransportSegmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.segmentId,
      referencedTable: $db.transportSegments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransportSegmentsTableOrderingComposer(
            $db: $db,
            $table: $db.transportSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TravelersTableOrderingComposer get paidByTravelerId {
    final $$TravelersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paidByTravelerId,
      referencedTable: $db.travelers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TravelersTableOrderingComposer(
            $db: $db,
            $table: $db.travelers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CostItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CostItemsTable> {
  $$CostItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CostCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CostStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SplitMethod, String> get splitMethod =>
      $composableBuilder(
        column: $table.splitMethod,
        builder: (column) => column,
      );

  GeneratedColumn<String> get receiptPhotoPath => $composableBuilder(
    column: $table.receiptPhotoPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TransportSegmentsTableAnnotationComposer get segmentId {
    final $$TransportSegmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.segmentId,
          referencedTable: $db.transportSegments,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TransportSegmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.transportSegments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$TravelersTableAnnotationComposer get paidByTravelerId {
    final $$TravelersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paidByTravelerId,
      referencedTable: $db.travelers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TravelersTableAnnotationComposer(
            $db: $db,
            $table: $db.travelers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> costSplitsRefs<T extends Object>(
    Expression<T> Function($$CostSplitsTableAnnotationComposer a) f,
  ) {
    final $$CostSplitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.costSplits,
      getReferencedColumn: (t) => t.costItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostSplitsTableAnnotationComposer(
            $db: $db,
            $table: $db.costSplits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CostItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CostItemsTable,
          CostItem,
          $$CostItemsTableFilterComposer,
          $$CostItemsTableOrderingComposer,
          $$CostItemsTableAnnotationComposer,
          $$CostItemsTableCreateCompanionBuilder,
          $$CostItemsTableUpdateCompanionBuilder,
          (CostItem, $$CostItemsTableReferences),
          CostItem,
          PrefetchHooks Function({
            bool tripId,
            bool segmentId,
            bool paidByTravelerId,
            bool costSplitsRefs,
          })
        > {
  $$CostItemsTableTableManager(_$AppDatabase db, $CostItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CostItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CostItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CostItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String?> segmentId = const Value.absent(),
                Value<CostCategory> category = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<CostStatus> status = const Value.absent(),
                Value<String?> paidByTravelerId = const Value.absent(),
                Value<SplitMethod> splitMethod = const Value.absent(),
                Value<String?> receiptPhotoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CostItemsCompanion(
                id: id,
                tripId: tripId,
                segmentId: segmentId,
                category: category,
                description: description,
                amountCents: amountCents,
                currency: currency,
                date: date,
                status: status,
                paidByTravelerId: paidByTravelerId,
                splitMethod: splitMethod,
                receiptPhotoPath: receiptPhotoPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                Value<String?> segmentId = const Value.absent(),
                Value<CostCategory> category = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<CostStatus> status = const Value.absent(),
                Value<String?> paidByTravelerId = const Value.absent(),
                Value<SplitMethod> splitMethod = const Value.absent(),
                Value<String?> receiptPhotoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CostItemsCompanion.insert(
                id: id,
                tripId: tripId,
                segmentId: segmentId,
                category: category,
                description: description,
                amountCents: amountCents,
                currency: currency,
                date: date,
                status: status,
                paidByTravelerId: paidByTravelerId,
                splitMethod: splitMethod,
                receiptPhotoPath: receiptPhotoPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CostItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tripId = false,
                segmentId = false,
                paidByTravelerId = false,
                costSplitsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (costSplitsRefs) db.costSplits],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tripId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tripId,
                                    referencedTable: $$CostItemsTableReferences
                                        ._tripIdTable(db),
                                    referencedColumn: $$CostItemsTableReferences
                                        ._tripIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (segmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.segmentId,
                                    referencedTable: $$CostItemsTableReferences
                                        ._segmentIdTable(db),
                                    referencedColumn: $$CostItemsTableReferences
                                        ._segmentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (paidByTravelerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.paidByTravelerId,
                                    referencedTable: $$CostItemsTableReferences
                                        ._paidByTravelerIdTable(db),
                                    referencedColumn: $$CostItemsTableReferences
                                        ._paidByTravelerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (costSplitsRefs)
                        await $_getPrefetchedData<
                          CostItem,
                          $CostItemsTable,
                          CostSplit
                        >(
                          currentTable: table,
                          referencedTable: $$CostItemsTableReferences
                              ._costSplitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CostItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).costSplitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.costItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CostItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CostItemsTable,
      CostItem,
      $$CostItemsTableFilterComposer,
      $$CostItemsTableOrderingComposer,
      $$CostItemsTableAnnotationComposer,
      $$CostItemsTableCreateCompanionBuilder,
      $$CostItemsTableUpdateCompanionBuilder,
      (CostItem, $$CostItemsTableReferences),
      CostItem,
      PrefetchHooks Function({
        bool tripId,
        bool segmentId,
        bool paidByTravelerId,
        bool costSplitsRefs,
      })
    >;
typedef $$CostSplitsTableCreateCompanionBuilder =
    CostSplitsCompanion Function({
      required String id,
      required String costItemId,
      required String travelerId,
      Value<double> shareWeight,
      Value<int> shareAmountCents,
      Value<bool> settled,
      Value<int> rowid,
    });
typedef $$CostSplitsTableUpdateCompanionBuilder =
    CostSplitsCompanion Function({
      Value<String> id,
      Value<String> costItemId,
      Value<String> travelerId,
      Value<double> shareWeight,
      Value<int> shareAmountCents,
      Value<bool> settled,
      Value<int> rowid,
    });

final class $$CostSplitsTableReferences
    extends BaseReferences<_$AppDatabase, $CostSplitsTable, CostSplit> {
  $$CostSplitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CostItemsTable _costItemIdTable(_$AppDatabase db) =>
      db.costItems.createAlias(
        $_aliasNameGenerator(db.costSplits.costItemId, db.costItems.id),
      );

  $$CostItemsTableProcessedTableManager get costItemId {
    final $_column = $_itemColumn<String>('cost_item_id')!;

    final manager = $$CostItemsTableTableManager(
      $_db,
      $_db.costItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_costItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TravelersTable _travelerIdTable(_$AppDatabase db) =>
      db.travelers.createAlias(
        $_aliasNameGenerator(db.costSplits.travelerId, db.travelers.id),
      );

  $$TravelersTableProcessedTableManager get travelerId {
    final $_column = $_itemColumn<String>('traveler_id')!;

    final manager = $$TravelersTableTableManager(
      $_db,
      $_db.travelers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_travelerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CostSplitsTableFilterComposer
    extends Composer<_$AppDatabase, $CostSplitsTable> {
  $$CostSplitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get shareWeight => $composableBuilder(
    column: $table.shareWeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shareAmountCents => $composableBuilder(
    column: $table.shareAmountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get settled => $composableBuilder(
    column: $table.settled,
    builder: (column) => ColumnFilters(column),
  );

  $$CostItemsTableFilterComposer get costItemId {
    final $$CostItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.costItemId,
      referencedTable: $db.costItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostItemsTableFilterComposer(
            $db: $db,
            $table: $db.costItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TravelersTableFilterComposer get travelerId {
    final $$TravelersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.travelerId,
      referencedTable: $db.travelers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TravelersTableFilterComposer(
            $db: $db,
            $table: $db.travelers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CostSplitsTableOrderingComposer
    extends Composer<_$AppDatabase, $CostSplitsTable> {
  $$CostSplitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get shareWeight => $composableBuilder(
    column: $table.shareWeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shareAmountCents => $composableBuilder(
    column: $table.shareAmountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get settled => $composableBuilder(
    column: $table.settled,
    builder: (column) => ColumnOrderings(column),
  );

  $$CostItemsTableOrderingComposer get costItemId {
    final $$CostItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.costItemId,
      referencedTable: $db.costItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostItemsTableOrderingComposer(
            $db: $db,
            $table: $db.costItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TravelersTableOrderingComposer get travelerId {
    final $$TravelersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.travelerId,
      referencedTable: $db.travelers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TravelersTableOrderingComposer(
            $db: $db,
            $table: $db.travelers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CostSplitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CostSplitsTable> {
  $$CostSplitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get shareWeight => $composableBuilder(
    column: $table.shareWeight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get shareAmountCents => $composableBuilder(
    column: $table.shareAmountCents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get settled =>
      $composableBuilder(column: $table.settled, builder: (column) => column);

  $$CostItemsTableAnnotationComposer get costItemId {
    final $$CostItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.costItemId,
      referencedTable: $db.costItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CostItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.costItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TravelersTableAnnotationComposer get travelerId {
    final $$TravelersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.travelerId,
      referencedTable: $db.travelers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TravelersTableAnnotationComposer(
            $db: $db,
            $table: $db.travelers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CostSplitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CostSplitsTable,
          CostSplit,
          $$CostSplitsTableFilterComposer,
          $$CostSplitsTableOrderingComposer,
          $$CostSplitsTableAnnotationComposer,
          $$CostSplitsTableCreateCompanionBuilder,
          $$CostSplitsTableUpdateCompanionBuilder,
          (CostSplit, $$CostSplitsTableReferences),
          CostSplit,
          PrefetchHooks Function({bool costItemId, bool travelerId})
        > {
  $$CostSplitsTableTableManager(_$AppDatabase db, $CostSplitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CostSplitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CostSplitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CostSplitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> costItemId = const Value.absent(),
                Value<String> travelerId = const Value.absent(),
                Value<double> shareWeight = const Value.absent(),
                Value<int> shareAmountCents = const Value.absent(),
                Value<bool> settled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CostSplitsCompanion(
                id: id,
                costItemId: costItemId,
                travelerId: travelerId,
                shareWeight: shareWeight,
                shareAmountCents: shareAmountCents,
                settled: settled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String costItemId,
                required String travelerId,
                Value<double> shareWeight = const Value.absent(),
                Value<int> shareAmountCents = const Value.absent(),
                Value<bool> settled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CostSplitsCompanion.insert(
                id: id,
                costItemId: costItemId,
                travelerId: travelerId,
                shareWeight: shareWeight,
                shareAmountCents: shareAmountCents,
                settled: settled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CostSplitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({costItemId = false, travelerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (costItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.costItemId,
                                referencedTable: $$CostSplitsTableReferences
                                    ._costItemIdTable(db),
                                referencedColumn: $$CostSplitsTableReferences
                                    ._costItemIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (travelerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.travelerId,
                                referencedTable: $$CostSplitsTableReferences
                                    ._travelerIdTable(db),
                                referencedColumn: $$CostSplitsTableReferences
                                    ._travelerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CostSplitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CostSplitsTable,
      CostSplit,
      $$CostSplitsTableFilterComposer,
      $$CostSplitsTableOrderingComposer,
      $$CostSplitsTableAnnotationComposer,
      $$CostSplitsTableCreateCompanionBuilder,
      $$CostSplitsTableUpdateCompanionBuilder,
      (CostSplit, $$CostSplitsTableReferences),
      CostSplit,
      PrefetchHooks Function({bool costItemId, bool travelerId})
    >;
typedef $$ItineraryDaysTableCreateCompanionBuilder =
    ItineraryDaysCompanion Function({
      required String id,
      required String tripId,
      Value<DateTime?> date,
      Value<int> dayIndex,
      Value<String?> title,
      Value<String?> notes,
      Value<int> sortIndex,
      Value<int> rowid,
    });
typedef $$ItineraryDaysTableUpdateCompanionBuilder =
    ItineraryDaysCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<DateTime?> date,
      Value<int> dayIndex,
      Value<String?> title,
      Value<String?> notes,
      Value<int> sortIndex,
      Value<int> rowid,
    });

final class $$ItineraryDaysTableReferences
    extends BaseReferences<_$AppDatabase, $ItineraryDaysTable, ItineraryDay> {
  $$ItineraryDaysTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TripsTable _tripIdTable(_$AppDatabase db) => db.trips.createAlias(
    $_aliasNameGenerator(db.itineraryDays.tripId, db.trips.id),
  );

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ActivitiesTable, List<Activity>>
  _activitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activities,
    aliasName: $_aliasNameGenerator(db.itineraryDays.id, db.activities.dayId),
  );

  $$ActivitiesTableProcessedTableManager get activitiesRefs {
    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.dayId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ItineraryDaysTableFilterComposer
    extends Composer<_$AppDatabase, $ItineraryDaysTable> {
  $$ItineraryDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> activitiesRefs(
    Expression<bool> Function($$ActivitiesTableFilterComposer f) f,
  ) {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItineraryDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $ItineraryDaysTable> {
  $$ItineraryDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItineraryDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItineraryDaysTable> {
  $$ItineraryDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get dayIndex =>
      $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> activitiesRefs<T extends Object>(
    Expression<T> Function($$ActivitiesTableAnnotationComposer a) f,
  ) {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ItineraryDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItineraryDaysTable,
          ItineraryDay,
          $$ItineraryDaysTableFilterComposer,
          $$ItineraryDaysTableOrderingComposer,
          $$ItineraryDaysTableAnnotationComposer,
          $$ItineraryDaysTableCreateCompanionBuilder,
          $$ItineraryDaysTableUpdateCompanionBuilder,
          (ItineraryDay, $$ItineraryDaysTableReferences),
          ItineraryDay,
          PrefetchHooks Function({bool tripId, bool activitiesRefs})
        > {
  $$ItineraryDaysTableTableManager(_$AppDatabase db, $ItineraryDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItineraryDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItineraryDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItineraryDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<int> dayIndex = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItineraryDaysCompanion(
                id: id,
                tripId: tripId,
                date: date,
                dayIndex: dayIndex,
                title: title,
                notes: notes,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                Value<DateTime?> date = const Value.absent(),
                Value<int> dayIndex = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItineraryDaysCompanion.insert(
                id: id,
                tripId: tripId,
                date: date,
                dayIndex: dayIndex,
                title: title,
                notes: notes,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ItineraryDaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripId = false, activitiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (activitiesRefs) db.activities],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tripId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tripId,
                                referencedTable: $$ItineraryDaysTableReferences
                                    ._tripIdTable(db),
                                referencedColumn: $$ItineraryDaysTableReferences
                                    ._tripIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (activitiesRefs)
                    await $_getPrefetchedData<
                      ItineraryDay,
                      $ItineraryDaysTable,
                      Activity
                    >(
                      currentTable: table,
                      referencedTable: $$ItineraryDaysTableReferences
                          ._activitiesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ItineraryDaysTableReferences(
                            db,
                            table,
                            p0,
                          ).activitiesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.dayId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ItineraryDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItineraryDaysTable,
      ItineraryDay,
      $$ItineraryDaysTableFilterComposer,
      $$ItineraryDaysTableOrderingComposer,
      $$ItineraryDaysTableAnnotationComposer,
      $$ItineraryDaysTableCreateCompanionBuilder,
      $$ItineraryDaysTableUpdateCompanionBuilder,
      (ItineraryDay, $$ItineraryDaysTableReferences),
      ItineraryDay,
      PrefetchHooks Function({bool tripId, bool activitiesRefs})
    >;
typedef $$ActivityCategoriesTableCreateCompanionBuilder =
    ActivityCategoriesCompanion Function({
      required String id,
      required String name,
      Value<String> iconKey,
      Value<String?> colorHex,
      Value<bool> isSystem,
      Value<int> sortIndex,
      Value<int> rowid,
    });
typedef $$ActivityCategoriesTableUpdateCompanionBuilder =
    ActivityCategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> iconKey,
      Value<String?> colorHex,
      Value<bool> isSystem,
      Value<int> sortIndex,
      Value<int> rowid,
    });

final class $$ActivityCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ActivityCategoriesTable,
          ActivityCategory
        > {
  $$ActivityCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ActivitiesTable, List<Activity>>
  _activitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activities,
    aliasName: $_aliasNameGenerator(
      db.activityCategories.id,
      db.activities.categoryId,
    ),
  );

  $$ActivitiesTableProcessedTableManager get activitiesRefs {
    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ActivityCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityCategoriesTable> {
  $$ActivityCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> activitiesRefs(
    Expression<bool> Function($$ActivitiesTableFilterComposer f) f,
  ) {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivityCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityCategoriesTable> {
  $$ActivityCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityCategoriesTable> {
  $$ActivityCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  Expression<T> activitiesRefs<T extends Object>(
    Expression<T> Function($$ActivitiesTableAnnotationComposer a) f,
  ) {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ActivityCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityCategoriesTable,
          ActivityCategory,
          $$ActivityCategoriesTableFilterComposer,
          $$ActivityCategoriesTableOrderingComposer,
          $$ActivityCategoriesTableAnnotationComposer,
          $$ActivityCategoriesTableCreateCompanionBuilder,
          $$ActivityCategoriesTableUpdateCompanionBuilder,
          (ActivityCategory, $$ActivityCategoriesTableReferences),
          ActivityCategory,
          PrefetchHooks Function({bool activitiesRefs})
        > {
  $$ActivityCategoriesTableTableManager(
    _$AppDatabase db,
    $ActivityCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityCategoriesCompanion(
                id: id,
                name: name,
                iconKey: iconKey,
                colorHex: colorHex,
                isSystem: isSystem,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> iconKey = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityCategoriesCompanion.insert(
                id: id,
                name: name,
                iconKey: iconKey,
                colorHex: colorHex,
                isSystem: isSystem,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActivityCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({activitiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (activitiesRefs) db.activities],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (activitiesRefs)
                    await $_getPrefetchedData<
                      ActivityCategory,
                      $ActivityCategoriesTable,
                      Activity
                    >(
                      currentTable: table,
                      referencedTable: $$ActivityCategoriesTableReferences
                          ._activitiesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ActivityCategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).activitiesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ActivityCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityCategoriesTable,
      ActivityCategory,
      $$ActivityCategoriesTableFilterComposer,
      $$ActivityCategoriesTableOrderingComposer,
      $$ActivityCategoriesTableAnnotationComposer,
      $$ActivityCategoriesTableCreateCompanionBuilder,
      $$ActivityCategoriesTableUpdateCompanionBuilder,
      (ActivityCategory, $$ActivityCategoriesTableReferences),
      ActivityCategory,
      PrefetchHooks Function({bool activitiesRefs})
    >;
typedef $$LocationsTableCreateCompanionBuilder =
    LocationsCompanion Function({
      required String id,
      required String tripId,
      required String label,
      Value<String?> address,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<PlaceType?> placeType,
      Value<String?> notes,
      Value<LocationSource> source,
      Value<int> rowid,
    });
typedef $$LocationsTableUpdateCompanionBuilder =
    LocationsCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<String> label,
      Value<String?> address,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<PlaceType?> placeType,
      Value<String?> notes,
      Value<LocationSource> source,
      Value<int> rowid,
    });

final class $$LocationsTableReferences
    extends BaseReferences<_$AppDatabase, $LocationsTable, Location> {
  $$LocationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) => db.trips.createAlias(
    $_aliasNameGenerator(db.locations.tripId, db.trips.id),
  );

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ActivitiesTable, List<Activity>>
  _activitiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.activities,
    aliasName: $_aliasNameGenerator(db.locations.id, db.activities.locationId),
  );

  $$ActivitiesTableProcessedTableManager get activitiesRefs {
    final manager = $$ActivitiesTableTableManager(
      $_db,
      $_db.activities,
    ).filter((f) => f.locationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_activitiesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PlaceType?, PlaceType, String> get placeType =>
      $composableBuilder(
        column: $table.placeType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocationSource, LocationSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> activitiesRefs(
    Expression<bool> Function($$ActivitiesTableFilterComposer f) f,
  ) {
    final $$ActivitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.locationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableFilterComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeType => $composableBuilder(
    column: $table.placeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PlaceType?, String> get placeType =>
      $composableBuilder(column: $table.placeType, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocationSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> activitiesRefs<T extends Object>(
    Expression<T> Function($$ActivitiesTableAnnotationComposer a) f,
  ) {
    final $$ActivitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.activities,
      getReferencedColumn: (t) => t.locationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.activities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationsTable,
          Location,
          $$LocationsTableFilterComposer,
          $$LocationsTableOrderingComposer,
          $$LocationsTableAnnotationComposer,
          $$LocationsTableCreateCompanionBuilder,
          $$LocationsTableUpdateCompanionBuilder,
          (Location, $$LocationsTableReferences),
          Location,
          PrefetchHooks Function({bool tripId, bool activitiesRefs})
        > {
  $$LocationsTableTableManager(_$AppDatabase db, $LocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<PlaceType?> placeType = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<LocationSource> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationsCompanion(
                id: id,
                tripId: tripId,
                label: label,
                address: address,
                latitude: latitude,
                longitude: longitude,
                placeType: placeType,
                notes: notes,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String label,
                Value<String?> address = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<PlaceType?> placeType = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<LocationSource> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationsCompanion.insert(
                id: id,
                tripId: tripId,
                label: label,
                address: address,
                latitude: latitude,
                longitude: longitude,
                placeType: placeType,
                notes: notes,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripId = false, activitiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (activitiesRefs) db.activities],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tripId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tripId,
                                referencedTable: $$LocationsTableReferences
                                    ._tripIdTable(db),
                                referencedColumn: $$LocationsTableReferences
                                    ._tripIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (activitiesRefs)
                    await $_getPrefetchedData<
                      Location,
                      $LocationsTable,
                      Activity
                    >(
                      currentTable: table,
                      referencedTable: $$LocationsTableReferences
                          ._activitiesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LocationsTableReferences(
                            db,
                            table,
                            p0,
                          ).activitiesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.locationId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$LocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationsTable,
      Location,
      $$LocationsTableFilterComposer,
      $$LocationsTableOrderingComposer,
      $$LocationsTableAnnotationComposer,
      $$LocationsTableCreateCompanionBuilder,
      $$LocationsTableUpdateCompanionBuilder,
      (Location, $$LocationsTableReferences),
      Location,
      PrefetchHooks Function({bool tripId, bool activitiesRefs})
    >;
typedef $$ActivitiesTableCreateCompanionBuilder =
    ActivitiesCompanion Function({
      required String id,
      required String dayId,
      required String tripId,
      required String title,
      Value<String?> categoryId,
      Value<int?> startMinutes,
      Value<int?> endMinutes,
      Value<bool> isAllDay,
      Value<String?> locationId,
      Value<int?> costCents,
      Value<String> currency,
      Value<ActivityStatus> status,
      Value<bool> ignoreConflict,
      Value<String?> notes,
      Value<String?> bookingRef,
      Value<String?> bookingUrl,
      Value<int> sortIndex,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ActivitiesTableUpdateCompanionBuilder =
    ActivitiesCompanion Function({
      Value<String> id,
      Value<String> dayId,
      Value<String> tripId,
      Value<String> title,
      Value<String?> categoryId,
      Value<int?> startMinutes,
      Value<int?> endMinutes,
      Value<bool> isAllDay,
      Value<String?> locationId,
      Value<int?> costCents,
      Value<String> currency,
      Value<ActivityStatus> status,
      Value<bool> ignoreConflict,
      Value<String?> notes,
      Value<String?> bookingRef,
      Value<String?> bookingUrl,
      Value<int> sortIndex,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ActivitiesTableReferences
    extends BaseReferences<_$AppDatabase, $ActivitiesTable, Activity> {
  $$ActivitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ItineraryDaysTable _dayIdTable(_$AppDatabase db) =>
      db.itineraryDays.createAlias(
        $_aliasNameGenerator(db.activities.dayId, db.itineraryDays.id),
      );

  $$ItineraryDaysTableProcessedTableManager get dayId {
    final $_column = $_itemColumn<String>('day_id')!;

    final manager = $$ItineraryDaysTableTableManager(
      $_db,
      $_db.itineraryDays,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TripsTable _tripIdTable(_$AppDatabase db) => db.trips.createAlias(
    $_aliasNameGenerator(db.activities.tripId, db.trips.id),
  );

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ActivityCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.activityCategories.createAlias(
        $_aliasNameGenerator(
          db.activities.categoryId,
          db.activityCategories.id,
        ),
      );

  $$ActivityCategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$ActivityCategoriesTableTableManager(
      $_db,
      $_db.activityCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LocationsTable _locationIdTable(_$AppDatabase db) =>
      db.locations.createAlias(
        $_aliasNameGenerator(db.activities.locationId, db.locations.id),
      );

  $$LocationsTableProcessedTableManager? get locationId {
    final $_column = $_itemColumn<String>('location_id');
    if ($_column == null) return null;
    final manager = $$LocationsTableTableManager(
      $_db,
      $_db.locations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_locationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get costCents => $composableBuilder(
    column: $table.costCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivityStatus, ActivityStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get ignoreConflict => $composableBuilder(
    column: $table.ignoreConflict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookingRef => $composableBuilder(
    column: $table.bookingRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookingUrl => $composableBuilder(
    column: $table.bookingUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ItineraryDaysTableFilterComposer get dayId {
    final $$ItineraryDaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.itineraryDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItineraryDaysTableFilterComposer(
            $db: $db,
            $table: $db.itineraryDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivityCategoriesTableFilterComposer get categoryId {
    final $$ActivityCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.activityCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.activityCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocationsTableFilterComposer get locationId {
    final $$LocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.locationId,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableFilterComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAllDay => $composableBuilder(
    column: $table.isAllDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get costCents => $composableBuilder(
    column: $table.costCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ignoreConflict => $composableBuilder(
    column: $table.ignoreConflict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookingRef => $composableBuilder(
    column: $table.bookingRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookingUrl => $composableBuilder(
    column: $table.bookingUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ItineraryDaysTableOrderingComposer get dayId {
    final $$ItineraryDaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.itineraryDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItineraryDaysTableOrderingComposer(
            $db: $db,
            $table: $db.itineraryDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivityCategoriesTableOrderingComposer get categoryId {
    final $$ActivityCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.activityCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActivityCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.activityCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocationsTableOrderingComposer get locationId {
    final $$LocationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.locationId,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableOrderingComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivitiesTable> {
  $$ActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isAllDay =>
      $composableBuilder(column: $table.isAllDay, builder: (column) => column);

  GeneratedColumn<int> get costCents =>
      $composableBuilder(column: $table.costCents, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get ignoreConflict => $composableBuilder(
    column: $table.ignoreConflict,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get bookingRef => $composableBuilder(
    column: $table.bookingRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bookingUrl => $composableBuilder(
    column: $table.bookingUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ItineraryDaysTableAnnotationComposer get dayId {
    final $$ItineraryDaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.itineraryDays,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItineraryDaysTableAnnotationComposer(
            $db: $db,
            $table: $db.itineraryDays,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ActivityCategoriesTableAnnotationComposer get categoryId {
    final $$ActivityCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.activityCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ActivityCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.activityCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$LocationsTableAnnotationComposer get locationId {
    final $$LocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.locationId,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActivitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivitiesTable,
          Activity,
          $$ActivitiesTableFilterComposer,
          $$ActivitiesTableOrderingComposer,
          $$ActivitiesTableAnnotationComposer,
          $$ActivitiesTableCreateCompanionBuilder,
          $$ActivitiesTableUpdateCompanionBuilder,
          (Activity, $$ActivitiesTableReferences),
          Activity,
          PrefetchHooks Function({
            bool dayId,
            bool tripId,
            bool categoryId,
            bool locationId,
          })
        > {
  $$ActivitiesTableTableManager(_$AppDatabase db, $ActivitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> dayId = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int?> startMinutes = const Value.absent(),
                Value<int?> endMinutes = const Value.absent(),
                Value<bool> isAllDay = const Value.absent(),
                Value<String?> locationId = const Value.absent(),
                Value<int?> costCents = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<ActivityStatus> status = const Value.absent(),
                Value<bool> ignoreConflict = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> bookingRef = const Value.absent(),
                Value<String?> bookingUrl = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion(
                id: id,
                dayId: dayId,
                tripId: tripId,
                title: title,
                categoryId: categoryId,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                isAllDay: isAllDay,
                locationId: locationId,
                costCents: costCents,
                currency: currency,
                status: status,
                ignoreConflict: ignoreConflict,
                notes: notes,
                bookingRef: bookingRef,
                bookingUrl: bookingUrl,
                sortIndex: sortIndex,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String dayId,
                required String tripId,
                required String title,
                Value<String?> categoryId = const Value.absent(),
                Value<int?> startMinutes = const Value.absent(),
                Value<int?> endMinutes = const Value.absent(),
                Value<bool> isAllDay = const Value.absent(),
                Value<String?> locationId = const Value.absent(),
                Value<int?> costCents = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<ActivityStatus> status = const Value.absent(),
                Value<bool> ignoreConflict = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> bookingRef = const Value.absent(),
                Value<String?> bookingUrl = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivitiesCompanion.insert(
                id: id,
                dayId: dayId,
                tripId: tripId,
                title: title,
                categoryId: categoryId,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                isAllDay: isAllDay,
                locationId: locationId,
                costCents: costCents,
                currency: currency,
                status: status,
                ignoreConflict: ignoreConflict,
                notes: notes,
                bookingRef: bookingRef,
                bookingUrl: bookingUrl,
                sortIndex: sortIndex,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActivitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                dayId = false,
                tripId = false,
                categoryId = false,
                locationId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (dayId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.dayId,
                                    referencedTable: $$ActivitiesTableReferences
                                        ._dayIdTable(db),
                                    referencedColumn:
                                        $$ActivitiesTableReferences
                                            ._dayIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (tripId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tripId,
                                    referencedTable: $$ActivitiesTableReferences
                                        ._tripIdTable(db),
                                    referencedColumn:
                                        $$ActivitiesTableReferences
                                            ._tripIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$ActivitiesTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn:
                                        $$ActivitiesTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (locationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.locationId,
                                    referencedTable: $$ActivitiesTableReferences
                                        ._locationIdTable(db),
                                    referencedColumn:
                                        $$ActivitiesTableReferences
                                            ._locationIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$ActivitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivitiesTable,
      Activity,
      $$ActivitiesTableFilterComposer,
      $$ActivitiesTableOrderingComposer,
      $$ActivitiesTableAnnotationComposer,
      $$ActivitiesTableCreateCompanionBuilder,
      $$ActivitiesTableUpdateCompanionBuilder,
      (Activity, $$ActivitiesTableReferences),
      Activity,
      PrefetchHooks Function({
        bool dayId,
        bool tripId,
        bool categoryId,
        bool locationId,
      })
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$TravelersTableTableManager get travelers =>
      $$TravelersTableTableManager(_db, _db.travelers);
  $$PackingCategoriesTableTableManager get packingCategories =>
      $$PackingCategoriesTableTableManager(_db, _db.packingCategories);
  $$BagsTableTableManager get bags => $$BagsTableTableManager(_db, _db.bags);
  $$PackingItemsTableTableManager get packingItems =>
      $$PackingItemsTableTableManager(_db, _db.packingItems);
  $$PackingTemplatesTableTableManager get packingTemplates =>
      $$PackingTemplatesTableTableManager(_db, _db.packingTemplates);
  $$PackingTemplateItemsTableTableManager get packingTemplateItems =>
      $$PackingTemplateItemsTableTableManager(_db, _db.packingTemplateItems);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$TransportSegmentsTableTableManager get transportSegments =>
      $$TransportSegmentsTableTableManager(_db, _db.transportSegments);
  $$CostItemsTableTableManager get costItems =>
      $$CostItemsTableTableManager(_db, _db.costItems);
  $$CostSplitsTableTableManager get costSplits =>
      $$CostSplitsTableTableManager(_db, _db.costSplits);
  $$ItineraryDaysTableTableManager get itineraryDays =>
      $$ItineraryDaysTableTableManager(_db, _db.itineraryDays);
  $$ActivityCategoriesTableTableManager get activityCategories =>
      $$ActivityCategoriesTableTableManager(_db, _db.activityCategories);
  $$LocationsTableTableManager get locations =>
      $$LocationsTableTableManager(_db, _db.locations);
  $$ActivitiesTableTableManager get activities =>
      $$ActivitiesTableTableManager(_db, _db.activities);
}
