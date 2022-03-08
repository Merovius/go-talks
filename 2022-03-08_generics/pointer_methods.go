package x

import (
	"encoding/json"
)

type Message interface {
	json.Marshaler
	json.Unmarshaler
}

// Illustrative implementation of the relevant parts of Call.
func Call[Req, Resp Message](req Req) (resp Resp, error) {
	b, err := req.MarshalJSON()
	if err != nil { return resp, err }
	// Send bytes over network, get response back
	err := resp.UnmarshalJSON(b)
	if err != nil { return resp, err }
	return resp, nil
}

// END DEFINITION OMIT

type Request struct { /* … */ }
func (m *Request) MarshalJSON() ([]byte, error) { /* … */ }
func (m *Request) UnmarshalJSON(b []byte) error { /* … */ }

type Response struct { /* … */ }
func (m *Response) MarshalJSON() ([]byte, error) { /* … */ }
func (m *Response) UnmarshalJSON(b []byte) error { /* … */ }

func instantiation() { // OMIT
// Error: Request/Response do not implement Message, methods have pointer receivers
resp, err := Call[Request, Response](req)
// Panics: resp.UnmarshalJSON(b) tries to unmarshal into a nil-pointer
resp, err := Call[*Request, *Response](req)
} // OMIT
