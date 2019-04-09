var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	var values = [[[[42]]]];
	var __ks_values_1 = values[0];
	if(Type.isValue(__ks_values_1)) {
		console.log(__ks_values_1);
		var __ks_values_2 = __ks_values_1[0];
		if(Type.isValue(__ks_values_2)) {
			console.log(__ks_values_2);
			var __ks_values_3 = __ks_values_2[0];
			if(Type.isValue(__ks_values_3)) {
				console.log(__ks_values_3);
				var __ks_values_4 = __ks_values_3[0];
				if(Type.isValue(__ks_values_4)) {
					console.log(__ks_values_4);
				}
			}
		}
	}
};