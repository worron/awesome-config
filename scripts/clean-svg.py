#!/usr/bin/python

import os
import subprocess

current_dir = os.path.dirname(os.path.abspath(__file__))
theme_dir = os.path.join(current_dir, '..', 'themes')

for root, _, files in os.walk(theme_dir):
	for name in files:
		if name.endswith('.svg'):
			image = os.path.join(root, name)
			subprocess.call(['svgcleaner', '--indent=2', image, image])
