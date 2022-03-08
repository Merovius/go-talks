package provider

type Publisher[Response any] interface {
	Publish(Response)
}

type Provider[Request, Response any] interface {
	ID() ID
	Run(context.Context, Publisher[Response], Request) error
	Close() error
}

func Call[Request, Response any](context.Context, ID, Request) (Response, error)

func Stream[Request, Response any](context.Context, ID, Request) Iterator[Response]

type Iterator[Response any] interface {
	Next() bool
	Resp() Response
}
