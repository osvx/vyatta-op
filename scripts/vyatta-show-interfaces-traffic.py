#!/usr/bin/python

from sys import argv, exit
from time import sleep

def get_stats(interface):
    stats = {}

    with open('/proc/net/dev') as file:
        for line in file:
            line = line.split()

            if line[0][:-1] == interface:
                stats['bytes_in'] = float(line[1])
                stats['packets_in'] = float(line[2])
                stats['errors_in'] = int(line[3])
                stats['drops_in'] = int(line[4])
                stats['bytes_out'] = float(line[9])
                stats['packets_out'] = float(line[10])
                stats['errors_out'] = int(line[11])
                stats['drops_out'] = int(line[12])

                break

    return stats

def compute_stats(start, end, interval=5):
    stats = {}
    computed = {}

    for stat in ['bytes_in', 'packets_in', 'errors_in', 'drops_in', 'bytes_out', 'packets_out', 'errors_out', 'drops_out']:
        stats[stat] = end[stat] - start[stat]

    if stats['bytes_in'] == 0:
        computed['mbps_in'] = 0.0
        computed['pps_in'] = 0
        computed['bpp_in'] = 0
        computed['errors_in'] = 0
        computed['drops_in'] = 0
    else:
        computed['mbps_in'] = round(stats['bytes_in'] / interval / 131072, 1)
        computed['pps_in'] = int(stats['packets_in'] / interval)
        computed['bpp_in'] = int(stats['bytes_in'] / stats['packets_in'])
        computed['errors_in'] = stats['errors_in']
        computed['drops_in'] = stats['drops_in']

    if stats['bytes_out'] == 0:
        computed['mbps_out'] = 0.0
        computed['pps_out'] = 0
        computed['bpp_out'] = 0
        computed['errors_out'] = 0
        computed['drops_out'] = 0
    else:
        computed['mbps_out'] = round(stats['bytes_out'] / interval / 131072, 1)
        computed['pps_out'] = int(stats['packets_out'] / interval)
        computed['bpp_out'] = int(stats['bytes_out'] / stats['packets_out'])
        computed['errors_out'] = stats['errors_out']
        computed['drops_out'] = stats['drops_out']

    return computed

def display_stats(stats):
    print 'RX Mbps  : %s' % stats['mbps_in']
    print 'RX PPS   : %s' % stats['pps_in']
    print 'RX BPP   : %s' % stats['bpp_in']
    print 'RX errors: %s' % stats['errors_in']
    print 'RX drops : %s' % stats['drops_in']
    print ''
    print 'TX Mbps  : %s' % stats['mbps_out']
    print 'TX PPS   : %s' % stats['pps_out']
    print 'TX BPP   : %s' % stats['bpp_out']
    print 'TX errors: %s' % stats['errors_out']
    print 'TX drops : %s' % stats['drops_out']

    return True

if __name__ == '__main__':
    try:
        name = argv[1]
    except:
        print 'no interface specified'
        exit(1)

    try:
        interval = int(argv[2])
    except:
        interval = 5

    try:
	print 'Measuring traffic at interface %s for %i seconds...' % (name, interval)
        start = get_stats(name)

        if len(start) == 0:
            print 'interface not found'
            exit(2)

        sleep(interval)

        end = get_stats(name)

        display_stats(compute_stats(start, end, interval))
    except Exception as e:
        print 'error: %s' % e
        exit(3)

    exit(0)

