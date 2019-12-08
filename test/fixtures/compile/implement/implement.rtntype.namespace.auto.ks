extern console

namespace NS {
}

impl NS {
	foobar(): auto => 'foobar'
}

console.log(`\(NS.foobar())`)

export NS