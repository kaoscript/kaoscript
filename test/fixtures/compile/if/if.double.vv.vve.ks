class ValueList {
	getTop(): String => 'foobar'
}

func loadValues(): ValueList {
	return ValueList.new()
}

if {
    var values ?= loadValues()
    var value ?= values.getTop()
}
then {
    echo(`\(value)`)
}