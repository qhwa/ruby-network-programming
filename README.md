# Examples of Ruby network programming

## useful commands

This command indicates connections bind to your interested port.  Replace `PORT` with a real port number such as `23333`.

~~~sh
watch -n 0 'netstat -nta | grep PORT'
~~~
