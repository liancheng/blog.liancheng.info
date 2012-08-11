---
layout: post
title: Concurrent Programming in Erlang (Part 1) 中文译稿
category: translation
tags: translation cpie-cn erlang
---

<div class="title-icon"><img src="{{ site.attachment_dir }}2009-12-15-erlang.png" alt="Erlang Logo" /></div>

链接：[《Erlang并发编程》第一部分][cpie-cn]

从去年年中开始，利用闲暇时间零零散散地翻译Concurrent Programming in Erlang (Part 1)。完成了[序言][preface]、[致谢][ack]、[简介][intro]和[第1章][chapter-1]之后由于工作繁忙暂停了很久。今年年初，又重新捡起来，完成了[第2章][chapter-2]。同时也将原先的reStructuredText格式的译稿迁移到Sphinx上。借助Sphinx，将译稿切分、组织成了合理的工程目录。于是将译稿上传到了SVN，又在Erlang-China和TopLanguage发了[帖子][post]，正式发起[CPiE-CN项目][project]，召集了一批志愿译者，开始合作翻译剩余章节。

各位志愿者们动作都相当迅速，没多久便相继提交了各自负责章节的译稿。不过有些并非是Sphinx格式，需要再手工适配到Sphinx。有些即使是 Sphinx格式，一些排版和格式的细节处理也还不到位（有些译者还是Sphinx新手）。也有志愿者出于种种原因遗弃了认领的章节——不过没关系，考虑到本人本来就拖拉成性，所以特地在[译者须知][notice]中注明本项目没有任何进度压力……

于是，适配非Sphinx格式译稿、整理其他译者的Sphinx译稿排版格式、校对所有译稿以及翻译惨遭遗弃的章节，就成了我剩下的工作。期间因为工作原因暂停过很长一段时间。不过说实话，由于暂停得实在太久，以至于后来工作不忙的时候也没能想起来……囧……咳，总之，断断续续一年，总算将全书主体 翻译完毕——“主体”的精确含义是：除附录B、E和参考文献列表以外的所有内容。

<!-- start -->

在此严重感谢无私贡献译稿的诸位志愿译者，他们是（按参与项目的时间次序排列）：

*   王飞（第4章、第8章）
*   Ken Zhao（第6章）
*   张驰原（第5章）
*   丁豪（第7章）
*   赵卫国（附录C、附录D）
*   吴峻（附录A）

最后……也感谢一下自己：

*   连城（序、致谢、简介、第1章、第2章、第3章、第9章、全文校对）

- - -

后记：

1.  CPiE-CN全部译稿使用[BY-NC-ND的CC协议][cc]许可。曾经在erlang-questions邮件组中询问过Joe大叔的意见，大叔称没问题并将邮件转发给了Prentice Hall出版社的编辑，不过出版社并没有回音。
2.  曾经说要在DreamHost上折腾一个Trac用来做勘误，最终可耻地没有搞定。此事无限期顺延……没有寄宿到Google Code等站点的原因是这些站点不支持相应的CC许可协议。
3.  今年3月14号翻译完第2章的时候本写过一篇blog。第二天便正式发布了CPiE-CN项目。在那篇里对长篇技术文档的撰写工具进行了探讨，盛赞了Sphinx，并对Erlang社区表达了无限的憧憬。然而，该篇blog后来由于未知原因（估计是误操作或WordPress升级事故）被不幸截肢，全文只剩下大约30%。可怜我在事发之后不知道多久才发现，遍寻Google Reader、Google Cache和百度Cache也找不到原来的全文，只好忍痛将该篇匿了，秘谋让该篇在全书译稿完成时再次涅磐。然而，昨天重新编辑了这篇blog后，发现RSS却没有更新，可能是跟发布时间等因素有关，只好又新开一篇。这件事情教育我们：一定要定期备份WordPress数据库啊！

<!-- end -->

[cpie-cn]:   http://cpie-cn.googlecode.com/hg/_build/html/index.html
[preface]:   http://cpie-cn.googlecode.com/hg/_build/html/preface.html
[ack]:       http://cpie-cn.googlecode.com/hg/_build/html/preface.html
[intro]:     http://cpie-cn.googlecode.com/hg/_build/html/preface.html
[chapter-1]: http://cpie-cn.googlecode.com/hg/_build/html/preface.html
[chapter-2]: http://cpie-cn.googlecode.com/hg/_build/html/part-i/chapter-2.html
[post]:      http://groups.google.com/group/erlang-china/browse_thread/thread/3baae94948d7a932
[project]:   http://cpie-cn.googlecode.com/hg/_build/html/cpie-cn-project.html#cpie-cn
[notice]:    http://cpie-cn.googlecode.com/hg/_build/html/cpie-cn-project.html#id6
[cc]:        http://creativecommons.org/licenses/by-nc-nd/2.5/cn/
