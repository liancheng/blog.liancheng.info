---
layout: post
title: Why I hate Markdown (and prefer reST)
category: misc
tags: markdown markup re-structured-text
---

TL;DR

最近把blog从WordPress迁移到了Jekyll。方便起见，目前暂时托管在GitHub上。Jekyll内置了多种标记语言支持，可惜其中并不包含我最喜爱的[reStructuredText][2]（以下简称为reST）。虽然也有[现成的Jekyll reST插件][3]，但GitHub出于安全考虑禁用了Jekyll插件。在Jekyll内置支持的若干标记语言中比较了一番之后，决定开始用[Markdown][7]写文章。然而很快便发现，Markdown实在是让人爱不起来。这篇就来批一批Markdown。作为对比，我还会写一写同样的问题在reST中是怎么解决的。

**注意**：我从来没有说Markdown是最烂的标记语言，比Markdown更烂的标记语言还有的是。但Markdown自身的确有一些严重的缺陷，尤其是在中文文档书写方面，无论是文档的结构语义表达还是样式套用，都令我非常不满意。

在我看来，Markdown的应用范围应当限制在千字以内、仅包含少量格式、无复杂结构的文档撰写，典型应用如类Doxygen的代码文档注释和blog评论等。除此之外，科技文档撰写、书籍撰写等场景下，Markdown都不是什么好的选择。并且，在这些应用中应当尽可能只使用Markdown的标准格式。Markdown的各种实现版本还各自新增了各式各样的语法扩展，这些扩展虽然便利，但却大大折损了Markdown文档及相关工具的互操作性。

## Keep it simple stupid, but not too simple, please

Markdown很简单，这本是好事。然而不幸的是它实在是太简单了，以至于很多基本任务都无法完成，简直就是“简陋”。和其他标记语言一样，Markdown内置支持标题、加粗、斜体、链接等多种常用格式。同时，作为特色功能，Markdown还支持直接内嵌HTML代码。初次接触Markdown的时候，我还觉得这个设计挺不错：通过内置支持的简化格式覆盖80%的需求，通过内嵌HTML覆盖剩下的20%，很好！可惜现实并非如此。首先，Markdown的语法过于简陋，很多**基本的文档结构语义**都无法表达；其次，Markdown生成的是**裸**HTML代码，不带任何CSS class信息，使得CSS样式套用非常不便；再次，Markdown的语法完全不可扩展，不可能在不修改具体实现代码的前提下解决上述问题。（注意我指的是Markdown语法的可扩展性，不是Markdown某具体实现在API层面的可扩展性。）

### 文档结构语义问题

考察以下这个常见场景：

*   在解释某个概念时，我们起草了一个段落；
*   为了进行更进一步的讨论，我们插入一个无序列表，针对若干方面展开讨论；
*   最后，继续上一段落，对上述讨论进行总结

我们希望上述三部分逻辑上是一个段落，而不是两个或三个独立段落。

#### Markdown中的（错误）做法

在Markdown中怎么表达上面的结构语义呢？没有办法。根据标准Markdown的语法，最为近似的做法如下：

    概念概述

    *   细分情况1
    *   细分情况2

    概念总结

理想情况下，我们期望得到以下输出：

    <p>
      概念概述

      <ul>
        <li>细分情况1</li>
        <li>细分情况2</li>
      </ul>

      概念总结
    </p>

然而Markdown给出的却是**三个**独立的段落：

    <p>概念概述</p>

    <ul>
      <li>细分情况1</li>
      <li>细分情况2</li>
    </ul>

    <p>概念总结</p>

你可能会说，这就是为什么Markdown支持内嵌HTML代码呀：直接把这段替换成你要的HTML代码不就行了？等等，请注意下[Markdown官方页面][4]上的这一句：

>   Note that Markdown formatting syntax is not processed within block-level HTML tags. E.g., you can’t use Markdown-style \*emphasis\* inside an HTML block.

处理小篇幅HTML片段时，没有问题。但如果是长达数百字、满是链接和各种其他标记的段落，那就郁闷了。仅仅为了修正文档结构的问题，就得用HTML把整个段落重写，这个代价实在是太高了。

还有人可能会说，结构不准确又有什么关系呢？绝大部分情况下，这两段HTML代码的视觉效果都是一样的嘛。不妨考虑一下中文的段落首行缩进问题。通常，在设计中文长文档网页时，我们可以通过以下CSS片段来实现段落首行缩进（实际应用中会更复杂，这里做了简化）：

    p {
      text-indent: 2em;
    }

问题来了，在Markdown输出的HTML代码中，“概念总结”被放入了`<p>`标签内，直接导致了一个错误的缩进（[正确版本][9] v.s. [错误版本][10]）。

#### reST的解决方案

现在我们来看看reST是如何解决这个问题的。ReST内置了多种[指令（directive）][5]，可用于表达数种复杂文档结构。其中一种便是[复合段落（compound paragraph)][6]指令：

>   The "compound" directive is used to create a compound paragraph, which is a single logical paragraph containing multiple physical body elements such as simple paragraphs, literal blocks, tables, lists, etc., instead of directly containing text and inline elements.

有了它，我们便可以这样解决问题：

    .. compound::

        [The description of the concept, bla bla...]

        *   case 1
        *   case 2

        [The summary, bla bla...]

ReST输出的HTML如下：

    <div class="compound">
      <p class="compound-first">概念概述</p>
        <ul class="compound-middle simple">
          <li>细分情况1</li>
          <li>细分情况2</li>
        </ul>
      <p class="compound-last">概念总结</p>
    </div>

看到了吗？虽然“概念总结”仍然被放入了单独的`<p>`标签内，但reST输出的HTML通过详细的CSS class，保留了我们所需的文档结构语义，使得更为精细的样式控制成为可能。对上述HTML片段应用如下CSS，便可以同时解决逻辑结构和视觉样式上的问题：

    p {
      text-indent: 2em;
    }

    p.compound-middle,
    p.compound-last {
      text-indent: 0;
    }

最终效果参见[这里][11]。

### 样式问题

Markdown只能输出**裸**HTML：只有标记，没有CSS class。这使得我们几乎不可能对Markdown输出的HTML进行精细化的样式控制。当然，内嵌HTML代码是可以的，只不过，这次还得通过`style`属性四处内嵌CSS样式。

#### 再来看看reST的解决方案

除章节标题等格式外，reST标记元素可分为两大类：[角色（role）][5]和[指令（directive）][12]。这两者都支持自定义CSS class。这也给reST语法带来了Markdown无法比拟的可扩展性。

首先来看下reST角色。在翻译[《Erlang/OTP并发编程实战》][13]时，我就曾经运用过这种手法来标识暂不确定译法的译文。首先在reST文稿中用`.. role::`指令自定义角色`unsure`：

    .. role:: unsure

然后在译文中应用该角色：

    这一段译文没有问题。\ :unsure:`但这一段译文我不是很确定`\ 。

经reST转换，HTML如下：

    这一段译文没有问题。<span class="unsure">但这一段译文我不是很确定</span>。

配合CSS样式

    .unsure {
      background-color: yellow;
    }

效果如下：

<p><center>这一段译文没有问题。<span class="unsure" style="background-color: yellow;">但这一段译文我不是很确定</span>。</center></p>

然后是reST指令。各种reST指令都支持用于指定自定义CSS class的`:class:`选项。如：

    .. image:: http://www.erlang.org/doc/erlang-logo.png
        :class: shading
        :alt: Erlang logo

经reST转换，HTML如下：

    <img class="shading" src="http://www.erlang.org/doc/erlang-logo.png" alt="Erlang logo" />

配合CSS样式

    img.shading {
      box-shadow: 0 0 14px rgba(0, 0, 0, 0.15);
      padding: 10px;
    }

效果如下：

<p><center><img style="box-shadow: 0 0 14px rgba(0, 0, 0, 0.15); padding: 10px;" src="http://www.erlang.org/doc/erlang-logo.png" alt="Erlang logo" /></center></p>

对于更为灵活的定制需求，reST还提供了用于给任意reST文档片段增加CSS样式的`.. class::`指令。

- - -

好了，对Markdown的批评就到此为止了。实际上还有一些其他问题，尤其是对中文等非英文Unicode字符的处理方面。不过这些问题基本上是所有类似markup语言的通病，也就不单独列出了。

另外不得不提的一点是，Markdown有两个reST比不上的优点：在中文中无需转义空白符，以及支持标记嵌套。这么说比较抽象，看下具体的例子。

*   在reST中，粗体、斜体等标记必须用空白符或若干英文标点作为分隔，并且该空白符会直接带入输出的HTML。在中文环境下，要想避免多余的空白符，就必须用反斜杠加空格作转义：

        这段reST格式的文本包含\ **粗体**\ 、\ *斜体*\ 和\ ``代码``\ 样式

    而在Markdown中，无需转义，可以直接书写为：

        这段reST格式的文本包含**粗体**、*斜体*和`代码`样式

*   ReST不支持嵌套格式，以下片段是错误的：

        reST中\ **粗体嵌套\ *斜体*\ 是不支持的**

    而Markdown却可以支持：

        Markdown中**粗体嵌套*斜体*也没问题**

[1]: http://en.wikipedia.org/wiki/Open/closed_principle
[2]: http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html
[3]: https://github.com/xdissent/jekyll-rst
[4]: http://daringfireball.net/projects/markdown/syntax/#html
[5]: http://docutils.sourceforge.net/docs/ref/rst/directives.html
[6]: http://docutils.sourceforge.net/docs/ref/rst/directives.html#compound-paragraph
[7]: http://daringfireball.net/projects/markdown/
[8]: http://www.ituring.com.cn/
[9]: {{ site.attachment_dir }}2012-08-03-correct.html
[10]: {{ site.attachment_dir }}2012-08-03-wrong.html
[11]: {{ site.attachment_dir }}2012-08-03-re-st.html
[12]: http://docutils.sourceforge.net/docs/ref/rst/roles.html
[13]: http://www.ituring.com.cn/book/828
