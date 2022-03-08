type X struct{}
func (X) F[T any](v T) {}

func FarAwayCode(x X) {
	// Compiler did not know it might need to generate S.F[int]
	fint := x.(interface{ F(int) })
}
