# SwiftSyntax

SwiftSyntax is a set of Swift bindings for the
[libSyntax](https://github.com/apple/swift/tree/master/lib/Syntax) library. It
allows for Swift tools to parse, inspect, generate, and transform Swift source
code.

> Note: SwiftSyntax is still in development, and the API is not guaranteed to
> be stable. It's subject to change without warning.

## Usage

### Declare SwiftPM dependency with release tag
Add this repository to the `Package.swift` manifest of your project:

```swift
// swift-tools-version:4.2
import PackageDescription

let package = Package(
  name: "MyTool",
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", .exact("<#Specify Release tag#>")),
  ],
  targets: [
    .target(name: "MyTool", dependencies: ["SwiftSyntax"]),
  ]
)
```

Replace `<#Specify Release tag#>` by the version of SwiftSyntax that you want to use (see the following table for mapping details).


| Swift Release Tag | SwiftSyntax Release Tag  |
|:-------------------:|:-------------------------:|
| swift-5.0-RELEASE   | 0.50000.0 |
| swift-4.2-RELEASE   | 0.40200.0 |


Then, import `SwiftSyntax` in your Swift code.


### Declare SwiftPM dependency with nightly build

1. Download and install the latest Trunk Development (master) [toolchain](https://swift.org/download/#snapshots).

2. Define the `TOOLCHAINS` environment variable as below to have the `swift` command point inside the toolchain:

```
$ export TOOLCHAINS=swift
```

3. To make sure everything is setup correctly, check the result of `xcrun --find swift`. It should point inside the OSS toolchain.

4. Add this entry to the `Package.swift` manifest of your project:

```swift
// swift-tools-version:4.2
import PackageDescription

let package = Package(
  name: "MyTool",
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", .revision("swift-DEVELOPMENT-SNAPSHOT-2019-02-26")),
  ],
  targets: [
    .target(name: "MyTool", dependencies: ["SwiftSyntax"]),
  ]
)
```

Tags will be created for every nightly build in the form of `swift-DEVELOPMENT-SNAPSHOT-<DATE>`. Revision field
should be specified with the intended tag.

Different from building SwiftSyntax from source, declaring SwiftSyntax as a SwiftPM dependency doesn't require
the Swift compiler source because we always push gyb-generated files to a tag.

### Some Example Users

[**Swift AST Explorer**](https://swift-ast-explorer.kishikawakatsumi.com/): a Swift AST visualizer.

[**Swift Stress Tester**](https://github.com/apple/swift-stress-tester): a test driver for sourcekitd and Swift evolution.

[**SwiftRewriter**](https://github.com/inamiy/SwiftRewriter): a Swift code formatter.

[**SwiftPack**](https://github.com/omochi/SwiftPack): a tool for automatically embedding Swift library source.

[**Periphery**](https://github.com/peripheryapp/periphery): a tool to detect unused code.

[**BartyCrouch**](https://github.com/Flinesoft/BartyCrouch): a tool to incrementally update strings files to help App localization.

[**Muter**](https://github.com/SeanROlszewski/muter): Automated mutation testing for Swift

[**Swift Variable Injector**](https://github.com/LucianoPAlmeida/variable-injector): a tool to replace string literals with environment variables values.

### Reporting Issues

If you should hit any issues while using SwiftSyntax, we appreciate bug reports on [bugs.swift.org](https://bugs.swift.org) in the [SwiftSyntax component](https://bugs.swift.org/issues/?jql=component%20%3D%20SwiftSyntax).

## Contributing

### Building SwiftSyntax from `master`

Since SwiftSyntax relies on definitions in the main Swift repository to generate the layout of the syntax tree using `gyb`, a checkout of [apple/swift](https://github.com/apple/swift) is still required to build `master` of SwiftSyntax.

To build the `master` version of SwiftSyntax, follow the following instructions:

1. Check `swift-syntax` and  `swift` out side by side:

```
- (enclosing directory)
  - swift
  - swift-syntax
```

2. Make sure you have a recent [master Swift toolchain](https://swift.org/download/#snapshots) installed.
3. Define the `TOOLCHAINS` environment variable as below to have the `swift` command point inside the toolchain:

```
$ export TOOLCHAINS=swift
```

4. To make sure everything is setup correctly, check the return statement of `xcrun --find swift`. It should point inside the latest installed master toolchain. If it points inside an Xcode toolchain, check that you exported the `TOOLCHAINS` environment variable correctly. If it points inside a version specific toolchain (like Swift 5.0-dev), you'll need to remove that toolchain.
5. Run `swift-syntax/build-script.py`.

If, despite following those instructions, you get compiler errors, the Swift toolchain might be too old to contain recent changes in Swift's SwiftSyntaxParser C library. In that case, you'll have to build the compiler and SwiftSyntax together with the following command:

```
$ swift/utils/build-script --swiftsyntax --swiftpm --llbuild
```

Swift-CI will automatically run the code generation step whenever a new toolchain (development snapshot or release) is published. It should thus almost never be necessary to perform the above build yourself.

Afterwards, SwiftPM can also generate an Xcode project to develop SwiftSyntax by running `swift package generate-xcodeproj`.

If you also want to run tests locally, read the section below as testing has additional requirements.

### Local Testing
SwiftSyntax uses some test utilities that need to be built as part of the Swift compiler project. To build the most recent version of SwiftSyntax and test it, follow the steps in [swift/README.md](https://github.com/apple/swift/blob/master/README.md) and pass `--llbuild --swiftpm --swiftsyntax` to the build script invocation to build SwiftSyntax and all its dependencies using the current `master` compiler.

SwiftSyntax can then be tested using the build script in `apple/swift` by running
```
swift/utils/build-script --swiftsyntax --swiftpm --llbuild -t --skip-test-cmark --skip-test-swift --skip-test-llbuild --skip-test-swiftpm
```
This command will build SwiftSyntax and all its dependencies, tell the build script to run tests, but skip all tests but the SwiftSyntax tests.

Note that it is not currently supported to SwiftSyntax while building the Swift compiler using Xcode.

### CI Testing

Running `@swift-ci Please test` on the main Swift repository will also test the most recent version of SwiftSyntax.

Testing SwiftSyntax from its own repository is now available by commenting `@swift-ci Please test macOS platform`.

## Example

This is a program that adds 1 to every integer literal in a Swift file.

```swift
import SwiftSyntax
import Foundation

/// AddOneToIntegerLiterals will visit each token in the Syntax tree, and
/// (if it is an integer literal token) add 1 to the integer and return the
/// new integer literal token.
class AddOneToIntegerLiterals: SyntaxRewriter {
  override func visit(_ token: TokenSyntax) -> Syntax {
    // Only transform integer literals.
    guard case .integerLiteral(let text) = token.tokenKind else {
      return token
    }

    // Remove underscores from the original text.
    let integerText = String(text.filter { ("0"..."9").contains($0) })

    // Parse out the integer.
    let int = Int(integerText)!

    // Return a new integer literal token with `int + 1` as its text.
    return token.withKind(.integerLiteral("\(int + 1)"))
  }
}

let file = CommandLine.arguments[1]
let url = URL(fileURLWithPath: file)
let sourceFile = try SyntaxParser.parse(url)
let incremented = AddOneToIntegerLiterals().visit(sourceFile)
print(incremented)
```

This example turns this:

```swift
let x = 2
let y = 3_000
```

into:

```swift
let x = 3
let y = 3001
```
