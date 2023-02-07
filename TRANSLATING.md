# Translating "Mastering the Lightning Network"

This book is now available under an open license, and therefore it is now possible to produce open licensed derivatives such as translations.

## Translating on Transifex

The translation effort is coordinated through the ["Mastering the Lightning Network" project](https://www.transifex.com/aantonop/mastering-the-lightning-network) on the [Transifex](https://www.transifex.com) platform.

Volunteers can contribute to different translations on an ad-hoc basis. Contributions to the translation fall under the same CC-BY-SA license and the English version of the book.

## Translating ASCIIDOC markup

The book's source files use the ASCIIDOC markup language with a few specialized extensions and stylesheet for the print edition by O'Reilly.

If you are translating the book, you must translate all content _without_ translating markup symbols, variable names, file names, anchors, references, command-line commands, and other markup related entries.

For example, in the following ASCIIDOC source:

```
[[set_up_a_lightning_node]]
== Lightning Node Software

((("Lightning node software", id="ix_04_node_client-asciidoc0", range="startofrange")))As we have seen in previous chapters, a Lightning node is a computer system that participates in the Lightning Network.

[role="pagebreak-before"]

On macOS, a common package manager used for open source development is https://brew.sh[Homebrew], which is accessed by the command +brew+.

[TIP]
====
In many of the examples in this chapter we will be using the operating system's command-line interface
====

Enter the following command shown in <<cd-lnbook>>:

[[cd-lnbook]]
----
$ cd lnbook
----

What result does this command produce?

```

In this text above there are many markup symbols, anchors, references and formatting directives. These must not be translated. This includes:

* Anchors between double square brackets eg. ```[[set_up_a_lightning_node]]```
* References to anchors between less-than, greater-than symbols eg. ```<<cd-lnbook>>```
* Code blocks between lines with four dashes eg. ```----```
* Template directives in square brackets eg. ```[TIP]```
* Formatting directives eg. ```[role="pagebreak-before"]```
* Indexing directives in three-parenthesis eg. ```((("Lightning node software", id="ix_04_node_client-asciidoc0", range="startofrange")))```
* Links eg. ```https://brew.sh``` (but translate the text ```[Homebrew]``` that is the anchor text)

## Attribution

If you contribute translations you are responsible for adding your own attribution, which you can do by adding your name to the [translation_contributors.asciidoc](translation_contributors.asciidoc) file on Github, under the corresponding language.

## Derivatives

If you produce a derivative of a translation (eg. a PDF, ebook or print book), you MUST include attribution to the original authors, the original githb contributors and the translation contributors for that language. You must also license your derivative under a CC-BY-SA license and make the source files available for free under a CC-BY-SA license.
