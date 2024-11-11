#import "@preview/polylux:0.3.1": *
#import "./theme.typ": *

#show: simple-theme.with(
	aspect-ratio: "16-9",
	background: rgb("#ffffdd"),
)
#set text(font: "Go", size: 20pt)
#show raw: set text(font: "Go Mono")
#let filled-slide(body) = {
	set page(margin: 0em)
	body
	set page(margin: 2em)
}

#title-slide[
	#side-by-side(columns: (1fr, 3fr, 1fr))[
		#image("gc_au_mascot.png", height: 5cm, width: 5cm)
	][
	= The Why of Iterator Design
	
	Axel Wagner

	https://blog.merovius.de/

	#link("https://chaos.social/@Merovius")[\@Merovius\@chaos.social]

	2024-11-07
	][
		#box(clip: true, radius: 5cm, width: 5cm, height: 5cm, image("avatar.jpg", height: 5cm))
	]
]

#focus-slide[
	= Go 1.23 iterators
]

#slide[
	```go
	func PrintSquares() {
		for s := range Squares() {
			if s < 10; { continue }
			if s > 100; { break	}
			fmt.Println(s)
		}
	}
	```
	#v(0em)
	#pause
	```go
	func Squares() iter.Seq[int]
	```
]

#slide[
	```go
	func PrintSquares() {
		for s := range Squares() {
			if s < 10; { continue }
			if s > 100; { break	}
			fmt.Println(s)
		}
	}
	```
	#v(0em)
	```go
	func Squares() iter.Seq[int] {
		return func(yield func(int) bool) {
	```
]

#slide[
	```go
	func PrintSquares() {
		for s := range Squares() {
			if s < 10; { continue }
			if s > 100; { break	}
			fmt.Println(s)
		}
	}
	```
	#v(0em)
	```go
	func Squares() iter.Seq[int] {
		return func(yield func(int) bool) {
			for i := 0; ; i++ {
				    yield(i*i)
	```
]

#slide[
	```go
	func PrintSquares() {
		for s := range Squares() {
			if s < 10; { continue }
			if s > 100; { break	}
			fmt.Println(s)
		}
	}
	```
	#v(0em)
	```go
	func Squares() iter.Seq[int] {
		return func(yield func(int) bool) {
			for i := 0; ; i++ {
				if !yield(i*i) {
					return
				}
			}
		}
	}
	```
]

#slide[
	```go
	func PrintSquares() {
		for i, s := range Squares() {
			if s < 10; { continue }
			if s > 100; { break	}
			fmt.Println(i, s)
		}
	}
	```

	```go
	func Squares() iter.Seq2[int, int] {
		return func(yield func(int, int) bool) {
			for i := 0; ; i++ {
				if !yield(i, i*i) {
					return
				}
			}
		}
	}
	```
]

#focus-slide[
	= This is not an iterator tutorial.
	#pause
	= This is a history lesson.
]

#slide[
	== range

	```go
	var s []T
	for range s {}
	for i := range s {}
	for i, v := range s {}

	var m map[K]V
	for range m {}
	for k := range m {}
	for k, v := range m {}

	var c chan T
	for range c {}
	for v := range c {}
	```
]

#slide[
	== Channel iterator

	```go
	func Squares() <-chan int {
		ch := make(chan int)
		go func(ch chan<- int) {
			for i := 0; ; i++ {
		 		ch <- i*i
			}
		}(ch)
		return ch
	}
	```
	#pause
	Stopping:

	```go
	package signal

	func Notify(c chan<- os.Signal, sig ...os.Signal)
	func Stop(c chan<- os.Signal)
	```
]

#slide[
	== Iterator types

	```go
	package sql

	type Rows struct{ /* … */ }
	func (*Rows) Next() bool
	func (*Rows) Scan(...any) error
	func (*Rows) Close() error
	```
	#pause

	Maps:

	```go
	type Set[E comparable] struct{ m map[E]struct{} }

	func (s *Set[E]) Elements() *Iter[E] {
		// needs to range in a goroutine and write to a channel,
		// to enumerate map keys.
	}
	```
]

#slide[
	== Callbacks

	```go
	type Map[K, V any] struct{ /* … */ }
	func (m *Map[K, V]) Range(f func(K, V) bool)
	```
	#pause

	Break/Continue/Return:

	```go
	func Find[K comparable, V any](m *Map[K, V], key K) (V, bool) {
		var val V
		var found bool
		m.Range(func(k K, v V) bool {
			if k == key {
				val, found = v, true
				return false
			}
		})
		return val, found
	}
	```
]

#focus-slide[
	= \#54245: discussion: standard iterator interface
]

#slide[
	== Interface

	```go
	package iter

	type Iter[E any] interface{ Next() (elem E, ok bool) }
	```
	#pause

	Use:
	```go
	for v := range it {
		fmt.Println(v)
	}
	```
	#pause

	Translated to:
	```go
	for v, _ok := it.Next(); _ok; v, _ok = it.Next() {
		fmt.Println(v)
	}
	```
]

#slide[
	== Example: Slice

	```go
	func Slice[E any](s []E) iter.Iter[E] {
		return &sliceIter[E]{s: s}
	}

	type sliceIter[E any] struct {
		s []E
		i int
	}

	func (it *sliceIter[E]) Next() (v E, ok bool) {
		if it.i < len(i.s) {
			v, ok = it.s[i.i], true
			i.i++
		}
		return v, ok
	}
	```
]

#slide[
	== Example: Map

	```go
	type Iter2[E1, E2 any] interface{ Next() (E1, E2, bool) }
	```
	#pause
	#v(0.6em)

	```go
	func Map[K comparable, V any](m map[K]V) iter.Iter2[K, V] {
		// Non-trivial, channel-based code.
	}
	```
]

#slide[
	== Generators

	```go
	// NewGen creates a new iterator from a generator function gen.
	// The gen function is called once.  It is expected to call
	// yield(v) for every value v to be returned by the iterator.
	// If yield(v) returns false, gen must stop calling yield and return.
	func NewGen[E any](gen func(yield func(E) bool)) StopIter[E]

	func NewGen2[E1, E2 any](gen func(yield func(E1, E2) bool)) StopIter2[E1, E2]
	```
]

#slide[
	== Stopping
	#pause

	Optional interface:

	```go
	type StopIter[E any] interface{
		Iter

		// Stop indicates that the iterator will no longer be used.
		// After a call to Stop, future calls to Next may panic.
		// Stop may be called multiple times;
		// all calls after the first will have no effect.
		Stop()
	}
	type StopIter2[E1, E2 any] interface{ Iter2; Stop() }
	```
	#pause
	Convention: Whoever gets a `StopIter`, has to ensure `Stop` is called.
]

#slide[
	== Example: Map (again)

	```go
	func Map[K comparable, V any](m map[K]V) iter.StopIter2[K, V] {
		return iter.NewGen2(func(yield func(K, V) bool) {
			for k, v := range m {
				if !yield(k, v) {
					return
				}
			}
		})
	}
	```
]

#slide[
	== Extension: Range
	
	```go
	func F(m *OrderedMap[K, V])
	```
]

#slide[
	== Extension: Range
	
	```go
	func F(m *OrderedMap[K, V]) {
		it := m.Range()




	}
	```
]

#slide[
	== Extension: Range
	
	```go
	func F(m *OrderedMap[K, V]) {
		it := m.Range()
		defer it.Stop()



	}
	```
]

#slide[
	== Extension: Range
	
	```go
	func F(m *OrderedMap[K, V]) {
		it := m.Range()
		defer it.Stop()
		for k, v := range it {
			fmt.Println(k, v)
		}
	}
	```
	#pause

	If `m` has method `Range() I` and `I` implements `Iter`:
	```go
	func F(m *OrderedMap[K, V]) {
		for k, v := range m { // implicitly calls m.Range()
			fmt.Println(k, v)
		} 										// if I implements StopIter, calls Stop()
	}
	```
]

#focus-slide[
	= 😵

	#pause

	= But is it good?
]

#slide[
	== Compatibility

	```go
	type C chan int
	func (C) Next() (int, bool) {
		return 0, true
	}

	func F(c C) {
		for v := range c {
			fmt.Println(v)
		}
	}
	```
	#pause
	Corollary: If the underlying type is slice, `map` or `chan`, `Next()` is ignored.
]

#slide[
	== Implementing multiple interfaces

	#pause

	1. A type can not implement `Iter` and `Iter2`.

	Can't have one shared type to iterate over keys *or* key/value-pairs.

	#pause

	2. A type can not implement `Range() Iter` and `Range() Iter2`.

	The most general is `Range() Iter2`, which is may be less efficient.

	#pause

	3. A type can implement both `Iter` and `Range() Iter`.

	Ambiguous what `range x` would do: Disallowed by compiler.
]

#slide[
	== StopIter

	Generators are often easier and sometimes necessary to write.

	But this proposal makes them harder to use, by requiring `Stop`.
]

#focus-slide[
	= \#56413: discussion: add range over func
]

#slide[
	== Pull functions

	Getting methods out of the way:

	```go
	func() bool
	func() (A, bool)
	func() (A, B, bool)
	```
	#pause
	#v(1em)
	Rewrite:
	#grid(
		columns: (auto, 1em, auto),
		rows: (auto),
		align: horizon,
		gutter: 1.5em,
		[
			```go
			for a, b := range f {
				if a == x { continue }
				if b == y { return 42 }
				if a+b == z { break }
			}
			```
		],
		[#uncover("3-")[→]],
		[#uncover("3-")[
			```go
			for a, b, _ok := f(); _ok; a, b, _ok = f() {
				if a == x { continue }
				if b == y { return 42 }
				if a+b == z { break }
			}
			```
		]],
	)
]

#slide[
	== Push functions

	Making generators first-class:

	#side-by-side[
	```go
	func(yield func() bool)
	func(yield func(A) bool)
	func(yield func(A, B) bool)
	```
	][
	```go
	func(yield func() bool) bool
	func(yield func(A) bool) bool
	func(yield func(A, B) bool) bool
	```
	]
	#pause
	#v(1em)
	Rewrite:
	#grid(
		columns: (auto, 3em, auto),
		rows: (auto),
		align: horizon,
		gutter: 2em,
		[
			```go
			for a, b := range f {
				if a == x { continue }
				if b == y {	return 42 }
				if a+b == z {	break	}
			}
			```
		],
		[#uncover("3-")[→]],
		[#uncover("3-")[
			```go
			_magic()
			f(_magic_yield)
			_moreMagic()
			```
		]],
	)
	#uncover("4-")[Corollary: Do *not* persist `yield` from iterator.]
]

#slide[
	== Push return value

	Push functions have an optional `bool` return, which is ignored.
	#pause

	Makes writing some iterators easier:
	```go
	type Node[E any] struct {
		Value E
		Left  *Node[E]
		Right *Node[E]
	}
	func (n *Node[E]) All(yield func(E) bool) bool {
		if n == nil {
			return true
		}
		return n.Left.All(yield) && yield(n.Value) && n.Right.All(yield)
	}
	```
]

#focus-slide[
	= \#61405: proposal: add range over func
]

#slide[
	== Changes

	- Drops pull functions
	- Drops half of push functions
	#pause
	Separate proposal:

	```go
	package iter

	type Seq[V any] func(yield func(V) bool)
	type Seq2[K, V any] func(yield func(K, V) bool)

	func Pull[V any](s Seq[V]) (next func() (V, bool), stop func())
	func Pull2[K, V any](s Seq2[K, V any]) (next func() (K, V, bool), stop func())
	```
]

#focus-slide[
	= Thank you
]
