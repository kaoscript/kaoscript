const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let values = [[[[42]]]];
	let __ks_values_1;
	if((Type.isValue(values[0]) ? (__ks_values_1 = values[0], true) : false)) {
		console.log(__ks_values_1);
		let __ks_values_2;
		if((Type.isValue(__ks_values_1[0]) ? (__ks_values_2 = __ks_values_1[0], true) : false)) {
			console.log(__ks_values_2);
			let __ks_values_3;
			if((Type.isValue(__ks_values_2[0]) ? (__ks_values_3 = __ks_values_2[0], true) : false)) {
				console.log(__ks_values_3);
				let __ks_values_4;
				if((Type.isValue(__ks_values_3[0]) ? (__ks_values_4 = __ks_values_3[0], true) : false)) {
					console.log(__ks_values_4);
				}
			}
		}
	}
};