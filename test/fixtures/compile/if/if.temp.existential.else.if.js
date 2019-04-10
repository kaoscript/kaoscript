var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function parse(color) {
		if(arguments.length < 1) {
			throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(color === void 0 || color === null) {
			throw new TypeError("'color' is not nullable");
		}
		else if(!(Type.isObject(color) || Type.isString(color))) {
			throw new TypeError("'color' is not of type 'Object' or 'String'");
		}
		if(Type.isString(color)) {
			let match, __ks_0;
			if(Type.isValue(__ks_0 = /^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/.exec(color)) ? (match = __ks_0, true) : false) {
				console.log(match);
			}
			else {
				if(Type.isValue(__ks_0 = /^#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/.exec(color)) ? (match = __ks_0, true) : false) {
					console.log(match);
				}
				else {
					if(Type.isValue(__ks_0 = /^#?([0-9a-f])([0-9a-f])([0-9a-f])([0-9a-f])$/.exec(color)) ? (match = __ks_0, true) : false) {
						console.log(match);
					}
					else {
						if(Type.isValue(__ks_0 = /^#?([0-9a-f])([0-9a-f])([0-9a-f])$/.exec(color)) ? (match = __ks_0, true) : false) {
							console.log(match);
						}
						else {
							if(Type.isValue(__ks_0 = /^rgba?\((\d{1,3}),(\d{1,3}),(\d{1,3})(,([0-9.]+)(\%)?)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
								console.log(match);
							}
							else {
								if(Type.isValue(__ks_0 = /^rgba?\(([0-9.]+\%),([0-9.]+\%),([0-9.]+\%)(,([0-9.]+)(\%)?)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
									console.log(match);
								}
								else {
									if(Type.isValue(__ks_0 = /^rgba?\(#?([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2}),([0-9.]+)(\%)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
										console.log(match);
									}
									else {
										if(Type.isValue(__ks_0 = /^rgba\(#?([0-9a-f])([0-9a-f])([0-9a-f]),([0-9.]+)(\%)?\)$/.exec(color)) ? (match = __ks_0, true) : false) {
											console.log(match);
										}
										else {
											if(Type.isValue(__ks_0 = /^(\d{1,3}),(\d{1,3}),(\d{1,3})(?:,([0-9.]+))?$/.exec(color)) ? (match = __ks_0, true) : false) {
												console.log(match);
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
};