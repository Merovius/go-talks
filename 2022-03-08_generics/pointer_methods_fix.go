package x

import (
	"encoding/json"
)

type Message[T any] interface { // HL
	*T // HL
	json.Marshaler
	json.Unmarshaler
}

func Call[Req, Resp any, ReqP Message[Req], RespP Message[Resp]](req Req) (resp Resp, error) { // HL
	b, err := ReqP(&req).MarshalJSON() // HL
	if err != nil { return resp, err }
	// Send bytes over network, get response back
	err := RespP(&resp).UnmarshalJSON(b) // HL
	if err != nil { return resp, err }
	return resp, nil
}

func main() { // OMIT
// This now works
resp, err := Call[Request, Response, *Request, *Response](req)
// The compiler can infer the pointer types ("Constraint type inference"):
resp, err := Call[Request, Response](req)
} // OMIT
