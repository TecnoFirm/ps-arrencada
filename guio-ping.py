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
    Retorna la data d'ara amb el format indicat. Les opcions son:
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

    parser = argparse.ArgumentParser(
        description='Analyse the network via `mtr` for a period of time (by default, a day)')
    # file-name: positional arg.
    parser.add_argument('hostnames', type=str,
    help='Path to hostnames file (each row should correspond to a singular hostname)'
                        )
    # file-name: optional required argument.
    parser.add_argument('-o', '--outfile', type=str,
        help='Path and filename where output should be written (will append to the end)')
    # integer: not required.
    parser.add_argument('-n', '--numb',
            type=int, default=int(24), required=False,
            help="Amount of packets sent while performing the analyses")

    args = parser.parse_args()
    # call a value: args.operacio or args.filename.

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

    with open(args.hostnames) as hfile:
        for hname in hfile:
            hname = hname.strip()
            print(f'-- Pinging to `{hname}`')
            # Make sure `mtr` is installed in the command-line.
            # Creates a tmp file (traceroute.tmp.csv) with the analysis results.
            command = f"mtr -c {args.numb} --csv -o 'LBAWV' {hname} > traceroute.tmp.csv"

            # -c 10 should send {args.numb} packets.
            # --csv: output in csv format.
            # -o 'lBAWV': output these fields only.

            os.system(command)
            # Concatena el dataframe `df` amb el resultat de la comanda
            # anterior.
            # elimina la primera i última columna (.iloc[:,1:-1])
            # la primera te la versió del soft. i la última és buida.
            df = pd.concat([df,
                    pd.read_csv('traceroute.tmp.csv').iloc[:,1:-1].assign(Hora=data('h'))])

    print(f'-- Writing pd.DataFrame() to `{args.outfile}`')
    # Imprimeix el header si el fitxer no existeix.
    # mode 'append' to already existing file.
    df.to_csv(args.outfile, mode='a', header=not os.path.exists(args.outfile))

    # Imprimeix els resultats finals en pantalla.
    print('-- Final dataframe:'); print()
    print(df.info())
    # remove tmp file
    os.system('rm --force traceroute.tmp.csv')
    print (f'-- temp. file traceroute.tmp.csv has been removed')

