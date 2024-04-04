const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let Foobar = Helper.namespace(function() {
		return {};
	});
	return {
		Foobar,
		__ks_Array: {}
	};
};