package main

import (
	"context"
	"net/netip"

	"tailscale.com/client/tailscale"
	"tailscale.com/ipn/ipnstate"
)

func getPeers(ctx context.Context) (peers map[string][]netip.Addr) {
	status, _ := new(tailscale.LocalClient).Status(ctx)
	peers = make(map[string][]netip.Addr)
	add := func(p *ipnstate.PeerStatus) {
		peers[p.HostName] = append(peers[p.HostName], p.TailscaleIPs...)
	}
	add(status.Self)
	for _, peer := range status.Peer {
		add(peer)
	}
	return peers
}
