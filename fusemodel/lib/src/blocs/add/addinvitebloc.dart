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
}

/// Sends an invite to all the specified played to the team.
///
class InvitePlayersToTeam extends AddInviteEvent {
  final Iterable<InviteTeamData> invites;
  final String seasonUid;

  InvitePlayersToTeam({@required this.invites, @required this.seasonUid});
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
}

///
/// Deals with specific players to allow for accepting/deleting/etc of the
/// players.
///
class AddInviteBloc extends Bloc<AddInviteEvent, AddItemState> {
  final CoordinationBloc coordinationBloc;

  AddInviteBloc({@required this.coordinationBloc}) {}

  @override
  AddItemState get initialState => new AddItemUninitialized();

  @override
  Stream<AddItemState> mapEventToState(AddInviteEvent event) async* {
    // Create a invite as player.
    if (event is InviteEventAddUserToPlayer) {
      yield AddItemSaving();
      try {
        String uid = await coordinationBloc.databaseUpdateModel
            .inviteUserToPlayer(
                myUid: coordinationBloc.authenticationBloc.currentUser.uid,
                playerUid: event.playerUid,
                playerName: event.playerName,
                email: event.email);
        yield AddItemDone(uid: uid);
      } catch (e) {
        yield AddItemSaveFailed(error: e);
      }
    }

    if (event is InvitePlayersToTeam) {
      yield AddItemSaving();
      try {
        for (InviteTeamData data in event.invites) {
          await coordinationBloc.databaseUpdateModel.inviteUserToSeason(
              seasonUid: event.seasonUid,
              playername: data.playerName,
              role: data.role,
              email: data.email,
              userId: coordinationBloc.authenticationBloc.currentUser.uid);
        }
        yield AddItemDone(uid: 'done');
      } catch (e) {
        yield AddItemSaveFailed(error: e);
      }
    }

    // Create a invite as admin.
    if (event is InviteEventAddAsAdmin) {
      yield AddItemSaving();
      try {
        String uid = await coordinationBloc.databaseUpdateModel
            .inviteAdminToTeam(
                myUid: coordinationBloc.authenticationBloc.currentUser.uid,
                teamUid: event.teamUid,
                teamName: event.teamName,
                email: event.email);
        yield AddItemDone(uid: uid);
      } catch (e) {
        yield AddItemSaveFailed(error: e);
      }
    }
  }
}
