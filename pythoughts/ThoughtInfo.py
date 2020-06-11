from typing import List, Dict
import os 
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

def listThoughtFiles(directory: str, absolute: bool = False) -> List[str]:
    directory = path.abspath(path.expanduser(directory))
    files = os.listdir(directory)
    files = [ f for f in files if f.endswith('.tb') ]
    files.sort()

    if absolute:
        files = [ path.join(directory, f) for f in files ]

    return files

def listThougthNumberAndTitle(directory: str) -> List[str]:
    names = []
    files = listThoughtFiles(directory, True)
    for f in files:
        name, content = readThoughtContent(f, max_lines=1)
        names.append((name, f, content['title']))
    return names

def readThoughtContent(file_name: str, max_lines: int = None) -> Dict[str, str]:
    name, _ = path.splitext(path.basename(file_name))
    with open(file_name, 'r') as thought_file:

        count = 0 
        heading = None
        content = []
        for line in thought_file:
            if max_lines is not None and count >= max_lines:
                break
            content.append(line.strip())

    return name, parseThoughtContent(content, name)

def parseThoughtContent(content: List[str], name: str) -> Dict[str,str]:
    heading = None
    result = {'title':None, 'content':[], 'tags': [], 'sources': []}
    for line in content:
        if line.startswith('#'):
            line= line[1:].strip()
            if heading is None:
                heading = 'content'
                result['title']=line
            else:
                heading=line
        elif heading in result:
            result[heading].append(line)
        else:
            print('Warning: did not understand heading %s in %s' % (heading, name))

    tags = []
    for line in result['tags']:
        if len(line) > 0:
            tags.extend([ tag.strip() for tag in line.split(',')])
    result['tags'] = tags
    return result
    

import unittest
class ThoughtInfoTests(unittest.TestCase):
    def test_splitName(self):
        self.assertEqual(splitName(''), [])
        self.assertEqual(splitName('1a.tb'), ['1','a'])
        self.assertEqual(splitName('1a'), ['1','a'])
        self.assertEqual(splitName('1a1a.tb'), ['1','a','1','a'])
        self.assertEqual(splitName('1aa100a.tb'), ['1','aa','100','a'])

    def test_parseThoughtContent(self):
        heading_content = ['# heading',
                'content 1',
                'content 2',
                '']

        tags_content = ['# tags',
                'tag1, tag1b',
                'tag 2, tag 2b',
                '']
        sources_content = ['# sources',
                'sources 1',
                'sources 2',
                '']

        result = parseThoughtContent([], 'test')
        self.assertEqual(result, {'title':None, 'content':[], 'tags':[], 'sources':[]})

        result = parseThoughtContent([heading_content[0]], 'test')
        self.assertEqual(result, {'title': 'heading', 'content':[], 'tags':[], 'sources':[]})
        
        result = parseThoughtContent(heading_content, 'test')
        self.assertEqual(result, {'title': 'heading', 'content':['content 1', 'content 2', ''], 'tags':[], 'sources':[]})

        result = parseThoughtContent(tags_content, 'test')
        self.assertEqual(result, {'title': 'tags', 'content':['tag1, tag1b','tag 2, tag 2b',''], 'tags':[], 'sources':[]})

        content = []
        content.extend([heading_content[0]])
        content.extend(tags_content)
        result = parseThoughtContent(content, 'test')
        self.assertEqual(result, {'title': 'heading', 'content':[], 'tags':['tag1','tag1b', 'tag 2', 'tag 2b'], 'sources':[]})

        content = []
        content.extend([heading_content[0]])
        content.extend(sources_content)
        result = parseThoughtContent(content, 'test')
        self.assertEqual(result, {'title': 'heading', 'content':[], 'tags':[], 'sources':['sources 1','sources 2','']})

        content = []
        content.extend(heading_content)
        content.extend(tags_content)
        content.extend(sources_content)
        result = parseThoughtContent(content, 'test')
        self.assertEqual(result, {'title': 'heading', 'content':['content 1', 'content 2', ''], 'tags':['tag1','tag1b', 'tag 2', 'tag 2b'], 'sources':['sources 1','sources 2','']})

