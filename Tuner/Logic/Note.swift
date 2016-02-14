/*
 * Copyright (c) 2016 Tim van Elsloo
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation

/**
 * Accidentals increase the pitch of a note. Note that e.g. A♯ and B♭ are
 * essentially the same frequency but have a different meaning based on context.
 */
enum Accidental: String {
    case Sharp = "♯"
    case Flat  = "♭"
}

enum Note: CustomStringConvertible {
    case C(_: Accidental?)
    case D(_: Accidental?)
    case E(_: Accidental?)
    case F(_: Accidental?)
    case G(_: Accidental?)
    case A(_: Accidental?)
    case B(_: Accidental?)

    /**
     * This array contains all notes.
     */
    static let all: [Note] = [
            C(nil),   C(.Sharp),
            D(nil),
            E(.Flat), E(nil),
            F(nil),   F(.Sharp),
            G(nil),
            A(.Flat), A(nil),
            B(.Flat), B(nil)
     ]

    /**
     * This function returns the frequency of this note in the 4th octave.
     */
    var frequency: Double {
        let index = Note.all.indexOf({ $0 == self   })! -
                    Note.all.indexOf({ $0 == A(nil) })!

        return 440 * pow(2, Double(index) / 12.0)
    }

    /**
     * This property is used in the User Interface to show the name of this
     * note.
     */
    var description: String {
        let concat = { (letter: String, accidental: Accidental?) in
            return letter + (accidental != nil ? accidental!.rawValue : "")
        }

        switch self {
            case let C(a): return concat("C", a)
            case let D(a): return concat("D", a)
            case let E(a): return concat("E", a)
            case let F(a): return concat("F", a)
            case let G(a): return concat("G", a)
            case let A(a): return concat("A", a)
            case let B(a): return concat("B", a)
        }
    }
}

/**
 * We override the equality operator so we can use `indexOf` on the static array
 * of all notes. Using the `description` property isn't the most idiomatic way
 * to do this but it does the job.
 */
func ==(a: Note, b: Note) -> Bool {
    return a.description == b.description
}
