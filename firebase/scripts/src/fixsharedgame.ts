import * as admin from "firebase-admin";

import * as serviceAccount from "./service-key.json";

const params = {
  type: serviceAccount.type,
  projectId: serviceAccount.project_id,
  privateKeyId: serviceAccount.private_key_id,
  privateKey: serviceAccount.private_key,
  clientEmail: serviceAccount.client_email,
  clientId: serviceAccount.client_id,
  authUri: serviceAccount.auth_uri,
  tokenUri: serviceAccount.token_uri,
  authProviderX509CertUrl: serviceAccount.auth_provider_x509_cert_url,
  clientC509CertUrl: serviceAccount.client_x509_cert_url
};

admin.initializeApp({
  credential: admin.credential.cert(params),
  databaseURL: "https://teamsfuse.firebaseio.com"
});

const db = admin.firestore();

export async function updateSharedGames(): Promise<void> {
  await db
    .collection("GamesShared")
    .get()
    .then(snap => {
      const ret = [];
      for (const index in snap.docs) {
        ret.push(
          (function(myDoc) {
            const sharedData = myDoc.data();

            console.log("fixing shared " + myDoc.id);
            if (sharedData.officialResult !== undefined) {
              if (
                sharedData.officialResult.result === undefined ||
                sharedData.officialResult.result === null
              ) {
                let newResult = sharedData.officialResult.officialResult;
                if (newResult === undefined || newResult === null) {
                  newResult = "Unknown";
                }
                sharedData.officialResult.result = newResult;
                console.log(sharedData.officialResult.scores);
              }
            }
            return myDoc.ref.update(sharedData);
          })(snap.docs[index])
        );
      }
      return Promise.all(ret);
    });
}

export async function updateGameScores(): Promise<void> {
  await db
    .collection("Games")
    .get()
    .then(snap => {
      const ret = [];
      for (const index in snap.docs) {
        ret.push(
          (async function(myDoc) {
            const sharedData = myDoc.data();

            console.log("fixing game " + myDoc.id);
            if (sharedData.sharedDataUid === undefined) {
              // Create a new doc.
              const newDoc = await db.collection("GamesShared").doc();
              sharedData.sharedDataUid = newDoc.id;
              console.log("new data " + newDoc.id);
              const toUpdate = {
                name: sharedData.name === undefined ? "" : sharedData.name,
                place: sharedData.place,

                uid: newDoc.id,
                time: sharedData.arrivalTime,
                timezone: sharedData.timezone,
                endTime: sharedData.endTime,
                type: sharedData.type,
                officialResult: {
                  scores: {},
                  result: "NotStarted"
                }
              };
              console.log(toUpdate);
              await myDoc.ref.update({ sharedGameUid: newDoc.id });
              await newDoc.set(toUpdate);
            }
            return;
          })(snap.docs[index])
        );
      }
      return Promise.all(ret);
    });
}

export async function updateAllGames(): Promise<void> {
  await db
    .collection("Games")
    .get()
    .then(snap => {
      const ret = [];
      for (const index in snap.docs) {
        (function(myDoc) {
          const data = myDoc.data();
          if (data != null) {
            // Add in the data and update the game.
            console.log("fixing game " + myDoc.id);
            data.result.result = data.result.result.replace("GameResult.", "");
            data.result.result = data.result.result.replace("undefined", "");
            data.result.inProgress = data.result.inProgress.replace(
              "GameInProgress.",
              ""
            );
            data.result.inProgress = data.result.inProgress.replace(
              "undefined",
              ""
            );
            if (data.result.divisions !== undefined) {
              data.result.divisions = data.result.divisions.replace(
                "GameDivisionsHalf.",
                ""
              );
            }
            if (data.type !== undefined) {
              data.type = data.type.replace("EventType.", "");
              data.type = data.type.replace("undefined", "");
            }
            if (data.sharedData !== undefined) {
              if (data.sharedData.type !== undefined) {
                data.sharedData.type = data.sharedData.type.replace(
                  "EventType.",
                  ""
                );
              }
              if (data.sharedData.officialResult != undefined) {
                if (data.sharedData.officialResult.divisions != undefined) {
                  data.sharedData.officialResult.divisions = data.sharedData.officialResult.divisions.replace(
                    "GameDivisionsType.",
                    ""
                  );
                }
                if (data.sharedData.officialResult.inProgress != undefined) {
                  data.sharedData.officialResult.inProgress = data.sharedData.officialResult.divisions.replace(
                    "GameInProgress.",
                    ""
                  );
                }
                if (data.sharedData.officialResult.result != undefined) {
                  data.sharedData.officialResult.result = data.sharedData.officialResult.divisions.replace(
                    "GameResult.",
                    ""
                  );
                }
              }

              if (
                data.sharedData.place !== undefined &&
                data.sharedData.place.type !== undefined
              ) {
                data.sharedData.place.type = data.sharedData.place.type.replace(
                  "EventType.",
                  ""
                );
              }
            }
            if (data.attendance !== undefined) {
              for (const attend in data.attendance) {
                if (data.attendance[attend].value !== undefined) {
                  data.attendance[attend].value = data.attendance[
                    attend
                  ].value.replace("Attendance.", "");
                } else {
                  for (const inner in data.attendance[attend]) {
                    if (data.attendance[attend][inner].value !== undefined) {
                      data.attendance[attend][inner].value = data.attendance[
                        attend
                      ][inner].value.replace("Attendance.", "");
                    }
                  }
                }
              }
            }
            data.uid = myDoc.id;
            ret.push(myDoc.ref.update(data));
          }
        })(snap.docs[index]);
      }
    });
}

export async function updateSeason(): Promise<void> {
  await db
    .collection("Seasons")
    .get()
    .then(snap => {
      const ret = [];
      for (const index in snap.docs) {
        ret.push(
          (function(myDoc) {
            const sharedData = myDoc.data();

            console.log("fixing season " + myDoc.id);
            sharedData.uid = myDoc.id;
            return myDoc.ref.update(sharedData);
          })(snap.docs[index])
        );
      }
      return Promise.all(ret);
    });
}

export async function updateInvites(): Promise<void> {
  await db
    .collection("Invites")
    .get()
    .then(snap => {
      const ret = [];
      for (const index in snap.docs) {
        ret.push(
          (function(myDoc) {
            const sharedData = myDoc.data();

            console.log("fixing invite " + myDoc.id);
            sharedData.uid = myDoc.id;
            return myDoc.ref.update(sharedData);
          })(snap.docs[index])
        );
      }
      return Promise.all(ret);
    });
}

export async function updateTeams(): Promise<void> {
  await db
    .collection("Teams")
    .get()
    .then(snap => {
      const ret = [];
      for (const index in snap.docs) {
        ret.push(
          (function(myDoc) {
            const sharedData = myDoc.data();

            console.log("fixing team " + myDoc.id);
            sharedData.uid = myDoc.id;
            return db
              .collection("Teams")
              .doc(myDoc.id)
              .update(sharedData);
          })(snap.docs[index])
        );
      }
      return Promise.all(ret);
    });
}

export async function updateGameLogs(): Promise<void> {
  await db
    .collectionGroup("Logs")
    .get()
    .then(snap => {
      const ret = [];
      for (const index in snap.docs) {
        ret.push(
          (function(myDoc) {
            const sharedData = myDoc.data();

            console.log("fixing game log " + myDoc.id);
            sharedData.uid = myDoc.id;
            return myDoc.ref.update(sharedData);
          })(snap.docs[index])
        );
      }
      return Promise.all(ret);
    })
    .catch(e => {
      console.log(e);
    });
}

export async function updateOpponents(): Promise<void> {
  try {
    const snap = await db.collectionGroup("Opponents").get();
    for (const index in snap.docs) {
      const myDoc = snap.docs[index];
      const op = myDoc.data();
      const teamUid = myDoc.ref.path.split("/")[1];

      console.log("fixing opponent " + myDoc.id + "  " + teamUid);
      op.uid = myDoc.id;
      op.teamUid = teamUid;
      await myDoc.ref.update(op);
    }
  } catch (e) {
    console.log(e);
  }
}

export async function deleteAllGamesFor(): Promise<void> {
  const teamUid = "-LAVoCeePAMJQYOyoQyW";

  try {
    const snap = await db
      .collection("Games")
      .where("teamUid", "==", teamUid)
      .get();
    for (const index in snap.docs) {
      const myDoc = snap.docs[index];
      const op = myDoc.data();

      console.log("deleteing game " + myDoc.id + "  " + op.sharedDataUid);
      await db
        .collection("Games")
        .doc(myDoc.id)
        .delete();
      //await db.collection("GamesShared").doc(op.sharedDataUid).delete();
    }
  } catch (e) {
    console.log(e);
  }
}

export async function convertSharedGametoSharedData(): Promise<void> {
  try {
    const snap = await db.collection("Games").get();
    for (const index in snap.docs) {
      const myDoc = snap.docs[index];
      const op = myDoc.data();

      console.log("  " + op.sharedDataUid + " -- " + op.sharedGameUid);
      if (op.sharedDataUid === undefined && op.sharedGameUid !== undefined) {
        console.log("Updating " + myDoc.id);
        await db
          .collection("Games")
          .doc(myDoc.id)
          .update({ sharedDataUid: op.sharedGameUid });
      }
    }
  } catch (e) {
    console.log(e);
  }
}

export async function fixupSharedGames(): Promise<void> {
  try {
    const snap = await db.collection("GamesShared").get();
    for (const index in snap.docs) {
      const myDoc = snap.docs[index];
      const op = myDoc.data();

      if (op.type === "Training" ) {
        console.log("Updating " + myDoc.id);
        await db
          .collection("GamesShared")
          .doc(myDoc.id)
          .update({ type: "Practice" });
      }
    }
  } catch (e) {
    console.log(e);
  }
}

export async function deleteOrphanedSharedGames(): Promise<void> {
  try {
    const snap = await db.collection("GamesShared").get();
    for (const index in snap.docs) {
      const myDoc = snap.docs[index];
      const sharedData = myDoc.data();

      // See if we can find a game with this id.
      const gameSnap = await db
        .collection("Games")
        .where("sharedDataUid", "==", myDoc.id)
        .get();
      if (
        gameSnap.size === 0 &&
        (sharedData.leagueUid === undefined ||
          sharedData.leagueUid === null ||
          sharedData.leagueUid === "")
      ) {
        console.log("Deleting " + myDoc.id + " " + gameSnap.size);
        await db
          .collection("GamesShared")
          .doc(myDoc.id)
          .delete();
      } else {
        console.log("Found " + myDoc.id + " " + sharedData.leagueUid);
      }
    }
  } catch (e) {
    console.log(e);
  }
}

//updateSharedGames();
//updateAllGames();
//updateSeason();
//updateTeams();
//updateInvites()
//updateGameLogs();
//updateGameScores();
//updateOpponents();


//convertSharedGametoSharedData();

export async function doStuff() {
await deleteAllGamesFor();
await deleteOrphanedSharedGames();
}

//doStuff();

fixupSharedGames();

