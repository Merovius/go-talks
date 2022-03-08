package x // OMIT

type Integer interface {
	~int|~int8|~int16|~int32|~int64|~uint|~uint8|~uint16|~uint32|~uint64|~uintptr
}

type ByteSeq interface {
	~string | ~[]byte
}
