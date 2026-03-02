## IOT BOOK维护

### 英文版页面
通过修改`md`文件后运行`mkdocs`即可，所有的文件均在`en-md`文件夹下

### 中文版页面
`zh-md`下存在对应的`md`，但是并不是最新的，而且也没有`mkdocs`，目前是静态网站维护

### 工具性代码讲解
```aiignore
inject_lang_button.py 
```
用于整体替换静态网页中的某些组件，本质原因是中文版的维护不是由`markdown`即时生成的

```aiignore
make_zh_redirects.py
```
由于代码文件路径发生了迁移，为了避免原有的链接失效增加的脚本，生成大量的`index.html`，作用只是单纯的跳转到`/zh`下的同名路径



