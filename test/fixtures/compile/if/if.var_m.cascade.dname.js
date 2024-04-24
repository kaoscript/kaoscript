const {Type} = require("@kaoscript/runtime");
module.exports = function() {
	let vals0 = [[[[42]]]];
	let vals1;
	if((Type.isValue(vals0[0]) ? (vals1 = vals0[0], true) : false)) {
		console.log(vals1);
		let vals2;
		if((Type.isValue(vals1[0]) ? (vals2 = vals1[0], true) : false)) {
			console.log(vals2);
			let vals3;
			if((Type.isValue(vals2[0]) ? (vals3 = vals2[0], true) : false)) {
				console.log(vals3);
				let vals4;
				if((Type.isValue(vals3[0]) ? (vals4 = vals3[0], true) : false)) {
					console.log(vals4);
				}
			}
		}
	}
};