import hello_python_library
from hello_python_uv_library import greetings

hello_python_library.hello()
print(greetings.hello())
print(greetings.hello_add(1, 2))
