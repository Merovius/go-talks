package foo

const ID = provider.ID("fooProvider")
type Request struct { /* … */ }
type Response struct { /* … */ }
func New() provider.Provider               { return &prov{} }
type prov struct { /* … */ }
func (p *prov) ID() provider.ID            { return ID }
func (p *prov) RequestType() reflect.Type  { return reflect.TypeOf(Request) }
func (p *prov) ResponseType() reflect.Type { return reflect.TypeOf(Response) }
func (p *prov) Run(ctx context.Context, pub provider.Publisher, req Message) error {
	r := req.(*Request)
	msg, err := provider.Call(ctx, dep.ID, &dep.Request{ /*…*/ })
	if err != nil {
		return err
	}
	subresp := msg.(*dep.Response)
	pub.Publish(&Response{ /*…*/ })
	return nil
}
