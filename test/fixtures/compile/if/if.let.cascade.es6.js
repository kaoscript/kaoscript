var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let values = [[[[42]]]];
	{
		let __ks_values_1 = values[0];
		if(Type.isValue(__ks_values_1)) {
			console.log(__ks_values_1);
			{
				let __ks_values_2 = __ks_values_1[0];
				if(Type.isValue(__ks_values_2)) {
					console.log(__ks_values_2);
					{
						let __ks_values_3 = __ks_values_2[0];
						if(Type.isValue(__ks_values_3)) {
							console.log(__ks_values_3);
							{
								let __ks_values_4 = __ks_values_3[0];
								if(Type.isValue(__ks_values_4)) {
									console.log(__ks_values_4);
								}
							}
						}
					}
				}
			}
		}
	}
};