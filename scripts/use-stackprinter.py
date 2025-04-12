# type: ignore
"""
We can use stackprinter (https://github.com/cknd/stackprinter/) to enhance
the printed information that we get when an exeption is thrown
"""

# The output:
# (hello-python-uv) hello-python-uv% uv run python examples/use-stackprinter.py
# File "/Users/takahito/projects/hello-python-uv/examples/use-stackprinter.py", line 13, in <module>
#     9        for i, word in enumerate(words_to_process):
#     10           processed_word = str.capitalize(word)
#     11
#     12
# --> 13   process_words(words)
#     ..................................................
#      words = ['debugging', 'with', 'stackprinter', 42, ]
#     ..................................................

# File "/Users/takahito/projects/hello-python-uv/examples/use-stackprinter.py", line 10, in process_words
#     8    def process_words(words_to_process):
#     9        for i, word in enumerate(words_to_process):
# --> 10           processed_word = str.capitalize(word)
#     ..................................................
#      words_to_process = ['debugging', 'with', 'stackprinter', 42, ]
#      i = 3
#      word = 42
#      processed_word = 'Stackprinter'
#     ..................................................

# TypeError: descriptor 'capitalize' for 'str' objects doesn't apply to a 'int' object'

import stackprinter

stackprinter.set_excepthook(style="darkbg2")

words = ["debugging", "with", "stackprinter", 42]


def process_words(words_to_process):
    for i, word in enumerate(words_to_process):
        processed_word = str.capitalize(word)


try:
    process_words(words)
except Exception as e:
    stackprinter.show(e, style="darkbg2")
