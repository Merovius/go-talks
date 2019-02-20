package parser

import (
	"encoding/binary"
	"io"
)

// START HELPERS OMIT
func readUint32(r io.Reader) (uint32, error) {
	buf := make([]byte, 4)
	if _, err := io.ReadFull(r, buf); err != nil {
		return 0, err
	}
	return binary.BigEndian.Uint32(buf), nil
}

func readString(r io.Reader) (string, error) {
	n, err := readUint32(r)
	if err != nil {
		return "", err
	}
	buf := make([]byte, n)
	n, err = io.ReadFull(r, buf)
	return string(buf[:n]), err
}
// END HELPERS OMIT

// START DECODE OMIT
func (req *FooRequest) decode(r io.Reader) error {
	var err error

	req.Name, err = readString(r)
	if err != nil {
		return err
	}
	req.Age, err = readUint32(r)
	if err != nil {
		return err
	}
	req.Height, err = readUint32(r)
	if err != nil {
		return err
	}

	// Validate foo
	return nil
}
// END DECODE OMIT
