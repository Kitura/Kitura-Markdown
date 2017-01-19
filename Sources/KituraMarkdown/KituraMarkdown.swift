/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation

import Ccmark
import KituraTemplateEngine

/// An implementation of Kitura's `TemplateEngine` protocol. In particular this templating
/// engine takes files in Markdown (.md) format and converts them to HTML. In addition this
/// class has some helper methods for taking Markdown formatted text and converting it to
/// HTML.
///
/// - Note: Under the covers this templating engine uses the cmark C language reference
///         implementation of Markdown.
public class KituraMarkdown: TemplateEngine {
    /// The file extension of files in the views directory that will be
    /// rendered by a particular templating engine.
    public var fileExtension: String { return "md" }

    /// Create a `KituraMarkdown` instance
    public init() {}


    /// Take a template file in Markdown format and generate HTML format content to
    /// be sent back to the client.
    ///
    /// - Parameter filePath: The path of the template file in Markdown format to use
    ///                      when generating the content.
    /// - Parameter context: A set of variables in the form of a Dictionary of
    ///                     Key/Value pairs. **Note:** This parameter is ignored at
    ///                     this time
    /// - Parameter options: useTemplate - The HTML page template to insert rendered markdown into.
    ///                     Passing in "default" will insert markdown as a child of <body>
    ///                     Custom HTML template should indicate location of insertion with
    ///                     <snippetInsertLocation></snippetInsertLocation> tag.
    ///
    /// - Returns: If an Error isn't thrown whenreading the template, a String containing
    ///            an HTML representation of the text marked up using Markdown.
    public func render(filePath: String, context: [String: Any]) throws -> String {
        return try render(filePath: filePath, context: context, options: [String: Any]())
    }

    public func render(filePath: String, context: [String: Any], options: [String: Any]) throws -> String {
        let md = try Data(contentsOf: URL(fileURLWithPath: filePath))
        let snippet = KituraMarkdown.render(from: md)
        if let template = options["useTemplate"] as? String {
            return  KituraMarkdown.createPage(from: snippet, withTemplate: template)
        } else {
            return snippet
        }
    }

    /// Generate HTML from a Data struct containing text marked up in Markdown in the
    /// form of UTF-8 bytes.
    ///
    /// - Returns: A String containing an HTML representation of the text marked up
    ///            using Markdown.
    public static func render(from: Data) -> String {
        return from.withUnsafeBytes() { (bytes: UnsafePointer<Int8>) -> String in
            guard let htmlBytes = cmark_markdown_to_html(bytes, from.count, 0) else { return "" }
            let html = String(utf8String: htmlBytes)
            free(htmlBytes)
            return html ?? ""
        }
    }

    /// Generate HTML from a String containing text marked up in Markdown.
    ///
    /// - Returns: A String containing an HTML representation of the text marked up
    ///            using Markdown.
    public static func render(from: String) -> String {
        let md = from.data(using: .utf8)
        return  md != nil ? KituraMarkdown.render(from: md!) : ""
    }

    /// Wrap markdown
    private static func createPage(from: String, withTemplate: String) -> String {
        if(withTemplate == "default") {
            return "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"UTF-8\"><title>Title</title></head><body>\(from)</body></html>"
        }

        let result = withTemplate.replacingOccurrences(of: "<snippetInsertLocation></snippetInsertLocation>", with: from)

        return (result == withTemplate ? from : result)
    }
}
