#import "@preview/polylux:0.4.0": *
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
	#toolbox.side-by-side(columns: (1fr, 3fr, 1fr))[
		#image("zurich_gophers.png", height: 5cm, width: 5cm)
	][
	== So you want to add variants to Go?
	
	Axel Wagner

	https://blog.merovius.de/

	#link("https://chaos.social/@Merovius")[\@Merovius\@chaos.social]

	2025-11-06
	][
		#box(clip: true, radius: 5cm, width: 5cm, height: 5cm, image("avatar.jpg", height: 5cm))
	]
]

#slide[
	= Prior art

	#show: later
	#place(top+left, dy: 1.5cm, rect(inset: 0pt, outset: 0pt, image("haskell.png", height: 2.8cm)))
	#show: later
	#place(top+right, dx: 0.5cm, dy: 0cm, rect(inset: 0pt, outset: 0pt, image("rust.png", height: 3.5cm)))
	#show: later
	#place(top+left, dy: 4.8cm, rect(inset: 0pt, outset: 0pt, image("java_csharp.png", height: 4cm)))
	#show: later
	#place(top+right, dx: 0.5cm, dy: 8.5cm, rect(inset: 0pt, outset: 0pt, image("c.png", height: 6.3cm)))
	#show: later
	#place(top+right, dx: 0.5cm, dy: 4cm, rect(inset: 0pt, outset: 0pt, image("typescript.png", height: 4.2cm)))
	#show: later
	#place(top+left, dx: 2.4cm, dy: 7.2cm, rect(inset: 0pt, outset: 0pt, image("python.png", height: 7.7cm)))
]

#slide[
	#place(horizon, image("proposal.png"))
	#show: later
	#place(horizon, image("proposal_scream.png"))
]

#focus-slide[
	= What people want
]

#slide[
	== What people want: closed list

	```go
	type Circle struct { Radius float64 }
	type Square struct { Side float64 }
	type Rectangle struct { Height, Width float64 }

	type Shape enum {
		Circle
		Square
		Rectangle
	}

	// Type error: Ellipsis is not in Shape
	var s Shape = Ellipsis{}
	```
	#show: later
	#v(0.5cm)
	Note: in this talk, I will *not worry* about specific syntax.
]

#slide[
	== What people want: exhaustiveness check

	```go
	func F(s Shape) {
		switch s := s.(type) {
		case Circle:
			DoCircleThing(s)
		case Square:
			DoSquareThing(s)
		// compiler error: missing case Rectangle
		}
	}
	```
]

#slide[
	== What people want: well-defined state

	```go
	type Result[T any] enum {
		T
		error
	}

	// GetThing returns either a Thing, or an error;
	// never both and never neither.
	func GetThing() Result[Thing]
	```
]

#focus-slide[
	= Design space
]

#slide[
	== Unions and Sums

	#show: later
	#align(center)[Union:
	#image("union.svg")]
	#show: later
	#align(center)[Sum:
	#image("sum.svg")]
]

#slide[
	== Unions and Sums (concretely)

	#toolbox.side-by-side(colums: (1fr, 2fr))[
		Typescript has unions:
		```typescript
		type MyUnion = number | string;
		let x: MyUnion;
		x = 42;
		x = "Hello, world";
		```
	][
		Rust has sums:
		```rust
		enum MySum {
		    Int(i64),
		    String(&'static str),
		}


		fn main() {
		    let mut x: MySum;
		    x = MySum::Int(42);
		    x = MySum::String("Hello, world");
		}
		```
	]
]

#slide[
	== Unions and Sums (concretely)

	#toolbox.side-by-side(colums: (1fr, 2fr))[
		Pretending go had unions:
		```go
		type MyUnion union {
			int,
			string,
		}

		
		func main() {
			var x MyUnion
			x = 42;
			x = "Hello, world";
		}
		```
	][
		Rust has sums:
		```rust
		enum MySum {
		    Int(i64),
		    String(&'static str),
		}


		fn main() {
		    let mut x: MySum;
		    x = MySum::Int(42);
		    x = MySum::String("Hello, world");
		}
		```
	]
]

#slide[
	== Unions and Sums (concretely)

	#toolbox.side-by-side(colums: (1fr, 2fr))[
		Pretending go had unions:
		```go
		type MyUnion union {
			int,
			string,
			time.Duration,
		}
		
		func main() {
			var x MyUnion
			x = 42; // int or time.Duration?
			x = "Hello, world";
		}
		```
	][
		Rust has sums:
		```rust
		enum MySum {
		    Int(i64),
		    String(&'static str),
		    Duration(i64),
		}

		fn main() {
		    let mut x: MySum;
		    x = MySum::Int(42); // clearly Int
		    x = MySum::String("Hello, world");
		}
		```
	]
]

#slide[
	== Unpacking
]

#slide[
	== Unpacking
	
	- Overlapping cases?
]

#slide[
	== Unpacking
	
	- Overlapping cases?
	- Exhaustiveness check?
]

#slide[
	== Unpacking
	
	- Overlapping cases?
	- Exhaustiveness check?
	- Forced `default`?
]

#slide[
	== Unpacking
	
	- Overlapping cases?
	- Exhaustiveness check?
	- Forced `default`?
	- Pattern matching?

	#show: later
	```rust
	fn degenerate(s: &Shape) -> bool {
		match s {
			Shape::Circle(0.0) => true,
			Shape::Square(0.0) => true,
			Shape::Rectangle(0.0, _) => true,
			Shape::Rectangle(_, 0.0) => true,
			_ => false,
		}
	}
	```
]

#slide[
	== Gradual code repair

	Principle: APIs should be interoperable, when moved from one package to another.
	
	#show: later
	```go
	package context // import "golang.org/x/net/context"
	import "context"
	type Context = context.Context
	```

	#show: later
	#toolbox.side-by-side(columns: (1fr, 1fr))[
		#align(center, image("gradual_repair_1.svg", height: 6cm))
	][
		#hide(align(center+horizon)[*Exhaustive switch checking breaks gradual repair!*])
	]
]

#slide[
	== Gradual code repair

	Principle: APIs should be interoperable, when moved from one package to another.
	
	```go
	package context // import "golang.org/x/net/context"
	import "context"
	type Context = context.Context
	```

	#toolbox.side-by-side(columns: (1fr, 1fr))[
		#align(center, image("gradual_repair_2.svg", height: 6cm))
	][
		#hide(align(center+horizon)[*Exhaustive switch checking breaks gradual repair!*])
	]
]

#slide[
	== Gradual code repair

	Principle: APIs should be interoperable, when moved from one package to another.
	
	```go
	package context // import "golang.org/x/net/context"
	import "context"
	type Context = context.Context
	```

	#toolbox.side-by-side(columns: (1fr, 1fr))[
		#align(center, image("gradual_repair_3.svg", height: 6cm))
	][
		#show: later
		#align(center+horizon)[*Exhaustive switch checking breaks gradual repair!*]
	]
]

#slide[
	== Zero values

	Every Go type needs a *zero value*, which should be represented by 0 bytes
]

#slide[
	== Zero values

	Every Go type needs a *zero value*, which should be represented by 0 bytes

	1. Use zero value of "default term"
]

#slide[
	== Zero values

	Every Go type needs a *zero value*, which should be represented by 0 bytes

	1. Use zero value of "default term"
		- Default is explicitly marked
		- Default is implied by order (usually the first term)
]

#slide[
	== Zero values

	Every Go type needs a *zero value*, which should be represented by 0 bytes

	1. Use zero value of "default term"
		- Default is explicitly marked
		- Default is implied by order (usually the first term)
	2. Use sentinel for "no value"
]

#focus-slide[
	= Variants in Go

	// So let's talk about what all of that means for fitting variant types into Go.
]

#slide[
	== Union elements

	```go
	type Shape interface{ Circle | Square | Rectangle }

	func F[S Shape](v S) {}
	// cannot use type Shape outside a type constraint:
	//   interface contains type constraints
	func G(v Shape) {}
	```
]

#slide[
	== Union elements

	```go
	type Shape interface{ Circle | Square | Rectangle }

	func F[S Shape](v S) {}


	func G(v Shape) {
		// unpacking via type switch:
		switch v := v.(type) {
		case Circle:
		case Square:
		case Rectangle:
		}
	}
	```

	Proposal: #link("https://github.com/golang/go/issues/57644")[\#57644]
]

#slide[
	== Consequence: nested unions

	```go
	type Signed interface { int8 | … | int64 }
	type Unsigned interface{ uint8 | … | uint64 }

	type Integer interface { Signed | Unsigned }
	```
]

#slide[
	== Consequence: nested unions

	```go
	type Signed interface { int8 | … | int64 }
	type Unsigned interface{ uint8 | … | uint64 }

	type Integer interface { Signed | Unsigned }
	type Integer2 interface{ int8 | … | int64 | uint8 | … | uint64 }
	```
	Should remain the same ⇒ no nested unions.
]

#slide[
	== Consequence: interface terms

	```go


	type Result[T] interface{ T | error }
	```
]

#slide[
	== Consequence: interface terms

	```go
	// error: term cannot be a type parameter
	// error: cannot use error in union (error contains methods)
	type Result[T] interface{ T | error }
	```
	Interfaces with methods disallowed ⇒ no interfaces in unions.

	More details: blog post and talk #link("https://blog.merovius.de/posts/2024-01-05_constraining_complexity/")["Constraining Complexity in the Generics Design"]
]

#slide[
	== Consequence: zero value

	```go
	type Union interface{ int | string }
	```
	Must remain valid ⇒ cannot require explicit default.
	#show: later
	```go
	type Union2 interface{ string | int }
	```
	Should remain the same as `Union` ⇒ cannot use order for default.
	#show: later

	⇒ We must make the zero value `nil`.
]

#slide[
	== Consequence: type switch

	```go
	type Reader interface{ *bytes.Reader | *strings.Reader | int }
	func F(r Reader) {
		switch r := r.(type) {
		case io.Reader:
		case *bytes.Reader: // never taken
		// case int not handled
		}
	}
	```

	Consistency:

	- No exhaustiveness check
	- No forced default
	- Overlapping cases allowed (choose first match)
]


#slide[
	== Sum types

	Alternative: add proper sum types.

	#show: later
	Relatively easy to design (e.g. #link("https://github.com/golang/go/issues/54685")[Proposal: unions as sigma types (\#54685)]).

	#show: later
	Downside: Two concepts of "closed list of types", with different uses, different syntax and different restrictions.

	#show: later
	⇒ Probably too confusing and hard to learn.
]

#slide[
	== Conclusion

	There are three realistic options:
]

#slide[
	== Conclusion

	There are three realistic options:

	1. Use existing union-elements: relatively low benefit, likely disappointing.
]

#slide[
	== Conclusion

	There are three realistic options:

	1. Use existing union-elements: relatively low benefit, likely disappointing.
	2. Add proper sum types: too redundant with union elements.
]

#slide[
	== Conclusion

	There are three realistic options:

	1. Use existing union-elements: relatively low benefit, likely disappointing.
	2. Add proper sum types: too redundant with union elements.
	3. Do nothing and leave Go without variants.
]

#slide[
	== Conclusion

	There are three realistic options:

	1. Use existing union-elements: relatively low benefit, likely disappointing.
	2. Add proper sum types: too redundant with union elements.
	3. Do nothing and leave Go without variants.

	As the first two options are not clearly good, we are so far stuck with the third.
]

#focus-slide[
	= Thank you
]
