import playersLogic from "./players/playersLogic";
import teamsLogic from "./players/teamsLogic";
import gamesLogic from "./players/gamesLogic";

export default [
 ...playersLogic,
 ...teamsLogic,
 ...gamesLogic
];
