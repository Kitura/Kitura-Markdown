/**
 * Copyright IBM Corporation 2016, 2017
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

/// Rendering options for KituraMarkdown
public struct MarkdownOptions: RenderingOptions {
    let pageTemplate: String

    /// Constructor
    ///
    /// - Parameter pageTemplate: String form of page template
    public init(pageTemplate: String) {
        self.pageTemplate = pageTemplate
    }
}

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
    public let fileExtension = "md"

    /// Create a `KituraMarkdown` instance
    public init() {}

    // This function is needed to satisfy TemplateEngine protocol, it is not possible to
    // statisfy swift protocols by providing default arguments. Otherwise,
    // render(:filePath:context:options) with default options argument would be used.
    /// Take a template file in Markdown format and generate HTML format content to
    /// be sent back to the client.
    ///
    /// - Parameter filePath: The path of the template file in Markdown format to use
    ///                      when generating the content.
    /// - Parameter context: A set of variables in the form of a Dictionary of
    ///                     Key/Value pairs. **Note:** This parameter is ignored at
    ///                     this time
    /// - Returns: If an Error isn't thrown when reading the template, a String containing
    ///            an HTML representation of the text marked up using Markdown.
    public func render(filePath: String, context: [String: Any]) throws -> String {
        return try render(filePath: filePath, context: context, options: NullRenderingOptions())
    }
    
    // This function is needed to satisfy TemplateEngine protocol.
    /// Take a template file in Markdown format and generate HTML format content to
    /// be sent back to the client.
    ///
    /// - Parameter filePath: The path of the template file in Markdown format to use
    ///                      when generating the content.
    /// - Parameter with: A value that conforms to Encodable.
    ///             **Note:** This parameter is ignored at this time.
    /// - Parameter forKey:  A value used to match the Encodable values to the
    ///             correct variable in a template file.
    ///             **Note:** This parameter is ignored at this time.
    /// - Parameter options: markdown options
    /// - Returns: If an Error isn't thrown when reading the template, a String containing
    ///            an HTML representation of the text marked up using Markdown.
    public func render<T: Encodable>(filePath: String, with: T, forKey: String?, options: RenderingOptions, templateName: String) throws -> String {
        //Pass through empty context as it's never used
        return try render(filePath: filePath, context: [:], options: NullRenderingOptions())
    }

    /// Take a template file in Markdown format and generate HTML format content to
    /// be sent back to the client.
    ///
    /// - Parameter filePath: The path of the template file in Markdown format to use
    ///                      when generating the content.
    /// - Parameter context: A set of variables in the form of a Dictionary of
    ///                     Key/Value pairs. **Note:** This parameter is ignored at
    ///                     this time
    /// - Parameter options: markdown options
    /// - Returns: If an Error isn't thrown when reading the template, a String containing
    ///            an HTML representation of the text marked up using Markdown.
    public func render(filePath: String, context: [String: Any],
                       options: RenderingOptions) throws -> String {
        let md = try Data(contentsOf: URL(fileURLWithPath: filePath))
        let snippet = KituraMarkdown.render(from: md)

        if let options = options as? MarkdownOptions, snippet != "" {
            return KituraMarkdown.createPage(from: snippet, withTemplate: options.pageTemplate)
        }

        return snippet
    }

    /// Generate HTML from a Data struct containing text marked up in Markdown in the
    /// form of UTF-8 bytes.
    ///
    /// - Parameter from: The Data struct containing markdown text in UTF-8
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
    /// - Parameter from: The String containing markdown text in UTF-8
    /// - Returns: A String containing an HTML representation of the text marked up
    ///            using Markdown.
    public static func render(from: String) -> String {
        guard let md = from.data(using: .utf8) else {
            return ""
        }

        return KituraMarkdown.render(from: md)
    }

    /// Generate HTML from a String containing text marked up in Markdown.
    ///
    /// - Parameter from: The String containing markdown in UTF-8
    /// - Parameter pageTemplate: The HTML page template used
    /// - Returns: A String containing an HTML representation of the text marked up
    ///            using Markdown.
    public static func render(from: String, pageTemplate: String) -> String {
        let snippet = KituraMarkdown.render(from: from)
        return KituraMarkdown.createPage(from: snippet, withTemplate: pageTemplate)
    }

    /// Wrap markdown
    private static func createPage(from: String, withTemplate: String) -> String {
        if(withTemplate == "default") {
            return "<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"UTF-8\"></head><body>\(from)</body></html>"
        }

        let result = withTemplate.replacingOccurrences(of: "<snippetInsertLocation></snippetInsertLocation>", with: from)
        
        return (result == withTemplate ? from : result)
    }
}
