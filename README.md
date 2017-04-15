# Danger Mention

A [Danger](https://github.com/danger/danger) plugin to automatically mention potential reviewers on pull requests on GitHub and GitLab.

**Note**: This plugin uses the web-scraping of GitHub.com and GitLab to detect the authors to find potential reviewers. This might cause the plugin to break if either of those pages introduce design changes.

## Installation

    $ gem install danger-mention

## Usage

The easiest way to use is just add this to your Dangerfile:

```rb
mention.run
```

<blockquote>Running plugin with reviewers count specified
  <pre>
# Find maximum two reviewers
mention.run(2, [], [])</pre>
</blockquote>

<blockquote>Running plugin with some files blacklisted
  <pre>
# Find reviewers without parsing blame information
# from files matching to 'Pods/*'
mention.run(2, ["Pods/*"], [])</pre>
</blockquote>

<blockquote>Running plugin with some users blacklisted
  <pre>
# Find reviewers ignoring users 'wojteklu' and 'danger'
mention.run(2, [], ["wojteklu", "danger"])</pre>
</blockquote>

## Caveats

Unfortunately Github does not allow access to the blame route for private repositories. Therefore this plugin only works with public repos.

## License

This project is licensed under the terms of the MIT license. See the LICENSE file.
