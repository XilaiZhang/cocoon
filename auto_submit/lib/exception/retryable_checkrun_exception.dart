// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

class RetryableCheckRunException implements Exception {
  RetryableCheckRunException(this.cause);

  final String cause;

  @override
  String toString() => cause;
}
