#
# Biicode Boost blocks templates settings for block generation.
#

import os
import urllib
import json
import sys
import ast


class BiiBoostCorruptSettingsError(Exception):
    pass


class BiiBoostSettings:
    def __init__(self, packages, variables, passwords):
        self._packages = packages
        self._variables = variables
        self._passwords = passwords

        self._check()

    def _error(self, message):
        raise BiiBoostCorruptSettingsError(message)

    def _check_entry(self, block, file, variable):
        blockPath = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                 "blocktemplates", block)
        filePath = os.path.join(blockPath, file)
        tag = "<" + variable + ">"

        if os.path.isdir(blockPath):
            if os.path.exists(filePath):
                with open(filePath, 'r') as f:
                    for line in f:
                        if tag in line:
                            return

                self._error("No tag '{0}' found on '{1}/{2}'".format(tag, block, file))
            else:
                self._error("No '{0}' found inside '{1}' block".format(file, block))
        else:
            self._error("No '{0}' block found in block templates directory".format(block))

    def _check(self):
        for block, (publish, replaces) in self._packages.iteritems():
            for file, variables in replaces:
                for variable in variables:
                    if variable in self._variables:
                        self._check_entry(block, file, variable)
                    else:
                        self._error("No variable corresponding to '{0}' tag found in '{1}/{2}'".format(tag, block, file))

    def packages(self):
        return self._packages

    def variables(self):
        return self._variables

    def passwords(self):
        return self._passwords


def latest_block_version(block, track):
    user = block.split("/")[0]
    url = ("https://webapi.biicode.com/v1/blocks/{0}/{1}/{2}"
           .format(user, block, track))

    try:
        data = json.loads(urllib.urlopen(url).read())
        version = str(data["version"])
    except ValueError:
        version = "-1"

    print "Found " + block + ":" + version

    return version


def settings():
    track = sys.argv[2]
    boost_version = track if track != "master" else "1.57.0"
    version = "disabled"
    publish = version if track == "master" else "disabled"

    variables = {"BIICODE_BOOST_VERSION":
                 lambda block, block_track, file: boost_version,
                 "WORKING_TRACK":
                 lambda block, block_track, file: track,
                 "BIICODE_BOOST_BLOCK":
                 lambda block, block_track, file: "biicode/boost({0})"
                                                  .format(block_track),
                 "LATEST_BLOCK_VERSION":
                 lambda block, block_track, file: latest_block_version(block, block_track)}

    packages = {"biicode/boost"             : (version, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION"]), ("setup.cmake", ["BIICODE_BOOST_VERSION"])]),
                "manu343726/math"           : (publish, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "manu343726/boost-lib"      : (publish, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "manu343726/boost-main"     : (publish, [("biicode.conf", ["LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "examples/boost-coroutine"  : (publish, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "examples/boost-filesystem" : (publish, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "examples/boost-flyweight"  : (publish, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "examples/boost-log"        : (publish, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "examples/boost-multiindex" : (publish, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "examples/boost-phoenix"    : (publish, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])]),
                "examples/boost-signals"    : (publish, [("biicode.conf", ["BIICODE_BOOST_BLOCK", "LATEST_BLOCK_VERSION", "WORKING_TRACK"])])}

    passwords = ast.literal_eval(sys.argv[1].replace('->', ':'))

    return BiiBoostSettings(packages, variables, passwords)

if __name__ == '__main__':
    print(settings())
