from setuptools import setup

setup(
    # Package metadata.
    author='Rally Health',
    description='Pre-Commit hooks for Rally.',
    name='rally_pre_commit',
    packages=['pre_commit_hooks'],
    platforms='linux',
    url='https://github.com/AudaxHealthInc/pre-commit-hooks',
    classifiers=[
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: Implementation :: CPython',
        'Programming Language :: Python :: Implementation :: PyPy',
    ],

    # Require modern versions of Python.
    python_requires='>=3.6',

    # Package dependencies.
    install_requires=['argparse', 'pyhocon'],

    # These are the entry points for the various Python based pre-commit
    # hooks defined in this repo. The format is:
    # <cmd> = pre_commit_hooks.<filename>:<function>
    entry_points={
        'console_scripts': [
            'csv-formatter = pre_commit_hooks.csv_formatter:csv_formatter',
            'scalafmt = pre_commit_hooks.scalafmt:scalafmt'
        ],
    },

    # If static data into this repo is necessary for hook operation, add it
    # here. Globbing is supported.
    package_data={
        '': [
            'scalafmt/conf/*',
            'scalafmt/scalafmt-*'
            ]
        }
)
