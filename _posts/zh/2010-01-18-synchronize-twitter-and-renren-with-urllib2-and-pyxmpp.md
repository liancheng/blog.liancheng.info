---
layout: post
title: 尝试用urllib2和PyXMPP同步Twitter和校内状态
category: dev-notes
tags: python renren twitter xiaonei xmpp
---

在翻墙技能还不熟练，同时Twitter上好友也还很稀少的那么一段日子里，一度拿校内状态当作Twitter使用。上周末，看到[@Jun_Yu][1]的[这么一推][2]：

>   发现一件有意思的事儿 好多有意思的推被转到校内 然后又被有的推友贴上"转自校内"的标签重新在这儿疯狂rt</p></blockquote>

于是想起之前发现[校内桌面][3]采用的是标准XMPP协议，且校内状态的更新是采用XMPP Presence实现的，便回了一句：

>   校内的IM是基于XMPP的，理论上只需要发一条`<presence/>`消息就可以修改校内状态，可以做一个校内和Twitter同步的工具 :)

然后[@2325bt][4]便推荐了这篇[将Twitter自动同步到Facebook、饭否、校内、海内等网站的方法][5]。不过这个办法严重依赖于[嘀哒][6]。然而，在墙内的网络环境下，任何和Twitter关系密切的Web服务只怕都难得长寿。而且，对于Twitter/校内状态同步这个简单需求而言，用于完成多方同步的嘀哒不免牛刀样十足。既然人家校内十分友好地采用了开放的XMPP，那么求人不如求己。这两年一直对XMPP保持高度关注，却一直没有机会实际接触相关项目，权当练手。而且说实在的，自己在校内和Twitter上好友群体差异比较大，个人对这个功能其实没啥需求，just for fun。  对我而言，完成这个任务的最佳工具是Python。最原始的想法是写一个脚本，用于：

*   从终端读入帐号信息和一条消息
*   用[urllib2][7]登录Twitter发推
*   [PyXMPP][8]登录校内发送`<presence/>`消息更新状态

<!-- start -->

估摸着复杂度不高，于是放言[应该可以在50行以内搞定][9]，心想最多一个晚上也就差不多了。然而事实证明我过于乐观了。仅仅是在Twitter上，我这个可耻的HTTP盲就撞了两次南墙：

*   居然忘了自己身在墙内——只好把脚本拷到DH服务器上在墙外测试Twitter部分。这意味着要想让该脚本步入实用阶段，至少要支持Twitter API自定义，而此前我对Twitter API一无所知。
*   非常可耻地完全不了解HTTP Basic Authentication——亏得[这篇urllib2手册][10]的指点，花了些时间现学了些HTTP基本知识，总算用`urllib2`发推成功。

最终实现的Twitter部分的功能：采用最简单的Basic Authentication登录，然后调用API [`statuses/update`][11]发推。代码直截了当：

{% highlight python %}
#!/usr/bin/python

import urllib2
from sys import argv

TWITTER_API_STATUSES_UPDATE = 'http://twitter.com/statuses/update.xml'
TWITTER_BASIC_AUTH_REALM = 'Twitter API'

def update(user, password, message):
    auth_handler = urllib2.HTTPBasicAuthHandler()
    auth_handler.add_password(realm=TWITTER_BASIC_AUTH_REALM,
                              uri=TWITTER_API_STATUSES_UPDATE,
                              user=user,
                              passwd=password)

    opener = urllib2.build_opener(auth_handler)
    urllib2.install_opener(opener)
    urllib2.urlopen(TWITTER_API_STATUSES_UPDATE, 'status=' + message)

if __name__ == '__main__':
    user, password, message = argv[1], argv[2], argv[3]
    update(user, password, message)
{% endhighlight %}

功能算是实现了，不过不支持Twitter API，致使在墙内实用性全无。另外最好能支持[OAuth][12]。然而在打算进一步增加功能时，想起应该先看看有没有现成的，于是发现Twitter官方果然列出了[若干个Python Twitter API库][13]。考虑到继续做下去最多也就是再捣腾出另一个类似的东西，顿时兴趣索然。于是决定就这么将就着用了，真有高级功能需求的话，直接用现成的库来实现好了。至此，Twitter部分算是告一段落。

折腾PyXMPP的过程却也并不顺利。首先简单介绍一些XMPP的背景知识和校内XMPP服务的部署。按照RFC 3920 XMPP Core的约定，一个XMPP用户可以由一个JID（Jabber ID，Jabber是XMPP的前身）唯一标识，其格式为`id@domain/resource`。RFC 3920将形如`id@domain/resource`的JID称为完整JID（full JID），而将形如`id@domain`的JID称为裸JID（bare JID）。其中`domain`（域）唯一标识一套XMPP服务器（这个说法并不准确，但在此处无碍），`id@domain`则可标识该服务器账户系统中的一个用户，而`resource`可用于在同一帐号的多个登录会话中唯一标识一个登录会话，内容可由用户指定。例如对于同一个XMPP用户`micky@disney.im`，可以在办公室和家中分别以`micky@disney.im/office`和`micky@disney.im/home`同时登录。如果客户端不指定`resource`，服务器会为其分配一个，一般是一个随机串。裸JID看起来和Email地址是一模一样的，这对于同时提供Email和XMPP服务的服务商来说就很方便，比如Gmail/Gtalk之于Google。

由于校内后来更名为人人网，校内实际上持有两个XMPP域：`talk.xiaonei.com`和`talk.renren.com`。二域并存，应该是为了向下兼容更名前发布的旧版本客户端。校内的帐号也是基于Email地址的，这是否意味着你可以直接使用校内的注册Email登录校内的XMPP服务呢？答案是否定的。校内并不限制Email的域，gmail、163、sina等等应有尽有，而校内是绝然不可能拥有这些域的使用权的。解决的办法很简单：校内中每个用户的注册邮箱都被分配了一个全域唯一的数字ID，校内桌面也就是用形如`123456@talk.renren.com`这样的裸JID来登录XMPP服务器的。要得到这个数字ID很简单：登录你的校内帐号，个人主页URL末尾的那串数字便是这个ID。

拿到裸JID后，第一步就是借助PyXMPP来登录校内XMPP帐号。头一回用PyXMPP，翻文档，接口如云。心想，对于登录这样的常见任务，应该有简化接口吧。果然让我找到了[`pyxmpp.jabber.simple.xmpp_do`][14]：

{% highlight python %}
xmpp_do(jid, password, function, server=None, port=None)
{% endhighlight %}

其文档描述为：

>   Connect as client to a Jabber/XMPP server and call the provided function when stream is ready for IM.

这就好办了，顺手写下一段测试代码（登录指定帐号后打印“hello”）：

{% highlight python %}
def foo(stream):
    print 'hello'

xmpp_do(JID('123546@talk.renren.com/python', 'secret', foo))
{% endhighlight %}

执行、登录失败、挠头、看文档、阅读源码、复习RFC 3920、日志调试……这个问题足足block了我好几个钟头——不过80%的时间花费是由于调试受挫转而去看了大半季的TBBT `;-)` 言归正传，最终我发现上面这短短三行代码其实包含了两个错误：

**TLS和SASL**

校内XMPP服务器要求使用TLS加密。虽然[RFC 3920][15]规定，XMPP客户端必须使用SASL并应该在SASL认证前使用TLS对数据流进行加密，但默认情况下[PyXMPP不启用TLS][16]，`xmpp_do`在登录时采用的是默认设置，因此无法通过协商，进而无法登录。这个问题是参考PyXMPP的echobot示例，输出了PyXMPP的调试日志后发现的。

在[这篇文章][17]的帮助下，从[`pyxmpp.jabber.client.JabberClient`][18]派生了自定义的XMPP客户端类，增加了TLS设置和SASL认证设置，问题解决：

{% highlight python %}
class R2Client(JabberClient):
    def __init__(self, jid, password):
        tls = streamtls.TLSSettings(require=True, verify_peer=False)
        auth = ['sasl:PLAIN']
        JabberClient.__init__(self, jid, password, tls_settings=tls,
                              auth_methods=auth)
{% endhighlight %}

**XMPP域**

修正TLS的问题后再次尝试，却得到一个莫名其妙的`pyxmpp.exceptions.HostMismatch`。该异常类的文档中没有任何说明，只好再次翻[源码][19]。结合日志，发现问题出在XMPP域上。考虑到校内已经正式更名为人人网，在上面的代码中我采用的XMPP域是`talk.renren.com`。观察调试日志，PyXMPP发起连接时向服务器发送的stream header为：

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>
<stream:stream
  xmlns:stream="http://etherx.jabber.org/streams"
  xmlns="jabber:client"
  to="talk.renren.com"
  version="1.0">
{% endhighlight %}

服务器回复的stream header为：

{% highlight xml %}
<?xml version='1.0'?>
<stream:stream
  from='talk.xiaonei.com'
  xmlns='jabber:client'
  xmlns:stream='http://etherx.jabber.org/streams'
  version='1.0'>
{% endhighlight %}

注意客户端发送的stream header的`to`为`talk.renren.com`，而服务器回复的stream header的`from`却是`talk.xiaonei.com`。而PyXMPP在这里做了一个判断，当客户端发送的stream header中的`to`和服务器的stream header中的`from`不符时，便抛出`HostMismatch`异常。

找到了症结就好解决，把XMPP域改为`talk.xiaonei.com`即可。至此，终于登录成功。

不过，在XMPP域的这个问题上，校内和PyXMPP的做法都欠妥。RFC 3920并未规定在stream建立过程中接收方stream header的`from`字段必须和发起方stream header的`to`字段吻合。因此PyXMPP在判断二者不相符时抛出异常导致连接断开的行为是不合适的。而校内这样做的动机，应该是为了对校内更名为人人网之前发布出去的旧版本客户端做兼容。在这个场景下，更合适的做法是由`talk.renren.com`的XMPP服务器向客户端返回一个`<see-other-host/>`错误，同时将正确的XMPP域`talk.xiaonei.com`告知客户端以进行重定向。相较之下，校内XMPP服务器的行为虽然欠妥，但并未违反RFC，倒是PyXMPP的做法有违标准。

完成登录后，更新校内状态就比较简单了，只需要发送一条`<presence/>`消息即可。发送成功后断开连接，脚本执行结束。相关代码如下：

{% highlight python %}
class R2Client(JabberClient):
    ...
    def session_started(self):
        self.stream.send(Presence(status=message))
        self.stream.disconnect()
{% endhighlight %}

最后是XMPP客户端的主循环：

{% highlight python %}
client = R2Client(JID( user + '@talk.xiaonei.com/r2'), password)
client.connect()
client.loop(1)
{% endhighlight %}

上述代码中的R2代表RenRen `:-)` 本以为到此就结束了，不想最后又被PyXMPP绊了一跤：`R2Client.session_started`最后的`disconnect()`调用无法结束主循环。无奈之下再翻源码，在[`pyxmpp.client.Client.loop`][20]中看到：

{% highlight python %}
while 1:
    stream = self.get_stream()
    if not stream:
        break
    ...
{% endhighlight %}

也就是说，只要`stream`对象不为`None`，无论其连接状态如何，`Client.loop`都不会从这个`while`中返回。这得算是个bug了，挠头……最后hack了一下，在`disconnect()`之后将`self.stream`设为`None`，终于大功告成。更新校内状态的完整代码如下：

{% highlight python %}
#!/usr/bin/python

import logging

from pyxmpp import streamtls
from pyxmpp.jabber.client import JabberClient
from pyxmpp.jid import JID
from pyxmpp.presence import Presence
from sys import argv

def UpdateR2(user, password, message):
    class R2Client(JabberClient):
        def __init__(self, jid, password):
            tls = streamtls.TLSSettings(require=True, verify_peer=False)
            auth = ['sasl:PLAIN']
            JabberClient.__init__(self, jid, password, tls_settings=tls,
                                  auth_methods=auth)

        def session_started(self):
            self.stream.send(Presence(status=message))
            self.stream.disconnect()
            self.stream = None

    client = R2Client(JID(user + '@talk.xiaonei.com/r2'), password)
    client.connect()
    client.loop(1)

if __name__ == '__main__':
    logger = logging.getLogger()
    logger.addHandler(logging.StreamHandler())
    logger.setLevel(logging.DEBUG)

    user, password, message = argv[1], argv[2], argv[3]
    UpdateR2(user, password, '[r2] ' + message)
{% endhighlight %}

将这个脚本和前面的Twitter脚本简单整合一下，便可实现Twitter/校内状态的同步更新了。如文章开头所说，其实我自己对这个同步功能并没有什么需求，纯粹是做着玩。把过程写出来，也许对其他人会有些用处吧  `;-)` 起先吹牛说50行以内搞定，最后还是超了，而且还只能算是个原型。要在墙内达到实用水准，至少还要支持Twitter API，最好还能支持OAuth。

最后再多说点关于校内XMPP服务的问题。只要查明自己的校内数字ID，就可以以*`id`*`@talk.xiaonei.com`用任意一款支持XMPP协议的客户端（如[Pidgin][21]、[Psi][22]、[Miranda][23]等）登录校内（实验证明使用`talk.renren.com`域也可成功登录）。登录后可以使用的主要功能包括：

*   与在线的校内好友聊天
*   通过自定义在线状态更新校内状态
*   接收校内新鲜事通知
*   （可能还有其他我尚未发觉的功能）

你会发现自己时不时地收到来自`feed.talk.renren.com@feed.talk.renren.com`的莫名其妙的空消息。这个“空”消息并不空，它其实就是校内新鲜事通知。在协议上，新鲜事通知以`<message/>`消息的形态被发送到客户端。与普通好友消息不同，新鲜事`<message/>`消息的`<body/>`元素为空，新鲜事的详细内容则包含于附加的`<xfeed/>`字段。该`<xfeed/>`字段的格式是校内自定义的，Pidgin等标准XMPP客户端无法解读，因此在客户端界面表现上看来，便是一条“空”消息。如果打开Pidgin的XMPP控制台插件，便可以一窥`<xfeed/>`的全貌。

另外，校内的XMPP服务器不支持域间互通，因此你也就没法在你的Gtalk等其他XMPP帐号上添加自己的校内帐号为好友，反之亦然。

再有一点，就是Pidgin等客户端在默认设置下总会在客户端持续空闲一段时间后自动切入“离开”状态。而XMPP在线状态的改变会导致校内状态的改变。所以当你用Pidgin登录校内一段时间后会发现自己的校内状态列表里多出若干条“我现在不在”，可不要觉得奇怪 `:-D`

<!-- end -->

[1]: http://twitter.com/Jun_Yu/
[2]: http://twitter.com/Jun_Yu/status/7553900526
[3]: http://im.renren.com/?rrpchomepg=1001
[4]: http://twitter.com/2325bt/
[5]: http://www.mixfog.com/blog/2009/05/twitter-sync-to-another-sns.htm
[6]: http://digufeed.com/
[7]: http://docs.python.org/library/urllib2.html
[8]: http://pyxmpp.jajcus.net/
[9]: http://twitter.com/liancheng/status/7555900211
[10]: http://www.voidspace.org.uk/python/articles/urllib2.shtml#id5
[11]: http://apiwiki.twitter.com/Twitter-REST-API-Method%3A-statuses%C2%A0update
[12]: http://apiwiki.twitter.com/OAuth-FAQ
[13]: http://apiwiki.twitter.com/Libraries#Python
[14]: http://pyxmpp.jajcus.net/api/pyxmpp.jabber.simple-module.html#xmpp_do
[15]: http://xmpp.org/rfcs/rfc3920.html#tls
[16]: http://pyxmpp.jajcus.net/api/pyxmpp.jabber.client.JabberClient-class.html#__init__
[17]: http://www.stillhq.com/google/gtalk/
[18]: http://pyxmpp.jajcus.net/api/pyxmpp.jabber.client.JabberClient-class.html
[19]: http://pyxmpp.jajcus.net/api/pyxmpp.streambase-pysrc.html#StreamBase.stream_start
[20]: http://pyxmpp.jajcus.net/api/pyxmpp.client-pysrc.html#Client.loop
[21]: http://pidgin.im/
[22]: http://psi-im.org/
[23]: http://www.miranda-im.org/
