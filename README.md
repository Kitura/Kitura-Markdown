<p align="center">
    <a href="http://kitura.io/">
        <img src="https://raw.githubusercontent.com/IBM-Swift/Kitura/master/Sources/Kitura/resources/kitura-bird.svg?sanitize=true" height="100" alt="Kitura">
    </a>
</p>


<p align="center">
    <a href="http://www.kitura.io/">
        <img src="https://img.shields.io/badge/docs-kitura.io-1FBCE4.svg" alt="Docs">
    </a>
    <a href="https://travis-ci.org/IBM-Swift/Kitura-Markdown">
        <img src="https://travis-ci.org/IBM-Swift/Kitura-Markdown.svg?branch=master" alt="Build Status - Master">
    </a>
        <img src="https://img.shields.io/badge/os-Mac%20OS%20X-green.svg?style=flat" alt="Mac OS X">
        <img src="https://img.shields.io/badge/os-linux-green.svg?style=flat" alt="Linux">
        <img src="https://img.shields.io/badge/license-Apache2-blue.svg?style=flat" alt="Apache 2">
    <a href="http://swift-at-ibm-slack.mybluemix.net/">
        <img src="http://swift-at-ibm-slack.mybluemix.net/badge.svg" alt="Slack Status">
    </a>
</p>

# Kitura-Markdown
A templating engine for Kitura that uses Markdown-based templates.

## Summary
`Kitura-Markdown` enables a [Kitura](https://github.com/IBM-Swift/Kitura) server to serve HTML content generated from Markdown templates (`.md` files).

## Markdown File
Markdown is a lightweight markup language with plain text formatting syntax.

[Mastering Markdown](https://guides.github.com/features/mastering-markdown/) provides documentation and examples on how to write Markdown files.

By default the Kitura Router will look in the `Views` folder for Markdown files with the extension `.md`.


## Example
The following example takes a server generated using `kitura init` and modifies it to serve Markdown-formatted text from a `.md` file.

The files which will be edited in this example, are as follows:

<pre>
&lt;ServerRepositoryName&gt;
├── Package.swift
├── Sources
│    └── Application
│         └── Application.swift
└── Views
     └── Example.md
</pre>

The `Views` folder and `Example.md` file will be created later on, since they are not initialized by `kitura init`.

#### Package.swift
* Define "https://github.com/IBM-Swift/Kitura-Markdown.git" as a dependency.
* Add "KituraMarkdown" to the targets for `Application`.

#### Application.swift
Inside the `Application.swift` file, add the following code to render the `Example.md` template file on the "/docs" route.

```swift
import KituraMarkdown
```

Add the following code inside the `postInit()` function:

```swift
router.add(templateEngine: KituraMarkdown())
router.get("/docs") { _, response, next in
    try response.render("Example.md", context: [String:Any]())
    response.status(.OK)
    next()
}
```

#### Example.md
Create the `Views` folder and put the following Markdown template code into a file called `Example.md`:

```
It's very easy to make some words **bold** and other words *italic* with Markdown. You can even [link to Kitura](https://github.com/IBM-Swift/Kitura) and write code examples:
`print("Hello world!")`
```

When the server is running, go to [http://localhost:8080/docs](http://localhost:8080/docs) to view the rendered Markdown template.

## License
This library is licensed under Apache 2.0. Full license text is available in [LICENSE](https://github.com/IBM-Swift/Kitura-Markdown/blob/master/LICENSE.txt).
