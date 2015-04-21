#
# Biicode Boost blocks templates settings for block generation.
#

import os
import urllib
import json
import sys
import ast
import argparse

import utils

def settings(default_parser):
    parser = default_parser

    args = default_parser.parse_args()

    boost_version = args.track if args.track != "master" else "1.57.0"
    passwords = ast.literal_eval(args.passwords.replace('->', ':'))

    variables = {"BIICODE_BOOST_VERSION":
                 lambda block, block_track, file: boost_version,
                 "WORKING_TRACK":
                 lambda block, block_track, file: args.track,
                 "BIICODE_BOOST_BLOCK":
                 lambda block, block_track, file: "biicode/boost({0})"
                                                  .format(block_track),
                 "LATEST_BLOCK_VERSION":
                 lambda block, block_track, file: utils.latest_block_version(block, block_track)}

    templates={"biicode/boost": 
                {"publish": not args.no_publish,
                   "tag": args.tag,          
                   "files": 
                     {"biicode.conf": ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION"],
                      "setup.cmake": ["BIICODE_BOOST_VERSION"]}
                },
               "examples/boost-coroutine": 
                {"publish": args.publish_examples and not args.no_publish,
                   "tag": args.tag,          
                   "files": 
                     {"biicode.conf": ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION"]}
                }
             }

    if args.exclude:
        for block in args.exclude.split(' '):
            if block in templates:
                del templates[block]
    

    return utils.GenerationSettings(templates, variables, passwords, 
                                    args.templates_path, args.blocks_path)

if __name__ == '__main__':
    print(settings())
