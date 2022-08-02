type RegExpExecArray = Array<String?> & {
    index: Number
    input: String
}

extern console
extern func exec(): RegExpExecArray

var match = exec()

console.log(`\(match.input)`)
console.log(`\(match[0])`)
console.log(`\(match[0]!?)`)