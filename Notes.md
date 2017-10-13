A small note about RubyGems + FastRI
====================================
RubyGems adds a noticeable overhead to fri, making it run slower than if you
installed it directly from the tarball with setup.rb.

Compare the execution time when installed with RubyGems:
  $ time fri -f plain String > /dev/null

  real  0m0.385s
  user  0m0.244s
  sys   0m0.036s

to the time fri actually takes to run, without the overhead introduced by
RubyGems:
  $ time ruby bin/fri -f plain String > /dev/null

  real  0m0.088s
  user  0m0.040s
  sys   0m0.008s

If you care about those extra 300ms (and there are situations where they will
matter, e.g. when using fri for method completion), get FastRI from the
tarballs.
