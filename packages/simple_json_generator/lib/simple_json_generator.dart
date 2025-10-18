library;

import 'package:build/build.dart';
import 'package:simple_json_generator/src/json_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder generateJsonClass(BuilderOptions options) =>
    PartBuilder([JsonGenerator()], '.g.dart');
