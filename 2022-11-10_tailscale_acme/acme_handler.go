package acmeserver // import "gonih.org/acmeserver"

type Handler interface {
	Meta() DirectoryMeta
	NewAccount(context.Context, *AccountRequest) error
	NewOrder(context.Context, *OrderRequest) (*Order, error)
	Authorize(context.Context, id acme.AuthzID) (*Authorization, error)
	AcceptChallenge(context.Context, Challenge) (bool, error)
	Finalize(context.Context, []byte, *OrderRequest) (time.Duration, []byte, error)
}

type AccountRequest {
	Key         crypto.PublicKey
	TermsAgreed bool
	Contact     []string
	/* more */
}
type OrderRequest struct { Identifiers []acme.AuthzID; /* more */ }
type Order struct { Authorizations []*Authorization; /* more */ }
type Authorization struct { Challenges []Challenge; /* more */ }
type Challenge struct { Type string; Token string }
