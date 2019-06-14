import os
import time


def run():
    protocols = ['DSDV', 'DSR']
    nodes = [12, 32, 52]
    velocity = [1.0, 5.0, 10.0]

    for i in range(1, 11):
        print(i)
        cmd = 'ns wireless.tcl'
        output = os.popen(cmd)
        time.sleep(5)

run()
