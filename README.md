What?
=====

A JSON backend for Hiera

Configuration?
==============

A sample Hiera config file that activates this backend and stores
data in _/etc/puppet/hieradata_ can be seen below:

<pre>
---
:backends: json
:hierarchy: %{location}
            common
:json:
   :datadir: /etc/puppet/hieradata
</pre>

Constact?
=========

R.I.Pienaar / rip@devco.net / @ripienaar / www.devco.net
