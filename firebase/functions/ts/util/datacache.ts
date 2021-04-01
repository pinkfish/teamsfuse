import NodeCache from 'node-cache';
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export class DataNodeCache {
    cache = new NodeCache({ useClones: false });

    // Cleanup the cache.
    close() {
        this.cache.close();
    }

    async getSeason(seasonUid: string): Promise<functions.firestore.DocumentSnapshot> {
        const data = this.cache.get<functions.firestore.DocumentSnapshot>(seasonUid);
        if (data !== undefined) {
            return data;
        }

        const season = await db.collection('Seasons').doc(seasonUid).get();
        this.cache.set(seasonUid, season);
        return season;
    }

    async getUser(userUid: string): Promise<functions.firestore.DocumentSnapshot> {
        const data = this.cache.get<functions.firestore.DocumentSnapshot>(userUid);
        if (data !== undefined) {
            return data;
        }

        const user = await db.collection('UserData').doc(userUid).get();
        this.cache.set(userUid, user);
        return user;
    }

    async getTeam(teamUid: string): Promise<functions.firestore.DocumentSnapshot> {
        const data = this.cache.get<functions.firestore.DocumentSnapshot>(teamUid);
        if (data !== undefined) {
            return data;
        }

        const team = await db.collection('Teams').doc(teamUid).get();
        this.cache.set(teamUid, team);
        return team;
    }

    async getOpponent(teamUid: string, opponentUid: string): Promise<functions.firestore.DocumentSnapshot> {
        const data = this.cache.get<functions.firestore.DocumentSnapshot>(opponentUid + teamUid);
        if (data !== undefined) {
            return data;
        }

        const op = await db.collection('Teams').doc(teamUid).collection('Opponents').doc(opponentUid).get();
        this.cache.set(opponentUid + teamUid, op);
        return op;
    }

    async getPlayer(playerUid: string): Promise<functions.firestore.DocumentSnapshot> {
        const data = this.cache.get<functions.firestore.DocumentSnapshot>(playerUid);
        if (data !== undefined) {
            return data;
        }

        const player = await db.collection('Players').doc(playerUid).get();
        this.cache.set(playerUid, player);
        return player;
    }
}
