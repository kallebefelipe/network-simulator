protocols = ['DSDV', 'DSR']
nodes = ['12', '32', '52']
velocitys = ['1', '5', '10']


def get_data(path):
    f = open(path, "r")
    data = []
    for x in f:
        data.append(x)
    return data


def trat_data(data):
    new_data = []

    for line in data:
        new_line = line.replace('\n', '').split(' ')
        value = float(new_line[3])
        new_data.append(value)
    return new_data


def calc_med(data):
    _sum = 0
    for value in data:
        _sum += value
    return _sum/10


def run_statistic():
    for protocol in protocols:
        for node in nodes:
            for velocity in velocitys:
                data = get_data(
                    'trace_files/'+protocol+'_'+node+'_'+velocity+'.tr')
                data_trat = trat_data(data)
                med = calc_med(data_trat)
                print(protocol+'_'+node+'_'+velocity+': '+str(med))


run_statistic()
