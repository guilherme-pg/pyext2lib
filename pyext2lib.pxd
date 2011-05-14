# XXX Probably includes much more than we actually need/implement
cdef extern from "ext2fs/ext2fs.h":
	cdef struct struct_io_manager:
		pass

	cdef struct ext2fs_block_bitmap:
		pass

	cdef struct ext2_super_block:
		int s_first_data_block

	cdef struct struct_ext2_filsys:
		ext2_super_block *super
		int group_desc_count
		ext2fs_block_bitmap block_map

	cdef struct ext2_inode:
		pass

	cdef struct ext2_struct_inode_scan:
		pass

	ctypedef struct_ext2_filsys *ext2_filsys
	ctypedef struct_io_manager *io_manager
	ctypedef ext2_struct_inode_scan *ext2_inode_scan

	ctypedef int ext2_ino_t
	ctypedef unsigned int blk_t

	cdef io_manager unix_io_manager

	int ext2fs_open(char *name, int flags, int superblock,
					unsigned int block_size, io_manager manager,
					ext2_filsys *ret_fs)

	int ext2fs_close(ext2_filsys fs)
	int ext2fs_flush(ext2_filsys fs)
	int ext2fs_read_block_bitmap(ext2_filsys fs)
	int ext2fs_read_inode_bitmap(ext2_filsys fs)
	int ext2fs_read_bitmaps(ext2_filsys fs)

	int EXT2_BLOCKS_PER_GROUP(ext2_super_block *s)
	int ext2fs_test_bit(unsigned int nr, void *addr)
	int ext2fs_get_block_bitmap_range(ext2fs_block_bitmap bmap,
									int start, unsigned int num,
									void *out)

	int ext2fs_open_inode_scan(ext2_filsys fs, int buffer_blocks,
									ext2_inode_scan *ret_scan)
	int ext2fs_get_next_inode(ext2_inode_scan scan, ext2_ino_t *ino,
							ext2_inode *inode)
	void ext2fs_close_inode_scan(ext2_inode_scan scan)
	int ext2fs_inode_scan_flags(ext2_inode_scan scan, int set_flags, int
								clear_flags)

	int ext2fs_get_blocks(ext2_filsys fs, ext2_ino_t ino, blk_t *blocks)
	int ext2fs_inode_has_valid_blocks (ext2_inode *inode)

	enum:
		EXT2_NDIR_BLOCKS = 12
		EXT2_IND_BLOCK = EXT2_NDIR_BLOCKS
		EXT2_DIND_BLOCK = EXT2_IND_BLOCK + 1
		EXT2_TIND_BLOCK = EXT2_DIND_BLOCK + 1
		EXT2_N_BLOCKS = EXT2_TIND_BLOCK + 1

cdef class ExtFS:
	# XXX - Can't be instantiated directly as that leaves self.fs as NULL,
	# making all methods segfault. Instantiate only through open() or fix
	# this later.

	cdef ext2_filsys fs

	cpdef read_block_bitmap(self)
	cpdef read_inode_bitmap(self)
	cpdef read_bitmaps(self)
	cpdef flush(self)
	cpdef close(self)
	cpdef iterinodes(self, flags = ?)

cdef class ExtFSInodeIter:
	cdef ExtFS extfs
	cdef ext2_inode_scan scan

cdef class ExtInode:
	cdef ext2_filsys fs
	cdef readonly int number
	cdef ext2_inode inode

	cpdef get_blocks(self)

