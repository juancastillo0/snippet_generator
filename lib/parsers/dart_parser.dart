import 'package:petitparser/petitparser.dart';

final dartStringParser =
    ((char('@').optional() & dartMultiLineStringParser).pick(1) |
            dartSingleLineStringParser)
        .cast<String>();

final dartMultiLineStringParser = (string('"""') &
            any().starLazy(string('"""')) &
            string('"""') |
        string("'''") & any().starLazy(string("'''")) & string("'''"))
    .map<String>(
        (value) => List.castFrom<dynamic, String>(value[1] as List).join(""));

final dartSingleLineStringParser = (char('"') &
            _stringContentDq.star() &
            char('"') |
        char("'") & _stringContentSq.star() & char("'") |
        string('@"') & pattern('^"\n\r').star() & char('"') |
        string("@'") & pattern("^'\n\r").star() & char("'"))
    .map<String>(
        (value) => List.castFrom<dynamic, String>(value[1] as List).join(""));

final _stringContentDq = pattern('^\\"\n\r') | char('\\') & pattern('\n\r');

final _stringContentSq = pattern("^\\'\n\r") | char('\\') & pattern('\n\r');
