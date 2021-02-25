import * as admin from "firebase-admin";

import * as serviceAccount from "./service-key.json";
import { gameData } from "./data";
import { Client, PlaceInputType } from "@googlemaps/google-maps-services-js";
import * as moment from "moment-timezone";
import { v4 as uuidv4 } from "uuid";

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
  clientC509CertUrl: serviceAccount.client_x509_cert_url,
};

admin.initializeApp({
  credential: admin.credential.cert(params),
  databaseURL: "https://teamsfuse.firebaseio.com",
});

const db = admin.firestore();
db.settings({ ignoreUndefinedProperties: true });
const mapsClient = new Client();

interface GameEntry {
  uid: string;
  arrivalTime: number;
  homegame: boolean;
  notes: string;
  seasonUid: string;
  opponentUid?: string;
  teamUid: string;
  trackAttendance: boolean;
  uniform: string;
  result: GameResultDetails;
  sharedDataUid: string;
}

interface GameScore {
  ptsFor: number;
  ptsAgainst: number;
  intermediate: boolean;
}

interface GameResult {
  period: string;
  score: GameScore;
}

interface ScorePerPeriod {
  [period: string]: GameResult;
}

interface GamePeriodTime {
  currentPeriodStartInternal: number; // Start of the current period.
  currentOffsetInternal: number;
  defaultPeriodDurationInternal: number;
  // If we count up the time, or down the time.  This changes how the
  // duration works in this game.
  timeCountUp: boolean;
}

interface GameResultDetails {
  result: string;
  inProgress: string;
  currentPeriod: string;
  divisions: string;
  time: GamePeriodTime;
  scores: ScorePerPeriod;
}

interface GamePlace {
  address: string;
  lat: number;
  long: number;
  name: string;
  notes: string;
  placeId?: string;
  unknown: boolean;
}

interface GameOfficialResult {
  scores: ScorePerPeriod;

  /// The team uid, this pointed to a leagueortourneamentteam data.
  homeTeamLeagueUid?: string;

  /// The team uid, this pointed to a leagueortourneamentteam data.
  awayTeamLeagueUid?: string;

  /// The official result for the game.
  result: string;
}

interface SharedGameEntry {
  place: GamePlace;
  time: number;
  timezone: string;
  type: string;
  uid: string;
  endTime: number;
  homeTeam: string;
  officalResult: GameOfficialResult;
}

interface BothBits {
  game: GameEntry;
  shared: SharedGameEntry;
}

const divisionsForTeam = "Halves";
const teamUid = "-LAVoCeePAMJQYOyoQyW";
const seasonsUid = [
  {
    uid: "-LAVoCenYC2-iVdVTbJD",
    time: moment.tz(
      { years: 2015, months: 5, days: 10, hours: 0, minutes: 0 },
      "America/Los_Angeles"
    ),
  },
  {
    uid: "-LJKC2rPUIoI3PFV53cM",
    time: moment.tz(
      { years: 2018, months: 5, days: 10, hours: 0, minutes: 0 },
      "America/Los_Angeles"
    ),
  },
  {
    uid: "5CkFxhouoK37ZFIqerQ4",
    time: moment.tz(
      { years: 2019, months: 5, days: 10, hours: 0, minutes: 0 },
      "America/Los_Angeles"
    ),
  },
  {
    uid: "3GHM8BfQEwmJe3qjeLe9",
    time: moment.tz(
      { years: 2020, months: 5, days: 10, hours: 0, minutes: 0 },
      "America/Los_Angeles"
    ),
  },
];

export function generateUUID() {
  /*
  // Public Domain/MIT
  let d = new Date().getTime(); //Timestamp
  let d2 = (performance && performance.now && performance.now() * 1000) || 0; //Time in microseconds since page-load or 0 if unsupported
  return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function(c) {
    let r = Math.random() * 16; //random number between 0 and 16
    if (d > 0) {
      //Use timestamp until depleted
      r = (d + r) % 16 | 0;
      d = Math.floor(d / 16);
    } else {
      //Use microseconds since page-load if supported
      r = (d2 + r) % 16 | 0;
      d2 = Math.floor(d2 / 16);
    }
    return (c === "x" ? r : (r & 0x3) | 0x8).toString(16);
  });
  */
  return uuidv4();
}

function getSeasonUid(tz: moment.Moment) {
  let diff = 0;
  let seasonUid = "";

  for (const entry of seasonsUid) {
    if (
      (seasonUid === "" || diff < entry.time.diff(tz)) &&
      entry.time.isBefore(tz)
    ) {
      diff = entry.time.diff(tz);
      seasonUid = entry.uid;
    }
  }
  console.log(seasonUid + "  " + tz.format());
  return seasonUid;
}

function getGameResult(input: string): GameResultDetails {
  if (input === "") {
    return {
      result: "Unknown",
      inProgress: "NotStarted",
      currentPeriod: "Final",
      divisions: divisionsForTeam,
      time: {
        currentPeriodStartInternal: 0,
        currentOffsetInternal: 0,
        defaultPeriodDurationInternal: 0,
        timeCountUp: true,
      },
      scores: {},
    };
  }
  // Do Stuff!
  const bits = input.split(" ");
  const nums = bits[1].split("-");
  const result: string =
    bits[0] == "W" ? "Win" : bits[0] == "L" ? "Loss" : "Tie";
  return {
    result: result,
    inProgress: "Final",
    divisions: divisionsForTeam,
    time: {
      currentPeriodStartInternal: 0,
      currentOffsetInternal: 0,
      defaultPeriodDurationInternal: 0,
      timeCountUp: true,
    },
    currentPeriod: "Final",
    scores: {
      Regulation: {
        period: "Regulation",
        score: {
          ptsFor: +nums[0],
          ptsAgainst: +nums[1],
          intermediate: false,
        },
      },
    },
  };
}

function getGameOfficialResult(input: string): GameOfficialResult {
  if (input === "") {
    return {
      result: "Unknown",
      scores: {},
    };
  }
  // Do Stuff!
  const bits = input.split(" ");
  const nums = bits[1].split("-");
  const result: string =
    bits[0] == "W" ? "Win" : bits[0] == "L" ? "Loss" : "Tie";
  return {
    result: result,
    scores: {
      Regulation: {
        period: "Regulation",
        score: {
          ptsFor: +nums[0],
          ptsAgainst: +nums[1],
          intermediate: false,
        },
      },
    },
  };
}

async function getGamePlace(name: string, address: string): Promise<GamePlace> {
  address = address.trim();
  if (address === "") {
    return {
      unknown: true,
      lat: 0,
      long: 0,
      address: "",
      name: "Unknown",
      notes: "",
    };
  }
  try {
    //    console.log("Lookup " + address);
    const result = await mapsClient.findPlaceFromText({
      params: {
        input: address,
        inputtype: PlaceInputType.textQuery,
        fields: ["place_id", "formatted_address", "geometry/location"],
        key: "AIzaSyBpcE6m0ydl6S5ilZ8XwML7lZ0sUmYz8E8",
      },
    });

    const latSt = result.data.candidates[0].geometry!.location.lat;
    const lat = latSt === undefined ? 0 : latSt;
    const lngSt = result.data.candidates[0].geometry!.location.lng;
    const lng = lngSt === undefined ? 0 : lngSt;

    return {
      unknown: false,
      lat: lat,
      long: lng,
      address: address,
      name: name,
      notes: "",
      placeId: result.data.candidates[0].place_id!,
    };
  } catch (e) {
    console.log("Error " + e);
    throw e;
  }
}

const _opponentUidLookup = new Map<string, string>();

function getOpponentUid(name: string): string | undefined {
  name = name.trim();
  if (name === "" || name === "Game") {
    // Weird, return a random opponent in this case.
    return undefined;
  }
  const lowerName = name.toLowerCase().replace(/\s/g, "");
  if (_opponentUidLookup.has(lowerName)) {
    const ret = _opponentUidLookup.get(lowerName);
    if (ret !== undefined) {
      return ret;
    }
  }
  console.log("new opponent " + name);
  const opDoc = db
    .collection("Teams")
    .doc(teamUid)
    .collection("Opponents")
    .doc();
  /*
  opDoc.set({
    contact: "",
    name: name,
    teamUid: teamUid,
    uid: opDoc.id,
    seasons: {}
  });
  */
  _opponentUidLookup.set(lowerName, opDoc.id);
  return opDoc.id;
}

async function loadOpponents(): Promise<void> {
  const snap = await db
    .collection("Teams")
    .doc(teamUid)
    .collection("Opponents")
    .get();

  for (const index in snap.docs) {
    const doc = snap.docs[index];
    const lowerName: string = doc.data().name!.toLowerCase().replace(/\s/g, "");
    _opponentUidLookup.set(lowerName, doc.id);
  }
  console.log(_opponentUidLookup);
  return;
}

function getArrivalTime(
  date: string,
  arrival: string,
  start: string
): moment.Moment {
  if (arrival === "") {
    arrival = start;
  }
  const bits = date.replace(/\s/g, "").split("/");
  const nextBits = arrival.split(":");
  const ampmSplit = nextBits[1].split(" ");
  const month = parseInt(bits[0]);
  const day = parseInt(bits[1]);
  const year = parseInt(bits[2]);
  let hour = parseInt(nextBits[0]);
  const minute = parseInt(ampmSplit[0]);
  if (ampmSplit[1] == "PM" && hour != 12) {
    hour += 12;
  }
  const dt = moment.tz(
    {
      year: year,
      month: month - 1,
      day: day,
      hour: hour,
      minute: minute,
      second: 0,
      millisecond: 0,
    },
    "America/Los_Angeles"
  );
  if (!dt.isValid()) {
    console.log(
      "Input " +
        date +
        " " +
        arrival +
        " +++ " +
        year +
        " " +
        month +
        " " +
        day +
        " " +
        hour +
        " " +
        minute
    );
  }
  return dt;
}

async function updateGameData(): Promise<BothBits[]> {
  const data = gameData;

  await loadOpponents();

  const ret: BothBits[] = [];

  for (const i in data) {
    const entry = data[i];
    const date = entry["Date"];
    const startTime = entry["Start Time"];
    const endTime = entry["End Time"];
    const arrivalTime = entry["Arrival Time"];
    let eventName = entry["Game "]["Event Name"];
    const locationName = entry["Location"];
    const address = entry["Address"];
    const result = entry["Result"];

    let gameType = "Game";
    let opponentName = "";
    let homeGame = true;
    eventName = eventName.trim();
    if (
      eventName.startsWith("Practice") ||
      eventName.startsWith("Training") ||
      result === ""
    ) {
      gameType = "Practice";
    } else {
      if (eventName.startsWith("at ")) {
        homeGame = false;
        opponentName = eventName.replace("at", "");
      } else {
        opponentName = eventName.replace(/^.*vs\.* (.*)/, "$1");
      }
      //console.log("Checking " + opponentName);
      gameType = "Game";
    }

    // Parse the data.
    const gameResult = getGameResult(result);
    const gameOfficialResult = getGameOfficialResult(result);
    const gamePlace = await getGamePlace(locationName, address);
    const opponentUid = getOpponentUid(opponentName);
    const arriveAt = getArrivalTime(date, arrivalTime, startTime);
    const startAt = getArrivalTime(date, startTime, startTime);
    const endAt = getArrivalTime(date, endTime, startTime);
    const sharedDoc = db.collection("GamesShared").doc();
    const gameDoc = db.collection("Games").doc();
    const shared: SharedGameEntry = {
      place: gamePlace,
      time: startAt.valueOf(),
      timezone: "America/Los_Angeles",
      type: gameType,
      uid: sharedDoc.id,
      endTime: endAt.valueOf(),
      homeTeam: teamUid,
      officalResult: gameOfficialResult,
    };
    const gameEntry: GameEntry = {
      uid: gameDoc.id,
      arrivalTime: arriveAt.valueOf(),
      homegame: homeGame,
      notes: "",
      seasonUid: getSeasonUid(startAt),
      opponentUid: opponentUid,
      teamUid: teamUid,
      trackAttendance: true,
      uniform: "blue",
      result: gameResult,
      sharedDataUid: sharedDoc.id,
    };
    //console.log(shared);
    //console.log(shared.officalResult.scores);
    //console.log(gameEntry);
    await sharedDoc.set(shared);
    await gameDoc.set(gameEntry);
    ret.push({ shared: shared, game: gameEntry });
  }
  return ret;
}

export async function updateResults(data: BothBits[]): Promise<void> {
  for (const i in data) {
    const game = data[i].game;
    const shared = data[i].shared;
    await db.collection("Game").add(game);
    await db.collection("SharedGame").add(shared);
  }
  return;
}

try {
  updateGameData();
} catch (e) {
  console.log("Error " + e);
}
