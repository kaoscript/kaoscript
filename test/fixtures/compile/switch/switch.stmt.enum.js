module.exports = function() {
	let ANSIColor = {
		black: 0,
		red: 1,
		green: 2,
		yellow: 3,
		blue: 4,
		magenta: 5,
		cyan: 6,
		white: 7,
		default: 8
	};
	function color(fg, bg) {
		if(fg === void 0 || fg === null) {
			throw new Error("Missing parameter 'fg'");
		}
		else if(!Type.is(fg, ANSIColor)) {
			throw new Error("Invalid type for parameter 'fg'");
		}
		if(bg === void 0 || bg === null) {
			throw new Error("Missing parameter 'bg'");
		}
		else if(!Type.is(bg, ANSIColor)) {
			throw new Error("Invalid type for parameter 'bg'");
		}
		let fg_code;
		if(fg === ANSIColor.black) {
			fg_code = 30;
		}
		else if(fg === ANSIColor.red) {
			fg_code = 31;
		}
		else if(fg === ANSIColor.green) {
			fg_code = 32;
		}
		else if(fg === ANSIColor.yellow) {
			fg_code = 33;
		}
		else if(fg === ANSIColor.blue) {
			fg_code = 34;
		}
		else if(fg === ANSIColor.magenta) {
			fg_code = 35;
		}
		else if(fg === ANSIColor.cyan) {
			fg_code = 36;
		}
		else if(fg === ANSIColor.white) {
			fg_code = 37;
		}
		else if(fg === ANSIColor.default) {
			fg_code = 39;
		}
		let bg_code;
		if(bg === ANSIColor.black) {
			bg_code = 40;
		}
		else if(bg === ANSIColor.red) {
			bg_code = 41;
		}
		else if(bg === ANSIColor.green) {
			bg_code = 42;
		}
		else if(bg === ANSIColor.yellow) {
			bg_code = 44;
		}
		else if(bg === ANSIColor.blue) {
			bg_code = 44;
		}
		else if(bg === ANSIColor.magenta) {
			bg_code = 45;
		}
		else if(bg === ANSIColor.cyan) {
			bg_code = 46;
		}
		else if(bg === ANSIColor.white) {
			bg_code = 47;
		}
		else if(bg === ANSIColor.default) {
			bg_code = 49;
		}
		return fg_code + ";" + bg_code + "m";
	}
};