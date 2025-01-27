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
		#box(clip: true, width: 5cm, height: 5cm, image("hero-mascots.png"))
	][
	= Why we can't have nice things:
	== Generic methods
	
	Axel Wagner

	https://blog.merovius.de/

	#link("https://chaos.social/@Merovius")[\@Merovius\@chaos.social]

	2025-01-24
	][
		#box(clip: true, radius: 5cm, width: 5cm, height: 5cm, image("avatar.jpg", height: 5cm))
	]
]

#focus-slide[
	= Examples
]

#slide[
	== `math/rand/v2`
	#image("randN.png")
	#pause
	```go
	// Sleep for a random duration up to 1s.
	func RandomSleep() {
		time.Sleep(rand.N(time.Second))
	}
	```
]

#slide[
	== `math/rand/v2`
	#image("rand_type.png", height: 80%)
]

#slide[
	== `math/rand/v2`

	```go
	// Sleep for a random duration up to 1s.
	func RandomSleep(r *rand.Rand) {
		time.Sleep(time.Duration(r.IntN(int(time.Second))))
	}
	```
	#pause
	#v(1em)
	#align(center, box(width: 5cm, height: 5cm, image("vomit-emoji.png")))
]

#slide[
	== Cache

	```go
	type Cache interface {
		// Get the value associated with key. On a cache miss, calls
		// make to populate the cache.
		Get(key string, make func(key string) any) any
	}

	func DoThing(c Cache, …) Stuff {
		// …
		v := c.Get("foo", calculate).(internalState)
		// …
	}

	func calculate(key string) any { /* … */ }
	```
]

#slide[
	== Cache

	```go
	type Cache[Key, Value any] interface {
		// Get the value associated with k. On a cache miss, calls
		// make to populate the cache.
		Get(k Key, make func(Key) Value) Value
	}

	func DoThing(c Cache[string, internalState], …) Stuff {
		// …
		v := c.Get("foo", calculate)
		// …
	}

	func calculate(key string) internalState { /* … */ }
	```
]

#slide[
	== Cache

	```go
	type Cache interface {
		// Get the value associated with k. On a cache miss, calls
		// make to populate the cache.
		Get[Key, Value any](k Key, make func(Key) Value) Value
	}

	func DoThing(c Cache, …) Stuff {
		// …
		v := c.Get("foo", calculate)
		// …
	}

	func calculate(key string) internalState { /* … */ }
	```
]

#slide[
	== `iter.Seq[E]`

	```go
	package xiter

	func Map[A, B any](s iter.Seq[A], f func(A) B) iter.Seq[B]
	func Filter[A any](s iter.Seq[A], f func(A) bool) iter.Seq[A]
	func Reduce[A any](s iter.Seq[A], f func(A, A) A) A
	// …
	```
]

#slide[
	== `iter.Seq[E]`

	```go
	type Shape interface{ Area() float64 }
	func ListShapes() iter.Seq[Shape] { … }

	func main() {
		m := xiter.Reduce(
			xiter.Map(
				ListShapes(),
				Shape.Area,
			),
			math.Max,
		)
		fmt.Printf("The largest shape has area %v", m)
	}
	```
]

#slide[
	== `iter.Seq[E]`

	```go
	type Shape interface{ Area() float64 }
	func ListShapes() iter.Seq[Shape] { … }

	func main() {
		m := xiter.Reduce(
			math.Max,
			xiter.Map(
				Shape.Area,
				ListShapes(),
			),
		)
		fmt.Printf("The largest shape has area %v", m)
	}
	```
]

#slide[
	== `iter.Seq[E]`

	```go
	package iter

	type Seq[A any] func(yield func(A) bool)

	func (s Seq[A]) Map[B any](f func(A) B) Seq[B]
	func (s Seq[A]) Filter(f func(A) bool) Seq[A]
	func (s Seq[A]) Reduce(f func(A, A) A) A
	```
]

#slide[
	== `iter.Seq[E]`

	```go
	type Shape interface{ Area() float64 }
	func ListShapes() iter.Seq[Shape] { … }

	func main() {
		m := ListShapes().
			Map(Shape.Area).
			Reduce(math.Max)
		fmt.Printf("The largest shape has area %v", m)
	}
	```
	#pause
	#align(center, box(width: 4cm, height: 4cm, image("relieved-emoji.png")))
]

#slide[
	== `iter.Seq[E]`

	```go
	package iter

	type Seq[A any] func(yield func(A) bool)

	// iter.go:5:21: method must have no type parameters
	func (s Seq[A]) Map[B any](f func(A) B) Seq[B]
	func (s Seq[A]) Filter(f func(A) bool) Seq[A]
	func (s Seq[A]) Reduce(f func(A, A) A) A
	```
]


#slide[#align(center, image("proposal.png"))]
#slide[#align(center, image("proposal_party.png"))]
#slide[#align(center, image("proposal_thinking.png"))]
#slide[#align(center, image("proposal_anxiety.png"))]

#focus-slide[
	= The generic dilemma
]

#slide[
	== The generic dilemma

	#set quote(block: true, quotes: true)
	#quote(attribution: [Russ Cox, 2009-12-03])[
		The generic dilemma is this: do you want slow programmers, slow compilers and bloated binaries, or slow execution times? 
	]
	#pause
	- Slow programmers: No generics
	- Slow compilers, bloated binaries: Compile-time expansion (e.g. C++)
	- Slow execution time: Runtime boxing (e.g. Java)
]

#slide[
	== Go's answer

	#quote(block: true, quotes: true, attribution: [#link("https://go.googlesource.com/proposal/+/refs/heads/master/design/43651-type-parameters.md#implementation")[Type Parameters Proposal]])[
		*We believe that this design permits different implementation choices.* […]
		In other words, this design permits people to stop choosing slow programmers, and permits the implementation to decide between slow compilers […] or slow execution times […].
	]
	#pause
	Implementation strategy is an optimization choice.

	#pause
	Importantly: "Different implementations" can mean "different versions of the same compiler".
]

#focus-slide[
	= First class generic functions
]

#slide[
	== First class generic functions

	```go




	         var f func[A any](A) int
	```
]

#slide[
	== First class generic functions

	```go




	func DoThing(f func[A any](A) int) int {



	}
	```
]

#slide[
	== First class generic functions

	```go
	



	func DoThing(f func[A any](A) int) int {
		x := f[string]("Hello, world")


	}
	```
]

#slide[
	== First class generic functions

	```go




	func DoThing(f func[A any](A) int) int {
		x := f[string]("Hello, world")
		y := f[int](42)
		return x+y
	}
	```
]

#slide[
	== First class generic functions

	```go



	// Syntax error: function type must have no type parameters
	func DoThing(f func[A any](A) int) int {
		x := f[string]("Hello, world")
		y := f[int](42)
		return x+y
	}
	```
]

#focus-slide[
	= Implementation
]

#slide[
	== Implementation

	```go
	type _table struct {
		_string func(string) int
		_int    func(int) int
	}
	func DoThing(f _table) int {
		x := f._string("Hello, world")
		y := f._int(42)
		return x+y
	}
	```
]

#slide[
	== Implementation

	```go
	type _table struct {
		_string func(string) int
		_int    func(int) int
	}
	func DoThing(f _table) int {
		x := f._string("Hello, world")
		y := f._int(42)
		return x+y
	}

	func F[T any](x T) int { /* … */ }
	func main() {
		fmt.Println(DoThing(F))
	}
	```
]

#slide[
	== Implementation

	```go
	type _table struct {
		_string func(string) int
		_int    func(int) int
	}
	func DoThing(f _table) int {
		x := f._string("Hello, world")
		y := f._int(42)
		return x+y
	}

	func F[T any](x T) int { /* … */ }
	func main() {
		fmt.Println(DoThing(_table{F[string], F[int]}))
	}
	```
]

#slide[
	== Implementation

	```go
	var ch = make(chan func[T any](T), 1)

	func Thing1() { f := <-ch; f[string]("Hello, world") }
	func Thing2() { f := <-ch; f[int](42) }

	func F[T any](v T) { /* … */ }
	func main() {
		ch <- F
		switch rand.N(2) {
		case 0: Thing1()
		case 1: Thing2()
		}
	}
	```
]

#slide[
	== Implementation

	```go
	package pkgA

	var Chan = make(chan func[T any](T), 1)

	package pkgB

	func Thing1() { f := <-pkgA.Chan; f[string]("Hello, world") }

	package pkgC

	func Thing2() { f := <-pkgA.Chan; f[int](42) }
	```
]

#slide[
	== Implementation

	```go
	func Add[T intType](a, b T) T { return a + b }
	func Sub[T intType](a, b T) T { return a - b }
	func Mul[T intType](a, b T) T { return a * b }
	func Div[T intType](a, b T) T { return a % b }
	func Max[T intType](a, b T) T { return max(a, b) }
	func Min[T intType](a, b T) T { return min(a, b) }
	func UseInt(fs ...func[T intType](T, T) T) {
		for _, f := range fs { f[int](1,2) }
	}
	func UseUint(fs ...func[T intType](T, T) T) {
		for _, f := range fs { f[uint](1,2) }
	}
	func main() {
		UseInt(Add, Mul, Max)
		UseUint(Sub, Div, Min)
	}
	```
]

#slide[
	== Implementation

	Why is this not a problem right now?

	#v(1em)

	#pause
	```go
	func DoThing() {
		// generic functions must be fully instantiated before use!
		sompkg.SomeFunction[int, string](42, "Hello, world!")
	}
	```

	#v(1em)

	#pause
	Statically couples the type arguments with a reference to the body!
]

#focus-slide[
	= Methods
]

#slide[
	== Generic methods in interfaces

	If we had generic methods, they should be usable in interfaces:
	```go
	type Caller interface{
		Call[T any](T) int
	}
	```
	#pause
	But:
	#side-by-side[
	```go
	func F(c Caller) int {
		x := c.Call[string]("Hello, world")
		y := c.Call[int](42)
		return x+y
	}
	```
	][
	```go





	```
	]
]

#slide[
	== Generic methods in interfaces

	If we had generic methods, they should be usable in interfaces:
	```go
	type Caller interface{
		Call[T any](T) int
	}
	```
	But:
	#side-by-side[
	```go
	func F(c Caller) int {
		x := c.Call[string]("Hello, world")
		y := c.Call[int](42)
		return x+y
	}
	```
	][
	```go
	func F(f func[A any](A) int) int {
		x := f[string]("Hello, world")
		y := f[int](42)
		return x+y
	}
	```
	]
	#pause
	This is just first class generic functions with extra steps!

	#pause
	Corollary: No generic methods in interfaces.
]

#slide[
	== Satisfying interfaces

	If we had generic methods, we probably want them to implement regular interfaces:

	```go
	type Writer …
	// Write can write any string or []byte type, generalizing io.Writer.
	func (w *Writer) Write[S ~string|~[]byte](s S) (int, error) { … }

	// We probably would like this to be allowed.
	var _ io.Writer = new(Writer)
	```

	#pause
	Type assertions:
	```go
	func F(v any) {
		v.(int)       // "Normal" type assertion

	}
	```
]

#slide[
	== Satisfying interfaces

	If we had generic methods, we probably want them to implement regular interfaces:

	```go
	type Writer …
	// Write can write any string or []byte type, generalizing io.Writer.
	func (w *Writer) Write[S ~string|~[]byte](s S) (int, error) { … }

	// We probably would like this to be allowed.
	var _ io.Writer = new(Writer)
	```

	Type assertions:
	```go
	func F(v any) {
		v.(int)       // "Normal" type assertion
		v.(io.Reader) // Interface type assertion
	}
	```
]

#slide[
	== Satisfying interfaces

	Thus:
	```go
	type intCaller interface{ Call(int) int }
	type stringCaller interface{ Call(string) int }
	```
]

#slide[
	== Satisfying interfaces

	Thus:
	```go
	type intCaller interface{ Call(int) int }
	type stringCaller interface{ Call(string) int }
	func F(v any) int {
		x := v.(stringCaller).Call("Hello, world")
		y := v.(intCaller).Call(42)
		return x+y
	}
	```
	#pause
	This is just first class generic functions with extra steps!

	#pause
	Corollary: Generic methods don't implement *any* interfaces.
]

#slide[
	== What's left

	Call chaining:
	```go
	type Shape interface{ Area() float64 }
	func ListShapes() iter.Seq[Shape] { … }

	func main() {
		m := ListShapes().
			Map(Shape.Area).
			Reduce(math.Max)
		fmt.Printf("The largest shape has area %v", m)
	}
	```
	#pause
	Has the static association between body and type argument.
]

#slide[
	== What's left

	#quote(block: true, quotes: true, attribution: [#link("https://go.googlesource.com/proposal/+/refs/heads/master/design/43651-type-parameters.md#No-parameterized-methods")[Type Parameters Proposal]])[
		In Go, one of the main roles of methods is to permit types to implement interfaces. […] we could decide that parameterized methods do not, in fact, implement interfaces, but then it's much less clear why we need methods at all.
	]

	#quote(block: true, quotes: true, attribution: link("https://github.com/golang/go/issues/49085#issuecomment-1188572825")[Ian Lance Taylor])[
		You are proposing large and significant language changes, which make generic methods behave significantly different from non-generic methods. The benefit of these changes appears to be to permit call chaining. I don't think the benefit outweighs the cost.
	]
]

#focus-slide[
	= Summary
]

#slide[
	== Summary

	1. Everybody agrees this is a useful feature and wants it.
]

#slide[
	== Summary

	1. Everybody agrees this is a useful feature and wants it.
	2. Implementing it requires runtime boxing or excluding interfaces.
]

#slide[
	== Summary

	1. Everybody agrees this is a useful feature and wants it.
	2. Implementing it requires runtime boxing or excluding interfaces.
	3. *Requiring* runtime boxing is an unacceptable cost.
]

#slide[
	== Summary

	1. Everybody agrees this is a useful feature and wants it.
	2. Implementing it requires runtime boxing or excluding interfaces.
	3. *Requiring* runtime boxing is an unacceptable cost.
	4. The cost of excluding interfaces isn't justified by the leftover benefits.
]

#focus-slide[
	= Thank you
]
