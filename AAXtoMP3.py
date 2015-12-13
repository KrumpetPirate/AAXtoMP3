#!/usr/bin/python3
import sys
import getopt
import shutil

def usage():
    print('Usage: '+sys.argv[0]+' -a <AMAZON AUTH STRING> -f <AAX FILE>')

def main(argv):
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'a:f:h', ['auth=', 'file=', 'help'])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage()
            sys.exit(2)
        elif opt in ('-a', '--auth'):
            auth_string = arg
        elif opt in ('-f', '--file'):
            input_file = arg
        else:
            usage()
            sys.exit(2)
    if not auth_string:
        usage()
        sys.exit(2)
    if not input_file:
        usage()
        sys.exit(2)
    print(auth_string)
    print(input_file)

if __name__ == "__main__":
    main(sys.argv[1:])
