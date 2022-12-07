#! /usr/bin/env python3
# -*- coding: utf-8 -*-
#
# plot-ping.py
#
# 07 de des. 2022  <adria@molevol-OptiPlex-9020>

"""
"""

import sys
import pandas as pd
import matplotlib.pyplot as plt

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Si es crida com a script:
if __name__ == '__main__':

    ### PARSE ARGUMENTS ###
    import argparse

    parser = argparse.ArgumentParser(description='')
    # file-name: positional arg.
    parser.add_argument('filename', type=str, help='Path to pings.csv file')
    # integer argument
#    parser.add_argument('-a', '--numero_a', type=int, help='Paràmetre "a"')
    # choices argument
#    parser.add_argument('-o', '--operacio', 
#            type=str, choices=['suma', 'resta', 'multiplicacio'],
#            default='suma', required=False,
#            help='')

    args = parser.parse_args()
    # Call a value: args.operacio or args.filename.
    df = pd.read_csv(args.filename)
    xax = 'Start_Time'
    # Avg value appears to be most informative...
    # %Loss only holds noise. Wrst (and maybe best) are proportional to average.
    yax = 'Avg'
    for hn in df['Host'].unique():
        data = df[df['Host']==hn]
        plt.plot(data[xax], data[yax], label=hn)
    plt.legend()
    plt.xlabel('Temps')
    plt.ylabel('Mitjana de temps de resposta')

    df_xlab=data[[xax,'Hora']].drop_duplicates()
    df_xlab=df_xlab[::12]
    df_xlab['max_Yval']=max(df[yax])
    t = [list(df_xlab.iloc[i]) for i in range(0, len(df_xlab))]
    [plt.text(i[0], i[2], i[1]) for i in t]
    plt.savefig('hello.png')

