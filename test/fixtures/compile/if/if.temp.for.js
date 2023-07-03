const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let items, item;
	let __ks_0;
	if(Type.isValue(__ks_0 = foo()) ? (items = __ks_0, true) : false) {
		for(let __ks_1 = 0, __ks_0 = items.length; __ks_1 < __ks_0; ++__ks_1) {
			item = items[__ks_1];
			console.log(items);
		}
	}
};