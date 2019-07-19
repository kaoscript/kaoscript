#[flags]
enum Foobar {
	NoFeatures			// 0

	Feature1			// 2^0 = 1
	Feature2			// 2^1 = 2
	Feature3			// 2^2 = 4

	Feature4	= 4		// 2^3 = 8

	Feature32	= 32	// 2^31

	Feature53	= 53	// 2^52
}