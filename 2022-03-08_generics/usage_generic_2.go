package dep

const ID = provider.ID[*Request, *Response]("depProvider")
// SPLIT OMIT
package foo

func usage() { // OMIT
// Can't use provider.ID[*dep.Request,*dep.Response] as provider.ID[*dep.Request,*Wrong]
resp, err := provider.Call[*dep.Request, *Wrong](ctx, dep.ID, &dep.Request{/*…*/})
// INFER OMIT
resp, err := provider.Call(ctx, dep.ID, &dep.Request{/* … */})
} // OMIT
