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
                }
             }

                # "examples/boost-log"        : (examples_version_tag, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                # "examples/boost-coroutine"  : (examples_version_tag, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                # "examples/boost-filesystem" : (examples_version_tag, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                # "examples/boost-flyweight"  : (examples_version_tag, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                # "examples/boost-multiindex" : (examples_version_tag, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                # "examples/boost-phoenix"    : (examples_version_tag, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                # "examples/boost-signals"    : (examples_version_tag, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])])}

    #Boost.Log takes so much time to compile, leads to timeouts on Travis CI
    #It was tested on Windows and linux, works 'ok' (Be careful with linking settings)
    if args.ci and 'examples/boost-log' in templates: del templates['examples/boost-log']  

    if args.exclude:
        for block in args.exclude.split(' '):
            if block in templates:
                del templates[block]
    

    return utils.GenerationSettings(templates, variables, passwords, 
                                    args.templates_path, args.blocks_path)

if __name__ == '__main__':
    print(settings())
