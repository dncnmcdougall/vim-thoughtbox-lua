from typing import List
from os import path

if __name__ == "__main__":
    import sys
    sys.path.append(path.abspath(path.join(path.dirname(__file__),'..')))

def splitName(filename: str) -> List[str]:
    if not filename:
        return []
    name, _ = path.splitext(filename)
    parts = [ name[0] ]
    letter = name[0].isalpha()
    for i in range(1, len(name)):
        if letter == name[i].isalpha():
            parts[-1] += name[i]
        else:
            letter = name[i].isalpha()
            parts.append( name[i] )
    return parts

import unittest
class ThoughtInfoTests(unittest.TestCase):
    def test_splitName(self):
        self.assertEqual(splitName(''), [])
        self.assertEqual(splitName('1a.tb'), ['1','a'])
        self.assertEqual(splitName('1a'), ['1','a'])
        self.assertEqual(splitName('1a1a.tb'), ['1','a','1','a'])
        self.assertEqual(splitName('1aa100a.tb'), ['1','aa','100','a'])

