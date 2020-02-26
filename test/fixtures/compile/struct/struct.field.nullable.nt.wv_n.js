var {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var Foobar = Helper.struct(function(x = null) {
		const _ = new Dictionary();
		_.x = x;
		return _;
	});
	const f = Foobar("");
	f.x = null;
};