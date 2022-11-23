#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# guio-ping.py
#
# 17 de nov. 2022  <adria@molevol-OptiPlex-9020>

"""
1. Envia una ordre de 'mtr' al sistema amb el mòdul 'os'.
2. Recull el resultat (en format csv?) amb pandas dins un dataframe.
3. Elimina i afegeix info per ajustar a les necessitats.
4. Append a un file.csv per guardar les anàlisis.
"""

import sys
import os
import pandas as pd

# Recull la data de les anàlisis de ping...
import datetime

# Funció per fer Sleep...
import time

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def data(f):
    """
    Retorna la data amb el format indicat. Les opcions son:
    + f = 'd'; '11-Sep-2022'
    + f = 'h'; '10:56'
    """
    # Imprimeix-la segons el format que indica als documents...
    # <https://docs.python.org/3/library/datetime.html#strftime-strptime-behavior>

    ara = datetime.datetime.now()
    if f=='d':
        # Prén la data 'avui'.
        return ara.strftime('%d-%b-%Y')
    elif f=='h':
        # Prén la hora 'ara'.
        return ara.strftime('%H:%M')

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Si es crida com a script:
if __name__ == '__main__':

    ### PARSE ARGUMENTS ###
    import argparse

    parser = argparse.ArgumentParser(description='')
    # file-name: positional arg.
    parser.add_argument('hostnames', type=str,
    help='Path to hostnames file (each row should correspond to a singular hostname)'
                        )
    # integer argument
#    parser.add_argument('-a', '--numero_a', type=int, help='Paràmetre "a"')
    # choices argument
#    parser.add_argument('-o', '--operacio', 
#            type=str, choices=['suma', 'resta', 'multiplicacio'],
#            default='suma', required=False,
#            help='')

    args = parser.parse_args()
    # call a value: args.operacio or args.filename.

    # Un dia sencer es podria formar amb 72 intervals de 20 minuts...
    # O amb 72*2 = 144 intervals de 10 minuts.
    sleep_interval = 10 #in minutes, between repeats (replicates)
    repeats = 0
    while repeats < 72:
        with open(args.hostnames) as hfile:
            # init the dataframe to store all hostnames' traceroutes:
            df = pd.DataFrame(columns=[
                'Start_Time',
                'Status',
                'Host',
                'Hop',
                'Ip',
                'Loss%',
                'Best',
                'Avg',
                'Wrst',
                'StDev',
            ])
            for hname in hfile:
                # Make sure `mtr` is installed in the command-line.
                # Creates a tmp file (traceroute.tmp.csv) with the analysis results.
                command = f"mtr --csv -o 'LBAWV' {hname.strip()} > traceroute.tmp.csv"
                os.system(command)
                # Concatena el dataframe `df` amb el resultat de la comanda
                # anterior.
                # elimina la primera i última columna (.iloc[:,1:-1])
                # la primera te la versió del soft. i la última és buida.
                df = pd.concat([df, pd.read_csv('traceroute.tmp.csv').iloc[:,1:-1]])
                print(df)

        # Tick forward the counter.
        repeats += 1
        # Exporta els resultats *cada vegada* que es faci de nou anàlisi?
        df.to_csv('ping-traceroute.csv')
        # Sleep for 'sleep_interval' minutes until next analyses
        time.sleep(sleep_interval*60)
    # Output dels resultats a un fitxer.
    print('-- Final dataframe --'); print()
    print(df) ; print()
    print('-- Saving pd.DataFrame() to `ping-traceroute.csv` --')

