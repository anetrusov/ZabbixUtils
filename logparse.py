import sys
import os
import re
import hashlib

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


def readpos(file):
    file = os.path.join(sys.path[0], '.' + hashlib.md5(bytes(file, encoding='utf-8')).hexdigest())

    try:
        with open(file, 'r') as f:
            position = f.readline()
    except FileNotFoundError:
        position = 0

    return int(position)


def writepos(file, position):
    file = os.path.join(sys.path[0], '.' + hashlib.md5(bytes(file, encoding='utf-8')).hexdigest())

    with open(file, 'w') as f:
        f.write(str(position))


with open(argv['file'], 'r') as f:
    f.seek(readpos(argv['file']))

    while True:
        line = f.readline()

        entry['final'] = None

        if argv['mask'].search(line):
            entry['final'] = entry['temp']
            entry['temp'] = line
        else:
            if multiline:
                entry['temp'] += line

        for _entry in ['final'] if line else ['final', 'temp']:
            if entry[_entry]:
                if argv['match'].search(entry[_entry]):
                    if argv['except'] and argv['except'].search(entry[_entry]):
                        pass
                    else:
                        print(entry[_entry])
        if not line:
            break

    writepos(argv['file'], f.tell())
