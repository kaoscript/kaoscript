var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		let data = 42;
		if(true) {
		}
		else if(false) {
			let __ks_data_1;
			while(Type.isValue(__ks_data_1 = quxbaz())) {
				console.log(__ks_data_1);
			}
			console.log(data);
		}
		console.log(data);
	}
	function quxbaz() {
	}
};