esyslog: Simple interface to syslog
===================================

Sample configuration
--------------------

<pre>
[
    {esyslog, [
        {server, {127, 0, 0, 1}},
        {port, 514}
    ]}
]}.
</pre>

Sample syslog-ng configuration
------------------------------

<pre>
destination d\_mylog {
    file("/var/log/my.log");
};

source s\_net {
    udp();
};

log {
    source(s\_net);
    destination(d\_mylog);
};
</pre>

LICENSE
-------

Some code was taken from https://github.com/lemenkov/erlsyslog
