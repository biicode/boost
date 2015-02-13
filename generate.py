import settings
import sys
import subprocess
import os


class generator:
    """ Generates the Boost blocks (biicode/boost, examples, etc) from the
        Boost version settings and templates"""

    def __init__(self):
        __settings = settings.settings()
        self.packages = __settings.packages()
        self.variables = __settings.variables()
        self.passwords = __settings.passwords()
        self.projectDir = os.path.dirname(os.path.abspath(__file__))

        self.blocks_directory = os.path.join(os.path.dirname(os.path.abspath(__file__)), "blocks")
        self.templates_directory = os.path.join(os.path.dirname(os.path.abspath(__file__)), "blocktemplates")

    def setting_to_tag(self, setting):
        """Returns the file template tag corresponding to a specific setting"""

        return "<{0}>".format(setting.upper())

    def replace(self, template, block, track, file):
        """Replaces the tags on the file template with the settings"""

        for variable, value in self.variables.iteritems():
            if self.setting_to_tag(variable) in template:
                template = template.replace(self.setting_to_tag(variable),
                                            value(block, track, file))

        return template

    def boost_version(self):
        return self.variables["BIICODE_BOOST_VERSION"](None, None, None)

    def working_track(self):
        return self.variables["WORKING_TRACK"](None, None, None)

    def execute(self):
        from shutil import copytree, rmtree, ignore_patterns

        for block, (publish_block, entry) in sorted(self.packages.iteritems()):
            print "Processing " + block
            print "="*30

            template_files = [x[0] for x in entry]

            #Copy block contents except templates to blocks/block

            rmtree(os.path.join(self.blocks_directory, block), ignore_errors=True)
            copytree(os.path.join(self.templates_directory, block),
                     os.path.join(self.blocks_directory, block),
                     ignore_patterns(template_files))

            for template, _ in entry:
                print " - " + template

                ifile = open(os.path.join(self.templates_directory, block, template), 'r')
                ofile = open(os.path.join(self.blocks_directory, block, template), 'w')

                ofile.write(self.replace(ifile.read(),
                                         block,
                                         self.working_track(),
                                         template))

                ifile.close()
                ofile.close()

            if publish_block != "disabled":
                print "Publishing '{0}({1})'".format(block, self.working_track())

                user = block.split('/')[0]

                login = subprocess.Popen(['bii', 'user', '-p', self.passwords[user], user], cwd=self.projectDir)
                login.wait()

                out, _ = subprocess.Popen(['bii', 'user'], cwd=self.projectDir, stdout=subprocess.PIPE).communicate()
                if not user in out:
                    raise RuntimeError("Failed logging in as '" + user + "'. bii user output: \"" + out + "\"")

                publish = subprocess.Popen(['bii', 'publish', block, '--tag', publish_block], cwd=self.projectDir)
                publish.wait()


def run():
    #Ok Diego, here's your login
    login = subprocess.Popen(['bii', 'user', "manu343726"], cwd=os.path.dirname(os.path.abspath(__file__)))
    login.wait()

    generator().execute()

if __name__ == '__main__':
    run()
