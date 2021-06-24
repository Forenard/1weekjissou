# 1weekjissou
 
画面遷移の実装

## 画面遷移の問題
1. 遷移中に他の動作(Playerが動き続けているなど)は止めたい
2. なるべく他コンポーネントとの依存関係は作らずにSceneTransitionコンポーネント単体で動くようにしたい

## 案
- `Time.timeScale=0`
- postprocessを利用してMaterial単位で遷移アニメーションを管理、作成する

## 雑記

`Time.timeScale=0`だけでは問題1を完全に解決はできない。Update()は普通に呼び出されてしまう
まあそこらへんは実装する人が何とかする領域なので、問題2だけ考えればいいでしょ

## URLら

- [ShaderのPropertiesにboolを入れる](https://docs.unity3d.com/Manual/SL-Properties.html)
- [`Time.timeScale=0`でとまらないもの](https://tech.pjin.jp/blog/2016/12/20/unity_skill_7/)
- [CustomPostProcessの基本](https://qiita.com/Hirai0827/items/4946ee4b8b52d6f1da27)
- [GLSLビルドイン関数](https://qiita.com/edo_m18/items/71f6064f3355be7e4f45)
- [HLSLビルドイン関数](https://docs.microsoft.com/ja-jp/previous-versions/direct-x/bb509611(v=vs.85)?redirectedfrom=MSDN)
- [Shader共通化テクニック](https://light11.hatenadiary.com/entry/2019/01/20/013748)
- [Editorの状態を監視](https://kan-kikuchi.hatenablog.com/entry/playModeStateChanged)
