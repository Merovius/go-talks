package main

import (
	"strings"

	"github.com/miekg/dns"
)

func handler(w dns.ResponseWriter, r *dns.Msg) {
	q := r.Question[0]
	m := new(dns.Msg)
	m.SetReply(r)
	host := dns.CanonicalName(q.Name)
	host = strings.TrimSuffix(name, ".merovi.us")
	for _, a := range peers[host] {
		if a.Is4() && q.Qtype == dns.TypeA {
			rr, _ := dns.NewRR(host + " 3600 IN A " + a.String())
			m.Answer = append(m.Answer, rr)
		}
		if a.Is6() && q.Qtype == dns.TypeAAAA {
			rr, _ = dns.NewRR(host + " 3600 IN AAAA " + a.String())
			m.Answer = append(m.Answer, rr)
		}
	}
	if len(m.Answer) == 0 {
		m.SetReplyCode(r, dns.RcodeNameError)
	} else {
		m.SetReplyCode(r, dns.RcodeSuccess)
	}
	w.WriteMsg(m)
}
