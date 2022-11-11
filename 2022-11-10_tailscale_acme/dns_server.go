package main

import (
	"log"
	"net"

	"github.com/miekg/dns"
)

func main() {
	dns.HandleFunc("merovi.us", handler)
	srv := &dns.Server{
		Addr: net.JoinHostPort(tailscaleIP, "53"),
		Net:  "udp",
	}
	log.Fatal(srv.ActivateAndServe())
}

func handler(w dns.ResponseWriter, r *dns.Msg) {
	// …
}
