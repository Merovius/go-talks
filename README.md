# Go talks

These are slides for a couple of Go-related talks I gave using the
[Go present too](https://pkg.go.dev/golang.org/x/tools/present).

There used to be a publicly hosted version of it that you could just point at a
repository and it would render them, but that doesn't seem to be working
lately. So to look at the rendered slides, you have to install the present tool
yourself:

```
$ go install golang.org/x/tools/present@v0.3.0
$ present -base $(go env GOMODCACHE)/golang.org/x/tools@v0.3.0/cmd/present
```
