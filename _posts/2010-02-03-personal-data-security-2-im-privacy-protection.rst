---
layout: post
title: "个人数据安全 (2)：保护即时通讯隐私"
category: personal
tags: data-security censorship im otr xmpp
language: zh
---

{% include emoticon.rst %}

.. default-role:: math

.. image:: {{ site.attachment_dir }}2010-02-03-censorship.gif
    :class: title-icon
    :alt: Cencorship

**本文部分链接可能需要翻墙访问**

一般来说，即时通讯（IM）软件都会对客户端到服务器的通讯进行加密，对用户隐私数据安全提供一定程度的保障。但也有例外，比如MSN就完全不加密。所以一些小公司将MSN作为主要IM工具是极为不明智的，借助Wireshark等简单工具对员工间甚至员工和客户间的对话内容进行监听易如反掌，极容易造成商业机密的泄漏。微软坚持使用明文MSN协议的目的让人难以捉摸，其中恐怕难免混有政治因素。使用MSN Shell插件的加密功能或者SSH隧道转发等手段，也可以不同程度地间接加密MSN通讯数据。

即使是那些号称使用加密协议的IM服务，也并不真的就百分之百地安全，在国内的网络环境下尤其如此。一直饱受质疑的QQ（\ `1`__\ 、\ `2`__\ ）自不必说，国内其他的IM运营商也多少存在类似的境况。这种行为固然可恶，但作为国内的运营商，若不如此便无法生存——饭否便是个极好的例子。即便是Google，也干出了中文版Gtalk不开启加密（\ `1`__\ 、\ `2`__\ ）这样的事情来。如果不采取一些特别的措施，无论你愿不愿意，正如题图一样：The big brother is watching you!

__ http://rt.ju690.com/rt/15711
__ http://www.chinagfw.org/2009/09/qq_23.html
__ http://xijie.wordpress.com/2009/08/26/%E3%80%90%E6%B3%A8%E6%84%8F%E3%80%91%E4%B8%AD%E6%96%87%E7%89%88google-talk%E6%98%AF%E6%9C%AA%E5%8A%A0%E5%AF%86%E6%98%8E%E6%96%87%E4%BC%A0%E8%BE%93%E8%81%8A%E5%A4%A9%E5%86%85%E5%AE%B9/
__ http://www.google.com/support/forum/p/other/thread?tid=5ee3c6dc35225996&amp;hl=zh-CN

.. more

Why?
====

为什么即使是采用加密协议，仍然逃不过监视？那就要先看看通讯过程中哪些内容被加密，以及是如何被加密的。各种IM系统的加密方式林林总总，有的采用标准的SSL/TLS，有的则自行打造。但总体上说大致还是脱不开SSL/TLS的主体脉络，也就是先用非对称加密交换对称密钥，再用对称密钥对链路上的数据进行加密，同时辅以身份验证。其基本原理可以参见\ `本系列的第一篇`__\ 。

__ /personal-data-security-1-protect-personal-privacy-with-gnupg/

.. compound::

    通常，在发送方和接收方客户端连接到服务器时首先会和服务器协商对称密钥。之后，一条聊天消息从发送到接受大致可以分为一下几个阶段：

    * 	发送方客户端用自己的对称密钥加密明文消息并发送至服务器
    * 	**服务器用和发送方客户端的对称密钥还原出明文消息**
    * 	服务器用和接收方客户端的对称密钥加密明文消息并发送至接收方客户端
    * 	接收方客户端用自己的对称密钥还原出明文消息

    所以，被加密的实际上是消息在服务器和客户端之间的传输链路，以防在传输过程中遭到第三方（比如GFW）监听。特别需要注意的是在第2步，消息会在服务器被还原为明文。从功能角度上说，这么做的优势很明显，运营商在服务器端可以提供更多的功能。例如Gtalk的服务器端存储聊天记录，还有QQ的聊天记录漫游，以及对spam消息进行分拣过滤等等。当然，从保护用户隐私的角度考虑，运营商是不应该将明文聊天记录泄漏出去的。然而嘛……大家都知道。

Hosted.IM——搭建自己的IM服务器
=============================

既然整个环节的漏洞出在IM运营商处，那么不妨搭建自己的IM服务器吧 |smile| 这里介绍的由\ `ProcessOne`__\ 提供的\ `Hosted.IM`__\ 是一个免费的XMPP托管服务，只需要一个域名即可。提供的功能包括群组聊天、文件传输、域间互通等等，详细说明参见\ `这里`__\ 。

__ http://www.process-one.net/
__ http://hosted.im
__ http://hosted.im/portal/features

Hosted.IM的用户界面极精简，配置的过程很简单。首先你得在Hosted.IM上注册帐号，通过邮箱验证后，还需要在自己的域名服务商处为自己的域名配上如下的DNS条目（强烈建议使用国外的域名服务，国内的域名服务很多都不提供SRV设置入口）：

.. parsed-literal::

	_xmpp-client._tcp.\ **your.name**\ . IN SRV 20 0 5222 xmpp2.hosted.im.
	_xmpp-client._tcp.\ **your.name**\ . IN SRV 10 0 5222 xmpp1.hosted.im.
	_xmpp-server._tcp.\ **your.name**\ . IN SRV 10 0 5269 xmpp1.hosted.im.
	_xmpp-server._tcp.\ **your.name**\ . IN SRV 20 0 5269 xmpp2.hosted.im.
	_jabber._tcp.\ **your.name**\ . IN SRV 20 0 5269 xmpp2.hosted.im.
	_jabber._tcp.\ **your.name**\ . IN SRV 10 0 5269 xmpp1.hosted.im.
	_vhreg_auth.\ **your.name**\ . IN TXT "c500b6278e37092eb24eb71492719a7e68009ac5"

将以上的\ ``your.name``\ 更改为你自己的域名。最后，添加若干用户，便可用Pidgin、Psi等支持XMPP的客户端登录使用了。

简单快捷的背后，缺点也很明显：

* 	每个域名只支持10个注册用户，适合于小范围的注重即时通讯隐私的团体交流，比如小型创业团队。好在XMPP天然支持域间互通，如果一个域名不够用，再来几个就是。
* 	管理界面太过简洁了，实际上除了增删用户以外什么功能有没有。如果你需要更多的功能或在一个域内支持更多的用户帐号，就得给ProcessOne发邮件申请付费服务了。
* 	采用这种做法，事实上并没有改变问题的本质，只是做了一个风险转移。前提是我们假设将IM服务托管在身处墙外的、相对小众的ProcessOne的风险要远小于国内的IM服务商。

ProcessOne
----------

顺便说一说ProcessOne。可能很多人都没有听说过这家公司，但在Erlang和XMPP界，ProcessOne可是鼎鼎大名。近年来Erlang在互联网应用中的流行也跟ProcessOne的杀手级应用\ `ejabberd`__\ 有着密切的联系——Facebook的IM服务器采用的就是定制版的ejabberd。ProcessOne还有其他的一些有趣的项目，比如：

* 	`CEAN`__

	Erlang应用管理工具，借鉴自CPAN

* 	`Talkr.im`__

	ProcessOne的IM服务，支持AIM、ICQ、MSN/WLM、Yahoo!等多种IM协议网关，近期还推出了Google Wave的协议网关

* 	`Tweet.im`__

	Twitter/XMPP网关，借助Gtalk或任意一款XMPP客户端即可免翻墙轻松访问Twitter（最大的缺点是不支持RT）

__ http://www.ejabberd.im/
__ http://cean.process-one.net/
__ http://talkr.im
__ http://tweet.im

OTR
===

如果觉得ProcessOne还是不足以受信怎么办？好吧您可真够多疑的。这时候就可以祭出OTR了。OTR实际上是一类技术的通称，全名是Off The Record，用以指代避免在服务器上以任何形式留存下消息明文的各种技术。

OTR的基本原理其实也很简单，简而言之就是借助公钥加密算法多做一层加密。以XMPP为例，拆解一下就是：

* 	参与IM通讯的每个IM用户都自行生成一对公私钥对，并将自己的公钥发送给对方
* 	若消息发送方打算发送消息\ `M_0`\ ，则发送方首先用接收方的公钥和自己的私钥对\ `M_0`\ 进行加密、签名，得到\ `M_1`
* 	`M_1`\ 被投递给XMPP客户端程序，客户端将使用TLS对其进行二次加密，得到\ `M_2`
* 	\ `M_2`\ 经由服务器被发送给消息接收方的XMPP客户端程序
* 	消息接收方客户端程序收到\ `M_2`\ 后通过TLS解密还原出\ `M_1`
* 	接收方用自己的私钥和发送方的公钥对\ `M_1`\ 进行解密、签名校验，最终还原出\ `M_0`

这样做的好处在于：

由于公钥加密的介入，无论所使用的底层IM协议是否支持加密，消息本身的保密性都可得到保障。即使IM服务器尝试对消息\ `M_2`\ 进行解密，也只能还原出\ `M_1`\ ，而无法得到\ `M_0`\ ；也就是说服务器端无论如何都得不到消息明文

这样一来，即使服务器端尝试对解密出的消息“明文”进行存储，也只能存储由公钥加密保护的\ `M_1`\ ，而无法触及\ `M_0`\ ，OTR也正是由此而得名的。

Pidgin Encryption
=================

Pidgin便有一个OTR插件——\ `Pidgin Encryption`__\ ，可对Pidgin支持的各种IM协议进行OTR保护。Debian/Ubuntu用户可以直接用\ ``aptitude``\ 安装\ ``pidgin-ecnryption``\ 包。

__ http://pidgin-encrypt.sourceforge.net/

使用PE时，需要消息收发双方都安装该插件，并各自生成自己的密钥对（推荐使用4096位密钥）。发起会话时，PE会自动发起密钥交换过程，用户只需确认对方的公钥即可。后续的会话过程便都将处于OTR的保护之下。

使用OTR虽然非常安全，但使用起来也相应地有些麻烦。比如通讯双方必须使用相同的OTR算法（这往往意味着双方必须使用同一种IM客户端及OTR插件），以及必须小心保护和备份密钥对文件以防被盗取或遗失。

XMPP/OpenPGP双剑合璧
--------------------

如果各个客户端都采用标准的IM协议和OTR算法，那么不同客户端之间的互操作性就可以大大加强。我们已经知道XMPP是一个标准、开放的IM协议，同时也知道了OpenPGP是一个基于公钥加密算法的隐私数据保护标准。那么是否能在XMPP上采用OpenPGP作为OTR算法呢？

事实上XMPP的扩展协议之一，\ `XEP-0027`__\ 便定义了在XMPP中使用OpenPGP的方法。Psi已支持XEP-0027，Pidgin则尚不支持。不过我在\ `这里`__\ 发现确实有人在进行Pidgin的GnuPG插件开发。

__ http://xmpp.org/extensions/xep-0027.html
__ http://blog.chavant.info/2009/06/01/gnupg-plugin-for-pidgin

结语
====

墙内的网络环境越来越恶劣，让人越来越没有安全感。但其实要对个人隐私进行一些基本的保护，也并不困难。当然不希望在日常生活中也不得不用上这些方法，这篇权且当作是未雨绸缪。

.. vim:ft=rst ts=4 sw=4 sts=4 et wrap
