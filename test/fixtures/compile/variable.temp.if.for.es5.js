var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var items, __ks_0;
	if(Type.isValue(__ks_0 = foo()) ? (items = __ks_0, true) : false) {
		for(var __ks_0 = 0, __ks_1 = items.length, item; __ks_0 < __ks_1; ++__ks_0) {
			item = items[__ks_0];
			console.log(items);
		}
	}
}