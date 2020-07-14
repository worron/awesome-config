#!/usr/bin/python

# Direct brightness control for laptops.
# Your system brightness file should be writable by user.

from argparse import ArgumentParser

# Brightness files location
MAX_BRIGHTNESS_FILE = "/sys/class/backlight/intel_backlight/max_brightness"
MAIN_BRIGHTNESS_FILE = "/sys/class/backlight/intel_backlight/brightness"


# Argument parser
def build_parser():
	parser = ArgumentParser()

	parser.add_argument(
		"--set", metavar='PERCENT', type=int,
		help="Set brightness level 1..100."
	)

	parser.add_argument(
		"--inc", metavar='PERCENT', type=int,
		help="Increase brightness level."
	)

	parser.add_argument(
		"--dec", metavar='PERCENT', type=int,
		help="Decrease brightness level."
	)

	return parser


# Brightness control
class Brightness:
	def __init__(self):

		with open(MAX_BRIGHTNESS_FILE, 'r') as max_brightness_file:
			self._max = int(max_brightness_file.read())

		with open(MAIN_BRIGHTNESS_FILE, 'r') as brightness_file:
			self._current = int(brightness_file.read())

		self.step = self._max / 100

	@staticmethod
	def _clamp(n, minn, maxn):
		return max(min(maxn, n), minn)

	@property
	def percentage(self):
		return round(self._current / self.step)

	@percentage.setter
	def percentage(self, value):
		new_value = round(value * self.step)
		self._current = self._clamp(new_value, 0, self._max)

		with open(MAIN_BRIGHTNESS_FILE, 'w') as brightness_file:
			brightness_file.write(str(self._current))


# Main
if __name__ == "__main__":
	args_parser = build_parser()
	args = args_parser.parse_args()

	brightness = Brightness()

	if args.set:
		brightness.percentage = args.set
	elif args.inc:
		brightness.percentage += args.inc
	elif args.dec:
		brightness.percentage -= args.dec

	print(brightness.percentage)
