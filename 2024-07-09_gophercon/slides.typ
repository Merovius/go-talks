#import "@preview/polylux:0.3.1": *
#import "./theme.typ": *

// Note: This is the first time I've used Typst to create a presentation and I
// was under big time pressure, so all of this is full of hacks and not very
// nice - Don't judge me :)

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
		#image("gc_logo.png", height: 5cm, width: 5cm)
	][
	= Advanced generics patterns
	
	Axel Wagner

	https://blog.merovius.de/

	#link("https://chaos.social/@Merovius")[\@Merovius\@chaos.social]

	2024-07-09
	][
		#box(clip: true, radius: 5cm, width: 5cm, height: 5cm, image("avatar.jpg", height: 5cm))
	]
]

#filled-slide[
	#image("adoption.jpg", fit: "cover")
]

#filled-slide[
	#image("biggest_challenge.png", width: 100%)
]

#filled-slide[
	#image("good_tools.jpg", fit: "cover")
]

#focus-slide(background: rgb("#007d9d"))[
	= The Basics
]

#slide[
	```go
	type Slice[E any] []E
	```
	#pause
	```go
	func (s Slice[E]) Filter(keep func(E) bool) Slice[E]
	```
]

#slide[
	```go
	type Slice[E any] []E
	```
	```go
	func (s Slice[E]) Filter(keep func(E) bool) Slice[E] {
		var out Slice[E]
		for i, v := range s {
			if keep(v) { out = append(out, v) }
		}
		return out
	}
	```
	#pause
	```go
	func Map[A, B any](s Slice[A], f func(A) B) Slice[B]
	```
]

#slide[
	```go
	type Slice[E any] []E
	```
	```go
	func (s Slice[E]) Filter(keep func(E) bool) Slice[E] {
		var out Slice[E]
		for _, v := range s {
			if keep(v) { out = append(out, v) }
		}
		return out
	}
	```
	```go
	func Map[A, B any](s Slice[A], f func(A) B) Slice[B] {
		out := make(Slice[B], len(s))
		for i, v := range s {
			out[i] = f(v)
		}
		return out
	}
	```
]

#slide[
	```go
	func usage() {
		primes := Slice[int]{2, 3, 5, 7, 11, 13}
	```
	#pause
	```go
		strings := Map(primes, strconv.Itoa)
	```
	#pause
	```go
		fmt.Printf("%#v", strings)
		// Slice[string]{"2", "3", "5", "7", "11", "13"}
	```
	#pause
	```go
		// package reflect
		// func TypeFor[T any]() Type
		intType := reflect.TypeFor[int]()
	}
	```
]

#centered-slide[
	#text(size: 25pt, weight: "bold")[A type parameter can be inferred if and only if it appears in an argument.]
	#pause

	#text(size: 25pt, weight: "bold")[Corollary: If you want a type parameter to be inferrable, make sure it appears as an argument.]
]

#focus-slide(background: rgb("#007d9d"))[
	= Constraints
]

#slide[
	```go
	// StringifyAll converts the elements of a slice to strings and returns the
	// resulting slice.
	func StringifyAll[E any](s []E) []string
	```
]

#slide[
	```go
	// StringifyAll converts the elements of a slice to strings and returns the
	// resulting slice.
	func StringifyAll[E any](s []E) []string {
		out := make([]string, len(s))
		for i, v := range s {
			out[i] = ???
		}
		return out
	}
	```
]

#slide[
	```go
	// StringifyAll converts the elements of a slice to strings and returns the
	// resulting slice.
	func StringifyAll[E ~string|~[]byte](s []E) []string
	```
]

#slide[
	```go
	// StringifyAll converts the elements of a slice to strings and returns the
	// resulting slice.
	func StringifyAll[E ~string|~[]byte](s []E) []string {
		out := make([]string, len(s))
		for i, v := range s {
			out[i] = string(v)
		}
		return out
	}
	```
	#pause
	```go

	func usage() {
		type Path string
		s := []Path{"/usr", "/bin", "/etc", "/home", "/usr"}
		fmt.Printf("%#v", StringifyAll(s))
		// []string{"/usr", "/bin", "/etc", "/home", "/usr"}
	}
	```
]

#slide[
	```go
	// StringifyAll converts the elements of a slice to strings and returns the
	// resulting slice.
	func StringifyAll[E Bytes](s []E) []string {
		out := make([]string, len(s))
		for i, v := range s {
			out[i] = string(v)
		}
		return out
	}

	type Bytes interface {
		~string | ~[]byte
	}
	```
]


#slide[
	```go
	// StringifyAll converts the elements of a slice to strings and returns the
	// resulting slice.
	func StringifyAll[E fmt.Stringer](s []E) []string
	```
]

#slide[
	```go
	// StringifyAll converts the elements of a slice to strings and returns the
	// resulting slice.
	func StringifyAll[E fmt.Stringer](s []E) []string {
		out := make([]string, len(s))
		for i, v := range s {
			out[i] = v.String()
		}
		return out
	}
	```
	#pause
	```go

	func usage() {
		durations := []time.Duration{time.Second, time.Minute, time.Hour}
		fmt.Printf("%#v", StringifyAll(durations))
		// []string{"1s", "1m0s", "1h0m0s"}
	}
	```
]

#slide[
	```go
	// StringifyAll converts the elements of a slice to strings and returns the
	// resulting slice.
	func StringifyAll[E any](s []E, stringify func(E) string) []string
	```
]

#slide[
	```go
	// StringifyAll converts the elements of a slice to strings and returns the
	// resulting slice.
	func StringifyAll[E any](s []E, stringify func(E) string) []string {
		out := make([]string, len(s))
		for i, v := range s {
			out[i] = stringify(v)
		}
		return out
	}
	```
	#pause
	```go

	func usage() {
		// time.Time.String has type func(time.Time) string
		strings := StringifyAll(times, time.Time.String)
		// strconv.Itoa has type func(int) string
		strings = StringifyAll(ints, strconv.Itoa)
	}
	```
]

#slide[
	```go
	package slices

	func Compact[E comparable](s []E) []E
	func CompactFunc[E any](s []E, eq func(E, E) bool) []E

	func Compare[E cmp.Ordered](s1, s2 S) int
	func CompareFunc[E1, E2 any](s1 []E1, s2 []E2, cmp func(E1, E2) int) int

	func Sort[E cmp.Ordered](x []E)
	func SortFunc[E any](x []E, cmp func(a, b E) int)

	// etc.
	```
]

#slide[
	```go
	func Sort[E cmp.Ordered](x []E) {
		SortFunc(x, cmp.Compare[E])
	}

	func SortFunc[E any](x []E, cmp func(a, b E) int) {
		// sort in terms of cmp
	}
	```
]

#slide[
	```go
	// Heap implements a Min-Heap using a slice.
	type Heap[E cmp.Ordered] []E
	```
	#pause
	```go
	func (h *Heap[E]) Push(v E) {
		*h = append(*h, v)
		// […]
		if (*h)[i] < (*h)[j] {
			// […]
		}
	}
	```
]

#slide[
	```go
	// HeapFunc implements a Min-Heap using a slice and a custom comparison.
	type HeapFunc[E any] struct {
		Elements []E    
		Compare func(E, E) int
	}
	```
	#pause
	```go
	func (h *HeapFunc[E]) Push(v E) {
		h.Elements = append(h.Elements, v)
		// […]
		if h.Compare(h.Elements[i], h.Elements[j]) < 0 {
			// […]
		}
	}
	```
]

#focus-slide(background: rgb("#007d9d"))[
	= Generic interfaces
]

#slide[
	```go
	type Comparer interface {
		Compare(Comparer) int
	}
	```
	#pause
	```go
	// Does not implement Comparer: Argument has type time.Time, not Comparer
	func (t Time) Compare(u Time) int
	```
]

#slide[
	```go
	type Comparer[T any] interface {
		Compare(T) int
	}
	```
	#pause
	```go
	// implements Comparer[Time]
	func (t Time) Compare(u Time) int
	```
	#pause
	```go
	// E must have a method Compare(E) int
	type HeapMethod[E Comparer[E]] []E
	```
	#pause
	```go
	func (h *HeapMethod[E]) Push(v E) {
		*h = append(*h, v)
		// […]
		if (*h)[i].Compare((*h)[j]) < 0 {
			// […]
		}
	}
	```
]

#slide[
	```go
	func push[E any](s []E, cmp func(E, E) int, v E) []E {
		// […]
		if cmp(s[i], s[j]) < 0 {
			// […]
		}
	}
	```
	#pause
	```go
	func (h *Heap[E]) Push(v E) {
		*h = push(*h, cmp.Compare[E], v)
	}
	```
	#pause
	```go
	func (h *HeapFunc[E]) Push(v E) {
		h.Elements = push(h.Elements, h.Compare, v)
	}
	```
	#pause
	```go
	func (h *HeapMethod[E]) Push(v E) {
		*h = push(*h, E.Compare, v)
	}
	```
]

#focus-slide(background: rgb("#007d9d"))[
	= Pointer constraints
]

#slide[
	```go
	type Message struct {
		Price int // in cents
	}

	func (m *Message) UnmarshalJSON(b []byte) error {
		// { "price": 0.20 }
		var v struct {
			Price json.Number `json:"price"`
		}
		err := json.Unmarshal(b, &v)
		if err != nil {
			return err
		}
		m.Price, err = parsePrice(string(v.Price))
		return err
	}
	```
]

#slide[
	```go
	func Unmarshal[T json.Unmarshaler](b []byte) (T, error) {
		var v T
		err := v.UnmarshalJSON(b)
		return v, err
	}
	```
	#pause
	```go

	func usage() {
		input := []byte(`{"price": 13.37}`)
		// Message does not satisfy json.Unmarshaler
		//   (method UnmarshalJSON has pointer receiver)
		m, err := Unmarshal[Message](input)
		// …
	}
	```
]

#slide[
	```go
	func Unmarshal[T json.Unmarshaler](b []byte) (T, error) {
		var v T
		err := v.UnmarshalJSON(b)
		return v, err
	}
	```
	```go

	func usage() {
		input := []byte(`{"price": 13.37}`)
		// panic: runtime error: invalid memory address or
		//     nil pointer dereference
		m, err := Unmarshal[*Message](input)
		// …
	}
	```
]

#slide[
	```go
	func Unmarshal[T any, PT json.Unmarshaler](b []byte) (T, error) {
		var v T
		err := v.UnmarshalJSON(b)
		return v, err
	}
	```
]

#slide[
	```go
	func Unmarshal[T any, PT json.Unmarshaler](b []byte) (T, error) {
		var v T
		err := v.UnmarshalJSON(b) // v.UnmarshalJSON undefined
		return v, err
	}
	```
]

#slide[
	```go
	func Unmarshal[T any, PT json.Unmarshaler](b []byte) (T, error) {
		var v T
		err := PT(&v).UnmarshalJSON(b) // cannot convert &v to type PT
		return v, err
	}
	```
	#pause
	```go

	type Unmarshaler[T any] interface{
		*T
		json.Unmarshaler
	}
	```
]

#slide[
	```go
	func Unmarshal[T any, PT Unmarshaler[T]](b []byte) (T, error) {
		var v T
		err := PT(&v).UnmarshalJSON(b)
		return v, err
	}
	```
	```go

	type Unmarshaler[T any] interface{
		*T
		json.Unmarshaler
	}
	```
	#pause
	```go

	func usage() {
		input := []byte(`{"price": 13.37}`)
		m, err := Unmarshal[Message, *Message](input)
		// …
	}
	```
]

#slide[
	```go
	func Unmarshal[T any, PT Unmarshaler[T]](b []byte) (T, error) {
		var v T
		err := PT(&v).UnmarshalJSON(b)
		return v, err
	}
	```
	```go

	type Unmarshaler[T any] interface{
		*T
		json.Unmarshaler
	}
	```
	```go

	func usage() {
		input := []byte(`{"price": 13.37}`)
		m, err := Unmarshal[Message](input)
		// …
	}
	```
]

#slide[
	```go
	func Unmarshal[T any, PT Unmarshaler[T]](b []byte, p *T) error {
		return PT(p).UnmarshalJSON(b)
	}

	type Unmarshaler[T any] interface{
		*T
		json.Unmarshaler
	}

	func usage() {
		input := []byte(`{"price": 13.37}`)
		var m Message
		err := Unmarshal(input, &m)
		// …
	}
	```
]


#slide[
	```go
	func Unmarshal[PT json.Unmarshaler](b []byte, p PT) error {
		return p.UnmarshalJSON(b)
	}

	func usage() {
		input := []byte(`{"price": 13.37}`)
		var m Message
		err := Unmarshal(input, &m)
		// …
	}
	```
]

#slide[
	```go
	func Unmarshal(b []byte, p json.Unmarshaler) error {
		return p.UnmarshalJSON(b)
	}

	func usage() {
		input := []byte(`{"price": 13.37}`)
		var m Message
		err := Unmarshal(input, &m)
		// …
	}
	```
]

#focus-slide[
	= Specialization
]

#slide[
	```go
	// UnmarshalText implements the encoding.TextUnmarshaler interface. The time
	// must be in the RFC 3339 format.
	func (t *Time) UnmarshalText(b []byte) error {
		var err error
		*t, err = Parse(RFC3339, string(b))
		return err
	}

	// Parse parses a formatted string and returns the time value it represents.
	func Parse(layout, value string) (Time, error) {
		// parsing code
	}
	```
	#pause
	```go

	func parse[S string|[]byte](layout string, value S) (Time, error) {
		// parsing code
	}
	```
]

#slide[
	```go
	// UnmarshalText implements the encoding.TextUnmarshaler interface. The time
	// must be in the RFC 3339 format.
	func (t *Time) UnmarshalText(b []byte) error {
		var err error
		*t, err = parse(RFC3339, b)
		return err
	}

	// Parse parses a formatted string and returns the time value it represents.
	func Parse(layout, value string) (Time, error) {
		return parse(layout, value)
	}
	```
	```go

	func parse[S string|[]byte](layout string, value S) (Time, error) {
		// parsing code
	}
	```
]

#slide[
	```go
	// error: cannot use value (variable of type S constarined by string|[]byte)
	//   as string value in argument to strings.CutPrefix
	rest, ok := strings.CutPrefix(value, month)
	if !ok {
			return fmt.Errorf("can not parse %q as month name", value)
	}
	```
]

#slide[
	```go
	func cutPrefix[S string|[]byte](s, prefix S) (after S, found bool) {
		for i := 0; i < len(prefix); i++ {
			if i >= len(s) || s[i] != prefix[i] {
				return s, false
			}
		}
		return s[len(prefix):], true
	}
	```
]

#slide[
	```go
	func cutPrefix[S string|[]byte](s, prefix S) (after S, found bool) {
		switch s := any(s).(type) {
		case string:
			s, found = strings.CutPrefix(s, prefix)
			return S(s), found
		case []byte:
			s, found = bytes.CutPrefix(s, prefix)
			return S(s), found
		default:
			panic("unreachable")
		}
	}
	```
]


#focus-slide(background: rgb("#007d9d"))[
	= Phantom types
]

#slide[
	```go
	type X[T any] string
	```
]

#slide[
	```go
	func Parse[T any](r io.Reader) (T, error)
	```
]

#slide[
	```go
	func Parse[T any](r io.Reader) (T, error)






	type buffer struct { /* … */ }




	```
]

#slide[
	```go
	func Parse[T any](r io.Reader) (T, error)






	type buffer struct { /* … */ }

	var buffers = sync.Pool{
		New: func() any { return new(buffer) },
	}
	```
]

#slide[
	```go
	func Parse[T any](r io.Reader) (T, error) {
		b := buffers.Get().(*buffer)
		b.Reset(r)
		defer buffers.Put(b)
		// use the buffer
	}

	type buffer struct { /* … */ }

	var buffers = sync.Pool{
		New: func() any { return new(buffer) },
	}
	```
]

#slide[
	```go
	func Parse[T any](r io.Reader) (T, error) {
		b := buffers.Get().(*buffer[T]) // panics
		b.Reset(r)
		defer buffers.Put(b)
		// use the buffer
	}

	type buffer[T any] struct { /* … */ }

	var buffers = sync.Pool{
		// Can't set New: No known type argument
	}
	```
]

#slide[
	```go
	type key[T any] struct{}
	```
	#pause
	```go

	func usage() {
		var (
			kInt    any = key[int]{}
			kString any = key[string]{}
		)
		fmt.Println(kInt == kInt) // true
		fmt.Println(kString == kString) // false
	}
	```
]

#slide[
	```go
	type key[T any] struct{}
	```
	#pause
	```go

	var bufferPools sync.Map // maps key[T]{} -> *sync.Pool
	```
	#pause
	```go

	func poolOf[T any]() *sync.Pool {
		k := key[T]{}
	```
]

#slide[
	```go
	type key[T any] struct{}
	```
	```go

	var bufferPools sync.Map // maps key[T]{} -> *sync.Pool
	```
	```go

	func poolOf[T any]() *sync.Pool {
		k := key[T]{}
		if p, ok := bufferPools.Load(k); ok {
			return p.(*sync.Pool)
		}
	```
]

#slide[
	```go
	type key[T any] struct{}
	```
	```go

	var bufferPools sync.Map // maps key[T]{} -> *sync.Pool
	```
	```go

	func poolOf[T any]() *sync.Pool {
		k := key[T]{}
		if p, ok := bufferPools.Load(k); ok {
			return p.(*sync.Pool)
		}
		pi, _ := bufferPools.LoadOrStore(k, &sync.Pool{
			New: func() any { return new(T) },
		})
		return pi.(*sync.Pool)
	}
	```
]

#slide[
	```go
	func Parse[T any](r io.Reader) (T, error)
	```
]

#slide[
	```go
	func Parse[T any](r io.Reader) (T, error) {
		pool := poolOf[T]()
	```
]

#slide[
	```go
	func Parse[T any](r io.Reader) (T, error) {
		pool := poolOf[T]()
		b := pool.Get().(*buffer[T])
		b.Reset(r)
		defer pool.Put(b)
		// use the buffer
	}
	```
]

#focus-slide(background: rgb("#007d9d"))[
	= Overengineering
]

#slide[
	```go
	type Client struct { /* … */ }

	func (c *Client) CallFoo(req *FooRequest) (*FooResponse, error)
	func (c *Client) CallBar(req *BarRequest) (*BarResponse, error)
	func (c *Client) CallBaz(req *BazRequest) (*BazResponse, error)
	```
]

#slide[
	```go
	type Client struct { /* … */ }

	func Call[Req, Resp any](c *Client, name string, r Req) (Resp, error)
	```
	#pause
	```go
	const (
		Foo = "Foo"
		Bar = "Bar"
		Baz = "Baz"
	)
	```
	#pause
	```go

	func usage() {
		resp, err := rpc.Call[*rpc.FooRequest, *rpc.FooResponse](c, rpc.Foo, req)
		// …
	```
	#pause
	```go
		resp, err := rpc.Call[*rpc.FooRequest, *rpc.BarResponse](c, rpc.Baz, req)
	}
	```
]

#slide[
	```go
	type Endpoint[Req, Resp any] string
	```
	#pause
	```go
	const (
			Foo Endpoint[*FooRequest, *FooResponse] = "Foo"
			Bar Endpoint[*BarRequest, *BarResponse] = "Bar"
			Baz Endpoint[*BazRequest, *BazResponse] = "Baz"
	)
	```
	#pause
	```go
	func Call[Req, Resp any](c *Client, e Endpoint[Req, Resp], r Req) (Resp, error)
	```
	#pause
	```go

	func usage() {
		r1, err := rpc.Call(c, rpc.Foo, req) // r1 is inferred to be *FooResponse
	```
	#pause
	```go
		// type *rpc.FooRequest of req does not match inferred type *rpc.BazRequest
		r2, err := rpc.Call(c, rpc.Baz, req)
	```
	#pause
	```go
		r3, err := rpc.Call[int, string](c, "b0rk", 42) // compiles, but broken
	}
	```
]

#slide[
	```go
	type Endpoint[Req, Resp any] struct{ name string }
	```
	#pause
	```go
	var (
			Foo = Endpoint[*FooRequest, *FooResponse]{"Foo"}
			Bar = Endpoint[*BarRequest, *BarResponse]{"Bar"}
			Baz = Endpoint[*BazRequest, *BazResponse]{"Baz"}
	)
	```
	#pause
	```go
	func Call[Req, Resp any](c *Client, e Endpoint[Req, Resp], r Req) (Resp, error)
	```
	#pause
	```go

	func usage() {
		// cannot use "b0rk" (untyped string constant) as Endpoint[int, string] value
		r1, err := rpc.Call[int, string](c, "b0rk", 42)
	```
	#pause
	```go
		e := rpc.Endpoint[int, string](rpc.Foo)
		r2, err := rpc.Call(c, e, 42)
	}
	```
]

#slide[
	```go
	type Endpoint[Req, Resp any] struct{ _ [0]Req; _ [0]Resp; name string }
	```
	#pause
	```go
	var (
			Foo = Endpoint[*FooRequest, *FooResponse]{name: "Foo"}
			Bar = Endpoint[*BarRequest, *BarResponse]{name: "Bar"}
			Baz = Endpoint[*BazRequest, *BazResponse]{name: "Baz"}
	)
	```
	#pause
	```go
	func Call[Req, Resp any](c *Client, e Endpoint[Req, Resp], r Req) (Resp, error)
	```
	#pause
	```go

	func usage() {
		// cannot convert rpc.Bar to rpc.Endpoint[int, string]
		e := rpc.Endpoint[int, string](rpc.Bar)
		resp, err := rpc.Call(c, e, req)
	}
	```
]

#focus-slide(background: rgb("#007d9d"))[
	= Go forth and experiment
]
