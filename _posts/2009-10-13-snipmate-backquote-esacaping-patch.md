---
layout: post
title: snipMate反引号转义补丁
category: dev-notes
tags: tools vim
---

<img class="title-icon" src="{{ site.attachment_dir }}2009-12-13-vim.jpg" alt="Vim Logo" />

<small>后记：snipMate当前已经在官方版本中支持反引号的转义了。</small>

对于一套IDE来说，一个好的snippet管理工具可以大大提高程序员的工作效率。作为一个适应不了Emacs的Vim geek，Eclipse自带的代码补全、Visual Studio的Visual Assist插件、Emacs下由[Pluskid](http://blog.pluskid.org)荣誉出品的[yasnippet](http://code.google.com/p/yasnippet/)，都让我十分垂涎。之前曾经用过很长一段时间的[snippetEmu](http://www.vim.org/scripts/script.php?script_id=1318)（这也是Debian/Ubuntu vim-scripts包中所带的snippet插件），虽然确实有助于提高效率，却有诸多不足：视觉效果很不清爽，时不时还出些问题，最难忍的便是其晦涩不堪的snippet定义方式。后来也尝试过同事推荐的另一个已经不记得名字的插件，仍旧不趁手，又换回snippetEmu。

前两天无意中发现snipMate，试用之后大呼惊艳！虽然和snippetEmu同是模仿TextMate，snipMate要精致得多。Snippet的定义方式也非常灵活和人性化。只有一处让人不待见的地方，就是snippet定义必须像Makefile一样以tab开头。通读文档之后依照自己的代码风格改写了默认的C/C++ snippet文件，又录入了Emacs erlang-mode所带的几个OTP behaviour的snippet。把玩一番，爱不释手 `:-D`

<hr class="more docutils" />

周末闲时接着翻译[《Erlang并发编程》](http://svn.liancheng.info/cpie-cn/trunk/.build/html/index.html)第9章，又想到snipMate。于是顺手定义了一个`rst.snippets`文件，用来简化reStructuredText格式中多种Markup的输入。其中有这么一个用于输入等宽格式文本的snippet：

{% highlight vim %}
# Literal text
snippet l
    ``${1}``${2}
{% endhighlight %}

写到一半的时候就想起来，反引号在snipMate中是有特殊用途的：snipMate的snippet占位符中可以插入Vim脚本表达式以实现一些高级功能，Vim表达式就需要以一对反引号包围起来，例如默认的`_.snippets`中：

{% highlight vim %}
snippet date
    `strftime("%Y-%m-%d")`
{% endhighlight %}

就可以将`date`展开为当前日期。这样一来，我的`rst.snippets`中的反引号会不会被错误地解释呢？如果这么写不行，那么snipMate是否支持反引号的转义呢？试了一下，发现果然出错了。在snipMate文档中也没有找到反引号转义相关的说明。无奈之下只有去翻snipMate的源码。说来可耻，用Vim 4年了，一直都没有仔细学过Vim的脚本语言……除了日常的`.vimrc`配置以外，也从来没有写过别的Vim脚本。

所幸snipMate的代码并不复杂，很快在`autoload/snipMate.vim`中找到了这么一段：

{% highlight vim %}
" Evaluate eval (`...`) expressions.
" Using a loop here instead of a regex fixes a bug with nested "\=".
if stridx(snippet, '`') != -1
    while match(snippet, '`.\{-}`') != -1
        let snippet = substitute(snippet, '`.\{-}`',
                    \ substitute(eval(matchstr(snippet, '`\zs.\{-}\ze`')),
                    \ "\n\\%$", '', ''), '')
    endw
    let snippet = substitute(snippet, "\r", "\n", 'g')
endif
{% endhighlight %}

从第81行的正则表达式`` `.\{-}\` ``来看，snipMate的作者只是简单的匹配了成对的反引号及其间的内容，而没有作任何转义处理。简单构思了一下，决定以传统方式用反斜杠来转义反引号，于是动手打了一个简单的patch。</p>

首先将第81行的正则式修改为``[^\\]`.\{-}` ``，这样snipMate就不会将以反斜杠开头的反引号纳入处理范畴。同时，在第86行之后增加了这么一行：

{% highlight vim %}
let snippet = substitute(snippet, "\\\\`", "`", 'g')
{% endhighlight %}

用来将所有的``\```再次还原为单个反引号。最后，将之前的snippet改写为：

{% highlight vim %}
# Literal text
snippet l
    \`\`${1}\`\`${2}
{% endhighlight %}

简单测试了一下，大功告成！ `:-D` 开心之余屁颠地跑到snipMate的Google Code主页上去[提交了这个patch](http://code.google.com/p/snipmate/issues/detail?id=88&amp;colspec=ID%20Type%20Status%20Priority%20OS%20Summary)。说来再次可耻，虽然一直享着OpenSource的福，却从未正式提交过补丁，以至于我都不知道应该如何正确地提交一个补丁……Google了一把倒也迅速搞定。

提交patch的时候写道：我是个Vim脚本新手，不敢说这个补丁有没有什么问题。果不其然，在写这篇blog的时候便发现果然有个bug：第81行的那个修改过的正则式``[^\\]`.\{-}` ``要求在反引号前必须有一个不是反斜杠的字符，于是当反引号位于行首时，就匹配失败了。上文提到的用于输入当前日期的snippet便会因此而被错误地展开（我也正是因为尝试这个snippet才发现这个bug的）。好在解决起来也简单，需要匹配的反引号对所应满足的条件应该是：第一个反引号位于行首或者前一个字符不是反斜杠。于是将正则式改为改成``\(^|[^\\]\)`.\{-}` ``就可以了。
