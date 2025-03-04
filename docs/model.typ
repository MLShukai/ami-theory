#import "_template.typ": *

// このファイルは単独でコンパイルできる独立したドキュメント
#show: simple-document.with(
  title: "自律機械知能の理論モデル",
  author: "GesonAnko",
  date: "2025-02-28",
)

= 概要
好奇心ベースの自律機械知能のモデルアーキテクチャを原始的な部分からまとめます。

= モデル理論

== 1. プリミティブな好奇心フレームワーク
好奇心ベースのエージェントでは、世界モデル（予測器）の予測誤差を最大化するように行動を選択することで、未知の状態や興味深い結果を探索します。このメカニズムを定式化すると、以下のようになります。

状態 $s_t$、行動 $a_t$、次の状態 $s_(t+1)$ について考えます。パラメータ $theta$ を持つ予測器を $f_theta$ とし、その出力する次の状態の分布を $p^f (dot.op|s_t, a_t)$ とします：

$ p^f arrow.l f_theta (s_t, a_t) $
$ I_(t+1) = -log p^f (s_(t+1)|s_t, a_t) 
$

ここで $I_(t+1)$ は予測誤差（自己情報量または「驚き」）を表します。

一方、パラメータ $phi$ を持つ行動生成器（方策）を $pi_phi$ とし、その出力する行動の分布を $p^pi (dot.op|s_t)$ とすると：

$ p^pi (dot.op|s_t) arrow.l pi_phi (s_t) $
$ a_t tilde p^pi (dot.op|s_t) $

となります。

このとき、予測器と行動生成器の学習目標は以下のように定義されます：

$ phi arrow.l arg max_phi I $
$ theta arrow.l arg min_theta I $

この「ゼロサム的な敵対的学習関係」が好奇心ベースのエージェントの核心です。予測器は誤差を最小化しようとし、行動生成器はその予測を困難にするような状態を生み出そうとします。

=== 実装についてのTips

*NOTE*: 状態 $s_t$ としていますが、実際にこのプリミティブなフレームワークを用いる際は、状態を単に 観測 $o_t$ として扱ったり、いくつかの観測をスタックして状態 $s_t$ に近似して扱ったりします。

$f_theta$ や $pi_phi$ は単純な ResNet などが使われます。

== 2. 時系列データへの拡張
実世界では、システムの完全な状態 $s$ を直接観測できないことが多く、代わりに観測 $o_t$ のみが得られます。そこで、予測器 $f_theta$ に隠れ状態 $h^f_t$ を持たせ、時間的文脈を扱えるようにします: 

$ p^f, h^(f)_t arrow.l f_theta (o_t, a_t, h^(f)_(t-1)) $
$ I_t = -log p^f (o_(t+1)|o_t, a_t, h^(f)_(t-1)) $

同様に、方策 $pi_phi$ も隠れ状態 $h^(pi)_t$ を持つように拡張します：

$ p^pi, h^(pi)_t arrow.l pi_phi (o_t, h^(pi)_(t-1)) $

この時、最大化・最小化する$I$は、次のように与えれます:

$ I = lim_(T arrow.r infinity) -1/T sum^(T-1)_(i=0) log p^f (o_(t+i+1)|o_([t:t+i]), a_([t:t+i]), h^f_(t-1))  $

これは 最初の隠れ状態 $h^f_(t-1)$ から、実観測列と行動列を用いて予測を実行した際の損失関数となります。

=== 実装において

- $T$ は有限で打ち切ります。
- 時系列モデルのコアには並列処理も可能なRNN (Mamba, RWKV, SioConvなど)が使われます。

== 3. 観測 (空間) エンコーダ $E^o$ の導入

しばしば、観測 $o$は高次元の画像情報であるなど、直接観測の予測を $f$ が生成するには難しい場合があります。その時に、 高次元の観測 $o$ を低次元の特徴量 $z$ に写像する、 観測 (空間) エンコーダ $E^o$ (または $E^text("space")$) を用います。

$ E^o: o_t arrow.r.bar z_t $

観測エンコーダは 学習可能なパラメータを持つ事もあります。これは $theta$ や $phi$ とは独立に損失関数を持ち、学習されます。


この観測エンコーダを用いると、

$
  z_t arrow.l E^o_psi (o_t) \
  p^pi, h^(pi)_t arrow.l pi_phi (z_t, h^(pi)_(t-1)) \
  p^f, h^(f)_t arrow.l f_theta (z_t, a_t, h^(f)_(t-1)) \
  I_t = -log p^f (z_(t+1)|z_t, a_t, h^(f)_(t-1))
$

となります。

=== 補足

- JEPAやVAEがEncoderには使われます。
- 原始的には、ダウンサンプリング処理などがあります。

== 4. 時間エンコーダ $E^text("temporal")$ の導入

時間方向に関して特徴量をエンコードする時間エンコーダ$E^text("temporal")$は、隠れ状態 $h^text("temporal")_(t)$を持ちます。 エンコードされた観測を $x_t$ として、次のように表されます:

$
  x_t, h^text("temporal")_t arrow.l E^text("temporal") (o_t, h^text("temporal")_(t-1))
$

時間エンコーダは、学習可能なパラメータを持ち、独立した損失関数を用いて学習されます。

== 5. 観測エンコーダ $E^text("space")$ と 時間エンコーダ $E^text("temporal")$ を用いた時空間エンコーディング

観測エンコーダ $E^text("space")$ と 時間エンコーダ $E^text("temporal")$ を用いて、時空間的に特徴量をエンコードし、より高度な特徴量にする:

$
  z_t arrow.l E^text("space") (o_t) \
  x_t, h^text("temporal")_t arrow.l E^text("temporal") (z_t, h^text("temporal")_(t-1)) \
  p^pi, h^(pi)_t arrow.l pi_phi (x_t, h^(pi)_(t-1)) \
  p^f, h^(f)_t arrow.l f_theta (x_t, a_t, h^(f)_(t-1)) \
  I_t = -log p^f (x_(t+1)|x_t, a_t, h^(f)_(t-1))
$

== 6. マルチモーダル処理について

マルチモーダルな好奇心ベースの処理を考える。画像モダリティや音声もダリティをここでは具体的に取り扱う

- 画像の観測を $o^text("v")$ または $o^text("vision")$ とする
- 音声の観測を $o^text("a")$ または $o^text("audio")$ とする

複数のモダリティの観測を扱う際は、一つの特徴量にエンコードして取り扱うと扱いやすい。
各モダリティごとに観測エンコーダを用意し、そのエンコード結果を結合して時間エンコーダで特徴量を抽出する。

画像の観測エンコーダを $E^text("v")$, 音声の観測エンコーダを $E^text("a")$ とおく、それぞれのエンコード結果を $z^text("v")_t$, $z^text("a")_t$ とおく。
時間エンコーダを $E^text("temporal")$ として: 

$
  z^text("v")_t arrow.l E^text("v") (o^text("v")_t) \
  z^text("a")_t arrow.l E^text("a") (o^text("a")_t) \
  z_t := [z^text("v")_t, z^text("a")_t] \
  x_t, h^text("temporal")_t arrow.l E^text("temporal") (z_t, h^text("temporal")_(t-1))
$