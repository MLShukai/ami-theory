#import "_template.typ": *

// このファイルは単独でコンパイルできる独立したドキュメント
#show: simple-document.with(
  title: "Random Observation Generator",
  author: "GesonAnko",
  date: "2025-02-28",
)

= Random Observation Generator

== 概要
単位時間あたりの総情報量 $overline(I) text("[bit/s]")$ が計算可能であり、かつそれをいくつかの有界なパラメータで制御可能なランダム観測生成手法を考案します。

== 理論

=== 基本的な考え
ある時刻 $t$ における 観測 $o_t$ がある確率分布 $p$ からサンプルされるとします。

$ o_t tilde p(o_t) $

次の時刻 $t_(t+1)$ では、サンプル確率 $q$ で 新しく 観測がサンプルされ、 $q-1$ で前時刻の観測が用いられる、とします。

=== 設定
ここで、ハイパーパラメータなどの設定を列挙しておきます。

==== 確率分布 $p$ について
- $p$ の確率分布形状: これは、離散一様分布としておきます（後に情報量を計算しやすいため）
- $p$ の最大段階数のオーダー $B in NN$, 実際の最大段階数は $2^B$ とする。
- *[制御値]* 段階数のオーダ−比率 $rho in [0,1]$, $p$ の段階数は $text("round")(2^(B dot rho))$ となる。

==== 観測 $o$ について
- 観測 $o$ は長さ $L in NN$ のベクトル。 ($o in [-1,1]^L$)
- *[制御値]* 観測の長さの比率 $r in [0,1]$
- 観測 $o$ は、実際には 長さ $L^(text("raw")) = min[ text("round")(L dot r), 1]$ だけ $p$ からサンプルされ、線形補完されて 長さ $L$ となる。

==== 観測のフレームレート
- 時刻 $t$ と $t+1$ 間の長さを $T text("[s]")$ とする。
- サンプル確率 $q$ は *制御値*.

=== 総情報量 $overline(I)$
これらの設定値から、単位時間あたりの総情報量 $overline(I)$ を計算する:

$ overline(I) = (L dot r) dot (q/T) dot cal(H)(p) $
$ cal(H)(p) = - log_2 2^(-B dot rho) = B dot rho $
$ overline(I) = (L dot r) (q/T) (B dot rho) $

=== 制御値
- 長さ比率 $r$
- サンプル確率 $q$
- オーダー比率 $rho$
