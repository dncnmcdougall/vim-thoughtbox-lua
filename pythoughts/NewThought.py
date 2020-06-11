#!/usr/bin//python3

import os
import sys
import argparse
import string
from typing import List

if __name__ == "__main__":
    sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__),'..')))
from pythoughts.ThoughtInfo import splitName, listThoughtFiles

def inc(input: str) -> str:
    """ 
    Increments the given string of either letters or numbers.
    'aaa' becomes 'aab' and '100' becomes '101'.
    'zz' becomes 'aaa' and '99' becomes '100'.
    arguments:
        input: str
            the string to increment
    returns:
        The incremented string.
    """
    if input.isalpha():
        input = list(input)
        j = 1
        i = string.ascii_lowercase.index(input[-j]) +1

        while j < len(input) and i == 26:
            input[-j] = 'a'
            j += 1
            i = string.ascii_lowercase.index(input[-j]) +1
        if j == len(input) and i == 26:
            input[-j] = 'a'
            return ''.join(['a'] + input)
        else:
            input[-j] = string.ascii_lowercase[i]
        return ''.join(input)
    else:
        return '%d' % (int(input)+1)

def findNextFileName(files: List[str] , name: str) -> str:
    name_parts = splitName(name)
    length = len(name_parts)
    if len(name_parts) == 0 or name_parts[-1].isalpha():
        name_parts.append('1')
    else:
        name_parts.append('a')

    for i in range(len(files)):
        fparts = splitName(files[i])
        if len(fparts) <= length:
            continue
        if name_parts[0:-1] != fparts[0:length]:
            continue
        if name_parts[-1] == fparts[length]:
            name_parts[-1] = inc(name_parts[-1])
    return ''.join(name_parts) + '.tb'

def findNextFileNameInDirectory(directory: str, name: str) -> str:
    files = listThoughtFiles(directory)

    nextName = findNextFileName(files, name)
    nextName = os.path.join(directory, nextName)
    assert(not os.path.exists(nextName))

    return nextName

def getNewThoughtTemplate() -> List[str]:
    return ['# <+title+>',
            '',
            '# sources',
            '',
            '# tags',
            '']

def createNewThought(nextName):
    assert(not os.path.exists(nextName))
    with open(nextName, 'w') as nextFile:
        for line in getNewThoughtTemplate():
            nextFile.write(line + '\n')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Searches for the next available thought name.")
    parser.add_argument('--create', action='store_true', default=False, help='If True create the file.')
    parser.add_argument('--name', type=str, default='')
    parser.add_argument('-d','--directory', type=str, default='.', help='The directory to search in.')
    parser.add_argument('--vim', action='store_true', default=False, help='Run the vim command to open the file. This assumes we are in a python environment.')

    args = parser.parse_args()

    files = os.listdir(args.directory)
    files = [ f for f in files if f.endswith('.tb') ]
    files.sort()

    nextName = findNextFileNameInDirectory(args.directory, args.name)

    if args.create:
        createNewThought(nextName)

    if args.vim:
        import vim
        vim.command(':e %s' % nextName)
    else:
        print(nextName)

import unittest
class NewThoughtTests(unittest.TestCase):
    def test_inc_digits(self):
        self.assertEqual(inc('1'), '2')
        self.assertEqual(inc('9'), '10')
        self.assertEqual(inc('19'), '20')

    def test_inc_letters(self):
        self.assertEqual(inc('a'), 'b')
        self.assertEqual(inc('z'), 'aa')
        self.assertEqual(inc('az'), 'ba')
        self.assertEqual(inc('zz'), 'aaa')

    def test_findNextFileName(self):
        files = ['1.tb', '2.tb']
        self.assertEqual(findNextFileName(files, ''), '3.tb')
        self.assertEqual(findNextFileName(files, '2'), '2a.tb')

        files = ['1.tb', '2.tb', '4.tb']
        self.assertEqual(findNextFileName(files, ''), '3.tb')
        self.assertEqual(findNextFileName(files, '2'), '2a.tb')

        files = ['1.tb', '2.tb', '2a.tb', '2b.tb']
        self.assertEqual(findNextFileName(files, ''), '3.tb')
        self.assertEqual(findNextFileName(files, '2'), '2c.tb')

        files = ['1.tb', '2.tb', '2a.tb', '2b.tb', '3.tb']
        self.assertEqual(findNextFileName(files, ''), '4.tb')
        self.assertEqual(findNextFileName(files, '2'), '2c.tb')

        files = ['1.tb', '2.tb', '2a1.tb', '2a2.tb']
        self.assertEqual(findNextFileName(files, '2'), '2b.tb')
        self.assertEqual(findNextFileName(files, '2a'), '2a3.tb')

        files = ['1.tb', '2.tb', '2a1.tb', '2a2.tb', '2b.tb']
        self.assertEqual(findNextFileName(files, '2'), '2c.tb')
        self.assertEqual(findNextFileName(files, '2a'), '2a3.tb')

        files = ['1.tb', '2.tb', '2a.tb', '2b.tb', '3.tb', '3a.tb']
        self.assertEqual(findNextFileName(files, ''), '4.tb')
        self.assertEqual(findNextFileName(files, '2'), '2c.tb')
        self.assertEqual(findNextFileName(files, '3'), '3b.tb')
        
        files = ['1.tb', '2.tb', '2a.tb', '2.tb', '3.tb', '3a.tb', '3b.tb']
        self.assertEqual(findNextFileName(files, ''), '4.tb')
        self.assertEqual(findNextFileName(files, '2'), '2b.tb')
        self.assertEqual(findNextFileName(files, '3'), '3c.tb')

        files = ['1.tb', '2.tb', '2a.tb', '2b.tb', '3.tb', '3a.tb', '3b.tb']
        self.assertEqual(findNextFileName(files, ''), '4.tb')
        self.assertEqual(findNextFileName(files, '2'), '2c.tb')
        self.assertEqual(findNextFileName(files, '3'), '3c.tb')

