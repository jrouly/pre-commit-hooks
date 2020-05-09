#!/usr/bin/env python3

import logging
import os
import sys


# Configure logging to write to a backup file.
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
    datefmt='%m-%d %H:%M',
    filename=os.path.join('/tmp', 'scalafmt.log'),
    filemode='a')

logger = logging.getLogger('scalafmt')

console = logging.StreamHandler()
console.setLevel(logging.INFO)
formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
console.setFormatter(formatter)
logger.addHandler(console)


# Constants.
# Check scalafmt/README.md before modifying scalafmt version.
default_scalafmt_version = '2.0.0'
# Expected scalafmt configuration file name.
default_scalafmt_conf = '.scalafmt.conf'
default_conf = 'default'  # Default configuration file name.

# Derived filepath constants.
pre_commit_hooks_dir = os.path.dirname(os.path.realpath(__file__))
scalafmt_dir = os.path.join(pre_commit_hooks_dir, 'scalafmt')
scalafmt_conf_dir = os.path.join(scalafmt_dir, 'conf')


def scalafmt_kernel():
    """ Is this script running on Linux or MacOS? """
    import platform
    if platform.system() == 'Darwin':
        return 'scalafmt-macos'
    else:
        return 'scalafmt-linux'


def get_conf_path(conf_name):
    """ Verify that the requested configuration exists and return its file
    path. """

    conf_file = conf_name + '.conf'
    conf_path = os.path.join(scalafmt_conf_dir, conf_file)

    if not os.path.exists(conf_path):
        logger.error(f'Configuration file {conf_file} not recognized.')
        return None
    else:
        logger.debug(f'Found {conf_file} at {conf_path}')
        return conf_path


def generate_conf(conf_path, copy_conf, generated_conf_name):
    """ Generate a conf file for consumption by scalafmt, named
    {generated_conf_name}. If copy_conf is true, copy the generated file
    into the repo directory. Otherwise copy it into the pre-commit cache. """

    target_dir = os.getcwd() if copy_conf else pre_commit_hooks_dir
    target_path = os.path.join(target_dir, generated_conf_name)

    if os.path.exists(target_path):
        logger.debug(f'Callously overwriting existing config: {target_path}')

    with open(target_path, 'w') as outfile:
        preamble = \
            '# DO NOT MODIFY THIS FILE\n' \
            '# It was automatically generated using pre-commit hooks.\n' \
            '# Any manual changes to this file will be overwritten.\n'
        outfile.write(preamble)

        # This is really where the magic happens.
        # Because scalafmt HOCON files support including arbitrary other
        # HOCON files, we need a fairly robust parser. This pyhocon parser
        # will resolve any 'include' statements as relative paths from the
        # directory in which the config file resides. It then reads the
        # entire configuration block into memory as {conf}. We can write
        # this _back_ out to a .conf file anywhere we like.
        from pyhocon import ConfigFactory
        from pyhocon.tool import HOCONConverter

        conf = ConfigFactory.parse_file(conf_path)
        outfile.write(HOCONConverter.convert(conf, 'hocon'))

    return target_path


def download_file(url, filename):
    """ Stream a large file to disk.
    https://stackoverflow.com/a/16696317/5494389 """

    import requests
    with requests.get(url, stream=True) as r:
        r.raise_for_status()
        with open(filename, 'wb') as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)


def download_scalafmt(scalafmt_version):
    """ Download a version of scalafmt-native and place it in the
    {scalafmt_dir}. """

    kernel = scalafmt_kernel()
    url = 'https://github.com/scalameta/scalafmt/releases/download' \
        f'/v{scalafmt_version}/{kernel}.zip'

    filename = f'{kernel}-{scalafmt_version}'
    target_path = os.path.join(scalafmt_dir, filename)

    import tempfile
    with tempfile.TemporaryDirectory() as temp_dir:
        # Download the binary into a temporary path to unzip it.
        download_path = os.path.join(temp_dir, 'scalafmt.zip')
        download_file(url, download_path)

        # Extract the 'scalafmt' member to {temp_dir}.
        import zipfile
        with zipfile.ZipFile(download_path, 'r') as archive:
            archive.extract('scalafmt', temp_dir)

        # Move the unzipped binary to its target destination.
        unzipped_binary_path = os.path.join(temp_dir, 'scalafmt')
        os.rename(unzipped_binary_path, target_path)

        # Set the execute permission bit on the binary.
        import stat
        os.chmod(target_path, stat.S_IEXEC)

    return target_path


def get_scalafmt_binary_path(scalafmt_version):
    """ Checks that the required scalafmt native image exists.
    If it doesn't, download the binary from github.
    """

    scalafmt_bin_filename = scalafmt_kernel() + '-' + scalafmt_version
    scalafmt_bin_path = os.path.join(scalafmt_dir, scalafmt_bin_filename)

    if os.path.exists(scalafmt_bin_path):
        logger.debug(f'Using existing scalafmt binary: {scalafmt_bin_path}')
        return scalafmt_bin_path
    else:
        return download_scalafmt(scalafmt_version)


def run_scalafmt(conf_path, scalafmt_version, filenames):
    """ Run scalafmt with the given parameters. """

    scalafmt_bin_path = get_scalafmt_binary_path(scalafmt_version)
    if not scalafmt_bin_path:
        raise Exception(f'Could not locate a scalafmt binary!')

    import subprocess
    args = [scalafmt_bin_path, '--non-interactive',
            '-c', conf_path, '-i', '-f'] + filenames
    popen = subprocess.Popen(args, stdout=subprocess.PIPE)
    returncode = popen.wait()
    output = popen.stdout.read()

    logger.debug(' '.join(args))
    logger.info(output.decode("utf-8"))
    return returncode


def cli_parser():
    """ Set up and return a CLI argument parser. """

    import argparse
    parser = argparse.ArgumentParser(description='scalafmt pre-commit hook')

    parser.add_argument(
        '--conf-name',
        help='configuration file to use',
        default=default_conf)

    parser.add_argument(
        '--no-copy-conf',
        help='do not copy .scalafmt.conf into the app directory',
        action='store_false',
        default='true',
        dest='copy_conf')

    parser.add_argument(
        '--scalafmt-version',
        help='scalafmt native version to use',
        default=default_scalafmt_version)

    parser.add_argument(
        '--generated-conf-name',
        help='name of the output scalafmt config file',
        default=default_scalafmt_conf)

    parser.add_argument(
        'filenames',
        help='filename to execute scalafmt on',
        nargs='+')

    return parser


def scalafmt():
    """ Entry point. """
    if sys.version_info[0] < 3:
        print('Refusing to run on anything lower than Python 3.')
        sys.exit(1)

    parser = cli_parser()
    args = parser.parse_args()

    # Get the path to the conf file from pre_commit_hooks.
    conf_path = get_conf_path(args.conf_name)
    if not conf_path:
        return 1

    # Get the path to the generated conf file.
    conf_path = generate_conf(
        conf_path,
        args.copy_conf,
        args.generated_conf_name)

    return run_scalafmt(
        conf_path,
        args.scalafmt_version,
        args.filenames)


if __name__ == '__main__':
    sys.exit(scalafmt())
