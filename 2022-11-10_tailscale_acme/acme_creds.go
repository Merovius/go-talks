package main

import (
	"net"
	"net/http"

	"tailscale.com/client/tailscale"
)

func main() {
	srv := &http.Server{ConnContext: connContext /* … */}
	// …
}

type tsCreds struct {
	Name string   // Hostname of peer
	Tags []string // Machine Tags
	Caps []string // Extra capabilities (based on Tags, Machine owner, ACLs…)
}
type credsKey struct{}

func connContext(ctx context.Context, c net.Conn) context.Context {
	addr := c.RemoteAddr().String()
	whois, _ := new(tailscale.LocalClient).WhoIs(ctx, addr)
	return context.WithVale(ctx, credsKey{}, tsCreds{
		Name: whois.Node.ComputedName,
		Tags: whois.Node.Tags,
		Caps: whois.Caps,
	})
}
