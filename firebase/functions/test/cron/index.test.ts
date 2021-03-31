import * as sinon from 'sinon';
import { firebaseTest } from '../util/firebase';
//import { expect } from 'chai';
//import * as admin from 'firebase-admin';
//import { createSeasonAndTeam } from '../util/datacreation';
import * as notifyforgame from '../../ts/util/notifyforgame';

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

import { onHourlyPublish } from '../../ts/cron/hourly.f';

describe('Cron tests', () => {
    before(() => {
        return;
    });

    after(async () => {
        //  test.cleanup();
        sinon.restore();
        return;
    });

    it('no games', async () => {
        const spy = sinon.stub(notifyforgame, 'notifyForGame');

        // Just make sure creating a club actually works.
        test.wrap(onHourlyPublish)(null, undefined);
        sinon.assert.notCalled(spy);
    });
});
