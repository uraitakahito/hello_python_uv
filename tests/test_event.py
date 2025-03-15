from unittest import TestCase
from unittest.mock import patch

from event import Event


class EventTest(TestCase):
    @patch("event.get_available_seats")
    def test_availability(self, mock_func):
        event = Event(id=1)

        mock_func.return_value = 0
        availability = event.check_availability()
        self.assertEqual(availability, "Sold Out")

        mock_func.return_value = 19
        availability = event.check_availability()
        self.assertEqual(availability, "Few Left")

        self.assertEqual(mock_func.call_count, 2)
