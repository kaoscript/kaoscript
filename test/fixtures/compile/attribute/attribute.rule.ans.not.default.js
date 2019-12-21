var {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var Foobar = Helper.struct(function(x, y) {
		const _ = new Dictionary();
		_.x = x;
		_.y = y;
		return _;
	});
};