const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Array = {};
	let Foobar = Helper.namespace(function() {
		return {};
	});
	return {
		Foobar,
		__ks_Array
	};
};