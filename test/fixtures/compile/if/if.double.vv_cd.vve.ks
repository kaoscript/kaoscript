class ValueList {
	getTop() :> 'foobar'
	hasValues() :> true
}

func loadValues(): ValueList {
	return ValueList.new()
}

if {
    var values ?= loadValues() ;; values.hasValues()
    var value ?= values.getTop()
}
then {
    echo(`\(value)`)
}