
if __name__ == "__main__":
    import unittest

    import sys
    from os import path
    sys.path.append(path.abspath(path.join(path.dirname(__file__),'..')))

    from pythoughts.NewThought import *
    from pythoughts.ThoughtInfo import *

    unittest.main()

