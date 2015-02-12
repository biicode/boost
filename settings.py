#
# Biicode Boost blocks templates settings for block generation.
#

class BiiBoostCorruptSettingsError(Exception):
	pass

class BiiBoostSettings:
	def __init__(self, packages, variables):
		self.__packages = packages
		self.__variables = variables

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

				raise BiiBoostCorruptSettingsError("No '<" + variable + ">' tag found on " + file)
			else:
				raise BiiBoostCorruptSettingsError("No '" + file + "' file inside " + block + " block")
		else:
			raise BiiBoostCorruptSettingsError("No '" + block + "' block in blocks directory")

	def __check(self):
		for block, replaces in self.__packages.iteritems():
			for file, variable in replaces:
				if variable in self.__variables:
					self.__checkEntry(block, file, variable)
				else:
					raise BiiBoostCorruptSettingsError("No variable corresponding to '<" + variable + ">' tag")

	def packages(self):
		return self.__packages

	def variables(self):
		return self.__variables

		

def settings():
	variables = {"BIICODE_BOOST_VERSION" : "1.57.0",
	             "BIICODE_BOOST_BLOCK"   : "biicode/boost(1.57.0)"}

	packages = { "biicode/boost"             : [("biicode.conf", "BIICODE_BOOST_BLOCK"), ("CMakeLists.txt", "BIICODE_BOOST_VERSION")],
			     "manu343726/math"           : [("biicode.conf", "BIICODE_BOOST_BLOCK")],
	             "david/boost_lib"           : [("biicode.conf", "BIICODE_BOOST_BLOCK")],
	             "examples/boost-coroutine"  : [("biicode.conf", "BIICODE_BOOST_BLOCK")],
	             "examples/boost-filesystem" : [("biicode.conf", "BIICODE_BOOST_BLOCK")],
	             "examples/boost-flyweight"  : [("biicode.conf", "BIICODE_BOOST_BLOCK")],
	             "examples/boost-multiindex" : [("biicode.conf", "BIICODE_BOOST_BLOCK")],
	             "examples/boost-phoenix"    : [("biicode.conf", "BIICODE_BOOST_BLOCK")],
	             "examples/boost-signals"    : [("biicode.conf", "BIICODE_BOOST_BLOCK")] }
	
	return BiiBoostSettings(packages, variables)

if __name__ == '__main__': 
    print(settings())
