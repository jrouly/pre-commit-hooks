import logging
import os
from logging import Formatter
from logging import StreamHandler
from logging.handlers import RotatingFileHandler

# Set up logging for any Python language pre-commit hooks.

# Root logger.
logger = logging.getLogger()

# Console handler.
# INFO and above will go to console whenever the hook fails.
console_handler = StreamHandler()
console_handler.setLevel(logging.INFO)
console_handler.setFormatter(Formatter('[%(levelname)s] %(message)s'))

# Log file handler.
# DEBUG and above will go to a rotating file in /tmp.
log_file = os.path.join('/tmp', 'pre-commit-hooks.log')
log_file_handler = RotatingFileHandler(
    log_file,
    mode='a',
    maxBytes=5*1024*1024,
    backupCount=2,
    encoding='utf-8',
    delay=0)
log_file_handler.setLevel(logging.DEBUG)
log_file_handler.setFormatter(
    Formatter('%(asctime)s - %(name)s - [%(levelname)s] %(message)s'))

# Configure the root logger.
logger.addHandler(log_file_handler)
logger.addHandler(console_handler)
logger.setLevel(logging.DEBUG)


def pre_commit_hook_logger(hook_name):
    """ Return a logger named using the repository and hook. """
    repo_name = os.path.basename(os.getcwd())
    logger_name = f'{repo_name} - {hook_name}'
    return logging.getLogger(logger_name)
