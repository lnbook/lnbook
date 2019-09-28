# Guide to contributing

This book is developed collaboratively and openly, here on GitHub. We accept comments, contributions and corrections from all.

## Current Project STATUS
**OUTLINE PREPARATION**

We will be adding a draft outline for each chapter, starting September 15th 2019.

## Contributing with a Pull Request

Instructions on how to contribute with Issues and Pull Requests will be added shortly. In the mean time, please "Watch" the repository.

Before contributing with a Pull Request, please read the current **PROJECT STATUS**.

## License and attribution

All contributions must be properly licensed and attributed. If you are contributing your own original work, then you are offering it under a CC-BY license (Creative Commons Attribution). *You are responsible for adding your own name or pseudonym in the Acknowledgments section in the [Preface](preface.asciidoc), as attribution for your contribution.*

If you are sourcing a contribution from somewhere else, it must carry a compatible license. The book will initially be released under a CC-BY-NC-ND license which means that contributions must be licensed under open licenses such as MIT, CC0, CC-BY, etc. Contributions under a "share-alike" or GPL license are not compatible with the CC-BY-NC-ND license and therefore cannot be accepted. You need to indicate the original source and original license, by including an asciidoc markup comment above your contribution, like this:

```
////
Source: https://...
License: CC0
Added by: @aantonop
////
```

The best way to contribute to this book is by making a pull request:

1. Login with your GitHub account or create one now
2. [Fork](https://github.com/lnbook/lnbook#fork-destination-box) the `lnbook` repository. Work on your fork. In particular you can clone it to your local computer with `git clone https://github.com/ADD_YOUR_GIT_USER_NAME_HERE/lnbook.git`
3. Create a new branch on which to make your change, e.g. `git checkout -b my_code_contribution`, or make the change on the `develop` branch.
4. Please do one pull request PER asciidoc file, to avoid large merges. Edit the asciidoc file where you want to make a change or create a new asciidoc file in the `contrib` directory if you're not sure where your contribution might fit.
5. Edit `preface.asciidoc` and add your own name to the list of contributors under the Acknowledgment section. Use your name, or a GitHub username, or a pseudonym.
6. Commit your change. Include a commit message describing the correction.
7. Submit a pull request against the lnbook repository.
8. We currently use one line per sentence to make reviewing of pull requests and diffs easier. Make sure to follow this style guide and **turn off auto formatting** of your editor.

## Contributing with an issue

If you find a mistake and you're not sure how to fix it, or you don't know how to do a pull request, then you can file an Issue. Filing an Issue will help us see the problem and fix it.

Create a [new Issue](https://github.com/lnbook/lnbook/issues/new) now!

## Heading styles, anchors and references

Adjust heading style in each section as follows:

1. Only the chapter/section should be level 2, everything else should be level 3 and below (level 1 is the book title itself). Each asciidoc file should start with a "==" heading.
2. Headings should be all lower case, except for first letter, proper nouns and acronyms. "An introduction to the Lightning Network", "Explaining the physics of fulgurites" etc.
3. Acronyms are spelled out, capitalized, with the acronym in parentheses (eg. "Hash Time-Locked Contract (HTLC)"). Once you have spelled out an acronym in one heading, we can keep it as an acronym only in subsequent headings.
4. No period at the end of headings. Question mark if it is a question (generally avoid question headings, unless really appropriate)
5. Should include a unique anchor all lower case, underscore separated, within double square brackets (eg. [[intro_to_htlcs]]).
6. Headings should be followed by a blank line.
7. Heading should be followed by a paragraph of text, not a lower-level heading without any text. If you find one like this, add a TODO comment (line of 4 slashes "////", line with "TODO: add paragraph", line of 4 slashes)
8. Often it seems useful to link to a webpage / url. Since the research community figured out that every year about 50% of all outstanding url's become invalid we encourage you to use the wayback machine / Web Archive at: http://web.archive.org and provide a link to a saved copy of the web page.

Complete Example:

```
[[intro_to_ln]]
== Introduction to the Lightning Network

This is the intro paragraph

[[htlcs_explained]]
=== All about Hash Time-Locked Contracts (HTLCs)

As we saw in <<intro_to_ln>>, the intro paragraph is superb!

```

## Line endings

All submission should use Unix-like line endings: LF (not CR, not CR/LF). All the postprocessing is done on Unix-like systems. Incorrect line endings, or changes to line endings cause confusion for the diff tools and make the whole file look like it has changed.

If you are unsure or your OS makes things difficult, consider using a developer's text editor such as Atom.

## Thanks

We are very grateful for the support of the entire Lightning Network community. With your help, this will be a great book that can help thousands of developers get started and eventually "master" LN. Thank you!
