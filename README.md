# Pair

A tool for easily creating git commits while pairing.

## Description

Back in January, Github introduced support for showing git commits with multiple authors. This is done by adding one or more blank lines to a git commit and then adding a series of lines for each additional author.

```
This is my commit.

Co-authored-by: Another Committer <another_committer@example.com>
Co-authored-by: Yet Another Committer <yet_another_committer@example.com>
```

More info on the [GitHub post on multiple authors][git-pairing]

This is awesome for ensuring credit goes to everyone who worked on a project but a little tedious to do each commit. Until the official git clients start supporting this, I've created a small tool to do it for us.


## Installation
`pair` is a single Ruby file with no gem dependencies. Ensure you have Ruby installed, copy the `pair` file somewhere onto your `$PATH`, and you're ready to go!

## Usage
In the grand tradition of [`hub`][hub], this is designed to act like the official `git` client with some added behavior.

First, ensure that the `GIT_PAIR` environment variable is set to the person/people you're pairing with. If there's more than one, separater them with commas:

```
export GIT_PAIR='Lillian Rose <poison@ivy.com>'
export GIT_PAIR='Lillian Rose <poison@ivy.com>,Harleen Quinzel <harl@e-quin.com>'
```

When you're ready to commit, replace `git` with `pair`.

### Before
```
git commit -m "This is my commit"
git commit -t standard_commit_template
git commit -F prepared_git_commit_message
```

### After
```
pair commit -m "This is my commit"
pair commit -t standard_commit_template
pair commit -F prepared_git_commit_message
```

[git-pairing]: https://help.github.com/articles/creating-a-commit-with-multiple-authors/
[hub]: https://hub.github.com
