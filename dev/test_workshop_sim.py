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

    def delivery_source(self):
        text = (ROOT / 'skill/vex-aim-workshop/references/cargo-and-tags.md').read_text()
        return re.findall(r'```python\n(.*?)```', text, re.S)[0]

    def test_vision_reads_alone_cannot_collect_cargo(self):
        source = '\n'.join(['robot.vision.get_data(BLUE_BARREL)' for _ in range(50)]) + '\nprint(robot.has_blue_barrel())'
        result = run_source(source, FIXTURES['delivery'])
        self.assertEqual(result['output'].strip(), 'False')
        self.assertIsNone(result['held'])

    def test_contact_delivery_verifies_collection_then_placement(self):
        result = run_source(self.delivery_source(), FIXTURES['delivery'])
        self.assertIsNone(result['error'])
        final = json.loads(result['output'].splitlines()[-1])
        self.assertTrue(final['pickup']['collected'])
        self.assertTrue(final['delivery']['delivered'])
        self.assertEqual(final['delivery']['destination'], 'TAG0')
        self.assertIsNone(result['held'])
        self.assertTrue(result['stopped'])
        self.assertEqual([t['op'] for t in result['trace'] if t['op'].startswith('behaviors.')],
                         ['behaviors.configure', 'behaviors.collect', 'behaviors.deliver'])
        self.assertIn('contact_mmps=200', self.delivery_source())

    def test_stalled_contact_never_claims_delivery(self):
        result = run_source(self.delivery_source(), FIXTURES['delivery'], stalled=True)
        self.assertIn('deadline', result['error'])
        self.assertTrue(result['stopped'])
        self.assertFalse(any(t['op'] in ('kicker.place', 'screen.show_emoji') for t in result['trace']))

    def test_workshop_does_not_duplicate_cli_control_loops(self):
        for source in (self.delivery_source(), self.examples[2]):
            self.assertIn('behaviors.collect', source)
            self.assertNotIn('vision.get_data', source)
            self.assertNotIn('while ', source)

    def test_requested_color_is_a_parameter_not_copied_controller(self):
        source = self.delivery_source().replace('cargo = BLUE_BARREL', 'cargo = ORANGE_BARREL')
        result = run_source(source, dict(FIXTURES['delivery'], target='ORANGE_BARREL'))
        self.assertIsNone(result['error'])
        calls = [t for t in result['trace'] if t['op'] == 'behaviors.collect']
        self.assertEqual(calls[0]['args'], ['ORANGE_BARREL'])

    def test_missing_tag_preserves_cargo_and_does_not_place(self):
        result = run_source(self.delivery_source(), dict(FIXTURES['delivery'], tag=False))
        self.assertEqual(result['error'], 'not_found')
        self.assertEqual(result['held'], 'BLUE_BARREL')
        self.assertFalse(any(t['op'] == 'kicker.place' for t in result['trace']))
        self.assertLess(result['elapsed_ms'], 10000)

    def test_motion_exception_still_stops_and_does_not_celebrate(self):
        for source in self.examples[:2]:
            result = run_source(source, fail_motion=True)
            self.assertIn('Injected motion failure', result['error'])
            self.assertEqual(result['trace'][-1]['op'] in ('sound.stop', 'stop_all_movement'), True)
            self.assertTrue(result['stopped'])
            self.assertFalse(any(t['op'] == 'screen.show_emoji' for t in result['trace']))

    def test_empty_native_search_is_finite_without_host_traffic(self):
        result = run_source(self.examples[2])
        self.assertEqual(result['error'], 'not_found')
        self.assertTrue(result['stopped'])
        self.assertLessEqual(result['elapsed_ms'], 6100)
        self.assertFalse(any(t['op'] == 'screen.show_emoji' for t in result['trace']))

    def test_target_loss_stops_without_false_success(self):
        fixture = {'target': 'ORANGE_BARREL', 'lose_after': 1}
        result = run_source(self.examples[2], fixture)
        self.assertIn('target_lost', result['error'])
        self.assertTrue(result['stopped'])
        self.assertLessEqual(result['elapsed_ms'], 650)

    def test_wrong_held_cargo_never_counts_as_collection(self):
        result = run_source(self.examples[2], FIXTURES['wrong_cargo'])
        self.assertEqual(result['error'], 'wrong_cargo')
        self.assertTrue(result['stopped'])
        self.assertNotIn('collected', result['output'])
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

    def test_initial_independent_agent_uses_composable_cli_behaviors(self):
        evaluation = json.loads((ROOT / 'dev/workshop-evals/behaviors.json').read_text())
        self.assertEqual(evaluation['questions'], [])
        self.assertIn('exec --behaviors', evaluation['invocation'])
        self.assertGreaterEqual(evaluation['outer_timeout_seconds'], 120)
        for case in evaluation['cases']:
            for failure in (None, 'missing', 'stalled'):
                with self.subTest(prompt=case['prompt'],failure=failure):
                    fixture = {'target': case['cargo'], 'tag': bool(case['tag'])}
                    if failure == 'missing': fixture['target'] = 'AIM_ROBOT'
                    result = run_source(case['source'], fixture, stalled=failure=='stalled')
                    ops = [t['op'] for t in result['trace']]
                    self.assertTrue(result['stopped'])
                    self.assertNotIn('vision.get_data', case['source'])
                    self.assertNotIn('Robot()', case['source'])
                    self.assertEqual(ops.count('behaviors.collect'), 1)
                    if failure:
                        self.assertIsNotNone(result['error'])
                        self.assertNotIn('behaviors.deliver', ops)
                        self.assertNotIn('screen.show_emoji', ops)
                        self.assertNotIn('kicker.kick', ops)
                    else:
                        self.assertIsNone(result['error'])
                        if case['tag']:
                            delivery = next(t for t in result['trace'] if t['op']=='behaviors.deliver')
                            self.assertEqual(delivery['args'], [case['cargo'], case['tag']])

    def test_fast_play_agent_continues_after_assumed_contact_without_host_round_trips(self):
        evaluation = json.loads((ROOT / 'dev/workshop-evals/fast-play.json').read_text())
        self.assertEqual(evaluation['questions'], [])
        self.assertEqual(evaluation['host_ops'], ['exec'])
        for case in evaluation['cases']:
            fixture = {'target': case['cargo'], 'tag': bool(case['tag']), 'possession_missing': True}
            result = run_source(case['source'], fixture)
            self.assertIsNone(result['error'], result['error'])
            self.assertTrue(result['stopped'])
            ops = [t['op'] for t in result['trace']]
            settings = next(t['args'][0] for t in result['trace'] if t['op']=='behaviors.configure')
            self.assertEqual(settings['verification'], 'contact')
            self.assertEqual(settings['tag_turn_dps'], 90)
            self.assertEqual(settings['contact_mmps'], 200)
            self.assertEqual(ops.count('behaviors.collect'), 1)
            self.assertNotIn('vision.get_data', case['source'])
            outcome = json.loads(result['output'].splitlines()[-1])
            self.assertIsNone(outcome['pickup']['collected'])
            self.assertTrue(outcome['pickup']['completed'])
            if case['tag']:
                self.assertIn('behaviors.deliver', ops)
                self.assertIsNone(outcome['delivery']['delivered'])
            else:
                self.assertIn('kicker.kick', ops)
            if 'smile' in case['prompt']:
                self.assertIn('screen.show_emoji', ops)

    def test_fast_play_plans_finish_effects_after_assumed_marker_arrival(self):
        evaluation = json.loads((ROOT / 'dev/workshop-evals/fast-play.json').read_text())
        review = json.loads((ROOT / 'dev/workshop-evals/arrival.json').read_text())
        self.assertEqual(review['questions'], [])
        self.assertEqual(review['host_ops'], ['exec'])
        self.assertEqual(review['ambiguities'], [])
        cases = evaluation['cases'] + [{'prompt':'blue to tag then smile','cargo':'BLUE_BARREL','tag':'TAG0','source':review['source']}]
        for case in cases:
            if case['tag'] is None:
                continue
            result = run_source(case['source'], {'target':case['cargo'],'tag':True,'near_marker_loss':True})
            self.assertIsNone(result['error'])
            self.assertTrue(result['stopped'])
            outcome = json.loads(result['output'].splitlines()[-1])
            self.assertTrue(outcome['delivery']['completed'])
            self.assertEqual(outcome['delivery']['evidence'],'near_marker_assumed')
            self.assertIsNone(outcome['delivery']['delivered'])
            if 'smile' in case['prompt']:
                self.assertIn('screen.show_emoji',[t['op'] for t in result['trace']])

    def test_independent_pickup_and_explicit_retry_plans(self):
        cases = json.loads((ROOT / 'dev/workshop-evals/recovery.json').read_text())['cases']
        for case in cases[:2]:
            self.assertEqual(case['questions'], [])
            self.assertEqual(case['host_ops'].count('exec'), 1)
            self.assertGreaterEqual(case['outer_timeout'], case['timeout'] + 60)
            for scenario in ('normal', 'stalled', 'missing_tag'):
                with self.subTest(case=case['id'], scenario=scenario):
                    fixture = dict(FIXTURES['delivery'], tag=scenario != 'missing_tag')
                    result = run_source(case['source'], fixture, stalled=scenario == 'stalled')
                    self.assertTrue(result['stopped'])
                    self.assertLess(result['elapsed_ms'], 30000)
                    celebrated = any(t['op'] == 'screen.show_emoji' for t in result['trace'])
                    if scenario == 'normal':
                        self.assertIsNone(result['error'])
                        self.assertIsNone(result['held'])
                        self.assertTrue(celebrated)
                    else:
                        self.assertIsNotNone(result['error'])
                        self.assertFalse(celebrated)
                        self.assertFalse(any(t['op'] == 'kicker.place' for t in result['trace']))
        self.assertEqual(cases[1]['host_ops'], ['stop', 'info', 'exec'])
        self.assertEqual(cases[2]['questions'], [])
        self.assertEqual(cases[2]['host_ops'], ['wait', 'session status', 'info', 'camera observe', 'view_image'])
        self.assertEqual(cases[3]['host_ops'], ['session close'])
        self.assertEqual(cases[4]['host_ops'], [])

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
