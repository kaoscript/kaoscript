class Quxbaz {
}

func foobar(aType: Quxbaz, bType: Quxbaz) => foobar([aType], [bType])
func foobar(aType: Quxbaz, bTypes: Array<Quxbaz>) => foobar([aType], bTypes)
func foobar(aTypes: Array<Quxbaz>, bType: Quxbaz) => foobar(aTypes, [bType])
func foobar(aTypes: Array<Quxbaz>, bTypes: Array<Quxbaz>) {
}