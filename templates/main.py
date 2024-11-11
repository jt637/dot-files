#!/usr/bin/env python3

# Copyright
# Written by: Justin Tornetta ()
# Description: 
# Date:

import argparse

def func1(command, flag):
    print(f"this is a sample function with COMMANDS: {command} and FLAGS {flag}")

if (__name__ == '__main__'):
    parser = argparse.ArgumentParser(description='')
    parser.add_argument('command', help='command line argument')
    parser.add_argument('-f', '--flag', default='template', help='command line flag')
    
    args = parser.parse_args()

    func1(args.command, args.flag)
