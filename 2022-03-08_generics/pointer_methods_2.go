package x

import (
	"encoding/json"
)

func Call[TODO](req Req) (resp Resp, error) { // HL
	// Call MarshalJSON on the pointer // HL
	b, err := (&req).MarshalJSON() // HL
	if err != nil { return resp, err }
	// Send bytes over network, get response back
	// Call UnmarshalJSON on the pointer // HL
	err := (&resp).UnmarshalJSON(b) // HL
	if err != nil { return resp, err }
	return resp, nil
}
