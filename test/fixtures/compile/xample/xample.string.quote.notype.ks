extern sealed class String

impl String {
	quote(quote: String = '"', escape: String): String => quote + this.replaceAll(escape, escape + escape).replaceAll(quote, escape + quote) + quote
	replaceAll(find: String, replacement: String): String => this
}