func fib(m, n) => [n, m + n]

var f = [1, 1]
	*|> fib
	*|> fib
	*|> fib
	*|> fib