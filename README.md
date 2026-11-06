# 日语工具体验站

`jlpt-study-preview` 是一个只存放体验版的 GitHub Pages 站点。三个工具共用同一个
首页和同一个 `main` 分支，通过独立子路径进入。

## 当前内容

所有工具只保留最近一次已举行的 JLPT 考试，也就是 **2026.7 一套**。

| 工具 | 子路径 | 当前范围 |
| --- | --- | --- |
| N1 問題四 · 词汇用法 | `/n1-q4/` | 第 20～25 题，共 6 题 |
| N1 問題六 · 语法排序 | `/n1-q6/` | 第 36～40 题，共 5 题 |
| N2 問題六 · 词汇用法 | `/n2-q6/` | 第 26～30 题，共 5 题 |

预计仓库地址：

```text
https://github.com/chenxiaoshi920/jlpt-study-preview
```

预计公开入口：

```text
https://chenxiaoshi920.github.io/jlpt-study-preview/
```

## 文件结构

```text
jlpt-study-preview/
├── index.html
├── README.md
├── AGENTS.md
├── COPYRIGHT.md
├── site-manifest.json
├── .nojekyll
├── assets/
│   └── bear-author.jpg
├── .github/
│   └── workflows/
│       └── pages.yml
├── scripts/
│   ├── filter_embedded_data.rb
│   └── verify_preview.rb
├── n1-q4/
├── n1-q6/
└── n2-q6/
```

根目录中的 `index.html` 是唯一主入口。每个工具目录都可以独立打开，彼此不共享学习记录。

## 建立 GitHub 仓库

1. 在 GitHub 新建公开仓库，名称填写 `jlpt-study-preview`。
2. 不要勾选自动生成 README、`.gitignore` 或 License。
3. 创建后，只上传当前 `jlpt-study-preview` 文件夹里的内容，不把外面的原版工具、
   真题截图、PDF、工作稿或压缩包一起上传。
4. `.github` 和 `.nojekyll` 是隐藏文件。macOS Finder 中按 `Command + Shift + .`
   可以显示它们，务必确认一起上传。
5. 打开 `Settings → Pages`，把 Source 选为 `GitHub Actions`。
6. 等待 `Deploy static preview site` 工作流完成，再打开预计公开入口。

如果暂时不想使用 Actions，也可以在 Pages 中选择
`Deploy from a branch → main → / (root)`。两种方式都只使用一个 `main` 分支。

## 本地检查

在仓库根目录运行：

```sh
ruby scripts/verify_preview.rb
python3 -m http.server 4173
```

浏览器打开 `http://127.0.0.1:4173/`。Service Worker 和离线功能需要通过 HTTP
访问，直接双击 HTML 不能完整检查缓存行为。

每次交付给用户验收时，统一使用：

```text
http://127.0.0.1:4174/
```

修改完成后还要同时提供受影响工具的直达链接。

## 更新原则

工具页面必须保持原正式版的布局、配色、操作流程和功能。更新体验内容时只替换
对应工具子目录中的发布文件，并同步修改题目数据范围、缓存版本、学习记录键、
首页题量和 `site-manifest.json`。

详细规则见 `AGENTS.md`。任何 AI 修改此仓库前都必须先阅读并遵守该文件。
