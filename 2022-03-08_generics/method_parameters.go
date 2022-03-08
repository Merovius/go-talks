type Set[A comparable] map[A]struct{}

// Error: Can't have extra type parameters on methods
func (s Set[A]) Map[B comparable](f func(A) B) Set[B]

// SPLIT OMIT
func Map[A, B comparable](s Set[A], f func(A) B) Set[B]
