# Kitura-Markdown
A Templating engine for Kitura that uses Markdown based templates.

[![Build Status - Master](https://travis-ci.org/IBM-Swift/Kitura.svg?branch=master)](https://travis-ci.org/IBM-Swift/Kitura-Markdown)
![Mac OS X](https://img.shields.io/badge/os-Mac%20OS%20X-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)

## Summary
Kitura-Markdown enables a Kitura based server to serve HTML content generated from templates of
Markdown (.md) marked up text. In addition Kitura-Markdown can be be used to generate HTML from
Markdown formatted text passed to provided helper functions.

## Example
The following is an example of a server that serves Markdown formatted text from .md files
under the views/docs directory of the server's repository, as in the following structure:
<pre>

ServerRepository
├── Package.swift
├── Sources
│   └── Server
│       └── main.swift
└── views
    └── docs
        └── main.md
</pre>

In the main.swift file, there would be the following code:

```swift
import Kitura
import KituraMarkdown

// Create a new router
let router = Router()

// Add KituraMarkdown as a TemplatingEngine
router.add(templatingEngine: KituraMarkdown())

// Handle HTTP GET requests to /docs
router.get("/docs") { request, response, next in
    if let path = request.parsedUrl.path {
        try response.render(path, context: [String:Any]())
        response.status(.OK)
    }
    next()
}

// Add an HTTP server and connect it to the router
Kitura.addHTTPServer(onPort: 8090, with: router)

// Start the Kitura runloop (this call never returns)
Kitura.run()
```

If you pointed your browser as http://_hostname_:8090/docs/main.md, the contents of main.md
you would see the contents of main.md in HTML form.

## License
This library is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE.txt).
