import pytest

from hello_python_uv.prime import is_prime


@pytest.mark.parametrize(
    ("number", "expected"),
    [
        (1, False),
        (2, True),
        (3, True),
        (4, False),
        (5, True),
        (6, False),
        (7, True),
        (8, False),
        (9, False),
        (10, False),
    ],
)
def test_is_prime(number: int, expected: bool):
    assert is_prime(number) == expected
