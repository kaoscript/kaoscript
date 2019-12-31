var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	var __ks_Array = {};
	let Foobar = Helper.namespace(function() {
		return {};
	});
	return {
		Foobar: Foobar,
		__ks_Array: __ks_Array
	};
};