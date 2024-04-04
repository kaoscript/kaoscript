#![libstd(off)]

type RegExpExecArray = Array<String?> & {
    index: Number
    input: String
}

extern func exec(): RegExpExecArray

export exec, RegExpExecArray