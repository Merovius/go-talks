package provider

type ID[Request, Response any] string // HL

type Provider[Request, Response any] interface {
	ID() ID[Request, Response] // HL
	Run(context.Context, Publisher[Response], Request) error
	Close() error
}

type Publisher[Response any] interface {
	Publish(Response)
}

func Call[Req, Resp any](context.Context, ID[Req, Resp], Req) (Resp, error) // HL

func Stream[Req, Resp any](context.Context, ID[Req, Resp], Req) Iterator[Resp] // HL
