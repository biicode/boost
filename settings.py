#
# Biicode Boost blocks templates settings for block generation.
#

import os, urllib, json, sys, ast

class BiiBoostCorruptSettingsError(Exception):
	pass

class BiiBoostSettings:
	def __init__(self, packages, variables, passwords):
		self.__packages = packages
		self.__variables = variables
		self.__passwords = passwords

		self.__check()

	def __checkEntry(self, block, file, variable):
		blockPath = os.path.join(os.path.dirname(os.path.abspath(__file__)), "blocktemplates", block)
		filePath = os.path.join(blockPath, file)
		tag = "<" + variable + ">"

		if os.path.isdir(blockPath):
			if os.path.exists(filePath):
				with open(filePath, 'r') as f:
					for line in f:
						if tag in line:
							return

				raise BiiBoostCorruptSettingsError("No '<" + variable + ">' tag found on " + block + "/" + file)
			else:
				raise BiiBoostCorruptSettingsError("No '" + file + "' file inside " + block + " block")
		else:
			raise BiiBoostCorruptSettingsError("No '" + block + "' block in blocks directory")

	def __check(self):
		for block, (publish, replaces) in self.__packages.iteritems():
			for file, variable in replaces:
				if variable in self.__variables:
					self.__checkEntry(block, file, variable)
				else:
					raise BiiBoostCorruptSettingsError("No variable corresponding to '<" + variable + ">' tag found in '" + block + "/" + file + "'")

	def packages(self):
		return self.__packages

	def variables(self):
		return self.__variables

	def passwords(self):
		return self.__passwords

def latest_block_version(block, track):
	user = block.split("/")[0]
	url = "https://webapi.biicode.com/v1/blocks/" + user + "/" + block + "/" + track

	try:
		data = json.loads(urllib.urlopen(url).read())
		version = str(data["version"])
	except ValueError:
		version = "-1"

	print "Found " + block + ":" + version

	return version


def settings():
	track = sys.argv[2]

	if track != "master":
		boost_version = track
	else:
		boost_version = "1.57.0"

	publish = (track == "master")

	variables = {"BIICODE_BOOST_VERSION" : lambda block, block_track, file: boost_version,
	       	     "WORKING_TRACK"         : lambda block, block_track, file: track,
	             "BIICODE_BOOST_BLOCK"   : lambda block, block_track, file: "biicode/boost(" + track + ")",
	             "LATEST_BLOCK_VERSION"  : lambda block, block_track, file: latest_block_version(block, block_track)}

	packages = { "biicode/boost"             : (True,    [("biicode.conf", "BIICODE_BOOST_BLOCK"), ("biicode.conf", "LATEST_BLOCK_VERSION"), ("setup.cmake", "BIICODE_BOOST_VERSION")]),
		     "manu343726/math"           : (publish, [("biicode.conf", "BIICODE_BOOST_BLOCK"), ("biicode.conf", "LATEST_BLOCK_VERSION"), ("biicode.conf", "BIICODE_BOOST_VERSION")]),
	             "manu343726/boost-lib"      : (publish, [("biicode.conf", "BIICODE_BOOST_BLOCK"), ("biicode.conf", "LATEST_BLOCK_VERSION"), ("biicode.conf", "BIICODE_BOOST_VERSION")]),
	             "manu343726/boost-main"     : (publish, [                                         ("biicode.conf", "LATEST_BLOCK_VERSION"), ("biicode.conf", "BIICODE_BOOST_VERSION")]),
	             "examples/boost-coroutine"  : (publish, [("biicode.conf", "BIICODE_BOOST_BLOCK"), ("biicode.conf", "LATEST_BLOCK_VERSION"), ("biicode.conf", "BIICODE_BOOST_VERSION")]),
	             "examples/boost-filesystem" : (publish, [("biicode.conf", "BIICODE_BOOST_BLOCK"), ("biicode.conf", "LATEST_BLOCK_VERSION"), ("biicode.conf", "BIICODE_BOOST_VERSION")]),
	             "examples/boost-flyweight"  : (publish, [("biicode.conf", "BIICODE_BOOST_BLOCK"), ("biicode.conf", "LATEST_BLOCK_VERSION"), ("biicode.conf", "BIICODE_BOOST_VERSION")]),
	             "examples/boost-multiindex" : (publish, [("biicode.conf", "BIICODE_BOOST_BLOCK"), ("biicode.conf", "LATEST_BLOCK_VERSION"), ("biicode.conf", "BIICODE_BOOST_VERSION")]),
	             "examples/boost-phoenix"    : (publish, [("biicode.conf", "BIICODE_BOOST_BLOCK"), ("biicode.conf", "LATEST_BLOCK_VERSION"), ("biicode.conf", "BIICODE_BOOST_VERSION")]),
	             "examples/boost-signals"    : (publish, [("biicode.conf", "BIICODE_BOOST_BLOCK"), ("biicode.conf", "LATEST_BLOCK_VERSION"), ("biicode.conf", "BIICODE_BOOST_VERSION")]) }

        passwords = ast.literal_eval(sys.argv[1].replace('->', ':'))
	
	return BiiBoostSettings(packages, variables, passwords)

if __name__ == '__main__': 
    print(settings())
