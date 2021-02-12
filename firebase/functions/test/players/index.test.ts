import * as sinon from 'sinon';
import { firebaseTest } from '../util/firebase';
import { expect } from 'chai';
import { createPlayer } from '../util/datacreation';

const projectName = 'teamsfuse';

const test = firebaseTest(projectName);

test.mockConfig({
    mailgun: {
        apikey: 'frog',
        domain: 'frog.com',
    },
    links: {
        key: 'rabbit',
    },
    algolia: {
        appid: 'frog',
        key: 'rabbit',
    },
});

import { onPlayerWrite } from '../../ts/db/player/update.f';

describe('Player Tests', () => {
    before(() => {
        return;
    });

    after(async () => {
        //  test.cleanup();
        sinon.restore();
        return;
    });

    it('create with a user, no teams', async () => {
        // Just make sure creating a player actually works.
        const player = await createPlayer(['me']);
        const playerDocId = player.id;
        const oldPlayer = test.firestore.makeDocumentSnapshot({}, 'Players/' + playerDocId);
        await test.wrap(onPlayerWrite)(test.makeChange(oldPlayer, player), {
            auth: {
                uid: 'me',
            },
            authType: 'USER',
        });

        const data = player;
        expect(data).to.not.be.null;
        if (data !== null && data !== undefined) {
            expect(data.exists).to.be.true;
            const myData = data.data();
            expect(myData).to.not.be.null;
            if (myData !== undefined && myData !== null) {
                expect(myData.uid).to.equal(playerDocId);
            }
        }
    });
});
