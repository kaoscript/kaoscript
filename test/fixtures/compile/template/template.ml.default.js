const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function book2xml() {
		return book2xml.__ks_rt(this, arguments);
	};
	book2xml.__ks_0 = function({id, author, title, genre, price}) {
		return Helper.concatString("<book id=\"bk", id, "\">\n	<author>", author, "</author>\n	<title>", title, "</title>\n	<genre>", genre, "</genre>\n	<price>", price, "</price>\n</book>");
	};
	book2xml.__ks_rt = function(that, args) {
		const t0 = Type.isDestructurableObject;
		if(args.length === 1) {
			if(t0(args[0])) {
				return book2xml.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};