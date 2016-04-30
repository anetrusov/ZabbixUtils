import sys
import re

if len(sys.argv) < 4:
    print('Usage: logparse.py <file>[+multiline] <mask> <match> [<except>]')
    sys.exit(1)

argv = {}

for arg in 'file', 'mask+re', 'match+re', 'except+re':
    arg, regex = re.match(r'^(.+?)([+]re)?$', arg).groups()
    try:
        argv[arg] = sys.argv.pop(1)
        if regex:
            argv[arg] = re.compile(argv[arg])
    except IndexError:
        argv[arg] = None

argv['file'], multiline = re.match(r'^(.+?)([+]multi[line]{0,4})?$', argv['file']).groups()

entry = {
    'final': None,
    'temp': None
}

with open(argv['file'], 'r') as f:
    for line in f:
        entry['final'] = None

        if argv['mask'].search(line):
            entry['final'] = entry['temp']
            entry['temp'] = line
        else:
            if multiline:
                entry['temp'] += line

        if entry['final']:
            if argv['match'].search(entry['final']):
                if argv['except'] and argv['except'].search(entry['final']):
                    continue
                else:
                    print(entry['final'])

