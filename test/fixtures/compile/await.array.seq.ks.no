func foo() async => 42

func doAsyncOp() async => [await foo(), await foo()]