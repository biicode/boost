#print bii

import os
import subprocess
import platform

install_folder = os.path.join(bii.environment_folder, "boost/1.57.0/")
install_flag = os.path.join(install_folder, "biinstalled.bii")
extract_folder = os.path.join(install_folder, "")
extracted_sources_location = os.path.join(extract_folder, "boost_1_57_0")   
sources_location = os.path.join(install_folder, "sources")
build_location = os.path.join(install_folder, "lib")

link="shared"
compiler = "gcc"
build_disabled = False

def extract_zip(file, to):
    import zipfile

    with zipfile.ZipFile(file, "r") as zip:
        zip.extractall(to)

def extract_tar(file, to):
    os.system('tar -xzf %s -C %s' % (file, to))

def setup_and_download(url, filepath):
    if not os.path.exists(filepath):
        bii.out.info("Downloading boost...")
        bii.download(url, filepath)

    if not os.path.exists(install_folder):
        bii.out.info("Setting up boost installation") 
        os.makedirs(install_folder)
        os.makedirs(extracted_sources_location)

def extract(filepath):
    if platform.system() == "Windows":
        extract_zip(filepath, extract_folder)
    else:
        extract_tar(filepath, extract_folder)


def download_settings():
    if platform.system() == "Windows":
        filename = "boost_1_57_0.zip"
        url = "http://sourceforge.net/projects/boost/files/boost/1.57.0/boost_1_57_0.zip"

        return (filename, url, os.path.join(bii.environment_folder, filename))
    else:
        filename = "boost_1_57_0.tar.gz"
        url = "http://sourceforge.net/projects/boost/files/boost/1.57.0/boost_1_57_0.tar.gz"

        return (filename, url, os.path.join(bii.environment_folder, filename))

def install(filepath):
    bii.out.info("Installing Boost")
    bii.out.info(" - Extracting Boost...")
    extract(filepath)
    bii.out.info(" - Installing sources...")
    os.rename(extracted_sources_location, sources_location)

def build_setup():
    if platform.system() == "Windows":
        bootstrapper = 'bootstrap.bat'
        builder = 'b2.exe' 
    else:
        bootstrapper = 'bootstrap.sh'
        builder = 'b2'

    return os.path.join(sources_location, bootstrapper), os.path.join(sources_location, builder)

def build():
    bootstrapper, builder = build_setup()

    if not os.path.exists(builder):
        bii.out.info("Building Boost libraries:")

        bii.out.info(" - Bootstrapping...")
        proc = subprocess.Popen([bootstrapper,'--prefix=' + sources_location], cwd=sources_location)
        proc.wait()    

        bii.out.info(" - Building...")
        proc = subprocess.Popen([builder, '--includedir=' + sources_location], cwd=sources_location)
        proc.wait()
    else:
        bii.out.info("Boost already builded. Nothing to do here")    

def run():
    if os.path.exists(sources_location):
        bii.out.info(""">>> Boost already installed in your biicode environment!
          Nothing to do here.""")
    else:
        bii.out.info(""">>> We need to configure the Boost libraries.
          Please wait...""")
        
        file, url, filepath = download_settings()
        
        setup_and_download(url, filepath)
        install(filepath)
        
    if not build_disabled:
        build()

run()
