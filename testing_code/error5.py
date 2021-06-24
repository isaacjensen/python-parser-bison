# This file contains an invalid if/elif/else statement (elif before if).
a = 1
b = 1
x = 1
elif b < 2:
    x = x + 1
if a >= 16:
    x = x + 4
else:
    x = 1
