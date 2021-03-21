import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fusemodel/fusemodel.dart';
import 'package:meta/meta.dart';

import '../coordinationbloc.dart';
import 'additemstate.dart';

abstract class AddInviteEvent extends Equatable {}

///
/// Sends the invite off to invite world.
///
class InviteEventAddUserToPlayer extends AddInviteEvent {
  final String playerUid;
  final String email;
  final String playerName;

  InviteEventAddUserToPlayer(
      {@required this.playerUid,
      @required this.email,
      @required this.playerName});

  @override
  List<Object> get props => [playerName, email, playerName];
}

///
/// Sends an invite to all the specified played to the team.
///
class InvitePlayersToTeam extends AddInviteEvent {
  /// The email to add the invite.
  final String email;

  /// The name of the player in the invite.
  final String playerName;

  /// The role the user is added as.
  final RoleInTeam role;

  /// The uid of the seson to invite to.
  final String seasonUid;

  /// The name of the seson.
  final String seasonName;

  /// The team uid to invite to.
  final String teamUid;

  /// The name of the team to invite to.
  final String teamName;

  /// The jersey number in the team.
  final String jerseyNumber;

  /// Create an invite.
  InvitePlayersToTeam(
      {@required this.email,
      @required this.playerName,
      @required this.role,
      @required this.seasonUid,
      @required this.teamUid,
      @required this.seasonName,
      @required this.teamName,
      @required this.jerseyNumber});

  @override
  List<Object> get props =>
      [email, playerName, role, seasonUid, seasonName, teamUid, teamName];
}

///
/// Sends the add as admin invite.
///
class InviteEventAddAsAdmin extends AddInviteEvent {
  final String teamUid;
  final String email;
  final String teamName;

  InviteEventAddAsAdmin(
      {@required this.teamUid, @required this.email, @required this.teamName});

  @override
  // TODO: implement props
  List<Object> get props => [teamName, email, teamUid];
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddInviteBloc extends Bloc<AddInviteEvent, AddItemState> {
  final CoordinationBloc coordinationBloc;

  AddInviteBloc({@required this.coordinationBloc})
      : super(AddItemUninitialized());

  @override
  Stream<AddItemState> mapEventToState(AddInviteEvent event) async* {
    // Create a invite as player.
    if (event is InviteEventAddUserToPlayer) {
      yield AddItemSaving();
      try {
        var uid = await coordinationBloc.databaseUpdateModel.inviteUserToPlayer(
            myUid: coordinationBloc.authenticationBloc.currentUser.uid,
            playerUid: event.playerUid,
            playerName: event.playerName,
            email: event.email);
        yield AddItemDone(uid: uid);
      } catch (e, stack) {
        coordinationBloc.analytics.recordException(e, stack);

        yield AddItemSaveFailed(error: e);
      }
    }

    if (event is InvitePlayersToTeam) {
      yield AddItemSaving();
      try {
        await coordinationBloc.databaseUpdateModel.inviteUserToSeason(
            email: event.email,
            playerName: event.playerName,
            role: event.role,
            seasonUid: event.seasonUid,
            teamName: event.teamName,
            teamUid: event.teamUid,
            seasonName: event.seasonName,
            jerseyNumber: event.jerseyNumber);

        yield AddItemDone(uid: 'done');
      } catch (e, stack) {
        coordinationBloc.analytics.recordException(e, stack);

        yield AddItemSaveFailed(error: e);
      }
    }

    // Create a invite as admin.
    if (event is InviteEventAddAsAdmin) {
      yield AddItemSaving();
      try {
        var uid = await coordinationBloc.databaseUpdateModel.inviteAdminToTeam(
            myUid: coordinationBloc.authenticationBloc.currentUser.uid,
            teamUid: event.teamUid,
            teamName: event.teamName,
            email: event.email);
        yield AddItemDone(uid: uid);
      } catch (e, stack) {
        coordinationBloc.analytics.recordException(e, stack);

        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
