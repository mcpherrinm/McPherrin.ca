---
layout: post
title: Web PKI Revocation is Broken (but we can fix it!)
---

The web public key infrastructure is used to secure HTTPS connections between
browsers and websites using certificates. Today, when something goes wrong,
browsers can't reliably find out those certificates have been revoked. We
examine past and future solutions to this problem, and how we can make progress
on fixing revocation.

This talk covers the history of the protocols used to communicate web PKI
revocation, including CRLs and OCSP, discusses why they have been ineffective.
Then goes over future improvements that are ongoing now to make certificate
lifetimes shorter, revive CRLs with new distribution and compression
mechanisms. It discusses why new solutions might work where previous attempts
like OCSP stapling failed.

The talk was given at the Cryptography and Privacy Village at DEFCON31, and
then at BSides Toronto 2023.

The BSides recording is available
[on youtube](https://www.youtube.com/watch?v=4TbtL73ibh0).
and embedded below.

<iframe width="560" height="315" frameborder="0"
  src="https://www.youtube-nocookie.com/embed/4TbtL73ibh0?si=cK-jDxTn3zj7Jqsl"
  title="YouTube video player"
  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
  allowfullscreen>
</iframe>
