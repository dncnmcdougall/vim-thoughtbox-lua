import pynvim

import sys 
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__),'..', '..')))
import pythoughts

@pynvim.plugin
class thoughtbox(object):

    def __init__(self, vim):
        self.vim = vim

    def _print(self, args):
        self.vim.out_write(str(args))
        self.vim.out_write('\n')

    def _getSettings(self):
        return { 
                'sep' : self.vim.eval("exists('+shellslash') && !&shellslash ? '\\' : '/'"),
                'folder' : self.vim.eval('g:thoughtbox#folder'),
                'vertical_split': self.vim.eval('g:thoughtbox#vertical_split'),
                'open_pos': self.vim.eval('g:thoughtbox#open_pos'),
                'split_size': self.vim.eval('g:thoughtbox#split_size'),
                'list_auto_close': self.vim.eval('g:thoughtbox#list_auto_close'),
                'list_jump_to_on_open': self.vim.eval('g:thoughtbox#list_jump_to_on_open')
                }

    @pynvim.function("ThoughtboxNewThought", sync=True)
    def newThought(self, args):
        settings = self._getSettings()

        directory = settings['folder']
        name = args[0]

        nextName = pythoughts.NewThought.findNextFileNameInDirectory(directory, name)

        self.vim.command(':e %s' % nextName)

        cb = self.vim.current.buffer
        cb[:] = pythoughts.NewThought.getNewThoughtTemplate()


