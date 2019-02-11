[kaoscript](https://github.com/kaoscript/kaoscript)
===================================================

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![NPM Version](https://img.shields.io/npm/v/kaoscript.svg)](https://www.npmjs.com/package/kaoscript)
[![Dependency Status](https://badges.depfu.com/badges//count.svg)](https://depfu.com/github/kaoscript/kaoscript)
[![Build Status](https://travis-ci.org/kaoscript/kaoscript.svg?branch=master)](https://travis-ci.org/kaoscript/kaoscript)
[![CircleCI](https://circleci.com/gh/kaoscript/kaoscript/tree/master.svg?style=shield)](https://circleci.com/gh/kaoscript/kaoscript/tree/master)
[![Coverage Status](https://img.shields.io/coveralls/kaoscript/kaoscript/master.svg)](https://coveralls.io/github/kaoscript/kaoscript)
[![Known Vulnerabilities](https://snyk.io/test/github/kaoscript/kaoscript/badge.svg)](https://snyk.io/test/github/kaoscript/kaoscript)
[![Waffle.io](https://img.shields.io/badge/kanban-waffle.io-blue.svg)](https://waffle.io/kaoscript/kaoscript)
[![Gitter](https://img.shields.io/gitter/room/kaoscript/kaoscript.svg)](https://gitter.im/kaoscript/kaoscript)

[![NPM](https://nodei.co/npm/kaoscript.png?downloads=true&stars=true)](https://www.npmjs.com/package/kaoscript)

Kaoscript is a language that compile to regular Javascript.
It takes ideas from ES6, ES7, CoffeeScript, Swift, Rust, Dart, Spider, TypeScript, Haxe, C#, Java.

Why?
----

I have only one main reason: it's **not recommended to extends natives classes** to avoid any conflict with a JavaScript engine or a dependency.
Because of that, your code consistency is broken!
For example, to call the array's functions `map` and `clone`, it is written differently:
- `array.map(...)`
- `_.clone(array)`

So how *kaoscript* is different?

*kaoscript* compiles `array.clone()` to `_.clone(array)` so you can keep your code consistency.


Additionally, I don't mind callbacks but **async/await are easier to read** but it will be only available for ES7.

Status
------

It is still in an **experimental state** due to **major missing features** (macro, trait, mixin and operator overloading).

Features
--------

- **easy syntax**: close to ES6 and Swift
- **fully OOP**: extendable native classes but fully compatible with the node.js
- **partial/impl paradigm**
- **async/await**: don't wait ES7
- **check variables existences**
- **automatically declare variable**: `i = 0` => `let i = 0`
- **array range**
- **for/to, for/til, for/in, for/of, for/range, until**: no more `for(;;)`
- **comprehensions**
- **typed or not** `let i = 0` or `let i: Number = 0`
- **type alias**: `type float = Number`
- **generics**
- **automatic typing**: on assignement with operator `:=`
- **chained operations**: `1 < x < 10`
- **enum**
- **import/export**: `import` is the equivalent of node.js `require`
- **require**: declare requirements (only for a module)
- **extern**: explicit global scope
- **attributes**
- **advanced parameters**
- **error handling**: by default, it's à la Java but it's configurable
- **conditional compilation**
- **typed import**: import non-kaoscript objects and indicate their types

Getting Started
---------------

With [node](http://nodejs.org) previously installed:

	npm install -g kaoscript

Executes the file `hello.ks`:
```
#![bin]

extern console

console.log('Hello World!')
```
with the command line `kaoscript hello.ks`, you will get `Hello World!`.

Module
------

By default, a koascript file is a module.
The global atttribute `#![bin]` indicates that the file is a binary file (i.e. it executes itself like usual javascript file)

For Node, a module file will look as:
```
module.exports = function() {
	...your code...
}
```

Alien Dependencies
------------------

There are three basics ways to add external dependencies:
- `extern`: from the global scope (`extern console`)
- `import`: from other dependencies (`import 'fs' for readFile`)
- `require`: from the module parameters (`require foo` -> `module.exports = function(foo)`)

Three combined ways:
- `extern|require`: first look into the global scope, and if not found, look into the module parameters
- `require|extern`: first look into the module parameters, and if not found, look into the global scope
- `require|import`: first look into the module parameters, and if not found, import it

Array
-----

```kaoscript
let foo = [1, 2, 3]
```

```kaoscript
let a = [1..5]
// 1, 2, 3, 4, 5

let b = [1..<5]
// 1, 2, 3, 4

let c = [1<..5]
// 2, 3, 4, 5

let d = [1<..<5]
// 2, 3, 4

let e = [1..6..2]
// 1, 3, 5

let f = [1<..<6..2]
// 3, 5

let g = [5..1]
// 5, 4, 3, 2, 1

let h = [5..1..2]
// 5, 3, 1

let i = [1..2..0.3]
// 1.0, 1.3, 1.6, 1.9
```

```kaoscript
let min = 1
let max = 5

let a = [min..max]
// 1, 2, 3, 4, 5
```

Function
--------

```kaoscript
import './_number.ks'

extern console, parseFoat

func alpha(n: Number, percentage = false): float {
	let i: Number = parseFoat(n)

	return 1 if i is NaN else (percentage ? i / 100 : i).limit(0, 1).round(3)
}
```

Async/Await
-----------

```kaoscript
import './_string.ks'
import 'child_process' for exec

const df_regex = /([\/[a-z0-9\-\_\s]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+%)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+%)\s+(\/.*)/i

func disks() async {
	let stdout: string, stderr = await exec('df -k')

	let disks = []
	let matches: Array<String?>
	for line in stdout.lines() {
		matches = df_regex.exec(line)

		if matches {
			disks.push({
				device: matches[1].trim(),
				mount: matches[9],
				total: matches[2].toInt() * 1024,
				used: matches[3].toInt() * 1024,
				available: matches[4].toInt() * 1024
			})
		}
	}

	return disks
}

let d = await disks()
```

Loop
----

```kaoscript
for x from 0 to 10 {
	console.log(x)
}
// 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

for x from 0 til 10 {
	console.log(x)
}
// 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
```

```kaoscript
heroes = ['leto', 'duncan', 'goku']

for hero, index in heroes when index % 2 == 0
{
	console.log(hero)
}
// leto, goku
```

```kaoscript
heroes = ['leto', 'duncan', 'goku']

for hero in heroes until hero == 'duncan'
{
	console.log(hero)
}
// leto
```

```kaoscript
likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

for key, value of likes {
	console.log(`\(key) likes \(value)`)
}
// leto likes spice
// paul likes chani
// duncan likes murbella
```

Comprehensions
--------------

```kaoscript
likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

spicyHeroes = [hero for hero, like of likes when like == 'spice']
// spicyHeroes = ['leto']
```

Class
-----

```kaoscript
extern console: {
	log(...args)
}

class Shape {
	private {
		_color: String
	}

    constructor(@color)
	// automatically set the instance variable '_color' as the parameter 'color'

	destructor() {
		@color = null
	}

	color() => @color
	color(@color) => this

    draw(): String {
        return `I'm drawing with a \(@color) pen.`
    }
}

class Rectangle extends Shape {
    draw() {
        return `\(super()) I'm drawing a \(@color) rectangle.`
    }
}

let r = new Rectangle('black')

console.log(r.draw())
// I'm drawing with a black pen. I'm drawing a black rectangle.


impl Shape {
	draw(shape): String {
		return `I'm drawing a \(@color) \(shape).`
	}
}
// adds dynamically the method 'draw(shape)' to the class 'Shape'

let s = new Shape('red')

console.log(s.draw())
// I'm drawing with a red pen

console.log(s.draw('circle'))
// I'm drawing a red circle.
```

Override native class
---------------------

```kaoscript
extern console, isNaN

extern sealed class Number
// 'sealed' avoid to directly extends the class Number

impl Number {
	mod(max): Number {
		if isNaN(this) {
			return 0
		}
		else {
			let n = this % max
			if n < 0 {
				return n + max
			}
			else {
				return n
			}
		}
	}
}
// adds dynamically the method 'mod' to the class 'Number'

let i = 42

console.log(i.mod(2))
// throw an error that 'mod' is not defined

let j: Number = 42
// typed as a Number

console.log(j.mod(2))
// <- 0
// javascript code: console.log(__ks_Number._im_mod(j, 2))
```

Abstract class
--------------

```kaoscript
abstract class AbstractGreetings {
	private {
		_message: String: ''
	}

	constructor() {
		this('Hello!')
	}

	constructor(@message)

	abstract greet(name): String
}

class Greetings extends AbstractGreetings {
	greet(name) => `\(@message)\nIt's nice to meet you, \(name).`
}
```

Parameters
----------

```kaoscript
require expect: func

func foo(u = null, v, x, y = null, z = null) {
	return [u, v, x, y, z]
}

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(foo(1, 2)).to.eql([null, 1, 2, null, null])

expect(foo(1, 2, 3)).to.eql([1, 2, 3, null, null])

expect(foo(1, 2, 3, 4)).to.eql([1, 2, 3, 4, null])

expect(foo(1, 2, 3, 4, 5)).to.eql([1, 2, 3, 4, 5])
```

|                              | Required | Nullable | Typed | Default Value |
| ---------------------------- | -------- | -------- | ----- | ------------- |
| `foo(x)`                     | YES      |          |       |               |
| `foo(x?)`                    | YES      | YES      |       |               |
| `foo(x = null)`              |          | YES      |       | YES           |
| `foo(x = 'foobar')`          |          |          |       | YES           |
| `foo(x: String)`             | YES      |          | YES   |               |
| `foo(x: String?)`            | YES      | YES      | YES   |               |
| `foo(x: String = null)`      |          | YES      | YES   | YES           |
| `foo(x: String = 'foobar')`  |          |          | YES   | YES           |
| `foo(x: String? = null)`     |          | YES      | YES   | YES           |
| `foo(x: String? = 'foobar')` |          | YES      | YES   | YES           |

Enum
----

```kaoscript
extern console

enum Color {
	Red
	Green
	Blue
}

let color = Color::Red

console.log(color)
// 0
```

```kaoscript
enum CardSuit<String> {
	Clubs
	Diamonds
	Hearts
	Spades
}

let card = CardSuit::Clubs

console.log(card)
// clubs
```

Switch
------

```kaoscript
extern console

let number = 13

switch number {
	1               => console.log("One!")
	2, 3, 5, 7, 11  => console.log("This is a prime")
	13..19          => console.log("A teen")
	                => console.log("Ain't special")
}
```

Error Handling
--------------

```
try {
	console.log('foobar')
}
on RangeError catch error {
	console.log('RangeError', error)
}
catch error {
	console.log('Error', error)
}
finally {
	console.log('finally')
}
```

```
try {
	console.log('foobar')
}
on RangeError {
	console.log('RangeError')
}
catch {
	console.log('Error')
}
```

```kaoscript
try {
	foo()
}

func foo(name): String ~ Error {
	if name == 'foobar' {
		throw new Error(`Invalid name '\(name)'`)
	}

	return name
}

#[error(off)]
func bar() {
	validate('toto')
}
```

Conditional Compilation
-----------------------

```kaoscript
#[if(any(trident, safari-v8))]
impl String {
	startsWith(value: String): Boolean => this.length >= value.length && this.slice(0, value.length) == value
}
```

Compilation Steps
-----------------

1. parsing
2. analysing
  - include files
  - declare variables (type, class, import, extern, assignement, ...)
  - validate variables are existing
3. preparing
  - generate signature
  - acquire temp variables
4. translating
5. formatting

Runtime
-------

Kaoscript needs a runtime to add dynamics functions on classes (`Helper`) and to do type checking (`Type`).

The runtime is imported only when it's needed.

It can be configured with global attributes like `#![runtime(package="yourpackage")]`.

The default runtime (`@kaoscript/runtime`) has only the bare minimum.

Syntax Highlighting
-------------------

- [ACE](https://github.com/kaoscript/highlight-ace)
- [Atom](https://github.com/kaoscript/highlight-atom)
- [Brackets](https://github.com/kaoscript/highlight-brackets)
- [CodeMirror](https://github.com/kaoscript/highlight-codemirror)
- [jEdit](https://github.com/kaoscript/highlight-jedit)
- [Prism](https://github.com/kaoscript/highlight-prism)
- [Rainbow](https://github.com/kaoscript/highlight-rainbow)
- [TextMate](https://github.com/kaoscript/highlight-textmate)
- [VS Code](https://github.com/kaoscript/highlight-vscode)

Coverage
--------

kaoscript provides code coverage via the [Istanbul](https://github.com/gotwarlost/istanbul) instrumentation: [@kaoscript/coverage-istanbul](https://github.com/kaoscript/coverage-istanbul).

Register the compiler into Istanbul with the option `--compilers ks:@kaoscript/coverage-istanbul/register`.

You can look at `istanbul.json` in the project [@zokugun/lang](https://github.com/ZokugunKS/lang) to discover an easy integration between mocha, Istanbul and kaoscript.
It generates a report on the command line and as html pages (with minimap of warnings and errors).

Future
------

- add JSX-like support
- compile to another language (Rust, Go or Haxe)

License
-------

[MIT](http://www.opensource.org/licenses/mit-license.php) &copy; Baptiste Augrain