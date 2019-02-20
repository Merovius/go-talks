package parser

import (
	"io"
)
// START OMIT
type decoder struct {
	r     io.Reader
	check func(error)
}

func do(r io.Reader, f func(*decoder) error) (err error) {
	sentinel := new(uint8)
	defer func() {
		if v := recover(); v != nil && v != sentinel {
			panic(v)
		}
	}()
	d := &decoder{r: r}
	d.check = func(e error) {
		if e != nil {
			err = e
			panic(sentinel)
		}
	}
	return f(d)
}
