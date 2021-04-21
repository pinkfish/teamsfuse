import * as fs from 'fs';

export const TEXT_BODY: string = fs.readFileSync('lib/ts/templates/notify/game.upcoming.txt', 'utf8');

export const HTML_BODY: string = fs.readFileSync('lib/ts/templates/notify/game.upcoming.html', 'utf8');
