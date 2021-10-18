#!/bin/bash

cd `git rev-parse --show-toplevel`
cd flutter_fuse
flutter run -d chrome --dart-define=SENTRY_DSN="https://5691b440eb64430d9ba2917166fa17a1@o150925.ingest.sentry.io/1200691"
