"""Execute documented examples and frozen independent delegate proposals offline."""
import json
from pathlib import Path
import re
import unittest

from workshop_sim import FIXTURES, evaluate, run_source

ROOT = Path(__file__).resolve().parents[1]


class WorkshopBehaviors(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        text = (ROOT / 'skill/vex-aim-workshop/references/fast-behaviors.md').read_text()
        cls.examples = re.findall(r'```python\n(.*?)```', text, re.S)

    def test_all_documented_python_runs_with_supported_api(self):
        self.assertEqual(len(self.examples), 4)
        fixtures = [{}, {}, FIXTURES['fetch'], {}]
        for index, (source, fixture) in enumerate(zip(self.examples, fixtures)):
            with self.subTest(example=index):
                result = run_source(source, fixture)
                self.assertIsNone(result['error'])
                self.assertTrue(result['stopped'])
                self.assertLess(result['elapsed_ms'], 30000)

    def test_motion_examples_stop_when_native_motion_stalls(self):
        for source in self.examples[:2]:
            with self.subTest(source=source[:40]):
                result = run_source(source, stalled=True)
                self.assertIn('deadline', result['error'])
                self.assertTrue(result['stopped'])
                self.assertLessEqual(result['elapsed_ms'], 20020)
                self.assertFalse(any(t['op'] == 'screen.show_emoji' for t in result['trace']))

    def test_motion_exception_still_stops_and_does_not_celebrate(self):
        for source in self.examples[:2]:
            result = run_source(source, fail_motion=True)
            self.assertIn('Injected motion failure', result['error'])
            self.assertEqual(result['trace'][-1]['op'] in ('sound.stop', 'stop_all_movement'), True)
            self.assertTrue(result['stopped'])
            self.assertFalse(any(t['op'] == 'screen.show_emoji' for t in result['trace']))

    def test_empty_native_search_is_finite_without_host_traffic(self):
        result = run_source(self.examples[2])
        self.assertIsNone(result['error'])
        self.assertTrue(result['stopped'])
        self.assertEqual(result['elapsed_ms'], 20000)
        self.assertIn('not_found', result['output'])
        self.assertFalse(any(t['op'] == 'screen.show_emoji' for t in result['trace']))

    def test_target_loss_stops_without_false_success(self):
        fixture = {'target': 'ORANGE_BARREL', 'lose_after': 1}
        result = run_source(self.examples[2], fixture)
        self.assertIsNone(result['error'])
        self.assertTrue(result['stopped'])
        self.assertIn('target_lost', result['output'])
        self.assertLessEqual(result['elapsed_ms'], 650)

    def test_wrong_held_cargo_never_counts_as_collection(self):
        result = run_source(self.examples[2], FIXTURES['wrong_cargo'])
        self.assertIsNone(result['error'])
        self.assertTrue(result['stopped'])
        self.assertNotIn('collected', result['output'])
        self.assertIn('timed_out', result['output'])
        self.assertFalse(any(t['op'] == 'screen.show_emoji' for t in result['trace']))

    def test_artwork_has_no_motion_or_kicker_and_clears_overlays(self):
        result = run_source(self.examples[3])
        ops = [t['op'] for t in result['trace']]
        self.assertEqual(ops[:3], ['screen.hide_aivision', 'screen.hide_emoji', 'screen.clear_screen'])
        self.assertFalse(any(op in ops for op in ('turn_for','move_for','move_at','turn','kicker.kick')))

    def test_host_modules_cannot_be_imported_by_robot_code(self):
        result = run_source('import serial\n')
        self.assertIn('Offline simulation has no serial', result['error'])
        self.assertEqual(result['trace'], [])

    def test_speed_units_are_not_interchangeable(self):
        result = run_source('robot.move_at(0, 90, DPS)')
        self.assertIn('speed out of range', result['error'])
        self.assertEqual(result['trace'], [])

    def test_stub_does_not_invent_explicit_speeds_when_agent_omits_them(self):
        result = run_source('robot.move_for(100, 0)\nrobot.stop_all_movement()')
        self.assertIsNone(result['error'])
        self.assertIsNone(result['trace'][0]['args'][2])
        self.assertEqual(result['trace'][0]['args'][3], 'PERCENT')

    def test_grader_rejects_confirmations_and_fragmented_execution(self):
        cases = json.loads((ROOT / 'dev/workshop-evals/accepted.json').read_text())['cases']
        spin = next(case for case in cases if case['id'] == 'spin')
        gated = dict(spin, questions=['Ready for the turn?'])
        fragmented = dict(spin, host_calls=spin['host_calls'] * 2)
        slow = json.loads(json.dumps(spin))
        slow['host_calls'][0]['source'] = slow['host_calls'][0]['source'].replace('360, 90, DPS', '360, 30, DPS')
        for case in (gated, fragmented, slow):
            self.assertFalse(evaluate(case)['pass'])

    def test_instruction_budget_bounds_a_non_yielding_generated_loop(self):
        result = run_source('while True:\n    pass\n')
        self.assertIn('instruction budget', result['error'])

    def test_session_source_budget(self):
        with self.assertRaisesRegex(ValueError, '48 KiB'):
            run_source('#' * (48 * 1024 + 1))

    def test_frozen_independent_agent_proposals(self):
        path = ROOT / 'dev/workshop-evals/accepted.json'
        cases = json.loads(path.read_text())['cases']
        self.assertGreaterEqual(len(cases), 10)
        for case in cases:
            with self.subTest(case=case['id']):
                result = evaluate(case)
                self.assertTrue(result['pass'], [c for c in result['checks'] if not c['pass']])

    def test_generated_finite_motions_have_working_robot_deadlines(self):
        cases = json.loads((ROOT / 'dev/workshop-evals/accepted.json').read_text())['cases']
        exercised = 0
        for case in cases:
            for call in case['host_calls']:
                if call['op'] != 'exec':
                    continue
                normal = run_source(call['source'], FIXTURES[case['id']])
                if not any(t['op'] in ('move_for', 'turn_for') for t in normal['trace']):
                    continue
                with self.subTest(case=case['id']):
                    result = run_source(call['source'], FIXTURES[case['id']], stalled=True)
                    self.assertIn('deadline', result['error'])
                    self.assertTrue(result['stopped'])
                    self.assertLess(result['elapsed_ms'], call['timeout'] * 1000)
                    exercised += 1
        self.assertGreaterEqual(exercised, 5)

    def test_generated_motion_failure_stops_every_moving_script(self):
        cases = json.loads((ROOT / 'dev/workshop-evals/accepted.json').read_text())['cases']
        exercised = 0
        motion = ('move_for', 'turn_for', 'move_at', 'turn', 'move_with_vectors')
        for case in cases:
            for call in case['host_calls']:
                if call['op'] != 'exec':
                    continue
                normal = run_source(call['source'], FIXTURES[case['id']])
                if not any(t['op'] in motion for t in normal['trace']):
                    continue
                with self.subTest(case=case['id']):
                    result = run_source(call['source'], FIXTURES[case['id']], fail_motion=True)
                    self.assertIn('Injected motion failure', result['error'])
                    self.assertTrue(result['stopped'])
                    exercised += 1
        self.assertGreaterEqual(exercised, 8)


if __name__ == '__main__':
    unittest.main()
