import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const map = JSON.parse(readFileSync(new URL('../../review/academy/nce-outline-map.json', import.meta.url), 'utf8'));

test('source provenance, complete hierarchy and first NCE level are retained', () => {
  assert.equal(map.source.pageCount, 12);
  assert.equal(map.source.sha256, 'b7bea51ee6f68b7caea3ae2a8444eef34d9cef19e0f60ab9781918dd48b28372');
  assert.equal(map.nodeCount, 412);
  assert.equal(map.leafCount, 336);
  assert.equal(map.firstLevelId, 'I.A.1');
  assert.equal(map.nodes.find(n => n.id === 'I.A.1').title, 'Cardiovascular');
  assert.equal(new Set(map.nodes.map(n => n.id)).size, map.nodeCount);
  assert.deepEqual(map.domainWeights, {I: 20, II: 20, III: 35, IV: 25});
  assert.equal(map.proposedLevelOrder.length, map.leafCount);
});

test('all sibling markers are contiguous in official order', () => {
  for (const parent of map.nodes.filter(n => n.childIds.length)) {
    const children = parent.childIds.map(id => map.nodes.find(n => n.id === id));
    const childType = children[0].type;
    const expected = children.map((_, i) => childType === 'detail'
      ? ['i', 'ii', 'iii', 'iv', 'v', 'vi'][i]
      : childType === 'topic' ? String(i + 1) : String.fromCharCode(97 + i));
    const actual = children.map(n => n.id.split('.').at(-1).toLowerCase());
    assert.deepEqual(actual, expected, parent.id);
  }
});

test('planned assets cannot be mistaken for publishable or purchased content', () => {
  assert.equal(map.status, 'planning_manifest_not_a_completed_course');
  for (const node of map.nodes) {
    assert.equal(node.reviewStatus, 'outline_only_content_not_authored');
    if (node.parentId) assert(map.nodes.some(n => n.id === node.parentId));
    if (node.isLeaf) {
      assert.equal(node.learningBundle.readyToPublish, false);
      assert.equal(node.learningBundle.topicPdf, null);
      assert.equal(node.learningBundle.flashcardDeck, null);
      assert.equal(node.learningBundle.practiceQuestions, null);
      assert.equal(node.learningBundle.masteryCheckpoint, null);
    }
  }
});
