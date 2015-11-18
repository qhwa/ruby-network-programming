# Examples of Ruby network programming

Example codes of Ruby's TCP related network programming, including:

1. basic classical style (bind-listen-accept-read-write-close) TCP server
2. basic TCP server with ruby's style
3. interactive TCP server
4. multiplexing a TCP server with either `Thread` or `Process`
5. basic TCP server with [EventMachine](https://github.com/eventmachine/eventmachine)
5. two versions of SOCKS5 server with [EventMachine](https://github.com/eventmachine/eventmachine)
5. adding your own logics to the SOCKS5 server 

[related slide](https://speakerdeck.com/qhwa/tcp-socket-network-programming-in-ruby)

## useful commands

This command indicates connections bind to your interested port.  Replace `PORT` with a real port number such as `23333`.

~~~sh
watch -n 0 'netstat -nta | grep PORT'
~~~
