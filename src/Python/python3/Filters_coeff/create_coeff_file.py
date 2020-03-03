#!/usr/bin/env python

# (C) 2009 Giovanni Busonera <giovannibusonera@gmail.com>
# Interface to a FPGA based correlator
# based on PySerial package

import sys
import os
import serial
import optparse

from math import sqrt
from math import atan

#########################
# BUILD PARSER FUNCTION #
#########################

def get_parser():
    parser = optparse.OptionParser(
        usage = "%prog -b bpf_coeff_file -h hpf_coeff_file -o coe_file(without the .coe extension)",
        description = "Application to build the .coe file for correlator filters",
        )

    parser.add_option("-b", "--bpf",
                     dest = "lpf_fn",
                     help = "bpf coefficient file name",
                     default = ''
                     )

    parser.add_option("-q", "--qf",
                     dest = "hpf_fn",
                     help = "hpf coefficient file name",
                     default = ''
                     )

    parser.add_option("-o", "--output",
                     dest = "out_fn",
                     help = "output .coe file name (without the .coe extension)",
		     default = 'filter_coeff'
                     )

    return parser

#################
# MAIN FUNCTION #
#################

def main():

    parser = get_parser()
    (options, args) = parser.parse_args()

    # Open Files
    try:
        lpf_fd = open(options.lpf_fn, "r")
        hpf_fd = open(options.hpf_fn, "r")
        out_fd = open(options.out_fn + ".coe", "w")
    except IOError:
        sys.stderr.write("Error opening files\n")
        parser.print_help()
        sys.exit(2)

    # Reading data
    lpf_coeff_wn = lpf_fd.readlines()
    hpf_coeff_wn = hpf_fd.readlines()

    # Removing \n char
    lpf_coeff = [line.replace("\n", "") for line in lpf_coeff_wn]
    hpf_coeff = [line.replace("\n", "") for line in hpf_coeff_wn]

    # Building .coe file
    out_fd.write("memory_initialization_radix=16;\n")
    out_fd.write("memory_initialization_vector=\n")

    for i in range(2):
        for j in range(len(lpf_coeff)):
            out_fd.write(lpf_coeff[j].rstrip() + ",\n")
	
    for j in range(len(hpf_coeff)-1):
        out_fd.write(hpf_coeff[j].rstrip() + ",\n")

    out_fd.write(hpf_coeff[len(hpf_coeff)-1] + ";\n")

    lpf_fd.close()
    hpf_fd.close()
    out_fd.close()

if __name__ == '__main__':
    main()
