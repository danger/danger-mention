# Danger Mention

A [Danger](https://github.com/danger/danger) plugin to automatically mention potential reviewers on pull requests.

## Installation

    $ gem install danger-mention

## Usage

The easiest way to use is just add this to your Dangerfile:

```rb
mention.run
```

Additionally you can set up maximum number of people to ping in the PR message, regexes of ignored files and list of users that will never be mentioned.

```rb
mention.run(2, ["Pods/"], ["wojteklu"])
```

## License

This project is licensed under the terms of the MIT license. See the LICENSE file.
