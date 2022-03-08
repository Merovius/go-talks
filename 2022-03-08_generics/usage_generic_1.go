package foo

const ID = provider.ID("fooProvider")

type Request struct { /* … */ }
type Response struct { /* … */ }

func New() provider.Provider[*Request, *Response] {
	return &prov{}
}

func (p *prov) ID() provider.ID { return ID }

func (p *prov) Run(ctx context.Context, pub provider.Publisher[*Response], req *Request) error {
	resp, err := provider.Call[*dep.Request, *dep.Response](ctx, dep.ID, &dep.Request{/*…*/})
	if err != nil { return err }

	pub.Publish[*Response](&Response{/*…*/})
	return nil
}

// INFER OMIT
func f() { // OMIT
	pub.Publish[*Response](&Response{/*…*/})
	// becomes
	pub.Publish(&Response{/*…*/})
	// NOINFER OMIT
	// Can not infer type arguments, as *dep.Response is not in arguments
	provider.Call[*dep.Request, *dep.Response](ctx, dep.ID, &dep.Request{/*…*/})
} // OMIT
