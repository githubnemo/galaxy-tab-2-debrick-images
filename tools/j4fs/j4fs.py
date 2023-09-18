#!/usr/bin/python3
import argparse, struct, sys, os

J4FS_MAX_FILE_NUM = 256

S_INODE = '8I128s'
S_MST = f'5I{J4FS_MAX_FILE_NUM}I3I'

J4FS_MAGIC = 0x87654321
J4FS_FILE_MAGIC = 0x12345678
J4FS_INODE_LENGTH = 160



def write_file(filename, length, fp):
    """ Write file data to file """
    if not os.path.isdir(args.dir):
        os.mkdir(args.dir)

    path = os.path.join(args.dir, filename)
    print(path)

    ofp = open(path, 'wb')

    while length > 0:
        nbyte = min(8192, length)
        ofp.write(fp.read(nbyte))
        length -= nbyte

    ofp.close()


def j4fs_image_valid(fp):
    """ Check whether fp is a valid j4fs image """
    fp.seek(0)

    magic, = struct.unpack('I', fp.read(4))

    return (magic == J4FS_MAGIC)


def j4fs_inode_is_valid(inode):
    """ Determine whether specified inode is valid (ie. not deleted) """
    flags = inode[4]

    return (flags & 0x01) == ((flags & 0x02) >> 1)


def j4fs_inode_is_last(inode):
    """ Determine whether specified inode is the last one """
    link = inode[0]
    flags = inode[4]

    return (link == 0xffffffff and (flags & 0x01) == 0x01) or \
           (link == 0x00000000 and (flags & 0x01) == 0x00)


def print_inode(fp_offset, inode, inode_size):
    """Print an j4fs inode entry as a sensible two-line string."""
    link, size, type, offset, flags, stroff, inode_id, length, filename_raw = inode

    filename = parse_filename(filename_raw)

    inode_str = '{link:x} {size} {type} {offset:x} {flags} {stroff} {inode_id} {length} {filename}'.format(
        link=link, size=size, type=type, offset=offset, flags=flags, stroff=stroff,
        inode_id=inode_id, length=length, filename=filename,
    )
    print('{fp_offset:x}: INODE ({inode_size} bytes,{filename})\n       {inode_str}'.format(
        inode_size=inode_size, fp_offset=fp_offset, inode_str=inode_str, filename=filename))


def print_file(fp_offset, filename, length):
    print('{:x}: FILE  {} ({})'.format(fp_offset, filename, length))


def parse_filename(inode_filename):
    """Parse the j4fs inode filename field (NUL-terminated string)."""
    # FIXME correct encoding?
    return str(inode_filename, 'iso-8859-1').split('\x00')[0]

def j4fs_extract(fp):
    # first ro entry is past mst
    link = args.block_size
    inode = None

    while not inode or not j4fs_inode_is_last(inode):
        inode_pos = link
        fp.seek(link)

        inode_data = fp.read(struct.calcsize(S_INODE))
        inode = list(struct.unpack(S_INODE, inode_data))

        # inode (link, size, type, offset, flags, stroff, id, length, filename)
        link, _, type, _, flags, _, _, length, filename = inode

        assert type == J4FS_FILE_MAGIC, 'Unknown inode type'

        filename = parse_filename(filename)

        # data is at inode_pos + page_size
        fp.seek(inode_pos + args.page_size)

        write_file(filename, length, fp)

def j4fs_dump_header(fp):
    fp.seek(0)
    mst_bytes = fp.read(struct.calcsize(S_MST))
    mst = struct.unpack(S_MST, mst_bytes)
    (
     magic,
     from_addr,
     to_addr,
     end,
     copyed,
     *offset,
     offset_number,
     status,
     rw_start,
    ) = mst
    s = f"""
MST:
magic: {magic:x}
from: {from_addr:x}, to: {to_addr:x}
end: {end:x}, copyed: {copyed:x}
offset: {offset}
offset_number: {offset_number:x}
status: {status:x}
rw_start: {rw_start:x}
    """
    print(s)


def j4fs_dump(fp):
    j4fs_dump_header(fp)

    # first ro entry is past mst
    link = args.block_size
    inode = None

    while not inode or not j4fs_inode_is_last(inode):
        inode_pos = link
        fp.seek(link)

        inode_offset = fp.tell()
        inode_size = struct.calcsize(S_INODE)
        inode_data = fp.read(inode_size)
        inode = list(struct.unpack(S_INODE, inode_data))

        # inode (link, size, type, offset, flags, stroff, id, length, filename)
        link, _, type, _, flags, _, _, length, filename = inode

        assert type == J4FS_FILE_MAGIC, 'Unknown inode type'

        print_inode(inode_offset, inode, inode_size)

        # data is at inode_pos + page_size
        fp.seek(inode_pos + args.page_size)

        filename = parse_filename(filename)
        print_file(fp.tell(), filename, length)


def j4fs_file_inode(link, inode_id, filename, file_length, flags=3):
    size = 0xffffffff
    type = J4FS_FILE_MAGIC
    offset = 0xffffffff
    flags = 3
    stroff = 0xffffffff
    filename = bytes(filename, 'utf8')

    inode_data = (link, size, type, offset, flags, stroff, inode_id, file_length, filename)
    inode_bytes = struct.pack(S_INODE, *inode_data)

    return inode_bytes


def align_to_page_size(addr, page_size):
    remainder = addr % page_size
    if remainder == 0:
        return addr
    return addr + (page_size - remainder)


def j4fs_create_file_entry(fp, inode_id, filepath, page_size, is_last=False):
    # inode (link, size, type, offset, flags, stroff, id, length, filename)
    # - link is the pointer to the next inode.
    #   it needs to be a multiple of the page size.
    # - inode_id is just a numeric value in addition to the filename
    # - is_last needs to be set when in order to mark this entry the last
    #   in the inode linked list.
    #
    # Expects `fp` to be at the correct position for the newly
    # created inode.
    #
    # Writes the data and returns link for the next entry.

    with open(filepath, 'rb') as fp_file:
        file_bytes = fp_file.read()
        file_length = len(file_bytes)

    file_start = align_to_page_size(
        addr=fp.tell() + J4FS_INODE_LENGTH,
        page_size=page_size,
    )

    if not is_last:
        link = file_start + file_length
        link = align_to_page_size(
            addr=link,
            page_size=page_size,
        )
    else:
        link = 0xffffffff

    filename = os.path.basename(filepath)
    inode_bytes = j4fs_file_inode(
        link,
        inode_id,
        filename,
        file_length,
    )
    fp.write(inode_bytes)

    fp.seek(file_start)
    fp.write(file_bytes)

    return link



def j4fs_write_files(fp, files, block_size, page_size):
    for i, filepath in enumerate(files):
        link = j4fs_create_file_entry(
            fp,
            inode_id=11 + i, # mimic ids of Samsung Galaxy Tab param fs
            filepath=filepath,
            page_size=page_size,
            is_last=(i+1) == len(files),
        )
        fp.seek(link)


def j4fs_write_header(
    fp,
    from_addr=0,
    to_addr=0,
    end=0,
    copyed=0,
    offset=None,
    offset_number=0,
    status=0x1230000,
    rw_start=0xb0000,
):
    """All default values are taken from the Galaxy Tab 2.
    These are most certainly different for other devices.
    """
    if offset is None:
        offset = [0] * J4FS_MAX_FILE_NUM

    header_data = (
        J4FS_MAGIC,
        from_addr,
        to_addr,
        end,
        copyed,
        *offset,
        offset_number,
        status,
        rw_start,
    )

    header_bytes = struct.pack(S_MST, *header_data)
    fp.write(header_bytes)


if __name__ == '__main__':

    def cli_dump(args):
        with open(args.file, 'rb') as fp:
            if not j4fs_image_valid(fp):
                print('Error: input file does not appear to contain a valid j4fs filesystem', file=sys.stderr)
                sys.exit(1)
            j4fs_dump(fp)


    def cli_create(args):
        with open(args.output_file, 'wb') as fp:
            j4fs_write_header(fp)
            fp.seek(args.block_size)
            j4fs_write_files(
                fp,
                args.files,
                block_size=args.block_size,
                page_size=args.page_size,
            )

    def cli_extract(args):
        with open(args.file, 'rb') as fp:
            if not j4fs_image_valid(fp):
                print('Error: input file does not appear to contain a valid j4fs filesystem', file=sys.stderr)
                sys.exit(1)
            j4fs_extract(fp)

    parser = argparse.ArgumentParser(description='Create new j4fs from list of files')

    subparsers = parser.add_subparsers(required=True)
    dump_parser = subparsers.add_parser('dump')
    dump_parser.add_argument('file', help='input image')
    dump_parser.add_argument('-p', dest='page_size', type=int, help='page size (default 4096)', default=4096)
    dump_parser.add_argument('-b', dest='block_size', type=int, help='block size (default 262144)', default=262144)
    dump_parser.set_defaults(func=cli_dump)

    create_parser = subparsers.add_parser('create')
    create_parser.add_argument('files', nargs='+', help='input image')
    create_parser.add_argument('-o', dest='output_file', type=str, help='path of j4fs file', default='out.j4fs')
    create_parser.add_argument('-p', dest='page_size', type=int, help='page size (default 4096)', default=4096)
    create_parser.add_argument('-b', dest='block_size', type=int, help='block size (default 262144)', default=262144)
    create_parser.set_defaults(func=cli_create)

    extract_parser = subparsers.add_parser('extract')
    extract_parser.add_argument('file', help='input image')
    extract_parser.add_argument('-o', dest='dir', help='output directory', default='out')
    extract_parser.add_argument('-p', dest='page_size', type=int, help='page size (default 4096)', default=4096)
    extract_parser.add_argument('-b', dest='block_size', type=int, help='block size (default 262144)', default=262144)
    extract_parser.set_defaults(func=cli_extract)

    args = parser.parse_args()
    args.func(args)
