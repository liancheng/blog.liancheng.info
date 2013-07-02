---
layout: post
title: Functional Programming Languages and Stack Overflow
category: dev-notes
tags: scala scheme erlang functional-programming algorithm
language: en
published: false
---

A few days ago, I finished my `Functional Programming Principles in Scala`__ (a.k.a. ProgFun) course on Coursera, lectured by the father of Scala, Martin Odisky.  Although I'm not a big fan of neither Java nor JVM, I appreciate Scala a lot.  New languages built upon JVM are easier to be accepted by the community.  Obviously, it's a very practical way to promote a new language by building it above an existing, robust VM like JVM and Erlang's BEAM.  However, that also means the new language also suffers all the limitations brought by the VM.  For example, stack overflow.

When attacking one of the programming assignments of ProgFun, I got a ``java.lang.StackOverflowError``.  The original problem is a little complicated, so I wrote a simple naive factorial function to illustrate:

.. class:: more

----

.. code-block:: scala

    object StackOverflow extends App {
      def naiveFactorial(n: Int): Int =
        if (n == 0)
          1
        else
          n * naiveFactorial(n - 1)

      println(naiveFactorial(10000))
    }

Run this program, and you'll get a long long messy garbage spit by JVM:

::

    [error] (run-main) java.lang.StackOverflowError
    java.lang.StackOverflowError
            at StackOverflow$.naiveFactorial(overflow.scala:3)
            at StackOverflow$.naiveFactorial(overflow.scala:6)
            at StackOverflow$.naiveFactorial(overflow.scala:6)
            ...

As an experienced C/C++/Java programmer, you may say: of course, the stack space is limited.

.. code-block:: scheme

    #lang racket

    (define (naive-factorial n)
      (if (zero? n)
        0
        (* n (naive-factorial (- n 1)))))

    (write (naive-factorial 10000))

.. code-block:: erlang

    #/usr/bin/env escript

    naive_factorial(0) ->
        1;
    naive_factorial(N) ->
        N * naive_factorial(N - 1).

    main(_) ->
        io:format("~w~n", naive_factorial(10000)).

__ https://class.coursera.org/progfun-002/class/index
