package main

import (
	"os"                 // standard library
	"rsc.io/quote"       // vanity import
	"github.com/foo/bar" // special case hoster
)

var (
	_, _, _ = os.A, tools.B, bar.C
)
