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
    parser = argparse.ArgumentParser()

    parser.add_argument("track", help="biicode track (Boost version) that will be generated",
                        choices=['master', '1.57.0', '1.56.0', '1.55.0'])
    parser.add_argument("--ci-build", "-ci", help="Specifies if the generation is being run inside a CI build", 
                        action="store_true", dest="ci")
    parser.add_argument("--passwords", "-pass", 
                        help=("Dictionary containing block accounts passwords to be able to publish. "
                              "Note that with publish disabled the passwords are not needed"),
                        default="{}")
    parser.add_argument("--no-publish", "-nopublish", help="Overrides publish settings and does not publish any block",
                        action="store_true", dest="no_publish")
    parser.add_argument("--publish-examples", help="Enables block examples publication",
                        action="store_true", dest="publish_examples")
    parser.add_argument("--tag", help="biicode version tag which blocks will be published",
                        default="DEV")
    parser.add_argument("--exclude", help="Exclude explcitly blocks from generation. Pass block names separated with spaces",
                        default="")

    args = parser.parse_args()

    boost_version = args.track if args.track != "master" else "1.57.0"
    version_tag = args.tag if not args.no_publish else "disabled"
    examples_version_tag = args.tag if  args.publish_examples and not args.no_publish else "disabled"
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

    packages = {"biicode/boost"             : (version_tag,          [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION"]), ("setup.cmake", ["BIICODE_BOOST_VERSION"])]),
                "manu343726/math"           : (examples_version_tag, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "manu343726/boost-lib"      : (examples_version_tag, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "manu343726/boost-main"     : (examples_version_tag, [("biicode.conf", ["LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "examples/boost-log"        : (examples_version_tag, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "examples/boost-coroutine"  : (examples_version_tag, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "examples/boost-filesystem" : (examples_version_tag, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "examples/boost-flyweight"  : (examples_version_tag, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "examples/boost-multiindex" : (examples_version_tag, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "examples/boost-phoenix"    : (examples_version_tag, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "examples/boost-signals"    : (examples_version_tag, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])])}

    #Boost.Log takes so much time to compile, leads to timeouts on Travis CI
    #It was tested on Windows and linux, works 'ok' (Be careful with linking settings)
    if args.ci: del packages['examples/boost-log']  

    if args.exclude:
        for block in args.exclude.split(' '):
            del packages[block]
    

    return utils.GenerationSettings(packages, variables, passwords)

if __name__ == '__main__':
    print(settings())
