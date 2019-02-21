package parser

import (
	"encoding/binary"
	"io"
)

// START OMIT
// read tries to fully fill p or aborts parsing.
func (d *decoder) read(p []byte) {
	_, err := io.ReadFull(d.r, p)
	// ReadFull returns io.EOF if zero bytes where read. We expect > 0 bytes.
	if err == io.EOF { err = io.ErrUnexpectedEOF }
	d.check(err)
}

// uint32 tries to read a uint32 or aborts parsing.
func (d *decoder) uint32() uint32 {
	buf := make([]byte, 4)
	d.read(buf)
	return binary.BigEndian.Uint32(buf[0:4])
}

// string tries to read a length-prefixed string or aborts parsing.
func (d *decoder) string() string {
	n := d.uint32()
	buf := make([]byte, n)
	d.read(buf)
	return string(buf)
}
