library firestore_mobile;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_storage/firebase_storage.dart' as st;
import 'package:flutter/cupertino.dart';
import 'package:fusemodel/firestore.dart' as wfs;

part 'src/auth.dart';
part 'src/collection.dart';
part 'src/documentreference.dart';
part 'src/documentsnapshot.dart';
part 'src/firestore.dart';
part 'src/query.dart';
part 'src/storagereference.dart';
part 'src/transaction.dart';
