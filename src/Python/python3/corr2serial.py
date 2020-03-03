#!/usr/bin/env python

# (C) 2009 Giovanni Busonera <giovannibusonera@gmail.com>
# Interface to a FPGA based correlator
# based on PySerial package

import sys
import os
import serial
import optparse
import datetime


from math import sqrt
from math import atan
from math import atan2
####################
# CORRELATOR CLASS #
####################

class correlator:
    def __init__(self):
        self.results = { 'x_2' : 0, 'y_2' : 0, 'xy' : 0, 'xy90' : 0, 'y90_2' : 0, 'y_y90' : 0 }
        self.coeff   = { 'real' : 0.00, 'imm' : 0.00 }
        self.buffer  = ""
        self.ser     = serial.Serial()
    
    def connect(self, portname, baudrate):
        conn_byte = 'c'
        ack_byte  = 'A'

        self.ser.port = portname
        self.ser.baudrate = baudrate
        self.ser.timeout = 10
        
        if self.ser.isOpen():
            self.ser.close()

        self.ser.open()
        self.ser.flushInput()
    
        self.ser.write(conn_byte)
        
        rx_byte = self.ser.read(1)

        if len(rx_byte) != 1 or rx_byte != ack_byte:
            sys.stderr.write("Connection Failed. rx_byte = %s, len = %d\n" % (rx_byte,len(rx_byte)))
            return -1
        
        return 0

    def reset(self):
        reset_byte = 'r'
        
        #No acknoledge is expected
        self.ser.write(reset_byte)

    def disconnect(self):
        self.ser.close()

    def set_samples(self, n_samples):
        send_sample = 't'
        ack_byte  = 'A'
        for i in range(4):
            q = n_samples / 256
            m = n_samples % 256
            n_samples = q
            self.ser.write(send_sample)
            self.ser.write(chr(m))
        
        rx_byte = self.ser.read(1)
        if len(rx_byte) != 1 or rx_byte != ack_byte:
            sys.stderr.write("Trasmission Failed. rx_byte = %s, len = %d\n" % (rx_byte,len(rx_byte)))
            return -1
            
    def run(self):
        start_byte = 's'
        buffer_size = 48
            
        self.ser.write(start_byte)
        self.ser.flushInput()
        self.buffer = self.ser.read(buffer_size)
        
        if len(self.buffer) != buffer_size:
            return -1
        else:
            return 0        

    def fixed2float(self,data, dim_data, q):
        
        if data == 2**(dim_data-1):
            return -1.00*2**(dim_data-q-1)
    
        if data & 2**(dim_data-1) == 2**(dim_data-1):
            return -1.00 * ((2**dim_data)-data) / float(2**q)
        else:
            return float(data/float(2**q))

    def getCoeff(self):
        sum_x_2   = 0
        sum_y_2   = 0
        sum_xy    = 0
        sum_xy90  = 0
        sum_y90_2 = 0
        sum_y_y90 = 0
        
        for i in range(8):
            sum_y_y90 = sum_y_y90 | (ord(self.buffer[i]) << 8*i)
            sum_y90_2 = sum_y90_2 | (ord(self.buffer[i+8]) << 8*i)
            sum_xy90 = sum_xy90 | (ord(self.buffer[i+16]) << 8*i)
            sum_xy = sum_xy | (ord(self.buffer[i+24]) << 8*i)
            sum_y_2 = sum_y_2 | (ord(self.buffer[i+32]) << 8*i)
            sum_x_2 = sum_x_2 | (ord(self.buffer[i+40]) << 8*i)
            
        self.results['x_2'] = self.fixed2float(sum_x_2, 64, 30)
        self.results['y_2'] = self.fixed2float(sum_y_2, 64, 30)
        self.results['xy'] = self.fixed2float(sum_xy, 64, 30)
        self.results['xy90'] = self.fixed2float(sum_xy90, 64, 30)
        self.results['y90_2'] = self.fixed2float(sum_y90_2, 64, 30)
        self.results['y_y90'] = self.fixed2float(sum_y_y90, 64, 30)
        self.results['t'] = datetime.datetime.now()
            
        self.coeff['real'] = self.results['xy'] / (sqrt(self.results['x_2']) * sqrt(self.results['y_2']))
        self.coeff['imm'] = self.results['xy90'] / (sqrt(self.results['x_2']) * sqrt(self.results['y90_2']))
            
    def get_real(self):
        return self.coeff['real']

    def get_imm(self):
        return self.coeff['imm']

    def printResults(self):

         print ("%10.4f\t\t" %self.results['x_2'], "% 10.4f\t\t" %self.results['y_2'], "%    10.4f\t\t" %self.results['xy'], "%    10.4f\t\t" %self.results['xy90'], "%    10.4f\t\t" %self.results['y90_2'], "%    10.4f\t\t" %self.results['y_y90'], "%     s" %self.results['t'])
         
         

    #    print ("x2    = %10.6f" % self.results['x_2'])
    #    print ("y2    = %10.6f" % self.results['y_2'])
    #    print ("xy    = %10.6f" % self.results['xy'])
    #    print ("xy90  = %10.6f" % self.results['xy90'])
    #    print ("y90_2 = %10.6f" % self.results['y90_2'])
        
    def printCoeff(self, message):

         message = ""

    #    if message == "":
    #       sys.stdout.write("%10.6f\t%10.6f\n" % (self.coeff['real'], self.coeff['imm']))
    #    else:
    #        sys.stdout.write("%s\t%10.6f\t%10.6f\n" % (message, self.coeff['real'], self.coeff['imm']))
            
#########################
# BUILD PARSER FUNCTION #
#########################

def get_parser():
    parser = optparse.OptionParser(
        usage = "%prog [options] [port [baudrate]]",
        description = "Interface to a FPGA based correlator",
        )

    group = optparse.OptionGroup(parser,
                                 "Serial Port",
                                 "Serial port settings"
                                 )
    parser.add_option_group(group)

    group.add_option("-p", "--port",
                     dest = "port",
                     help = "port, a number (default 0) or a device name",
                     default = None
                     )

    group.add_option("-b", "--baud",
                     dest = "baudrate",
                     action = "store",
                     type = 'int',
                     help = "set baud rate, default: %default",
                     default = 115200
                     )

    group.add_option("-v", "--verbose",
                     dest = "verbose",
                     action = "store_true"
                     )

    group.add_option("-m", "--msg",
                     dest = "msg",
                     action = "store",
                     type = 'string',
                     help = "set string message used as prefix of coefficient result",
                     default = ""
                     )
    group.add_option("-r", "--rst",
                     dest = "reset",
                     action = "store_true",
                     help = "correlator reset must be forced using board botton reset",
                     )
    group.add_option("-s", "--samples",
                     dest = "samples",
             type = 'int',
             action ="store",
                     help = "set the number of saples to be integrated",
                     default = 25000000
             )
    return parser

#################
# MAIN FUNCTION #
#################

def main():

    print (datetime.datetime.now())
    max_attempts = 10 # Max number of attempts to get a correlation coefficient before fail!
    
    parser = get_parser()
    (options, args) = parser.parse_args()

    # get port and baud rate from command line arguments or the option switches
    port = options.port
    baudrate = options.baudrate
    verbose = options.verbose
    message = options.msg
    manual_reset = options.reset
    samples = options.samples

    if args:
        if options.port is not None:
            parser.error("port as argument overrides --port option")
        port = args.pop(0)
        if args:
            try:
                baudrate = int(args[0])
            except ValueError:
                parser.error("baud rate must be a number, not %r" % args[0])
            args.pop(0)
        if args:
            parser.error("too many arguments")
    else:
        if port is None: 
            parser.print_help()
            sys.exit(2)

    # Creating Correlator Object
    corr = correlator();
    
    if verbose:
        pass
    #     print ("Port is    : %s" % port)
    #     print ("Baudrate is: %s" % baudrate)
    #     print ("Connecting to FPGA...")
    
    # Connecting to FPGA module
    err = corr.connect(port, baudrate)
    
    if err:
        sys.stderr.write("Error... cannot connect to FPGA module\n")
        corr.disconnect()
        sys.exit(2)

    # SET the number of samples to be integrated
    corr.set_samples(samples)


    # Running Correlation
    err = corr.run()
    i = 0
    while err and i < max_attempts:
        i = i + 1
        sys.stderr.write("Attempt %d failed. Retrying...\n" % i)
        if not manual_reset:
            corr.reset()
            err = corr.connect(port, baudrate)
        else:
            sys.stderr.write("You must use board reset. After pushing reset button, restart this application.")
            sys.exit(2)
        
        if err:
         sys.stderr.write("Error... cannot reconnect to FPGA module\n")
         corr.disconnect()
         sys.exit(2)

        err = corr.run()    

    if err and i == max_attempts:
        sys.stderr.write("Error... cannot get correlator coefficient in %d attempts\n" % max_attempts)
        corr.disconnect()
        sys.exit(2)

    # Getting coefficient    
    corr.getCoeff()
    
    # Data output
    if verbose:

      corr.printResults()
      corr.printCoeff("")
      module = sqrt(corr.get_real()**2 + corr.get_imm()**2) 
      phase = atan2 (corr.get_imm(),corr.get_real())
      phase_deg = (180 / 3.141592654) * phase
    else:
        corr.printCoeff(message)
    
    corr.disconnect()
    print (datetime.datetime.now())

if __name__ == '__main__':
    main()
