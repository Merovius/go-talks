package parser

import (
	"errors"
	"io"
)

// START FOOREQ OMIT
func (req *FooRequest) decode(d *decoder) error {
	req.Name = d.string()
	req.Age = d.uint32()
	req.Weight = d.uint32()

	// Validate req
	return req, nil
}
// END FOOREQ OMIT

// START SERVE OMIT
func Serve(rw io.ReadWriter, h Hander) error {
	return do(rw, func(d *decoder) error {
		buf := make([]byte, 8)
		d.read(buf)
		if string(buf) != "FAKEPROT" {
			return errors.New("invalid magic")
		}
		if _, err := io.WriteString(rw, "PROTFAKE"); err != nil { return err }
		for {
			kind := d.uint32()
			length := d.uint32()
			lr := io.LimitReader(rw, int64(length))
			switch kind {
			case KindFoo:
				req := new(FooRequest)
				if err := do(lr, req.decode); err != nil { return err }
				resp := h.HandleFoo(req)
				encodeFooResponse(rw, resp)
				// …
			}
		}
	})
}
// END SERVE OMIT
