from __future__ import print_function

import argparse
import csv
import os
import sys
import codecs


def format_csv(file_obj, delimiter, quotechar, quoting):
    """
    Consistently apply quoting in a csv file.
    """
    possible_bom = file_obj.read(4)
    bom_offset = next((len(bom) for bom in [codecs.BOM_UTF8,
                                            codecs.BOM_UTF16_LE,
                                            codecs.BOM_UTF16_BE,
                                            codecs.BOM_UTF32_LE,
                                            codecs.BOM_UTF32_BE] if possible_bom.startswith(bom)), 0)
    file_obj.seek(bom_offset, 0)

    reader = csv.reader(
        file_obj,
        skipinitialspace=True,
        delimiter=delimiter,
        quotechar=quotechar
    )
    writer = csv.writer(
        file_obj,
        delimiter=delimiter,
        quotechar=quotechar,
        quoting=quoting,
        lineterminator=os.linesep
    )

    rows = [row for row in reader]
    file_obj.seek(0, 0)
    writer.writerows(rows)
    file_obj.truncate() # if the BOM got stripped there may be some characters left over in the file.
    return 0


def csv_formatter(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument('filenames', nargs='*', help='Filenames to quote')
    parser.add_argument('--delimiter', help='CSV delimiter', default=',')
    parser.add_argument('--quotechar', help='CSV quotechar', default='"')
    parser.add_argument(
        '--quoting', help='CSV quoting method', default=csv.QUOTE_ALL)
    args = parser.parse_args(argv)

    retv = 0

    for filename in args.filenames:
        with open(filename, 'rU+') as file_obj:
            ret_for_file = format_csv(
                file_obj, args.delimiter, args.quotechar, args.quoting)
            if ret_for_file:
                print('Quoting {0}'.format(filename))
            retv |= ret_for_file

    return retv


if __name__ == '__main__':
    sys.exit(csv_formatter())
