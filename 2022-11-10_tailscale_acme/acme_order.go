package main

import (
	"context"
	"errors"
)

func (h *handler) NewOrder(ctx context.Context, req *OrderRequest) (*Order, error) {
	if len(req.Identifers) != 1 {
		return nil, errors.New("need exactly one domain")
	}
	creds := ctx.Value(credsKey{}).(tsCreds)
	if id := req.Identifiers[0]; id.Type != "dns" || id.Value != creds.Name {
		return nil, errors.New("forbidden identifier")
	}
	// validate rest of Order by policy
	return &Order{
		Authorizations: []*Authorization{
			{
				Identifier: req.Identifiers[0],
				Challenges: nil, // We already know they are who they say
			},
		},
	}
}
