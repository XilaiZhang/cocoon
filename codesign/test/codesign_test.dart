// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:codesign/codesign.dart';
import 'package:test/test.dart';

void main() {
  test('placeholder', () {
    throw ConductorException('jesusssss');
    expect(1, equals(1));
  });
}
