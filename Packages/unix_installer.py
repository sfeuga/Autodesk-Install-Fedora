import subprocess, zipfile, shutil
import os, sys, platform
import glob

silent = False;

installMode = 1
isRoot = False
inp = ''

def InstallerHeader():
        os.system('clear')
        print('   --== Maya to Arnold Installer ==--    ')


if len(sys.argv) > 3 and "silent" == sys.argv[3]:
    silent = True

if not silent:

    if platform.system().lower() != sys.argv[2]:
        print('''
        Installer incompatible with your operating system.
        Your system is %s , while the installer has been built
        for %s .
            ''' % (platform.system().lower(), sys.argv[2]))
        sys.exit(0)

    try: input = raw_input
    except NameError: pass

    subprocess.call(['less', '-e', os.path.abspath('MtoAEULA.txt')])

    InstallerHeader()
    print('''
        Please type accept and press enter to agree to the terms and conditions,
        or press enter to exit.
          ''')
    inp = input('    ').replace(' ', '').lower()

    if inp != 'accept':
        sys.exit(0)

    InstallerHeader()
    print('''
        Installation modes:
            1) Automatic (set up Maya module and arnoldRenderer.xml)
            2) Extract the package
          ''')
    inp = input('    Please select mode [1] : ')
    inp = inp.replace(' ', '')



if inp == '2':
    installMode = 2
else:
    # Check for being the root user
    try:
        p = subprocess.Popen('whoami', stdout=subprocess.PIPE)
        whoami, err = p.communicate()
        if whoami.find(b'root') != 0:
            if not silent:
                print('Root privileges are required to configure MtoA for Maya.')
            sys.exit(0)
        isRoot = True
    except:
        sys.exit(0)

installDir = ''

mayaVersionDir = ''

if sys.argv[1] == '2015':
    mayaVersionDir = '%s-x64' % sys.argv[1]
else:
    mayaVersionDir = sys.argv[1]

mayaVersion = ''
if sys.argv[1] != '20135':
    mayaVersion = sys.argv[1]
else:
    mayaVersion = '2013.5'

userString = '~'
sudoUser = ''

if isRoot:
    try:
        sudoUser = os.environ['SUDO_USER']
        userString = '~%s' % sudoUser
    except:
        userString = '~'
        sudoUser = 'root'

def EnsureDir(d):
    try:
        dirlist = d.split('/')
        dr = '/'
        for dd in dirlist:
            dr = os.path.join(dr, dd)
            if not os.path.exists(dr):
                os.makedirs(dr)
                try:
                    subprocess.call(['chown', sudoUser, dr])
                except:
                    pass
        return True
    except:
        return False

if silent:
    installDir = os.path.join('/usr', 'autodesk', 'arnold', 'maya{}'.format(mayaVersion))
    if not EnsureDir(installDir):
        sys.exit(0)
else:
    while True:
        InstallerHeader()
        installDir = os.path.join('/usr', 'autodesk', 'arnold', 'maya{}'.format(mayaVersion))
        print('''
        Select the installation directory.
        [%s]
              ''' % installDir)
        inp = input('    ').lstrip()
        if inp != '':
            installDir = inp
        if not EnsureDir(installDir):
            InstallerHeader()
            print('''
        Cannot create target directory.
        Do you want to install to a different directory?
        [yes / no]
                  ''')
            inp = input('    ').replace(' ', '').lower()
            if inp != 'yes':
                sys.exit(0)
        else:
            break

# http://stackoverflow.com/questions/7806563/how-to-unzip-a-file-with-python-2-4

def unzip(zipFilePath, destDir):
    zfile = zipfile.ZipFile(zipFilePath)
    for name in zfile.namelist():
        (dirName, fileName) = os.path.split(name)
        # Check if the directory exisits
        if dirName == '.':
            dirName = ''
        newDir = os.path.join(destDir, dirName)
        if not EnsureDir(newDir):
            continue
        if not fileName == '':
            # file
            fd = open(destDir + '/' + name, 'wb')
            fd.write(zfile.read(name))
            fd.close()
    zfile.close()


# delete previous files (#3040)
# Note that I'm leaving the AE scripts + NE templates for now.
# The list would be quite long, and to my knowledge it's harmless
# to keep eventually these deprecated scripts

previousFiles = [
'docs',
'extensions/bifrostTranslator.py',
'extensions/gpuCacheTranslator.py',
'extensions/gpuCacheTranslator.so',
'extensions/xgenArnoldUI.py',
'extensions/bifrostTranslator.so',
'extensions/xgenArnoldUI_res.py',
'extensions/hairPhysicalShaderTranslator.py',
'extensions/xgenSplineTranslator.py',
'extensions/xgenSplineTranslator.so',
'extensions/hairPhysicalShaderTranslator.so',
'extensions/xgenTranslator.py',
'extensions/xgenTranslator.so',
'extensions/lookdevkit.so',
'extensions/renderSetup.so',
'extensions/synColorTranslator.so',
'icons',
'include',
'bin/kick',
'bin/noice',
'bin/libmtoa_api.so',
'bin/libsynColor.so.2017.0.69',
'bin/libsynColor.so.2017.0.68',
'bin/libsynColor.so.2018.0.80',
'bin/libOpenColorIO.so',
'bin/libOpenColorIO.so.1',
'bin/libOpenColorIO.so.1.0.9',
'bin/libAdClmHub.so',
'bin/maketx',
'bin/libadlmint.so',
'bin/oslc',
'bin/libai_renderview.so',
'bin/oslinfo',
'bin/libai.so',
'bin/ProductInformation.pit',
'bin/lmutil',
'bin/rlmutil',
'bin/libAdClmHub.so',
'bin/libadlmint.so',
'bin/libai.so',
'bin/libcudart.so.9.0',
'bin/libcudnn.so.7',
'bin/liboptix_denoiser.so',
'bin/liboptix_denoiser.so.51',
'bin/liboptix.so.1',
'bin/liboptix.so.51',
'plug-ins/mtoa.mtd',
'plug-ins/mtoa.so',
'plugins/alembic_proc.so',
'plugins/synColor_shaders.so',
'procedurals/alembic_proc.so',
'procedurals/bifrost_procedural.so',
'procedurals/volume_openvdb.so',
'procedurals/bifrost_procedurals.so',
'procedurals/xgen_procedural.so',
'procedurals/mtoa_ParticleInstancer_proc.so',
'procedurals/xgenSpline_procedural.so',
'procedurals/mtoa_ParticleVolume_proc.so',
'presets',
'RSTemplates',
'scripts/arnold',
'scripts/pykick',
'scripts/mtoa/2015',
'scripts/mtoa/2016',
'scripts/mtoa/2017',
'scripts/mtoa/2018',
'scripts/mtoa/2019',
'scripts/mtoa/2020',
'scripts/mtoa/api',
'scripts/mtoa/aov.py',
'scripts/mtoa/core.py',
'scripts/mtoa/hooks.py',
'scripts/mtoa/callbacks.py',
'scripts/mtoa/lightFilters.py',
'scripts/mtoa/__init__.py',
'scripts/mtoa/makeTx.py',
'scripts/mtoa/renderToTexture.py',
'scripts/mtoa/txManager.py',
'scripts/mtoa/utils.py',
'scripts/mtoa/volume_vdb.py',
'scripts/mtoa/cmds',
'scripts/mtoa/mel',
'scripts/mtoa/ui/aoveditor.py',
'scripts/mtoa/ui/arnoldmenu.py',
'scripts/mtoa/ui/exportass.py',
'scripts/mtoa/ui/nodeTreeLister.py',
'scripts/mtoa/ui/globals',
'vp2',
'shaders/bifrost_procedurals.so',
'shaders/mtoa_shaders.so',
'shaders/bifrost_shaders.so',
'shaders/renderSetup_shaders.so',
'shaders/hairPhysicalShader_shaders.so',
'shaders/synColor_shaders.so',
'shaders/lookdevkit_shaders.so',
'shaders/xgen_procedural.so',
'shaders/mtoa_ParticleInstancer_proc.so',
'shaders/xgenSpline_procedural.so',
'shaders/mtoa_shaders.mtd',
'shaders/xgenSpline_shaders.so',
'osl/oslutil.h',
'osl/stdosl.h',
'osl/include/oslutil.h',
'osl/include/stdosl.h'
]

for previousFile in previousFiles:
    prevFile = os.path.join(installDir,previousFile)
    if not os.path.exists(prevFile):
        continue

    if os.path.isdir(prevFile):
        shutil.rmtree(prevFile)
    else:
        os.remove(prevFile)


try:
    #zipfile.ZipFile(os.path.abspath('package.zip'), 'r').extractall(installDir)
    unzip(os.path.abspath('package.zip'), installDir)
except:
    if not silent:
        print('Error extracting the contents of the package.')
    sys.exit(0)

# regenerating the module file
mtoaModPath = os.path.join(installDir, 'mtoa.mod')
mtoaMod = open(mtoaModPath, 'w')
mtoaMod.write('+ mtoa any %s\n' % installDir)
mtoaMod.write('PATH +:= bin\n')
mtoaMod.write('MAYA_CUSTOM_TEMPLATE_PATH +:= scripts/mtoa/ui/templates\n')
mtoaMod.write('MAYA_SCRIPT_PATH +:= scripts/mtoa/mel\n')
mtoaMod.write('MAYA_RENDER_DESC_PATH += %s\n' % installDir)
mtoaMod.close()

# setting up executables properly
exList = [os.path.join('bin', 'kick'), os.path.join('bin', 'maketx'), os.path.join('bin', 'noice'), os.path.join('bin', 'oslc'), os.path.join('bin', 'oslinfo'), os.path.join('bin', 'lmutil'), os.path.join('bin', 'rlmutil'), os.path.join('bin', 'ArnoldLicenseManager'), os.path.join('license', 'pitreg'), os.path.join('license', 'ArnoldLicensing-8.1.0.1084_RC6-linux.run')]
for ex in exList:
    if os.path.exists(os.path.join(installDir, ex)):
        try:
            subprocess.call(['chmod', '+x', os.path.join(installDir, ex)])
        except:
            if not silent:
                print('Error adding +x to executable %s' % ex)
            sys.exit(0)

licInstallerFiles = glob.glob(os.path.join(installDir, 'license', 'installer', '*'))
for licInstallerFile in licInstallerFiles:
    try:
        subprocess.call(['chmod', '+x', licInstallerFile])
    except:
        if not silent:
            print('Error adding +x to executable %s' % licInstallerFile)


# stop relying on pitreg
#subprocess.call(['chmod', '+x', os.path.join(installDir, 'pit', 'pitreg')])

if installMode == 1: # do the proper installation
    homeDir = os.path.expanduser(userString)
    mayaBaseDir = ''
    if sys.platform == 'darwin':
        mayaBaseDir = os.path.join(homeDir, 'Library', 'Preferences', 'Autodesk', 'maya%s' % mayaVersionDir)
    else:
        mayaBaseDir = os.path.join('/usr', 'autodesk', 'modules', 'maya', sys.argv[1])
    if not EnsureDir(mayaBaseDir):
        if not silent:
            os.system('clear')
            print('Home directory for Maya %s does not exists.' % mayaVersion)
        sys.exit(1)
    if sys.platform == 'darwin':
        modulesDir = os.path.join(mayaBaseDir, 'modules')
    else:
        modulesDir = mayaBaseDir
    if not EnsureDir(modulesDir):
        if not silent:
            os.system('clear')
            print('Modules directory for the current Maya version cannot be created.')
        sys.exit(1)
    shutil.copy(mtoaModPath, os.path.join(modulesDir, 'mtoa.mod'))
    try:
        subprocess.call(['chown', sudoUser, os.path.join(modulesDir, 'mtoa.mod')])
    except:
        pass
    # install the renderer description file in the maya dir
    mayaInstallDir = ''
    if sys.platform == 'darwin':
        mayaInstallDir = os.path.join('/Applications', 'autodesk', 'maya%s' % mayaVersionDir)
    else:
        mayaInstallDir = os.path.join('/usr', 'autodesk', 'maya%s' % mayaVersionDir)
    if not os.path.exists(mayaInstallDir):
        if not silent:
            print('''
        Please specify maya installation directory
        for version %s :
            ''' % mayaVersion)
            mayaInstallDir = input('    ')
    if sys.platform == 'darwin':
        renderDescFolder = os.path.join(mayaInstallDir, 'Maya.app', 'Contents', 'bin', 'rendererDesc')
    else:
        renderDescFolder = os.path.join(mayaInstallDir, 'bin', 'rendererDesc')

    if sys.argv[1] == '2017':
        shutil.copy(os.path.join(installDir, 'arnoldRenderer.xml'), os.path.join(renderDescFolder, 'arnoldRenderer.xml'))

    homeDir = os.path.expanduser(userString)
    templatesDir = os.path.join(homeDir, 'maya', 'RSTemplates')
    if EnsureDir(templatesDir):
        shutil.copy(os.path.join(installDir, 'RSTemplates', 'MatteOverride-Arnold.json'), os.path.join(homeDir, 'maya', 'RSTemplates', 'MatteOverride-Arnold.json'))
        shutil.copy(os.path.join(installDir, 'RSTemplates', 'RenderLayerExample-Arnold.json'), os.path.join(homeDir, 'maya', 'RSTemplates', 'RenderLayerExample-Arnold.json'))



    print ("Installing CLM Licensing Components....")
    if os.path.exists(os.path.join(installDir, 'license', 'ArnoldLicensing-8.1.0.1084_RC6-linux.run')):
        os.system(os.path.join(installDir, 'license', 'ArnoldLicensing-8.1.0.1084_RC6-linux.run --silent')) # register pit file
    elif os.path.exists(os.path.join(installDir, 'license', 'pitreg')):
        pitreg_result = os.system(os.path.join(installDir, 'license', 'pitreg'))
        if int(pitreg_result) > 0:
            os.system('clear')

            pitreg_msg = "Error %s" % pitreg_result
            if int(pitreg_result) == 2:
                pitreg_msg = "File could not be opened"
            elif int(pitreg_result) == 24:
                pitreg_msg = "File not found"
            elif int(pitreg_result) == 25:
                pitreg_msg = "Error while parsing .pit file"
            elif int(pitreg_result) == 27:
                pitreg_msg = "Invalid .pit file"
            elif int(pitreg_result) == 32:
                pitreg_msg = "Unable to set write access for all user in Linux and MAC"

            pitreg_msg = "Couldn't register Arnold renderer in Maya PIT file (%s). Please contact support@arnoldrenderer.com" % pitreg_msg
            os.system('clear')
            print(pitreg_msg)
            sys.exit(1)

if not silent:
    os.system('clear')
    print('Installation successful!')
