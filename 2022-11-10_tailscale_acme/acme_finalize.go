package main

import (
	c "context"
	t "time"
)

func (*handler) Finalize(ctx c.Context, csr []byte, o *OrderRequest) (t.Duration, []byte, error) {
	host := o.Identifiers[0].Value
	// acmeClient does the ACME DNS-01 challenge via Cloudflare
	certs, err := acmeClient.GetCertificate(ctx, csr, host)
	return 0, certs, err
}
