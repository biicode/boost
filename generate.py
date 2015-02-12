import settings
import sys

class generator:
	""" Generates the Boost blocks (biicode/boost, examples, etc) from the Boost version settings and templates"""

	def __init__(self):
		settings = settings.settings()
		self.packages = settings.packages()
		self.variables = settings.variables()

		self.blocks_directory = os.path.join(os.path.dirname(os.path.abspath(__file__)), "blocks")
		self.templates_directory = os.path.join(os.path.dirname(os.path.abspath(__file__)), "blocktemplates")


	def settingToTag(self,setting):
		"""Returns the file template tag corresponding to a specific setting"""

		return '<' + setting.upper() + '>' 


	def replace(self,template):
		"""Replaces the tags on the file template with the settings"""

		for variable, value in self.variables.iteritems():
			template = template.replace( self.settingToTag(variable) , value )

		return template


	def processFile(self,template_path,output_path):
		"""Generates a PKGBUILD from the specified template file and the current settings"""

		template_file = open(template_path, 'r')
		pkgbuild_file = open(output_path, 'w')

		template = template_file.read()
		output   = self.replace(template)
		pkgbuild_file.write(output)

		template_file.close()
		pkgbuild_file.close()

	def execute(self):
		from shutil import copytree, ignore_patterns

		for block, entry in self.packages.iteritems():
			template_files = [x[0] in for x in entry]

			#Copy block contents except templates to blocks/block
			copytree(os.path.join(self.templates_directory, block), os.path.join(self.blocks_directory, block), ignore_patterns(template_files))

			for templateFile, outputFile in [(os.path.join(self.templates_directory, block, x[0]),
			                                  os.path.join(self.blocks_directory, block, x[0])) in for x in entry

			ifile = open(templateFile, 'r')
			ofile = open(outputFile, 'w')

			ofile.write(self.replace(ifile.read()))

			ifile.close()
			ofile.close()


def run():
	generator().execute()

if __name__ == '__main__': 
	run()
