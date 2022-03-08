package strings

// Join is like strings.Join, but also works on defined types based on string.
// S is any type with underlying type string.
func Join[S ~string](parts []S, sep S) S {
	p := []string(parts)                  // allowed conversion from []S to []string
	joined := strings.Join(p, string(sep) // allowed conversion from S to string
	return S(joined)                      // allowed conversion from string to S
}
// SPLIT OMIT
type Path string

const Sep Path = "/"

func Join(parts ...Path) Path {
	// Infers strings.Join[Path], which has type
	//    func([]Path, Path) Path
	return strings.Join(parts, Sep)
}
