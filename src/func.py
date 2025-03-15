import random


def get_available_seats(event_id: int) -> int:
    """Returns the number of available seats for the given event ID."""
    available_seats = random.randint(0, 100)

    return available_seats
