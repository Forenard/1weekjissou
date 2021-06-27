### 1weekjissou-画面遷移の実装

![](https://j.gifs.com/lR5LjV.gif)

![](https://j.gifs.com/J8qAVv.gif)



# 使用方法
- CameraにTransitionCameraFilterコンポーネントをアタッチする。
- Filtersには、画面遷移用マテリアルを入れる(後述)
- public関数のStartTransition(bool isTransitionIn)を呼び出すと遷移が行われる

### 画面遷移用マテリアル

- Assets/Shaders/Transition.shaderを参考にしてください
- Propertyの`float _T`(遷移中time:0->1)がAnimationCurveを通して与えられるので、実装は線形にした方が分かりやすいです

### ExampleShader
- Transition:基本となるシェーダー　ネガポジ反転しかしない
- Pixel:ピクセル化する
- ColorBox:横から色が出てくる
- ColorCircle:↑を極座標変換しただけ
- DomainWarp:DomainWarp
---

# 実装で考えたこと

## 画面遷移の問題
1. 遷移中に他の動作(Playerが動き続けているなど)は止めたい
2. なるべく他コンポーネントとの依存関係は作らずにSceneTransitionコンポーネント単体で動くようにしたい

## 案
- `Time.timeScale=0`
- postprocessを利用してMaterial単位で遷移アニメーションを管理、作成する

## 雑記

- `Time.timeScale=0`だけでは問題1を完全に解決はできない。Update()は普通に呼び出されてしまう
- まあそこらへんは実装する人が何とかする領域なので、問題2だけ考えればいいのでは

## 実装
- `OnRenderImage`コールバックを利用してシェーダーから画面遷移のポストエフェクトをかける
- `StartTransition()`が呼び出された時の`RenderTexture`を保持しておくことで、画面を停止させる(処理は止められないが)

## URLら

- [ShaderのPropertiesにboolを入れる](https://docs.unity3d.com/Manual/SL-Properties.html)
- [`Time.timeScale=0`でとまらないもの](https://tech.pjin.jp/blog/2016/12/20/unity_skill_7/)
- [CustomPostProcessの基本](https://qiita.com/Hirai0827/items/4946ee4b8b52d6f1da27)
- [GLSLビルドイン関数](https://qiita.com/edo_m18/items/71f6064f3355be7e4f45)
- [HLSLビルドイン関数](https://docs.microsoft.com/ja-jp/previous-versions/direct-x/bb509611(v=vs.85)?redirectedfrom=MSDN)
- [Shader共通化テクニック](https://light11.hatenadiary.com/entry/2019/01/20/013748)
- [Editorの状態を監視](https://kan-kikuchi.hatenablog.com/entry/playModeStateChanged)
- [easing](https://easings.net/)



