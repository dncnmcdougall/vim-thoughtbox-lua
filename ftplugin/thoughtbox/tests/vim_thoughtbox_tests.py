import unittest
import vim_thoughtbox as sut


@unittest.skip("Don't forget to test!")
class VimThoughtboxTests(unittest.TestCase):

    def test_example_fail(self):
        result = sut.vim_thoughtbox_example()
        self.assertEqual("Happy Hacking", result)
