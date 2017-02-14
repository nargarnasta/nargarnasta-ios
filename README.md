# När går nästa? iOS

## Dependencies

- Xcode 8
- SwiftLint
- Carthage

## Getting started

1. Clone the repo and make sure you've got Xcode 8 or later ready
2. Install SwiftLint and Carthage (`brew install swiftlint carthage` if you're
   using Homebrew)
3. Bootstrap dependencies: `carthage bootstrap`
4. Create `Shared/Settings.swift` from `Shared/Settings.swift.example`
5. Good to go

## Contributing

Please follow these guidelines and open Pull Requests with isolated changes.
Feel free to open issues with suggestions if you're not able to make the changes
directly.

### Git

- Keep commit messages clear and descriptive. See [How to Write a Git Commit
  Message](http://chris.beams.io/posts/git-commit/) for some good guidelines.
- Rebase your branch and remove WIP or fix commits to make it ready for merge.

### Swift

[Raywenderlich.com Style Guide](
https://github.com/raywenderlich/swift-style-guide) is a good starting point,
but SwiftLint configuration is king. Propose changes if you don't agree with
current configuration.
