import playersLogic from "./players/playersLogic";
import teamsLogic from "./players/teamsLogic";
import gamesLogic from "./players/gamesLogic";
import opponentsLogic from "./players/opponentsLogic";

export default [
 ...playersLogic,
 ...teamsLogic,
 ...gamesLogic,
 ...opponentsLogic
];
