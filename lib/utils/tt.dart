import 'dart:convert';

import 'package:snippet_generator/database/models/sql_values.dart';

class Message {
  final int numId;
  final String codeMessage;
  final List<int> userCode;
  final String roomCode;
  final int roomCodeSection;
  final String text;
  final String? senderName;
  final String typeMessageCode;
  final int read;
  final DateTime createdAt;

  final List<Room>? refRoom;
  final List<User>? refUser;
  final List<TypeMessage>? refTypeMessage;

  final Map<String, Object?> additionalInfo;

  const Message({
    required this.numId,
    required this.codeMessage,
    required this.userCode,
    required this.roomCode,
    required this.roomCodeSection,
    required this.text,
    this.senderName,
    required this.typeMessageCode,
    required this.read,
    required this.createdAt,
    this.refRoom,
    this.refUser,
    this.refTypeMessage,
    this.additionalInfo = const {},
  });

  String insertShallowSql() {
    return """
INSERT INTO message(num_id,code_message,user_code,room_code,room_code_section,text,sender_name,type_message_code,read,created_at)
VALUES ($numId,$codeMessage,$userCode,$roomCode,$roomCodeSection,$text,$senderName,$typeMessageCode,$read,$createdAt);
""";
  }

  Future<SqlQueryResult> insertShallow(TableConnection conn) {
    final sqlQuery = insertShallowSql();
    return conn.query(sqlQuery);
  }

  static SqlQuery selectSql({
    SqlValue<SqlBoolValue>? where,
    List<SqlOrderItem>? orderBy,
    SqlLimit? limit,
    required SqlDatabase database,
    bool unsafe = false,
    bool withRoom = false,
    bool withUser = false,
    bool withTypeMessage = false,
  }) {
    final ctx = SqlContext(database: database, unsafe: unsafe);
    final query = """
SELECT num_id,code_message,user_code,room_code,room_code_section,text,sender_name,type_message_code,read,created_at
${withRoom ? ",JSON_ARRAYAGG(JSON_OBJECT('codeRoom',room.code_room,'section',room.section,'createdAt',room.created_at)) refRoom" : ""}
${withUser ? ",JSON_ARRAYAGG(JSON_OBJECT('codeUser',user.code_user,'createdAt',user.created_at)) refUser" : ""}
${withTypeMessage ? ",JSON_ARRAYAGG(JSON_OBJECT('codeType',type_message.code_type,'createdAt',type_message.created_at)) refTypeMessage" : ""}
FROM message
${withRoom ? "JOIN room ON message.room_code=room.code_room AND message.room_code_section=room.section" : ""}
${withUser ? "JOIN user ON message.user_code=user.code_user" : ""}
${withTypeMessage ? "JOIN type_message ON message.type_message_code=type_message.code_type" : ""}
${where == null ? '' : 'WHERE ${where.toSql(ctx)}'}
GROUP BY num_id,code_message
${orderBy == null ? '' : 'ORDER BY ${orderBy.map((item) => item.toSql(ctx)).join(",")}'}
${limit == null ? '' : 'LIMIT ${limit.rowCount} ${limit.offset == null ? "" : "OFFSET ${limit.offset}"}'}
;
""";
    return SqlQuery(query, ctx.variables);
  }

  static Future<List<Message>> select(
    TableConnection conn, {
    SqlValue<SqlBoolValue>? where,
    List<SqlOrderItem>? orderBy,
    SqlLimit? limit,
    bool withRoom = false,
    bool withUser = false,
    bool withTypeMessage = false,
  }) async {
    final query = Message.selectSql(
      where: where,
      limit: limit,
      orderBy: orderBy,
      database: conn.database,
      withRoom: withRoom,
      withUser: withUser,
      withTypeMessage: withTypeMessage,
    );

    final result = await conn.query(query.query, query.params);
    int _refIndex = 10;

    return result.map((r) {
      return Message(
        numId: r[0] as int,
        codeMessage: r[1] as String,
        userCode: r[2] as List<int>,
        roomCode: r[3] as String,
        roomCodeSection: r[4] as int,
        text: r[5] as String,
        senderName: r[6] as String?,
        typeMessageCode: r[7] as String,
        read: r[8] as int,
        createdAt: r[9] as DateTime,
        refRoom: withRoom ? Room.listFromJson(r[_refIndex++]) : null,
        refUser: withUser ? User.listFromJson(r[_refIndex++]) : null,
        refTypeMessage:
            withTypeMessage ? TypeMessage.listFromJson(r[_refIndex++]) : null,
      );
    }).toList();
  }

  factory Message.fromJson(dynamic json) {
    final Map map;
    if (json is Message) {
      return json;
    } else if (json is Map) {
      map = json;
    } else if (json is String) {
      map = jsonDecode(json) as Map;
    } else {
      throw Error();
    }

    return Message(
      numId: map["numId"] as int,
      codeMessage: map["codeMessage"] as String,
      userCode: map["userCode"] as List<int>,
      roomCode: map["roomCode"] as String,
      roomCodeSection: map["roomCodeSection"] as int,
      text: map["text"] as String,
      senderName: map["senderName"] as String?,
      typeMessageCode: map["typeMessageCode"] as String,
      read: map["read"] as int,
      createdAt: map["createdAt"] as DateTime,
      refRoom: Room.listFromJson(map["refRoom"]),
      refUser: User.listFromJson(map["refUser"]),
      refTypeMessage: TypeMessage.listFromJson(map["refTypeMessage"]),
    );
  }

  static List<Message>? listFromJson(dynamic _json) {
    final json = _json is String ? jsonDecode(_json) : _json;

    if (json is List || json is Set) {
      return (json as Iterable).map((e) => Message.fromJson(e)).toList();
    } else if (json is Map) {
      final _jsonMap = json.cast<String, List>();
      final numId = _jsonMap["numId"];
      final codeMessage = _jsonMap["codeMessage"];
      final userCode = _jsonMap["userCode"];
      final roomCode = _jsonMap["roomCode"];
      final roomCodeSection = _jsonMap["roomCodeSection"];
      final text = _jsonMap["text"];
      final senderName = _jsonMap["senderName"];
      final typeMessageCode = _jsonMap["typeMessageCode"];
      final read = _jsonMap["read"];
      final createdAt = _jsonMap["createdAt"];
      final refRoom = _jsonMap['refRoom'];
      final refUser = _jsonMap['refUser'];
      final refTypeMessage = _jsonMap['refTypeMessage'];
      return Iterable.generate(
        (numId?.length ??
            codeMessage?.length ??
            userCode?.length ??
            roomCode?.length ??
            roomCodeSection?.length ??
            text?.length ??
            senderName?.length ??
            typeMessageCode?.length ??
            read?.length ??
            createdAt?.length ??
            refRoom?.length ??
            refUser?.length ??
            refTypeMessage?.length)!,
        (_ind) {
          return Message(
            numId: numId?[_ind] as int,
            codeMessage: codeMessage?[_ind] as String,
            userCode: userCode?[_ind] as List<int>,
            roomCode: roomCode?[_ind] as String,
            roomCodeSection: roomCodeSection?[_ind] as int,
            text: text?[_ind] as String,
            senderName: senderName?[_ind] as String?,
            typeMessageCode: typeMessageCode?[_ind] as String,
            read: read?[_ind] as int,
            createdAt: createdAt?[_ind] as DateTime,
            refRoom: Room.listFromJson(refRoom?[_ind]),
            refUser: User.listFromJson(refUser?[_ind]),
            refTypeMessage: TypeMessage.listFromJson(refTypeMessage?[_ind]),
          );
        },
      ).toList();
    } else {
      return _json as List<Message>?;
    }
  }
}

class MessageCols {
  MessageCols(String tableAlias)
      : numId = SqlValue.raw('$tableAlias.num_id'),
        codeMessage = SqlValue.raw('$tableAlias.code_message'),
        userCode = SqlValue.raw('$tableAlias.user_code'),
        roomCode = SqlValue.raw('$tableAlias.room_code'),
        roomCodeSection = SqlValue.raw('$tableAlias.room_code_section'),
        text = SqlValue.raw('$tableAlias.text'),
        senderName = SqlValue.raw('$tableAlias.sender_name'),
        typeMessageCode = SqlValue.raw('$tableAlias.type_message_code'),
        read = SqlValue.raw('$tableAlias.read'),
        createdAt = SqlValue.raw('$tableAlias.created_at');

  final SqlValue<SqlNumValue> numId;
  final SqlValue<SqlStringValue> codeMessage;
  final SqlValue<SqlBinaryValue> userCode;
  final SqlValue<SqlStringValue> roomCode;
  final SqlValue<SqlNumValue> roomCodeSection;
  final SqlValue<SqlStringValue> text;
  final SqlValue<SqlStringValue> senderName;
  final SqlValue<SqlStringValue> typeMessageCode;
  final SqlValue<SqlNumValue> read;
  final SqlValue<SqlDateValue> createdAt;

  late final List<SqlValue> allColumns = [
    numId,
    codeMessage,
    userCode,
    roomCode,
    roomCodeSection,
    text,
    senderName,
    typeMessageCode,
    read,
    createdAt,
  ];
}

class User {
  final List<int> codeUser;
  final DateTime createdAt;

  final Map<String, Object?> additionalInfo;

  const User({
    required this.codeUser,
    required this.createdAt,
    this.additionalInfo = const {},
  });

  String insertShallowSql() {
    return """
INSERT INTO user(code_user,created_at)
VALUES ($codeUser,$createdAt);
""";
  }

  Future<SqlQueryResult> insertShallow(TableConnection conn) {
    final sqlQuery = insertShallowSql();
    return conn.query(sqlQuery);
  }

  static SqlQuery selectSql({
    SqlValue<SqlBoolValue>? where,
    List<SqlOrderItem>? orderBy,
    SqlLimit? limit,
    required SqlDatabase database,
    bool unsafe = false,
  }) {
    final ctx = SqlContext(database: database, unsafe: unsafe);
    final query = """
SELECT code_user,created_at

FROM user

${where == null ? '' : 'WHERE ${where.toSql(ctx)}'}
GROUP BY null
${orderBy == null ? '' : 'ORDER BY ${orderBy.map((item) => item.toSql(ctx)).join(",")}'}
${limit == null ? '' : 'LIMIT ${limit.rowCount} ${limit.offset == null ? "" : "OFFSET ${limit.offset}"}'}
;
""";
    return SqlQuery(query, ctx.variables);
  }

  static Future<List<User>> select(
    TableConnection conn, {
    SqlValue<SqlBoolValue>? where,
    List<SqlOrderItem>? orderBy,
    SqlLimit? limit,
  }) async {
    final query = User.selectSql(
      where: where,
      limit: limit,
      orderBy: orderBy,
      database: conn.database,
    );

    final result = await conn.query(query.query, query.params);
    int _refIndex = 2;

    return result.map((r) {
      return User(
        codeUser: r[0] as List<int>,
        createdAt: r[1] as DateTime,
      );
    }).toList();
  }

  factory User.fromJson(dynamic json) {
    final Map map;
    if (json is User) {
      return json;
    } else if (json is Map) {
      map = json;
    } else if (json is String) {
      map = jsonDecode(json) as Map;
    } else {
      throw Error();
    }

    return User(
      codeUser: map["codeUser"] as List<int>,
      createdAt: map["createdAt"] as DateTime,
    );
  }

  static List<User>? listFromJson(dynamic _json) {
    final json = _json is String ? jsonDecode(_json) : _json;

    if (json is List || json is Set) {
      return (json as Iterable).map((e) => User.fromJson(e)).toList();
    } else if (json is Map) {
      final _jsonMap = json.cast<String, List>();
      final codeUser = _jsonMap["codeUser"];
      final createdAt = _jsonMap["createdAt"];

      return Iterable.generate(
        (codeUser?.length ?? createdAt?.length)!,
        (_ind) {
          return User(
            codeUser: codeUser?[_ind] as List<int>,
            createdAt: createdAt?[_ind] as DateTime,
          );
        },
      ).toList();
    } else {
      return _json as List<User>?;
    }
  }
}

class UserCols {
  UserCols(String tableAlias)
      : codeUser = SqlValue.raw('$tableAlias.code_user'),
        createdAt = SqlValue.raw('$tableAlias.created_at');

  final SqlValue<SqlBinaryValue> codeUser;
  final SqlValue<SqlDateValue> createdAt;

  late final List<SqlValue> allColumns = [
    codeUser,
    createdAt,
  ];
}

class Room {
  final String codeRoom;
  final int section;
  final DateTime createdAt;

  final Map<String, Object?> additionalInfo;

  const Room({
    required this.codeRoom,
    required this.section,
    required this.createdAt,
    this.additionalInfo = const {},
  });

  String insertShallowSql() {
    return """
INSERT INTO room(code_room,section,created_at)
VALUES ($codeRoom,$section,$createdAt);
""";
  }

  Future<SqlQueryResult> insertShallow(TableConnection conn) {
    final sqlQuery = insertShallowSql();
    return conn.query(sqlQuery);
  }

  static SqlQuery selectSql({
    SqlValue<SqlBoolValue>? where,
    List<SqlOrderItem>? orderBy,
    SqlLimit? limit,
    required SqlDatabase database,
    bool unsafe = false,
  }) {
    final ctx = SqlContext(database: database, unsafe: unsafe);
    final query = """
SELECT code_room,section,created_at

FROM room

${where == null ? '' : 'WHERE ${where.toSql(ctx)}'}
GROUP BY null
${orderBy == null ? '' : 'ORDER BY ${orderBy.map((item) => item.toSql(ctx)).join(",")}'}
${limit == null ? '' : 'LIMIT ${limit.rowCount} ${limit.offset == null ? "" : "OFFSET ${limit.offset}"}'}
;
""";
    return SqlQuery(query, ctx.variables);
  }

  static Future<List<Room>> select(
    TableConnection conn, {
    SqlValue<SqlBoolValue>? where,
    List<SqlOrderItem>? orderBy,
    SqlLimit? limit,
  }) async {
    final query = Room.selectSql(
      where: where,
      limit: limit,
      orderBy: orderBy,
      database: conn.database,
    );

    final result = await conn.query(query.query, query.params);
    int _refIndex = 3;

    return result.map((r) {
      return Room(
        codeRoom: r[0] as String,
        section: r[1] as int,
        createdAt: r[2] as DateTime,
      );
    }).toList();
  }

  factory Room.fromJson(dynamic json) {
    final Map map;
    if (json is Room) {
      return json;
    } else if (json is Map) {
      map = json;
    } else if (json is String) {
      map = jsonDecode(json) as Map;
    } else {
      throw Error();
    }

    return Room(
      codeRoom: map["codeRoom"] as String,
      section: map["section"] as int,
      createdAt: map["createdAt"] as DateTime,
    );
  }

  static List<Room>? listFromJson(dynamic _json) {
    final json = _json is String ? jsonDecode(_json) : _json;

    if (json is List || json is Set) {
      return (json as Iterable).map((e) => Room.fromJson(e)).toList();
    } else if (json is Map) {
      final _jsonMap = json.cast<String, List>();
      final codeRoom = _jsonMap["codeRoom"];
      final section = _jsonMap["section"];
      final createdAt = _jsonMap["createdAt"];

      return Iterable.generate(
        (codeRoom?.length ?? section?.length ?? createdAt?.length)!,
        (_ind) {
          return Room(
            codeRoom: codeRoom?[_ind] as String,
            section: section?[_ind] as int,
            createdAt: createdAt?[_ind] as DateTime,
          );
        },
      ).toList();
    } else {
      return _json as List<Room>?;
    }
  }
}

class RoomCols {
  RoomCols(String tableAlias)
      : codeRoom = SqlValue.raw('$tableAlias.code_room'),
        section = SqlValue.raw('$tableAlias.section'),
        createdAt = SqlValue.raw('$tableAlias.created_at');

  final SqlValue<SqlStringValue> codeRoom;
  final SqlValue<SqlNumValue> section;
  final SqlValue<SqlDateValue> createdAt;

  late final List<SqlValue> allColumns = [
    codeRoom,
    section,
    createdAt,
  ];
}

class TypeMessage {
  final String codeType;
  final DateTime createdAt;

  final Map<String, Object?> additionalInfo;

  const TypeMessage({
    required this.codeType,
    required this.createdAt,
    this.additionalInfo = const {},
  });

  String insertShallowSql() {
    return """
INSERT INTO type_message(code_type,created_at)
VALUES ($codeType,$createdAt);
""";
  }

  Future<SqlQueryResult> insertShallow(TableConnection conn) {
    final sqlQuery = insertShallowSql();
    return conn.query(sqlQuery);
  }

  static SqlQuery selectSql({
    SqlValue<SqlBoolValue>? where,
    List<SqlOrderItem>? orderBy,
    SqlLimit? limit,
    required SqlDatabase database,
    bool unsafe = false,
  }) {
    final ctx = SqlContext(database: database, unsafe: unsafe);
    final query = """
SELECT code_type,created_at

FROM type_message

${where == null ? '' : 'WHERE ${where.toSql(ctx)}'}
GROUP BY null
${orderBy == null ? '' : 'ORDER BY ${orderBy.map((item) => item.toSql(ctx)).join(",")}'}
${limit == null ? '' : 'LIMIT ${limit.rowCount} ${limit.offset == null ? "" : "OFFSET ${limit.offset}"}'}
;
""";
    return SqlQuery(query, ctx.variables);
  }

  static Future<List<TypeMessage>> select(
    TableConnection conn, {
    SqlValue<SqlBoolValue>? where,
    List<SqlOrderItem>? orderBy,
    SqlLimit? limit,
  }) async {
    final query = TypeMessage.selectSql(
      where: where,
      limit: limit,
      orderBy: orderBy,
      database: conn.database,
    );

    final result = await conn.query(query.query, query.params);
    int _refIndex = 2;

    return result.map((r) {
      return TypeMessage(
        codeType: r[0] as String,
        createdAt: r[1] as DateTime,
      );
    }).toList();
  }

  factory TypeMessage.fromJson(dynamic json) {
    final Map map;
    if (json is TypeMessage) {
      return json;
    } else if (json is Map) {
      map = json;
    } else if (json is String) {
      map = jsonDecode(json) as Map;
    } else {
      throw Error();
    }

    return TypeMessage(
      codeType: map["codeType"] as String,
      createdAt: map["createdAt"] as DateTime,
    );
  }

  static List<TypeMessage>? listFromJson(dynamic _json) {
    final json = _json is String ? jsonDecode(_json) : _json;

    if (json is List || json is Set) {
      return (json as Iterable).map((e) => TypeMessage.fromJson(e)).toList();
    } else if (json is Map) {
      final _jsonMap = json.cast<String, List>();
      final codeType = _jsonMap["codeType"];
      final createdAt = _jsonMap["createdAt"];

      return Iterable.generate(
        (codeType?.length ?? createdAt?.length)!,
        (_ind) {
          return TypeMessage(
            codeType: codeType?[_ind] as String,
            createdAt: createdAt?[_ind] as DateTime,
          );
        },
      ).toList();
    } else {
      return _json as List<TypeMessage>?;
    }
  }
}

class TypeMessageCols {
  TypeMessageCols(String tableAlias)
      : codeType = SqlValue.raw('$tableAlias.code_type'),
        createdAt = SqlValue.raw('$tableAlias.created_at');

  final SqlValue<SqlStringValue> codeType;
  final SqlValue<SqlDateValue> createdAt;

  late final List<SqlValue> allColumns = [
    codeType,
    createdAt,
  ];
}
