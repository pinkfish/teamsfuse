import momenttz from 'moment-timezone';
import moment from 'moment';

export function getDisplayTime(game) {
  if (!game.displayTime || typeof(game.displayTime) == 'string') {
    game.displayTime = moment(game.time).tz(game.timezone);
  }
  return game.displayTime;
}

export function somethingElse() {
  
}
