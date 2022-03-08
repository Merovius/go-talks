package provider

type ID[Request, Response Message] string // HL

type Provider[Request, Response Message] interface { // HL
	ID() ID[Request, Response]
	Run(context.Context, Publisher[Response], Request) error
	Close() error
}

type Publisher[Response Message] interface { // HL
	Publish(Response)
}

func Call[Req, Resp Message](context.Context, ID[Req, Resp], Req) (Resp, error) // HL

func Stream[Req, Resp Message](context.Context, ID[Req, Resp], Req) Iterator[Resp] // HL

func usage() { // OMIT
// Error: int does not satisfy provider.Message (missing method MarshalJSON)
// Error: string does not satisfy provider.Message (missing method MarshalJSON)
const ID = provider.ID[int, string]
}

// CALL IMPL OMIT
func Call[Req, Resp Message](ctx context.Context, p ID[Req, Resp], r Req) (Resp, error) {
	buf, _ := r.MarshalJSON()
	// Error: r.Foo undefined (interface Message has no method Foo)
	r.Foo()
}
