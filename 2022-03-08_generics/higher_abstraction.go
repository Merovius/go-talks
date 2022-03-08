func Sort[T constraints.Ordered](s []T) {
	sort.Slice(s, func(i, j int) bool {
		return s[i] < s[j]
	})
}

func Example() {
	f := Sort      // Error: Sort must be fully instantiated
	f := Sort[int] // OK
}
