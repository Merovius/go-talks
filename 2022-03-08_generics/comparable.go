package set // OMIT

type Set[T any] map[T]struct{}        // Error: T is not comparable
type Set[T comparable] map[T]struct{} // OK
// INTERFACE OMIT
var s Set[any] // Error: any does not implement comparable
