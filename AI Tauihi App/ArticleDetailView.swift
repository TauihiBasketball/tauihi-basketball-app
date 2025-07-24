import SwiftUI
import UIKit

struct ArticleDetailView: View {
    let post: WPPost
    let onDismiss: () -> Void
    @State private var htmlViewHeight: CGFloat = 0

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Featured image at the top
                    if let imageURL = post.featuredImageURL {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.tauihiRed.opacity(0.1))
                                .overlay(
                                    Image(systemName: "newspaper")
                                        .font(.largeTitle)
                                        .foregroundColor(.tauihiRed)
                                )
                        }
                        .frame(height: 250)
                        .clipped()
                        .cornerRadius(16)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Article title
                        Text(stripHTML(post.title.rendered))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        // Article content
                        HTMLTextView(html: post.content.rendered, dynamicHeight: $htmlViewHeight)
                            .frame(minHeight: htmlViewHeight)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onDismiss) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.tauihiRed)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    func stripHTML(_ html: String) -> String {
        guard let data = html.data(using: .utf16) else { return html }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf16.rawValue
        ]
        return (try? NSAttributedString(data: data, options: options, documentAttributes: nil))?.string ?? html
    }
}

struct HTMLTextView: UIViewRepresentable {
    let html: String
    @Binding var dynamicHeight: CGFloat

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        let styledHTML = """
        <style>
        body { 
            font-family: -apple-system; 
            font-size: 18px; 
            color: #111; 
            line-height: 1.7; 
            margin: 0; 
            padding: 0; 
        }
        p { 
            margin-bottom: 1.2em; 
            margin-top: 0;
        }
        img { 
            max-width: 100%; 
            height: auto; 
            border-radius: 12px; 
            margin: 16px 0; 
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        strong, b { 
            font-weight: 600; 
        }
        em, i { 
            font-style: italic; 
        }
        ul, ol { 
            margin-left: 1.5em; 
            margin-bottom: 1.2em;
        }
        li {
            margin-bottom: 0.5em;
        }
        a { 
            color: #d50037; 
            text-decoration: underline; 
        }
        h1, h2, h3, h4, h5, h6 {
            margin-top: 1.5em;
            margin-bottom: 0.8em;
            font-weight: 600;
        }
        blockquote {
            border-left: 4px solid #d50037;
            padding-left: 16px;
            margin: 16px 0;
            font-style: italic;
            color: #666;
        }
        </style>
        <body>
        \(html)
        </body>
        """
        guard let data = styledHTML.data(using: .utf16) else {
            uiView.text = html
            return
        }
        if let attributedString = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf16.rawValue
            ],
            documentAttributes: nil
        ) {
            uiView.attributedText = attributedString
        } else {
            uiView.text = html
        }
        uiView.textColor = UIColor.label
        uiView.font = UIFont.preferredFont(forTextStyle: .body)
        DispatchQueue.main.async {
            self.dynamicHeight = uiView.contentSize.height
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: HTMLTextView
        init(_ parent: HTMLTextView) {
            self.parent = parent
        }
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.dynamicHeight = textView.contentSize.height
            }
        }
    }
} 