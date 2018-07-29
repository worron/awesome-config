#!/usr/bin/python

# Primitive script which can be used with mail widget.
# It's mostly demo assuming user can use something more advanced.

import poplib

pop_conn = poplib.POP3_SSL('pop.gmail.com')
pop_conn.user('username')
pop_conn.pass_('password')

# Get message num from server:
numMsgs, totalSize = pop_conn.stat()

# Print result:
print(numMsgs)

# Quit:
pop_conn.quit()
