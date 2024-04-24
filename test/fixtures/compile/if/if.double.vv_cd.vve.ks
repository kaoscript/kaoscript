class ValueList {
	getTop(): String? => 'foobar'
	hasValues(): Boolean => true
}

func loadValues(): ValueList? {
	return ValueList.new()
}

if {
    var values ?= loadValues() ;; values.hasValues()
    var value ?= values.getTop()
}
then {
    echo(`\(value)`)
}