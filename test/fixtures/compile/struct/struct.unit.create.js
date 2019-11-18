var {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var Unit = Helper.struct(function() {
		return new Dictionary;
	});
	const unit = Unit();
};