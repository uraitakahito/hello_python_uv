from func import get_available_seats


class Event:
    def __init__(self, id: int):
        self.id = id

    def check_availability(self):
        available_seats = get_available_seats(self.id)

        if available_seats == 0:
            return "Sold Out"
        elif available_seats < 20:
            return "Few Left"
        else:
            return "Available"
