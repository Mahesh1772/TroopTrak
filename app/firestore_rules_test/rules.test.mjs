import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, test } from 'node:test';

import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  collectionGroup,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  limit,
  query,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';

// Same project id as .firebaserc, as the emulators run in single-project mode.
const projectId = 'trooptrak-54337';
let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId,
    firestore: {
      rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
    },
  });
});

after(() => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'Users/Tan Ah Kow'), { name: 'Tan Ah Kow', points: 0 });
    await setDoc(doc(db, 'Users/Tan Ah Kow/Statuses/s1'), { statusType: 'Excuse' });
    await setDoc(doc(db, 'Users/Tan Ah Kow/Attendance/2023-07-05 08:00:00'), {
      isInsideCamp: true,
    });
    await setDoc(doc(db, 'Conducts/c1'), { conductName: 'Run' });
    await setDoc(doc(db, 'Duties/d1'), { points: 1 });
    await setDoc(doc(db, 'Men/soldier-uid'), { name: 'Tan Ah Kow', QRid: 'qr-1' });
  });
});

const commander = () =>
  env
    .authenticatedContext('commander-uid', { firebase: { sign_in_provider: 'password' } })
    .firestore();
const soldier = (uid = 'soldier-uid') =>
  env.authenticatedContext(uid, { firebase: { sign_in_provider: 'phone' } }).firestore();
const guest = () => env.unauthenticatedContext().firestore();

const commanderPaths = [
  'Users/Tan Ah Kow',
  'Users/Tan Ah Kow/Statuses/s1',
  'Users/Tan Ah Kow/Attendance/2023-07-05 08:00:00',
  'Conducts/c1',
  'Duties/d1',
];

describe('guests', () => {
  test('cannot read or write any collection', async () => {
    for (const path of [...commanderPaths, 'Men/soldier-uid']) {
      await assertFails(getDoc(doc(guest(), path)));
      await assertFails(setDoc(doc(guest(), path), { x: 1 }));
    }
  });

  test('cannot run the collection-group reads', async () => {
    await assertFails(getDocs(collectionGroup(guest(), 'Statuses')));
    await assertFails(getDocs(collectionGroup(guest(), 'Attendance')));
  });
});

describe('signed-in users', () => {
  test('read and write Users, its subcollections, Conducts and Duties', async () => {
    for (const db of [commander(), soldier()]) {
      for (const path of commanderPaths) {
        await assertSucceeds(getDoc(doc(db, path)));
        await assertSucceeds(updateDoc(doc(db, path), { touched: true }));
      }
    }
    await assertSucceeds(deleteDoc(doc(commander(), 'Conducts/c1')));
    await assertSucceeds(setDoc(doc(commander(), 'Duties/d2'), { points: 2 }));
  });

  test('run the Statuses and Attendance collection-group reads', async () => {
    await assertSucceeds(getDocs(collectionGroup(commander(), 'Statuses')));
    await assertSucceeds(getDocs(collectionGroup(commander(), 'Attendance')));
  });

  test('query Conducts by startDate', async () => {
    await assertSucceeds(
      getDocs(query(collection(commander(), 'Conducts'), where('startDate', '==', '5 Jul 2023'))),
    );
  });
});

describe('Men/{uid} (R15, R16)', () => {
  test('a commander reads and looks a code up but cannot write', async () => {
    await assertSucceeds(getDoc(doc(commander(), 'Men/soldier-uid')));
    await assertSucceeds(
      getDocs(query(collection(commander(), 'Men'), where('QRid', '==', 'qr-1'), limit(1))),
    );
    await assertFails(setDoc(doc(commander(), 'Men/soldier-uid'), { QRid: null }, { merge: true }));
  });

  test('the soldier registers, edits and publishes or clears their own code', async () => {
    const db = soldier('new-uid');
    await assertSucceeds(setDoc(doc(db, 'Men/new-uid'), { name: 'Lim Bah', points: 0, QRid: null }));
    await assertSucceeds(updateDoc(doc(db, 'Men/new-uid'), { rank: 'PTE' }));
    await assertSucceeds(setDoc(doc(db, 'Men/new-uid'), { QRid: 'qr-2' }, { merge: true }));
    await assertSucceeds(setDoc(doc(db, 'Men/new-uid'), { QRid: null }, { merge: true }));
  });

  test('another soldier cannot write someone else\'s registration', async () => {
    await assertFails(
      setDoc(doc(soldier('other-uid'), 'Men/soldier-uid'), { QRid: 'stolen' }, { merge: true }),
    );
    await assertFails(deleteDoc(doc(soldier('other-uid'), 'Men/soldier-uid')));
  });
});
