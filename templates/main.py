#!/usr/bin/env python3

"""
Copyright
Written by: Justin Tornetta <>
Description: Template for a Python CLI tool using argparse with subcommands.
Date: YYYY-MM-DD
"""

import argparse
import sys

def handle_foo(args):
    print(f"[foo] Received name={args.name} and count={args.count}")

def handle_bar(args):
    print(f"[bar] Enabled: {args.enable}")

def create_parser():
    parser = argparse.ArgumentParser(
        description="Template CLI tool with subcommands"
    )
    
    subparsers = parser.add_subparsers(
        title='subcommands',
        dest='subcommand',
        required=True,
        help='Available subcommands'
    )

    # Subcommand: foo
    parser_foo = subparsers.add_parser('foo', help='Do something with foo')
    parser_foo.add_argument('name', help='Name to process')
    parser_foo.add_argument('-c', '--count', type=int, default=1, help='Number of times to process')
    parser_foo.set_defaults(func=handle_foo)

    # Subcommand: bar
    parser_bar = subparsers.add_parser('bar', help='Toggle a flag')
    parser_bar.add_argument('--enable', action='store_true', help='Enable something')
    parser_bar.set_defaults(func=handle_bar)

    return parser

def main():
    parser = create_parser()
    args = parser.parse_args()
    args.func(args)

if __name__ == '__main__':
    main()