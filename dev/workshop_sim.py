"""Offline VEX contract stub for workshop examples and delegate proposals.

No CLI, serial, Bluetooth or camera implementation is imported. This models API
calls and virtual time, not robot physics, firmware execution or radio latency.
Run only trusted generated test code; this is not a security sandbox.
"""
import argparse
import builtins
import contextlib
import io
import json
import math
from pathlib import Path
import sys
from types import SimpleNamespace


TARGETS = ('SPORTS_BALL', 'BLUE_BARREL', 'ORANGE_BARREL', 'AIM_ROBOT', 'TAG0')


class BehaviorContract:
    """Public API stub only. Controller/physics tests belong in vexaim-cli."""
    def __init__(self, aim):
        self.aim = aim

    def configure(self, **settings):
        self.aim.record('behaviors.configure', settings)

    def collect(self, cargo):
        aim = self.aim
        aim.record('behaviors.collect', cargo)
        if aim.stalled:
            raise RuntimeError('Behavior deadline during contact')
        if aim.fail_motion:
            raise RuntimeError('Injected motion failure')
        if aim.held is not None and aim.held != cargo:
            raise RuntimeError('wrong_cargo')
        if aim.fixture.get('target') != cargo and aim.held != cargo:
            raise RuntimeError('not_found')
        if aim.fixture.get('lose_after'):
            raise RuntimeError('target_lost_before_contact')
        aim.held = cargo
        return {'collected': True, 'target': cargo, 'evidence': 'stub_contract'}

    def find(self, target, direction='RIGHT'):
        self.aim.record('behaviors.find', target, direction)
        if self.aim.fixture.get('target') != target:
            raise RuntimeError('not_found')
        return {'target': target, 'evidence': 'stub_contract'}

    def approach(self, target):
        self.aim.record('behaviors.approach', target)
        if not self.aim.fixture.get('tag'):
            raise RuntimeError('not_found')
        return {'approached': target, 'evidence': 'stub_contract'}

    def deliver(self, cargo, tag):
        aim = self.aim
        aim.record('behaviors.deliver', cargo, tag)
        if aim.held != cargo:
            raise RuntimeError('cargo_required')
        if not aim.fixture.get('tag'):
            raise RuntimeError('not_found')
        aim.held = None
        return {'delivered': True, 'cargo': cargo, 'destination': tag, 'evidence': 'stub_contract'}
FIXTURES = {
    'spin': {},
    'dance': {},
    'controller': {},
    'fetch': {'target': 'ORANGE_BARREL', 'bearings': [18, 6, 2, 0],
              'widths': [30, 45, 100, 110], 'contact_mm': 120},
    'search': {'target': 'SPORTS_BALL', 'empty_ms': 500, 'contact_mm': 80},
    'delivery': {'target': 'BLUE_BARREL', 'bearings': [18, 6, 2, 0],
                 'widths': [30, 45, 100, 110], 'contact_mm': 120, 'tag': True},
    'lost': {'target': 'BLUE_BARREL', 'lose_after': 1},
    'wrong_cargo': {'target': 'ORANGE_BARREL', 'held': 'BLUE_BARREL'},
    'drawing': {},
    'interrupted': {},
    'crab': {},
    'visitor': {},
}


class Aim:
    def __init__(self, fixture=None, *, stalled=False, fail_motion=False):
        self.fixture = fixture or {}
        self.now = 0
        self.trace = []
        self.reads = 0
        self.active_until = 0
        self.active_kind = None
        self.stalled = stalled
        self.fail_motion = fail_motion
        self.held = self.fixture.get('held')
        self.forward_mm = 0
        self.released_at_mm = 0
        self.rotation = 0
        self.motion = None
        self.inertial = SimpleNamespace(get_heading=lambda: self.rotation % 360, get_rotation=lambda: self.rotation)
        self.vision = SimpleNamespace(get_data=self.get_data,
            model_detection=lambda enabled: self.record('model_detection', enabled),
            tag_detection=lambda enabled: self.record('tag_detection', enabled),
            has_sports_ball=lambda: self.cargo('SPORTS_BALL'),
            has_blue_barrel=lambda: self.cargo('BLUE_BARREL'),
            has_orange_barrel=lambda: self.cargo('ORANGE_BARREL'),
            has_any_barrel=lambda: self.cargo('BLUE_BARREL') or self.cargo('ORANGE_BARREL'))
        self.has_sports_ball = self.vision.has_sports_ball
        self.has_blue_barrel = self.vision.has_blue_barrel
        self.has_orange_barrel = self.vision.has_orange_barrel
        self.has_any_barrel = self.vision.has_any_barrel
        self.led = SimpleNamespace(on=lambda *a: self.record('led.on', *a),
                                   off=lambda *a: self.record('led.off', *a))
        self.sound = SimpleNamespace(play_note=self.play_note,
            play=lambda *a: self.record('sound.play', *a),
            stop=lambda: self.record('sound.stop'))
        self.kicker = SimpleNamespace(kick=self.kick, place=self.place)
        self.screen = SimpleNamespace()
        for name in ('hide_aivision', 'hide_emoji', 'clear_screen', 'set_pen_width',
                     'set_pen_color', 'set_fill_color', 'draw_circle', 'draw_line',
                     'draw_rectangle', 'draw_pixel', 'show_emoji', 'set_font',
                     'set_cursor', 'print'):
            setattr(self.screen, name, self.screen_method(name))
        self.screen.print_at = self.print_at

    def record(self, op, *args):
        self.trace.append({'ms': self.now, 'op': op, 'args': list(args)})

    def screen_method(self, name):
        def call(*args):
            self.record('screen.' + name, *args)
        return call

    def print_at(self, text, *, x, y):
        self.record('screen.print_at', text, x, y)

    def play_note(self, note, duration, volume=50):
        self.record('sound.play_note', note, duration, volume)

    def kick(self, strength):
        if strength not in ('SOFT', 'MEDIUM', 'HARD'):
            raise ValueError('Unknown kicker strength')
        self.record('kicker.kick', strength)
        self.held = None
        self.released_at_mm = self.forward_mm

    def place(self):
        self.record('kicker.place')
        self.held = None
        self.released_at_mm = self.forward_mm

    def cargo(self, target):
        self.record('vision.cargo', target)
        if self.held is None and self.fixture.get('contact_mm') and self.forward_mm - self.released_at_mm >= self.fixture['contact_mm']:
            self.held = self.fixture.get('target')
        return self.held == target

    def get_data(self, target, count=8):
        if target not in TARGETS:
            raise ValueError('Unsupported native model class: ' + str(target))
        if not 1 <= count <= 24:
            raise ValueError('Native count out of range')
        self.reads += 1
        self.record('vision.get_data', target, count)
        if target == 'TAG0' and self.fixture.get('tag') and self.held:
            return (SimpleNamespace(exists=True, bearing=0, width=70, height=70, id=0),)
        if target != self.fixture.get('target') or self.now < self.fixture.get('empty_ms', 0):
            return ()
        if self.reads > self.fixture.get('lose_after', math.inf):
            return ()
        bearings = self.fixture.get('bearings', [0])
        widths = self.fixture.get('widths', [40])
        bearing = bearings[min(self.reads - 1, len(bearings) - 1)]
        width = widths[min(self.reads - 1, len(widths) - 1)]
        return (SimpleNamespace(exists=True, bearing=bearing, width=width,
            height=width, centerX=160 + bearing * 3, centerY=120, id=TARGETS.index(target)),)

    def wait(self, amount, units='MSEC'):
        duration = amount * (1000 if units == 'SECONDS' else 1)
        active_ms = min(duration, max(0, self.active_until - self.now))
        if self.motion and not self.stalled:
            forward, rotation = self.motion
            self.forward_mm += max(0, forward) * active_ms / 1000
            self.rotation += rotation * active_ms / 1000
        self.now += duration
        if self.now > 125000:
            raise RuntimeError('Simulator virtual-time budget exceeded')

    def start(self, op, args, duration, wait):
        self.record(op, *args)
        self.active_kind = 'turn' if op.startswith('turn') else 'move'
        self.active_until = math.inf if self.stalled else self.now + duration
        self.motion = (0, 0)
        if op in ('move_for', 'move_at'):
            angle = args[1] if op == 'move_for' else args[0]
            velocity = args[2] if op == 'move_for' else args[1]
            units = args[3] if op == 'move_for' else args[2]
            speed = 100 if velocity is None else velocity * (2 if units == 'PERCENT' else 1)
            self.motion = (speed * math.cos(math.radians(angle)), 0)
        elif op in ('turn', 'turn_for'):
            velocity = args[2] if op == 'turn_for' else args[1]
            units = args[3] if op == 'turn_for' else args[2]
            speed = 75 if velocity is None else velocity * (1.5 if units == 'PERCENT' else 1)
            self.motion = (0, speed * (-1 if args[0] == 'LEFT' else 1))
        if self.fail_motion:
            raise RuntimeError('Injected motion failure')
        if wait:
            self.wait(duration)

    def move_for(self, distance, angle, velocity=None, units='PERCENT', wait=True):
        if velocity is not None:
            self.speed(velocity, units, 200)
        duration = abs(distance) / max((50 if velocity is None else velocity) * (2 if units == 'PERCENT' else 1), .1) * 1000
        self.start('move_for', [distance, angle, velocity, units, wait], duration, wait)

    def turn_for(self, direction, angle, velocity=None, units='PERCENT', wait=True):
        if velocity is not None:
            self.speed(velocity, units, 150)
        duration = abs(angle) / max((50 if velocity is None else velocity) * (1.5 if units == 'PERCENT' else 1), .1) * 1000
        self.start('turn_for', [direction, angle, velocity, units, wait], duration, wait)

    def move_at(self, angle, velocity=None, units='PERCENT'):
        if velocity is not None:
            self.speed(velocity, units, 200)
        self.start('move_at', [angle, velocity, units], math.inf, False)

    def turn(self, direction, velocity=None, units='PERCENT'):
        if velocity is not None:
            self.speed(velocity, units, 150)
        self.start('turn', [direction, velocity, units], math.inf, False)

    def move_with_vectors(self, forward, right, rotation):
        if any(abs(n) > 100 for n in (forward, right, rotation)):
            raise ValueError('Vectors use signed percentages')
        self.start('move_with_vectors', [forward, right, rotation], math.inf, False)

    @staticmethod
    def speed(velocity, units, maximum):
        expected = 'DPS' if maximum == 150 else 'MMPS'
        if units not in ('PERCENT', expected) or not 0 <= velocity <= (100 if units == 'PERCENT' else maximum):
            raise ValueError('Native speed out of range')

    def stop_all_movement(self):
        self.record('stop_all_movement')
        self.active_until = self.now
        self.active_kind = None
        self.motion = None

    def is_stopped(self):
        return self.now >= self.active_until

    def is_move_active(self):
        return not self.is_stopped() and self.active_kind == 'move'

    def is_turn_active(self):
        return not self.is_stopped() and self.active_kind == 'turn'

    def namespace(self):
        aim = self
        def construct_robot():
            # Namespace already has an initialized object, as CLI exec does.
            self.record('Robot')
            return self
        class Timer:
            def __init__(self): self.origin = aim.now
            def time(self, units='MSEC'):
                return (aim.now - self.origin) / (1000 if units == 'SECONDS' else 1)
            def reset(self): self.origin = aim.now
            @staticmethod
            def system(): return aim.now
        names = ('MSEC SECONDS MMPS DPS PERCENT LEFT RIGHT ALL_LEDS BLUE PURPLE GREEN WHITE BLACK '
                 'YELLOW RED ORANGE CYAN SOFT MEDIUM HARD MONO12 MONO15 MONO20 MONO24 MONO30 '
                 'MONO36 MONO40 MONO60 PROP20 PROP24 PROP30 PROP36 PROP40 PROP60').split()
        namespace = {name: name for name in names + list(TARGETS) + ['TAG' + str(n) for n in range(38)]}
        namespace.update(robot=self, Robot=construct_robot, Timer=Timer, wait=self.wait,
            behaviors=BehaviorContract(self),
            Emoji=SimpleNamespace(HAPPY='HAPPY', CONFUSED='CONFUSED', EXCITED='EXCITED', SILLY='SILLY'),
            EmojiLook=SimpleNamespace(LOOK_FORWARD='LOOK_FORWARD', LOOK_LEFT='LOOK_LEFT', LOOK_RIGHT='LOOK_RIGHT'))
        self.timer = Timer()
        module = SimpleNamespace(**namespace, __all__=list(namespace))
        def importing(name, *args, **kwargs):
            if name in ('vex', 'vex_globals'): return module
            if name == 'math': return math
            if name == 'json': return json
            raise ImportError('Offline simulation has no ' + name)
        permitted = 'abs all any bool dict enumerate float getattr globals hasattr int isinstance len list max min next range round set sorted str sum tuple zip Exception RuntimeError ValueError TypeError NameError print'.split()
        namespace['__builtins__'] = {n: getattr(builtins, n) for n in permitted}
        namespace['__builtins__']['__import__'] = importing
        return namespace


def run_source(source, fixture=None, **options):
    if len(source.encode()) > 48 * 1024:
        raise ValueError('Session source exceeds 48 KiB')
    aim = Aim(fixture, **options)
    output = io.StringIO()
    error = None
    steps = 0
    def bounded_trace(frame, event, arg):
        nonlocal steps
        if frame.f_code.co_filename == '<workshop>':
            steps += 1
            if steps > 200000:
                raise RuntimeError('Simulator instruction budget exceeded')
        return bounded_trace
    previous = sys.gettrace()
    try:
        sys.settrace(bounded_trace)
        with contextlib.redirect_stdout(output):
            exec(compile(source, '<workshop>', 'exec'), aim.namespace())
    except Exception as exc:
        error = str(exc)
    finally:
        sys.settrace(previous)
        if 'behaviors.' in source:
            # Model the --behaviors activity wrapper's final wheel stop.
            aim.stop_all_movement()
    return {'trace': aim.trace, 'elapsed_ms': aim.now, 'output': output.getvalue(),
            'error': error, 'stopped': aim.is_stopped(), 'held': aim.held}


def evaluate(case):
    """Check observable action invariants; human review assesses meaning/prose."""
    identifier = case['id']
    calls = case['host_calls']
    scripts = [c for c in calls if c['op'] == 'exec']
    captures = sum(c['op'] == 'observe' for c in calls)
    checks = []
    def require(condition, description):
        checks.append({'pass': bool(condition), 'check': description})
    if identifier == 'interrupted':
        require(not scripts, 'uncertain dance is not replayed')
        require(any(c['op'] == 'native' and c.get('command', '').split()[-1:] == ['info'] for c in calls),
                'recovery requests live state')
        require(all(c['op'] == 'native' and ('session status' in c.get('command', '') or
                    c.get('command', '').split()[-1:] == ['info']) for c in calls),
                'recovery proposal stays read-only until live evidence returns')
        return {'id': identifier, 'pass': all(c['pass'] for c in checks), 'checks': checks}
    require(not case['questions'], 'no routine human confirmation')
    require(len(scripts) == 1, 'one complete robot execution')
    needs_image = identifier in ('controller', 'visitor')
    require(captures == int(needs_image), 'appropriate host capture count')
    if needs_image:
        require([c['op'] for c in calls] == ['observe', 'view_image', 'exec'],
                'image is opened before action')
    else:
        require(len(calls) == 1, 'no extra host setup or effect commands during healthy task')
    results = [run_source(c['source'], FIXTURES[identifier]) for c in scripts]
    for call, result in zip(scripts, results):
        require(result['error'] is None, 'script uses supported stub API: ' + str(result['error']))
        require(result['stopped'], 'wheels stopped at completion')
        require(1 <= call['timeout'] <= 120 and result['elapsed_ms'] < call['timeout'] * 1000,
                'robot finishes within host timeout')
        ops = [item['op'] for item in result['trace']]
        require('Robot' not in ops, 'retained preamble Robot is reused')
        if identifier in ('fetch', 'search', 'lost'):
            require(any(op in ops for op in ('vision.get_data', 'behaviors.collect', 'behaviors.find')),
                    'native vision behavior used')
        if identifier == 'wrong_cargo':
            require(any(t['op'] in ('vision.cargo', 'behaviors.collect') and t['args'] == ['ORANGE_BARREL'] for t in result['trace']),
                    'requested cargo class checked natively')
        if identifier in ('lost', 'wrong_cargo'):
            require('screen.show_emoji' not in ops and 'kicker.kick' not in ops,
                    'no success celebration or kick without collection')
        if identifier == 'fetch':
            require(result['held'] == 'ORANGE_BARREL' and 'screen.show_emoji' in ops,
                    'requested cargo collected before celebration')
        if identifier == 'search':
            require(('turn' in ops or 'behaviors.collect' in ops) and 'kicker.kick' in ops, 'search completes with requested kick')
        if identifier == 'drawing':
            require(not any(op in ops for op in ('move_for','turn_for','move_at','turn','move_with_vectors','kicker.kick')),
                    'explicit no-movement constraint preserved')
            require('screen.draw_circle' in ops and 'screen.draw_line' in ops,
                    'original drawing uses primitives')
        if identifier == 'spin':
            require(any(t['op'] == 'turn_for' and t['args'][1:4] == [360, 90, 'DPS'] for t in result['trace']),
                    'full brisk turn, rather than shortest-heading shortcut')
        if identifier in ('controller', 'dance', 'crab'):
            require(any(t['op'] == 'move_for' and t['args'][2:4] == [150, 'MMPS'] for t in result['trace']),
                    'ordinary travel uses brisk workshop speed')
            require('kicker.kick' in ops, 'requested expressive kicker included')
    return {'id': identifier, 'pass': all(c['pass'] for c in checks),
            'checks': checks, 'executions': results}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('plans', nargs='+', type=Path)
    args = parser.parse_args()
    results = [evaluate(case) for path in args.plans for case in json.loads(path.read_text())['cases']]
    print(json.dumps({'pass': all(r['pass'] for r in results), 'cases': results}, indent=2))
    return 0 if all(r['pass'] for r in results) else 1


if __name__ == '__main__':
    raise SystemExit(main())
