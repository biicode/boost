import settings
import sys, subprocess, os

class generator:
    """ Generates the Boost blocks (biicode/boost, examples, etc) from the Boost version settings and templates"""

    def __init__(self):
        __settings = settings.settings()
        self.packages = __settings.packages()
        self.variables = __settings.variables()
        self.passwords = __settings.passwords()
        self.projectDir = os.path.dirname(os.path.abspath(__file__))

        self.blocks_directory = os.path.join(os.path.dirname(os.path.abspath(__file__)), "blocks")
        self.templates_directory = os.path.join(os.path.dirname(os.path.abspath(__file__)), "blocktemplates")


    def settingToTag(self,setting):
        """Returns the file template tag corresponding to a specific setting"""

        return '<' + setting.upper() + '>'

    def replace(self,template, block, track, file):
        """Replaces the tags on the file template with the settings"""

        for variable, value in self.variables.iteritems():
            if self.settingToTag(variable) in template:
                template = template.replace( self.settingToTag(variable) , value(block, track, file) )

        return template

    def boostVersion(self):
        return self.variables["BIICODE_BOOST_VERSION"](None,None,None)

    def workingTrack(self):
        return self.variables["WORKING_TRACK"](None,None,None)

    def execute(self):
        from shutil import copytree, rmtree, ignore_patterns

        for block, (publish_block, entry) in sorted(self.packages.iteritems()):
            print "Processing " + block
            print "="*30

            template_files = [x[0] for x in entry]

            #Copy block contents except templates to blocks/block

            rmtree(os.path.join(self.blocks_directory, block), ignore_errors=True)
            copytree(os.path.join(self.templates_directory, block), os.path.join(self.blocks_directory, block), ignore_patterns(template_files))

            for template, _ in entry:
                print " - " + template

                ifile = open(os.path.join(self.templates_directory, block, template), 'r')
                ofile = open(os.path.join(self.blocks_directory, block, template), 'w')

                ofile.write(self.replace(ifile.read(), block, self.workingTrack(), template))

                ifile.close()
                ofile.close()

            if publish_block:
                print "Publishing '" + block + "'"

                user = block.split('/')[0]

                login = subprocess.Popen(['bii', 'user', '-p', self.passwords[user], user], cwd=self.projectDir)
                login.wait()

                out, _ = subprocess.Popen(['bii', 'user'], cwd=self.projectDir, stdout=subprocess.PIPE).communicate()
                if not user in out:
                    raise RuntimeError("Failed logging in as '" + user + "'. bii user output: \"" + out + "\"")

                publish = subprocess.Popen(['bii', 'publish', block], cwd=self.projectDir)
                publish.wait()


def run():
    try:
        #Ok Diego, here's your login
        login = subprocess.Popen(['bii', 'user', "manu343726"], cwd=os.path.dirname(os.path.abspath(__file__)))
        login.wait()

        generator().execute()
    except Exception as e:
        print "ERROR: ", str(e)

if __name__ == '__main__': 
    run()
