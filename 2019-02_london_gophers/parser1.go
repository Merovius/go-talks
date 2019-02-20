package parser

import (
	"encoding/binary"
	"errors"
	"io"
)

// START DEFINITIONS OMIT
const (
	KindFoo uint32 = 0x464f4f00
	KindBar uint32 = 0x42415200
	// …
)

type Handler interface {
	HandleFooRequest(*FooRequest) *FooResponse
	HandleBarMessage(*BarMessage) *BarResponse
}

// END DEFINITIONS OMIT

// START SERVE OMIT
func Serve(rw io.ReadWriter, h Handler) error {
	buf := make([]byte, 8)
	if _, err := io.ReadFull(rw, buf); err != nil { return err }
	if string(buf) != "FAKEPROT" { return errors.New("invalid magic") }
	if _, err := io.WriteString(rw, "PROTFAKE"); err != nil { return err }
	for {
		// +-----------+-------------+-------------------+
		// |  kind[4]  |  length[4]  |  payload[length]  |
		// +-----------+-------------+-------------------+
		if _, err := io.ReadFull(rw, buf); err != nil { return err }
		kind, length := binary.BigEndian.Uint32(buf[0:4]), binary.BigEndian.Uint32(buf[4:8])
		lr := io.LimitReader(rw, int64(length))
		switch kind {
		case KindFoo:
			req := new(FooRequest)
			if err := req.decode(lr); err != nil { return err }
			resp := h.HandleFoo(req)
			if err := resp.encode(rw); err != nil { return err }
			// …
		}
	}
}

// END SERVE OMIT

// START FOOREQ OMIT
type FooRequest struct {
	Name   string
	Age    uint32
	Height uint32
}

func (req *FooRequest) decode(r io.Reader) error {
	// +------------+---------------+--------+-----------+
	// | nlength[4] | name[nlength] | age[4] | height[4] |
	// +------------+---------------+--------+-----------+
	buf := make([]byte, 4)
	if _, err := io.ReadFull(r, buf); err != nil { return err }
	nlength := binary.BigEndian.Uint32(buf[0:4])
	nbuf := make([]byte, lname)
	if _, err := io.ReadFull(r, nbuf); err != nil { return err }
	req.Name = string(nbuf)
	if _, err := io.ReadFull(r, buf); err != nil { return err }
	req.Age = binary.BigEndian.Uint32(buf[0:4])
	if _, err := io.ReadFull(r, buf); err != nil { return err }
	req.Height = binary.BigEndian.Uint32(buf[0:4])
	return nil
}
// END FOOREQ OMIT
