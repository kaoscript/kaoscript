const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let items, item;
	let __ks_0;
	if(Type.isValue(__ks_0 = foo()) ? (items = __ks_0, true) : false) {
		for(let __ks_2 = 0, __ks_1 = items.length; __ks_2 < __ks_1; ++__ks_2) {
			item = items[__ks_2];
			console.log(items);
		}
	}
};