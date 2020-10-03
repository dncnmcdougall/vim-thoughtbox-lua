from typing import List, Dict
import os 
import re 
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

class NameSortKet:
    def __init__(self, name, *args):
        self.name = name
        self.parts = splitName(self.name)

    def _strComp(self, str1, str2):
        len1 = len(str1)
        len2 = len(str2)
        if len1 < len2:
            return -1
        elif len1 > len2:
            return 1
        else:
            for i,c in enumerate(str1):
                if c < str2[i]:
                    return -1
                if c > str2[i]:
                    return 1
            return 0

    def _comp(self, other):
        other_len = len(other.parts)
        for i, item in enumerate(self.parts):
            if i >= other_len:
                return 1
            str_comp = self._strComp(item, other.parts[i])
            if str_comp != 0:
                return str_comp
        if len(self.parts) < other_len:
            return -1
        return 0

    def __lt__(self, other):
        return self._comp(other) < 0 
    def __gt__(self, other):
        return self._comp(other) > 0 
    def __eq__(self, other):
        return self._comp(other) == 0 
    def __le__(self, other):
        return self._comp(other) <= 0 
    def __ge__(self, other):
        return self._comp(other) >= 0 
    def __ne__(self, other):
        return self._comp(other) != 0 

def sortNames(names: List[str]) -> None:
    names.sort(key=NameSortKet)

def listThoughtFiles(directory: str, absolute: bool = False) -> List[str]:
    directory = path.abspath(path.expanduser(directory))
    files = os.listdir(directory)
    files = [ f for f in files if f.endswith('.tb') ]
    sortNames(files)

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

def listThougthNumberTitleAndTag(directory: str) -> List[str]:
    names = []
    files = listThoughtFiles(directory, True)
    for f in files:
        name, content = readThoughtContent(f)
        names.append((name, f, content['title'], content['tags']))
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
    result = {'title':None, 'content':[], 'tags': [], 'sources': [], 'links':[]}
    for line in content:
        if line.startswith('# '):
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
    tag_re = re.compile('#\w*')

    for line in result['content']:
        matches = tag_re.finditer(line)
        for m in matches:
            tag = m.group()[1:]
            tags.append(tag)

    for line in result['tags']:
        if len(line) > 0:
            line = line.strip(' ,')
            tags.extend([ tag.strip() for tag in line.split(',')])
    result['tags'] = tags


    links = []
    link_re = re.compile('\[\[.*?\]\]')
    for line in result['content']:
        matches = link_re.finditer(line)
        for m in matches:
            link = m.group()[2:-2]
            links.append(link)
    result['links'] = links
    return result
    

import unittest
class ThoughtInfoTests(unittest.TestCase):
    def test_splitName(self):
        self.assertEqual(splitName(''), [])
        self.assertEqual(splitName('1a.tb'), ['1','a'])
        self.assertEqual(splitName('1a'), ['1','a'])
        self.assertEqual(splitName('1a1a.tb'), ['1','a','1','a'])
        self.assertEqual(splitName('1aa100a.tb'), ['1','aa','100','a'])

    def test_sortNames(self):
        def getSorted(arr: List[str]) -> List[str]:
            sortNames(arr)
            return arr
            

        self.assertEqual(getSorted(['b','c','a']), ['a','b','c'])
        self.assertEqual(getSorted(['2','3','1']), ['1','2','3'])
        self.assertEqual(getSorted(['1b','1c','1a']), ['1a','1b','1c'])
        self.assertEqual(getSorted(['1b','2','1a']), ['1a','1b','2'])
        self.assertEqual(getSorted(['1b','2b','1a', '2a']), ['1a','1b','2a', '2b'])
        self.assertEqual(getSorted(['2a','1a','2b', '1b']), ['1a','1b','2a', '2b'])
        self.assertEqual(getSorted(['2','10','1']), ['1','2','10'])
        self.assertEqual(getSorted(['b','aa','a']), ['a','b','aa'])

    def test_parseThoughtContent(self):
        heading_content = ['# heading',
                'content 1',
                'content 2',
                '']

        inline_tags = [
                'The #cat jumped',
                '#dog jumped too',
                'as did the #kangaroo',
                '']

        inline_links = [
                'The cat [[1]] jumped',
                '[[2]] dog jumped too',
                'as did the kangaroo [[3]]',
                '']

        tags_content = ['# tags',
                'tag1, tag1b',
                'tag 2, tag 2b,',
                'tag 3, tag 3b',
                '']

        sources_content = ['# sources',
                'sources 1',
                'sources 2',
                '']


        content = []
        content.extend(heading_content)
        content.extend(inline_tags)
        content.extend(inline_links)
        content.extend(tags_content)
        content.extend(sources_content)

        expected_content = []
        expected_content.extend(heading_content[1:])
        expected_content.extend(inline_tags)
        expected_content.extend(inline_links)
        result = parseThoughtContent(content, 'test')
        self.assertEqual(result, {
            'title': 'heading', 
            'content': expected_content,
            'tags':['cat', 'dog', 'kangaroo', 'tag1','tag1b', 'tag 2', 'tag 2b', 'tag 3', 'tag 3b'], 
            'sources':['sources 1','sources 2',''], 
            'links': ['1','2','3']})


    def test_parseThoughtContent_heading(self):
        heading_content = ['# heading',
                'content 1',
                'content 2',
                '']

        heading_content_2 = ['# heading 2',
                'content 1',
                'content 2',
                '']


        result = parseThoughtContent([], 'test')
        self.assertEqual(result, {'title':None, 'content':[], 'tags':[], 'sources':[], 'links': []})

        result = parseThoughtContent([heading_content[0]], 'test')
        self.assertEqual(result, {'title': 'heading', 'content':[], 'tags':[], 'sources':[], 'links': []})
        
        result = parseThoughtContent(heading_content, 'test')
        self.assertEqual(result, {'title': 'heading', 'content':['content 1', 'content 2', ''], 'tags':[], 'sources':[], 'links': []})

        result = parseThoughtContent(heading_content_2, 'test')
        self.assertEqual(result, {'title': 'heading 2', 'content':['content 1', 'content 2', ''], 'tags':[], 'sources':[], 'links': []})

    def test_parseThoughtContent_tags(self):
        heading_content = ['# heading',
                'content 1',
                'content 2',
                '']

        inline_tags = [
                'The #cat jumped',
                '#dog jumped too',
                'as did the #kangaroo',
                '']

        tags_content = ['# tags',
                'tag1, tag1b',
                'tag 2, tag 2b,',
                'tag 3, tag 3b',
                '']

        result = parseThoughtContent(tags_content, 'test')
        self.assertEqual(result, {'title': 'tags', 'content':['tag1, tag1b','tag 2, tag 2b,', 'tag 3, tag 3b',''], 'tags':[], 'sources':[], 'links': []})

        content = []
        content.extend([heading_content[0]])
        content.extend(tags_content)
        result = parseThoughtContent(content, 'test')
        self.assertEqual(result, {'title': 'heading', 'content':[], 'tags':['tag1','tag1b', 'tag 2', 'tag 2b', 'tag 3', 'tag 3b'], 'sources':[], 'links': []})

        content = []
        content.extend([heading_content[0]])
        content.extend(inline_tags)
        result = parseThoughtContent(content, 'test')
        self.assertEqual(result, {'title': 'heading', 'content':['The #cat jumped', '#dog jumped too', 'as did the #kangaroo', ''], 'tags':['cat','dog', 'kangaroo'], 'sources':[], 'links': []})

        content = []
        content.extend([heading_content[0]])
        content.extend(inline_tags)
        content.extend(tags_content)
        result = parseThoughtContent(content, 'test')
        self.assertEqual(result, {'title': 'heading', 'content':['The #cat jumped', '#dog jumped too', 'as did the #kangaroo', ''], 'tags':['cat', 'dog', 'kangaroo', 'tag1','tag1b', 'tag 2', 'tag 2b', 'tag 3', 'tag 3b'], 'sources':[], 'links': []})

    def test_parseThoughtContent_links(self):
        heading_content = ['# heading',
                'content 1',
                'content 2',
                '']

        inline_links = [
                'The cat [[1]] jumped',
                '[[2]] dog jumped too',
                'as did the kangaroo [[3]]',
                'all [[4]] jumping together [[5]]',
                '']

        content = []
        content.extend([heading_content[0]])
        content.extend(inline_links)
        result = parseThoughtContent(content, 'test')
        self.assertEqual(result, {'title': 'heading', 'content':['The cat [[1]] jumped', '[[2]] dog jumped too', 'as did the kangaroo [[3]]', 'all [[4]] jumping together [[5]]',''], 'tags':[], 'sources':[], 'links': ['1','2','3','4','5']})

    def test_parseThoughtContent_sources(self):
        heading_content = ['# heading',
                'content 1',
                'content 2',
                '']

        sources_content = ['# sources',
                'sources 1',
                'sources 2',
                '']

        result = parseThoughtContent(sources_content, 'test')
        self.assertEqual(result, {'title': 'sources', 'content':['sources 1','sources 2', ''], 'tags':[], 'sources':[], 'links': []})

        content = []
        content.extend([heading_content[0]])
        content.extend(sources_content)
        result = parseThoughtContent(content, 'test')
        self.assertEqual(result, {'title': 'heading', 'content':[], 'tags':[], 'sources':['sources 1','sources 2',''], 'links': []})


