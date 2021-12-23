/*
Copyright (c) 2019, Apple Inc. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1.  Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.

3. Neither the name of the copyright holder(s) nor the names of any contributors
may be used to endorse or promote products derived from this software without
specific prior written permission. No license is granted to the trademarks of
the copyright holders even if such marks are included in this software.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
#if !os(watchOS)

import Foundation
import SwiftUI

/// A card that displays multiple link buttons. Links buttons are capable of showing content in or out of app. Link buttons can be
/// configured using a `Link`.
///
/// # Style
/// The card supports styling using `careKitStyle(_:)`.
///
/// ```
///     +-------------------------------------------------------+
///     |                                                       |
///     |  <Title>                                              |
///     |  <Detail>                                             |
///     |                                                       |
///     |  --------------------------------------------------   |
///     |                                                       |
///     |  <Instructions>                                       |
///     |                                                       |
///     |  +-------------------------------------------------+  |
///     |  | <Link Title>                           <Image>  |  |
///     |  +-------------------------------------------------+  |
///     |                                                       |
///     |  +-------------------------------------------------+  |
///     |  | <Link Title>                           <Image>  |  |
///     |  +-------------------------------------------------+  |
///     |                                                       |
///     +-------------------------------------------------------+
/// ```
@available(iOS 14, *)
public struct LinkView<Header: View, Footer: View>: View {

    @Environment(\.isCardEnabled) private var isCardEnabled

    private let isHeaderPadded: Bool
    private let isFooterPadded: Bool
    private let header: Header
    private let footer: Footer
    private let instructions: Text?

    public var body: some View {
        InstructionsTaskView(isHeaderPadded: isHeaderPadded, isFooterPadded: isFooterPadded,
                             instructions: instructions, header: { header }, footer: { footer })
    }

    /// Create an instance.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter header: Header to inject at the top of the card. Specified content will be stacked vertically.
    /// - Parameter footer: View to inject under the instructions. Specified content will be stacked vertically.
    public init(instructions: Text? = nil, @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer) {
        self.init(isHeaderPadded: false, isFooterPadded: false, instructions: instructions, header: header, footer: footer)
    }

    private init(isHeaderPadded: Bool, isFooterPadded: Bool, instructions: Text? = nil,
                 @ViewBuilder header: () -> Header, @ViewBuilder footer: () -> Footer) {
        self.isHeaderPadded = isHeaderPadded
        self.isFooterPadded = isFooterPadded
        self.instructions = instructions
        self.header = header()
        self.footer = footer()
    }
}

@available(iOS 14, *)
public extension LinkView where Header == _LinkViewHeader {

    /// Create an instance.
    /// - Parameter title: Title text to display in the header.
    /// - Parameter detail: Detail text to display in the header.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter footer: View to inject under the instructions. Specified content will be stacked vertically.
    init(title: Text, detail: Text? = nil, instructions: Text? = nil, @ViewBuilder footer: () -> Footer) {
        self.init(isHeaderPadded: true, isFooterPadded: false, instructions: instructions, header: {
            _LinkViewHeader(title: title, detail: detail)
        }, footer: footer)
    }
}

// swiftlint:disable all
@available(iOS 14, *)
public extension LinkView where Footer == _LinkViewFooter {

    /// Create an instance.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter links: Configurations for each link button.
    /// - Parameter header: Header to inject at the top of the card. Specified content will be stacked vertically.
    init(instructions: Text? = nil, links: [LinkItem], @ViewBuilder header: () -> Header) {
        self.init(isHeaderPadded: false, isFooterPadded: !links.isEmpty, instructions: instructions, header: header, footer: {
            _LinkViewFooter(links: links)
        })
    }
}

@available(iOS 14, *)
public extension LinkView where Header == _LinkViewHeader, Footer == _LinkViewFooter {

    /// Create an instance.
    /// - Parameter title: Title text to display in the header.
    /// - Parameter detail: Detail text to display in the header.
    /// - Parameter instructions: Instructions text to display under the header.
    /// - Parameter links: Configurations for each link button.
    init(title: Text, detail: Text? = nil, instructions: Text? = nil, links: [LinkItem]) {
        self.init(isHeaderPadded: true, isFooterPadded: !links.isEmpty, instructions: instructions, header: {
            _LinkViewHeader(title: title, detail: detail)
        }, footer: {
            _LinkViewFooter(links: links)
        })
    }
}

/// Default header used by a `LinkView`.
@available(iOS 14, *)
public struct _LinkViewHeader: View {

    @Environment(\.careKitStyle) private var style

    fileprivate let title: Text
    fileprivate let detail: Text?

    public var body: some View {
        VStack(alignment: .leading, spacing: style.dimension.directionalInsets1.top) {
            HeaderView(title: title, detail: detail)
            Divider()
        }
    }
}

/// Default footer used by a `LinkView`.
@available(iOS 14, *)
public struct _LinkViewFooter: View {

    fileprivate let links: [LinkItem]

    public var body: some View {
        VStack {
            ForEach(links, id: \.self) { LinkButton(link: $0) }
        }
    }
}

#if DEBUG
@available(iOS 14, *)
struct LinkViewPreview: PreviewProvider {

    static var links: [LinkItem] = [
        .call(phoneNumber: "0000000000", title: "Call"),
        .email(recipient: "jappleseed@apple.com", title: "Email")
    ]

    static var previews: some View {
        LinkView(title: Text("Links"), links: links)
            .padding()
    }
}
#endif

#endif