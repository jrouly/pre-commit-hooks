from setuptools import find_packages
from setuptools import setup

setup(
    name='pre_commit_hooks',
    description='Pre-Commit hooks.',
    author='jrouly',
    platforms='linux',
    classifiers=[
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.6',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10',
        'Programming Language :: Python :: 3.11',
        'Programming Language :: Python :: 3.12',
        'Programming Language :: Python :: Implementation :: CPython',
        'Programming Language :: Python :: Implementation :: PyPy',
    ],
    packages=find_packages('.'),
    install_requires=[
        'argparse'
    ],
    entry_points={
        'console_scripts': [
            'csv-formatter = pre_commit_hooks.csv_formatter:csv_formatter'
        ],
    },
)
