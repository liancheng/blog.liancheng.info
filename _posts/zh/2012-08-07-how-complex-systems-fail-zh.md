---
layout: post
title: '译：复杂系统故障面面观'
category: translation
tags: complex-systems catastrophic-failure
published: false
---

<div class="title-icon"><img src="{{ site.attachment_dir }}2012-08-07-cloud.jpg" alt="Cloud Computing" width="200" height="160" /></div>

## 题记

两个月前，Amazon EC2集群因雷暴天气导致电源故障进而宕机，拖垮了包括Netflix、Instagram、Pinterest在内的一大批服务。几天后，在Channel 9上看到[Tim O'Brien针对这次事故所写的一篇文章][1]，进而顺藤摸瓜找到了Richard Cook的这篇[How Complex Systems Fail][2]。这篇短文既没有抽象的模型，也没有艰涩的公式，然而寥寥十八条直观的经验性总结都可谓鞭辟入里、入木三分，令人击节叫好。有意思的是，Cook在文中讨论的是医疗IT系统，跟大规模互联网基础服务并没有太大关系，正所谓大道归一。文章并没有局限在技术领域，而是从复杂系统、事故当事人、事故评估等一系列角度全方位地讨论了复杂系统的故障性质，很好地论述了复杂系统故障中的“潜规则”。

[1]: http://channel9.msdn.com/Blogs/Vector/How-Complex-Systems-Fail
[2]: http://www.ctlab.org/documents/How%20Complex%20Systems%20Fail.pdf

<!-- start -->

- - -

<center>
  <h2>复杂系统故障面面观</h2>
  <p>（一篇讨论故障性质的短文；如何评估故障；如何推测故障肇因；以及由此引出的针对病患安全的新认识）</p>
  <p>Richard I. Cook, MD<br/>芝加哥大学认知技术实验室</p>
</center>

1.  **复杂系统本质上都是高风险系统。**

    高风险性是各种备受瞩目的复杂系统（如交通系统、医疗系统、电力系统等）所固有的内在属性。尽管事故发生的频率时有波动，但导致系统固有高风险性的内因却无从化解。这些风险又催生了各式各样的风险防范措施，从而塑造了形形色色的复杂系统。

2.  **复杂系统都对故障严加防范且行之有效。**

    故障造成的高昂代价促使人们逐渐构筑起重重防范措施来抵御故障。其中既包括必要的技术措施（如后备系统、设备的各种“安全”功能等）和人力措施（如培训、经验传承等），也包括多种机构性措施、制度性措施和监管性措施（如政策流程、资格认证、工作守则、团队培训等）。这些手段构成了一系列防护，令日常运维得以远离意外事故。

3.  **灾难性事故是多起故障相互作用的结果——单点故障不足以兴风作浪……**

    多重防范的确行之有效，一般情况下足以保障系统正常运作。重大灾难性事故往往是由多起无足轻重的轻微故障共同导致的系统性的意外事故。这些轻微故障中的每一起都是事故的诱因，但只有当它们组合叠加起来时，才会酿成事故。换句话说，故障的发生概率比重大系统事故的发生概率要高得多。大部分故障一开始就被系统内预设的安全组件排除了。即便部分故障能突破到业务层面，其中绝大部分也会被业务人员排除掉。

4.  **复杂系统中潜伏着变化多端的故障组合。**

    由于过于复杂，这些系统在运作时总是伴随着多种缺陷。单独拎出来看的话，这些缺陷并不会导致故障，因此它们都被判定为业务中无足轻重的因素。要想彻底清除潜在的故障，经济成本往往太过高昂。此外，除非真的发生事故，否则我们很难看出这些故障如何会诱发事故。技术和工作机构的演变，加上人们为了排除故障而付出的种种努力，使得故障也不断地发生变化。

5.  **复杂系统运作时总是处于降级模式。**

    由上一条可知，运作中的复杂系统总是残缺不全的。系统之所以还能继续工作，是因为系统内包含充足的冗余部件，即便存在诸多缺陷，人们也有办法让它工作。从历次事故评估结果来看，系统此前几乎都出现过险些酿成灾难的“proto-accident”。有观点认为，在重大事故发生之前，应该能够通过观察系统表现的简单变化来辨别降级运行情况。系统的运作过程是动态的，各种（机构、人员、技术）部件会不断出现故障并被更替。

6.  **灾难总是近在咫尺。**

    复杂系统蕴含着诱发灾难性故障的可能。无论什么时间、什么地点，从业人员都免不了要与各种潜在故障比肩同行。复杂系统都有可能诱发灾难性的后果，这是它们的标志性特征。人们不可能完全排除发生这类灾难性故障的可能性；这类故障随时都有可能发生，这是由系统自身的性质决定的。

7.  **在事后将事故归咎于某项“罪魁祸首”的做法是完全错误的。**

    由于重大故障皆由多重失误共同造成，事故没有孤立的“肇因”。在导致事故的多种因素之中，任何单一因素都不足以酿成事故。只有当这些因素叠加在一起时事故才得以发生。事实上，正是这些环环相扣的因素共同形成了滋生事故的温床。因此，事故背后根本就不存在孤立的“罪魁祸首”。在事故评估中将事故原因归咎于某项“罪魁祸首”，无助于从技术角度探求故障的性质；对部分特定势力及事件的责难不过是为了对社会及文化诉求的一种迎合。[^1]

8.  **事后成见会扭曲事故评定人员的认知。**

    在已知事故后果的情况下，人们会产生一种错觉，认为对于当事人来说酿成事故的各种事件应该要比实际情况来得更加显眼。这意味着人们难以客观地分析事故经过。了解事故后果的事故分析人员容易先入为主，从而难以站在当事人的视角上在相同条件下还原事故经过。当事人似乎“早就应该知道”这些因素“必然”会导致事故[^2]。事后成见一直是阻碍事故调查的主要障碍，有专家参与时尤其如此。

9.  **运营人员分饰二角：既是故障的始作俑者，也是故障的抵御者。**

    系统内的从业人员在系统的运营过程中一边经营既定业务，一边防范事故的发生。系统运转过程中的这种动态特质，业务需求与故障滋生风险之间的矛盾是不可避免的。外界很少有人认识到这一角色的二重性。系统正常运转期间，经营角色唱主角。事故发生之后，故障防范角色唱主角。实际上，系统运营人员一直长期且持续地分饰二角，这一点往往为外界所误解。

10. **当事从业人员的举措完全是在冒险。**

    事故发生之后，人们往往会认为事故中的重大故障在所难免，而事故之所以会发生，是因为当事从业人员在故障迫近时处理失当或玩忽职守。实际上当事人采取行动时完全是在冒险，他们并不确定自己的举措会导致什么结果。在不同情况下，这种不确定性在程度上时有不同。当事人的冒险举措在事故发生之后体现得尤为明显；这些举措在灾后分析中通常会被认为是不明智的。然而反过来看：即便处理得当，也不过是运气好；无论如何，他们的举措都无法被广泛接受。

11. **风口浪尖上的举措方能化解一切模糊性。**

    各种机构都具有一定的模糊性，这种模糊性经常是蓄意造成的，它体现在经营目标、资源使用效率、运营成本、能够容忍多严重的潜在事故等多个方面。只有那些位于系统中风口浪尖位置上的从业人员的行动才能化解这些模糊性。发生事故之后，当事从业人员的行为往往会被判作“疏忽”或“违例”，但这类评判又带有严重的事后成见，往往无视业绩压力等其他诱因。

12. **从业人员是复杂系统中的适配元素。**

    Practitioners and first line management actively adapt the system to maximize production and minimize accidents.  These adaptations often occur on a moment by moment basis.  Some of these adaptations include: (1) Restructuring the system in order to reduce exposure of vulnerable parts to failure.  (2) Concentrating critical resources in areas of expected high demand.  (3) Providing pathways for retreat or recovery from expected and unexpected faults.  (4) Establishing means for early detection of changed system performance in order to allow graceful cutbacks in production or other means of increasing resiliency.

    从业人员及一线管理层积极适应系统，以最大化生产效率，并最小化事故。

13. **复杂系统中的专业人才不断地发生变化。**

    复杂系统的运营和管理需要大量专业人才。  This expertise changes in character as technology changes but it also changes because of the need to replace experts who leave in every case, training and refinement of skill and expertise is one part of the function of the system itself.  At any moment, therefore, a given complex system will contain practitioners and trainees with varing degrees of expertise.  Critical issues related to expertise arise from (1) the need to use scarse expertise as a resource for the most difficult or demanding production needs and (2) the need to develop expertise for future use.

14. **变化会引入新的故障。**

    The low rate of overt accidents in reliable systems may encourage changes, especially the use of new technology, to decrease the number of low consequence but high frequency failures.  These changes maybe actually create opportunities for new, low frequency but high consequence failures.  When new technologies are used to eliminate well understood system failures or to gain high precision performance they often introduce new pathways to large scale, catastrophic failures.  Not uncommonly, these new, rare catastrophes have even greater impact than those eliminated by the new technology.  These new forms of failure are difficult to see before the fact; attention is paid mostly to the putative beneficial characteristics of the changes.  Because these new, high consequence accidents occur at a low rate, multiple system changes may occur before an accident, making it hard to see the contribution of technology to the failure.

15. **Views of 'cause' limit the effectiveness of defenses against future events.**

    Post-accident remedies for "human error" are usually predicated on obstructing activities that can "cause" accidents.  These end-of-the-chain measures do little to reduce the likelihood of further accidents. In fact that likelihood of an identical accident is already extraordinarily low because the pattern of latent failures changes constantly. Instead of increasing safety, post-accident remedies usually increase the coupling and complexity of the system. This increases the potential number of latent failures and also makes the detection and blocking of accident trajectories more difficult.

16. **安全是整个系统的特性，而不是系统中各个部件的特性。**

    Safety is an emergent property of systems; it does not reside in a person, device or department of an organization or system. Safety cannot be purchased or manufactured; it is not a feature that is separate from the other components of the system. This means that safety cannot be manipulated like a feedstock or raw material. The state of safety in any system is always dynamic; continuous systemic change insures that hazard and its management are constantly changing.

17. **People continuously create safety.**

    Failure free operations are the result of activities of people who work to keep the system within the boundaries of tolerable performance. These activities are, for the most part, part of normal operations and superficially straightforward. But because system operations are never trouble free, human practitioner adaptations to changing conditions actually create safety from moment to moment. These adaptations often amount to just the selection of a well-rehearsed routine from a store of available responses; sometimes, however, the adaptations are novel combinations or de novo creations of new approaches.

18. **无故障运营需要故障处理相关的经验。**

    Recognizing hazard and successfully manipulating system operations to remain inside the tolerable performance boundaries requires intimate contact with failure. More robust system performance is likely to arise in systems where operators can discern the “edge of the envelope”. This is where system performance begins to deteriorate, becomes difficult to predict, or cannot be readily recovered. In intrinsically hazardous systems, operators are expected to encounter and appreciate hazards in ways that lead to overall performance that is desirable. Improved safety depends on providing operators with calibrated views of the hazards. It also depends on providing calibration about how their actions move system performance towards or away from the edge of the envelope.

[^1]: 脚注    
[^2]: 脚注    

<!-- end -->

{% comment %}
vim:ft=markdown.liquid wrap
{% endcomment %}
