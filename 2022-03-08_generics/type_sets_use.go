package x // OMIT

func usage() { // OMIT
Concat("foo", "bar", "baz")                   // Allowed: T is infered as string
Concat([]byte{102}, []byte{111}, []byte{111}) // Allowed: T is infered as []byte
Concat(42, 23, 1337)                          // Forbidden: int is not in ByteSeq
} // OMIT

func Concat[T ByteSeq](s ...T) T {
	var out []byte
	for _, piece := range s {
		// out += piece             // Forbidden: []byte does not support +.
		out = append(out, piece...) // Allowed: strings and []bytes can be appended to []byte
	}
	return T(out)                   // Allowed: []byte can be converted to []byte and string.
}
