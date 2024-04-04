#![libstd(off)]

import '../_/_string.ks'

extern console

func foo(): Array<String> => ['1', '8', 'F']

var dyn items = [item.toInt(16) for item in foo()]