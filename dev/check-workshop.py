"""Validate workshop skill references and documentation without a robot."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
skill = root / 'skill/vex-aim-workshop'
text = (skill / 'SKILL.md').read_text()
assert text.startswith('---\nname: vex-aim-workshop\n')
assert 'description:' in text.split('---', 2)[1]
assert '`vex-aim`' in text
assert not (skill / 'bin').exists(), 'the teaching skill must not duplicate the executable'
for name in re.findall(r'`(references/[^`]+\.md)`', text):
    assert (skill / name).is_file(), name
for page in [root / 'README.md'] + list((root / 'docs').glob('*.md')):
    for target in re.findall(r'\]\(([^)]+)\)', page.read_text()):
        target = target.split('#')[0]
        if target and ':' not in target and not target.startswith('/'):
            assert (page.parent / target).exists(), f'broken link: {page}: {target}'
print('Workshop skill and documentation links valid')
