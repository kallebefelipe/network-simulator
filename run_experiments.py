import os
import time
# from statistic import run_statistic

protocols = ['DSDV', 'DSR']
protocols = ['DSR']
nodes = ['12', '32', '52']
velocitys = ['1', '5', '10']


def run():
    for protocol in protocols:
        for node in nodes:
            for velocity in velocitys:
                for i in range(1, 11):
                    print(i)
                    cmd = 'ns wireless.tcl ' + \
                        '{' + protocol + '} ' + \
                        node + ' ' + str(velocity) + \
                        ' ' + str(i)
                    os.popen(cmd)
                    time.sleep(10)
                time.sleep(1)


run()
