extern parseFloat, parseInt

extern sealed class String {
	toLowerCase(): String
}

impl String {
	lines(emptyLines = false): Array { // {{{
		if this.length == 0 {
			return []
		}
		else if emptyLines {
			return this.replace(/\r\n/g, '\n').replace(/\r/g, '\n').split('\n')
		}
		else {
			return this.match(/[^\r\n]+/g) || []
		}
	} // }}}
	lower(): String => this.toLowerCase()
	toFloat(): Number => parseFloat(this)
	toInt(base = 10): Number => parseInt(this, base)
}

export String