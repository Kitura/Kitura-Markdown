# Kitura-Markdown
A Templating engine for Kitura that uses Markdown-based templates.

[![Build Status - Master](https://travis-ci.org/IBM-Swift/Kitura-Markdown.svg?branch=master)](https://travis-ci.org/IBM-Swift/Kitura-Markdown)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)

## Summary
`Kitura-Markdown` enables a Kitura-based server to serve HTML content generated from Markdown templates (`.md` files). In addition, `Kitura-Markdown` can be be used to generate HTML from Markdown-formatted text passed to provided helper functions.

## Prerequisites
Swift 4.0  or above

## Example
The following is an example of a server that serves Markdown-formatted text from `.md` files
under the `views`/`docs` directory of the server's repository, as in the following structure:

<pre>
ServerRepository
├── Package.swift
├── Sources
│   └── Server
│       └── main.swift
└── views
    └── docs
        ├── index.md
        └── doc1.md
</pre>

In the `main.swift` file, there would be the following code:

```swift
import Kitura
import KituraMarkdown

// Create a new router
let router = Router()

// Add KituraMarkdown as a TemplatingEngine
router.add(templateEngine: KituraMarkdown())

// Handle HTTP GET requests to /docs
router.get("/docs") { _, response, next in
    try response.render("/docs/index.md", context: [String:Any]())
    response.status(.OK)
    next()
}

// Handle HTTP GET requests to /docs/......
router.get("/docs/*") { request, response, next in
    if let path = request.parsedURL.path, path != "/docs/" {
        try response.render(path, context: [String:Any]())
        response.status(.OK)
    }
    next()
}

// Handle HTTP GET request to /page and wrap the result HTML with a static page template
// The default template is: <!DOCTYPE html><html lang=\"en\"><head><meta charset=\"UTF-8\"></head><body></body></html>
// Where the markdown code gets inserted in the body
router.get("/page") { _, response, next in
    let options = MarkdownOptions(pageTemplate: "default")
    try response.render("/docs/index.md", context: [String:Any](), options: options)
    response.status(.OK)
    next()
}

// Handle HTTP GET request to /custom and wrap the result HTML with a customized static page template
// Provide a custom template marking the insertion point with <snippetInsertLocation></snippetInsertLocation> tags
router.get("/custom") { _, response, next in
    let options = MarkdownOptions(pageTemplate: "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"UTF-8\"></head><body><div><snippetInsertLocation></snippetInsertLocation></div></body></html>")
    try response.render("/docs/index.md", context: [String:Any](), options: options)
    response.status(.OK)
    next()
}

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8090, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
```

If you pointed your browser at http://_hostname_:8090/docs or
http://_hostname_:8090/docs/dec1.md, you would see the contents of `index.md`
or `doc1.md`, respectively, in HTML form.

## License
This library is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE.txt).
