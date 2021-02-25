import 'gameresult.dart';

///
/// Abstract class used by both the offical result setup and
/// the results to return consistent data about regulation/overtime and
/// penalty results.
///
abstract class GameResultSharedDetails {
  GameResult get result;
  GameResultPerPeriod get regulationResult;
  GameResultPerPeriod get overtimeResult;
  GameResultPerPeriod get penaltyResult;
  bool get isGameFinished;
}
