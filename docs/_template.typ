// 最小限のテンプレート - 必要な設定のみを含む

// シンプルなドキュメントテンプレート
#let simple-document(
  title: "",
  author: "",
  date: none,
  body
) = {
  // ドキュメントの設定
  set document(title: title, author: (author,))
  set page(
    height: auto,
    numbering: none,
  )
  set text(font: ("Yu Gothic", "YuGothic", "Century"), lang: "ja")
  
  // 数式設定
  set math.equation(numbering: "(1)")
  
  // タイトルブロック
  align(center)[
    #block(text(weight: 700, size: 2em)[#title])
    #block(text(size: 1.2em)[#date])
    #if author != "" [
      #block(text(size: 1.2em)[#author])
    ]
  ]
  
  // 本文
  set heading(numbering: none)
  
  body
}
