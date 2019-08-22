h4. Bees with Machine Guns!

A utility for arming (creating) many bees (micro EC2 instances) to attack (load test) targets (web applications).

Also, retribution for "this shameful act":http://kottke.org/10/10/tiny-catapult-for-throwing-pies-at-bees against a proud hive.

h2. Dependencies

* Python 2.6 - 3.6
* boto
* paramiko

h2. Installation for users

<pre>
pip install https://github.com/newsapps/beeswithmachineguns/archive/master.zip
</pre>

h2. Installation for developers (w/ virtualenv + virtualenvwrapper)

<pre>
git clone git://github.com/newsapps/beeswithmachineguns.git
cd beeswithmachineguns
mkvirtualenv --no-site-packages beesenv
easy_install pip
pip install -r requirements.txt
</pre>

h2. Configuring AWS credentials

Bees uses boto to communicate with EC2 and thus supports all the same methods of storing credentials that it does.  These include declaring environment variables, machine-global configuration files, and per-user configuration files. You can read more about these options on "boto's configuration page":http://code.google.com/p/boto/wiki/BotoConfig.

At minimum, create a .boto file in your home directory with the following contents:

<pre>
[Credentials]
aws_access_key_id = <your access key>
aws_secret_access_key = <your secret key>
</pre>

The credentials used must have sufficient access to EC2.

Make sure the .boto file is only accessible by the current account:

<pre>
chmod 600 .boto
</pre>

h2. Usage

A typical bees session looks something like this:

<pre>
bees up -s 4 -g public -k frakkingtoasters
bees attack -n 10000 -c 250 -u http://www.ournewwebbyhotness.com/
bees down
</pre>

A bees session where this is being called from a python file, while specifying content type and a payload file.
This is a working example, all of these objects exist in the us-east-1 region.

<pre>
import bees
import json

sOptions = '{"post_file":"data.json","contenttype":"application/json"}'
options = json.loads(sOptions)

bees.up(1,'bees-sg','us-east-1b','ami-5d155d37','m3.medium','ubuntu','commerce-bees','subnet-b12880e8')
bees.attack('<URL TO TEST>',2,2,**options)
bees.down()
</pre>

In this case the data.json is a simple json file, mind the path.

This spins up 4 servers in security group 'public' using the EC2 keypair 'frakkingtoasters', whose private key is expected to reside at ~/.ssh/frakkingtoasters.pem.

*Note*: the default EC2 security group is called 'default' and by default it locks out SSH access. I recommend creating a 'public' security group for use with the bees and explicitly opening port 22 on that group.

It then uses those 4 servers to send 10,000 requests, 250 at a time, to attack OurNewWebbyHotness.com.

Lastly, it spins down the 4 servers.  *Please remember to do this*--we aren't responsible for your EC2 bills.

If you wanted 3 agents requesting url A and one requesting url B, your attack would look as follows (empty url -> use previous):

<pre>
bees attack -n 10000 -c 250 -u 'http://url.a,,,http://url.b'
</pre>

For complete options type:

<pre>
bees -h
</pre>

h2. Introduction to additions:

h4. Additions contributed Hurl integration and multi regional testing.


  *hurl* is an http server load tester similar to ab/siege/weighttp/wrk with support for multithreading, parallelism, ssl, url ranges, and an api-server for querying the running performance statistics.  *hurl* is primarily useful for benchmarking http server applications.
For more information about *hurl* please visit https://github.com/VerizonDigital/hlx

  Multi regional testing was added so user can call up multiple bees from different regions simultaneously. Users have the ability to “up”, “attack”, and  “down” instances from single command. “regions.json” file is supplied which contains public ami images with hurl pre installed for all regions.


*What kind of changes were made that's different from the old?*
  Instead of writing bees information into a single ~/.bees file, each zone recognized in arguments creates a new unique bees file. Bees.py was modified to read these files. Up, attack, and down functions are run with threads.

example .bees files in user home directory

<pre>
$ ls ~/.bees* | xargs -0 basename
.bees.ap-southeast-1b
.bees.eu-west-1b
.bees.us-west-2b
</pre>


h4. Motivation

Having the ability to generate a lot of HTTPS requests from many different regions around the world allows us to better test our platforms and services. This is also real helpful when there are tools that need to be tested for such things as location of requests.


h4. Hurl Usage


h4. bees up

  Command line arguments are still the same however to add multiple zones with multiple amis, the values must be comma delimited. The ami and zones must also be in same order for it to work. So for example “-i ami-zone1,ami-zone2,ami-zone3 -z zone1,zone2,zone3”.


<pre>
  ./bees up -s 2 -k bees -g bees2 -l ubuntu -i ami-9342c0e0,ami-fd489d
9e,ami-e8c93e88 -z eu-west-1b,ap-southeast-1b,us-west-2b
</pre>

h4. bees attack

  In order to use the hurl platform, --hurl or -j must be supplied. Attacks will run concurrently and return a summarized output. The output is summarized per region. More information can be seen if user supplies the -o, --long_output options.

<pre>
./bees attack --hurl -u $testurl -S20 -M1000 -H "Accept : text/html"
</pre>

h4. bees down

  Bringing down bees is the same and will bring down all bees for all regions

<pre>
./bees down
</pre>


*regions used*: eu-west-1b,ap-southeast-1b,us-west-2b

Some options were added to work with hurl

h4. Examples

<pre>
$ ./bees --help
Usage: 
bees COMMAND [options]

Bees with Machine Guns

A utility for arming (creating) many bees (small EC2 instances) to attack
(load test) targets (web applications).

commands:
  up      Start a batch of load testing servers.
  attack  Begin the attack on a specific url.
  down    Shutdown and deactivate the load testing servers.
  report  Report the status of the load testing servers.
    

Options:
  -h, --help            show this help message and exit

  up:
    In order to spin up new servers you will need to specify at least the
    -k command, which is the name of the EC2 keypair to use for creating
    and connecting to the new servers. The bees will expect to find a .pem
    file with this name in ~/.ssh/. Alternatively, bees can use SSH Agent
    for the key.

    -k KEY, --key=KEY   The ssh key pair name to use to connect to the new
                        servers.
    -s SERVERS, --servers=SERVERS
                        The number of servers to start (default: 5).
    -g GROUP, --group=GROUP
                        The security group(s) to run the instances under
                        (default: default).
    -z ZONE, --zone=ZONE
                        The availability zone to start the instances in
                        (default: us-east-1d).
    -i INSTANCE, --instance=INSTANCE
                        The instance-id to use for each server from (default:
                        ami-ff17fb96).
    -t TYPE, --type=TYPE
                        The instance-type to use for each server (default:
                        t1.micro).
    -l LOGIN, --login=LOGIN
                        The ssh username name to use to connect to the new
                        servers (default: newsapps).
    -v SUBNET, --subnet=SUBNET
                        The vpc subnet id in which the instances should be
                        launched. (default: None).
    -b BID, --bid=BID   The maximum bid price per spot instance (default:
                        None).

  attack:
    Beginning an attack requires only that you specify the -u option with
    the URL you wish to target.

    -u URL, --url=URL   URL of the target to attack.
    -K KEEP_ALIVE, --keepalive=KEEP_ALIVE
                        Keep-Alive connection.
    -p POST_FILE, --post-file=POST_FILE
                        The POST file to deliver with the bee's payload.
    -m MIME_TYPE, --mime-type=MIME_TYPE
                        The MIME type to send with the request.
    -n NUMBER, --number=NUMBER
                        The number of total connections to make to the target
                        (default: 1000).
    -C COOKIES, --cookies=COOKIES
                        Cookies to send during http requests. The cookies
                        should be passed using standard cookie formatting,
                        separated by semi-colons and assigned with equals
                        signs.
    -Z CIPHERS, --ciphers=CIPHERS
                        Openssl SSL/TLS cipher name(s) to use for negotiation.  Passed
                        directly to ab's -Z option.  ab-only.
    -c CONCURRENT, --concurrent=CONCURRENT
                        The number of concurrent connections to make to the
                        target (default: 100).
    -H HEADERS, --headers=HEADERS
                        HTTP headers to send to the target to attack. Multiple
                        headers should be separated by semi-colons, e.g
                        header1:value1;header2:value2
    -e FILENAME, --csv=FILENAME
                        Store the distribution of results in a csv file for
                        all completed bees (default: '').
    -P CONTENTTYPE, --contenttype=CONTENTTYPE
                        ContentType header to send to the target of the
                        attack.
    -S SECONDS, --seconds=SECONDS
                        hurl only: The number of total seconds to attack the
                        target (default: 60).
    -X VERB, --verb=VERB
                        hurl only: Request command -HTTP verb to use
                        -GET/PUT/etc. Default GET
    -M RATE, --rate=RATE
                        hurl only: Max Request Rate.
    -a THREADS, --threads=THREADS
                        hurl only: Number of parallel threads. Default: 1
    -f FETCHES, --fetches=FETCHES
                        hurl only: Num fetches per instance.
    -d TIMEOUT, --timeout=TIMEOUT
                        hurl only: Timeout (seconds).
    -E SEND_BUFFER, --send_buffer=SEND_BUFFER
                        hurl only: Socket send buffer size.
    -F RECV_BUFFER, --recv_buffer=RECV_BUFFER
                        hurl only: Socket receive buffer size.
    -T TPR, --tpr=TPR   The upper bounds for time per request. If this option
                        is passed and the target is below the value a 1 will
                        be returned with the report details (default: None).
    -R RPS, --rps=RPS   The lower bounds for request per second. If this
                        option is passed and the target is above the value a 1
                        will be returned with the report details (default:
                        None).
    -A basic_auth, --basic_auth=basic_auth
                        BASIC authentication credentials, format auth-
                        username:password (default: None).
    -j, --hurl          use hurl
    -o, --long_output   display hurl output
    -L, --responses_per
                        hurl only: Display http(s) response codes per interval
                        instead of request statistics
</pre>

A bringing up bees example

<pre>
$ ./bees up -s 2 -k bees -g bees2 -l ubuntu -i ami-9342c0e0,ami-fd489d
9e,ami-e8c93e88 -z eu-west-1b,ap-southeast-1b,us-west-2b
Connecting to the hive.
GroupId found: bees2
Placement: eu-west-1b
Attempting to call up 2 bees.
Connecting to the hive.
GroupId found: bees2
Placement: ap-southeast-1b
Attempting to call up 2 bees.
Connecting to the hive.
GroupId found: bees2
Placement: us-west-2b
Attempting to call up 2 bees.
Waiting for bees to load their machine guns...
Waiting for bees to load their machine guns...
.
Waiting for bees to load their machine guns...
.
.
.
.
.
.
.
.
.
.
.
.
Bee i-5568c1d9 is ready for the attack.
Bee i-5668c1da is ready for the attack.
Bee i-2cf8aba2 is ready for the attack.
The swarm has assembled 2 bees.
Bee i-2bf8aba5 is ready for the attack.
The swarm has assembled 2 bees.
Bee i-d05a6c08 is ready for the attack.
Bee i-d15a6c09 is ready for the attack.
The swarm has assembled 2 bees.

$ ./bees report
Read 2 bees from the roster: eu-west-1b
Bee i-5568c1d9: running @ 54.194.192.20
Bee i-5668c1da: running @ 54.194.197.233
Read 2 bees from the roster: ap-southeast-1b
Bee i-2cf8aba2: running @ 52.77.228.132
Bee i-2bf8aba5: running @ 52.221.250.224
Read 2 bees from the roster: us-west-2b
Bee i-d05a6c08: running @ 54.187.100.142
Bee i-d15a6c09: running @ 54.201.177.125
</pre>


A bees attack example

<pre>
$ ./bees attack --hurl -u $testurl -S20 -M1000 -H "Accept : text/html"
eu-west-1b
Read 2 bees from the roster: eu-west-1b
Connecting to the hive.
Assembling bees.
ap-southeast-1b
Read 2 bees from the roster: ap-southeast-1b
Connecting to the hive.
Assembling bees.
us-west-2b
Read 2 bees from the roster: us-west-2b
Connecting to the hive.
Assembling bees.
Each of 2 bees will fire 500 rounds, 50 at a time.
Stinging URL so it will be cached for the attack.
Organizing the swarm.
Bee 0 is joining the swarm.
Bee 1 is joining the swarm.
Each of 2 bees will fire 500 rounds, 50 at a time.
Stinging URL so it will be cached for the attack.
Organizing the swarm.
Bee 0 is joining the swarm.
Bee 1 is joining the swarm.
Bee 1 is firing her machine gun. Bang bang!
Bee 0 is firing her machine gun. Bang bang!
Each of 2 bees will fire 500 rounds, 50 at a time.
Stinging URL so it will be cached for the attack.
Organizing the swarm.
Bee 0 is joining the swarm.
Bee 1 is joining the swarm.
Bee 1 is firing her machine gun. Bang bang!
Bee 0 is firing her machine gun. Bang bang!
Bee 0 is firing her machine gun. Bang bang!
Bee 1 is firing her machine gun. Bang bang!
Offensive complete.

Summarized Results
     Total bytes:               32806393
     Seconds:                   20
     Connect-ms-max:            8.751000
     1st-resp-ms-max:           288.797000
     1st-resp-ms-mean:          41.120797
     Fetches/sec mean:          881.607553
     connect-ms-min:            0.000000
     Total fetches:             35274
     bytes/sec mean:            819934.329261
     end2end-ms-min mean:       7.538500
     mean-bytes-per-conn:       930.044494
     connect-ms-mean:           0.022659

Response Codes:
     2xx:                       372
     3xx:                       0
     4xx:                       34802
     5xx:                       0

Mission Assessment: Target crushed bee offensive.
The swarm is awaiting new orders.
Offensive complete.

Summarized Results
     Total bytes:               7820249
     Seconds:                   20
     Connect-ms-max:            198.442000
     1st-resp-ms-max:           799.969000
     1st-resp-ms-mean:          183.104679
     Fetches/sec mean:          265.758560
     connect-ms-min:            0.000000
     Total fetches:             10633
     bytes/sec mean:            195457.360660
     end2end-ms-min mean:       167.372500
     mean-bytes-per-conn:       735.470800
     connect-ms-mean:           1.685486

Response Codes:
     2xx:                       423
     3xx:                       0
     4xx:                       10110
     5xx:                       0

Mission Assessment: Target crushed bee offensive.
The swarm is awaiting new orders.
Offensive complete.

Summarized Results
     Total bytes:               26038521
     Seconds:                   20
     Connect-ms-max:            15.233000
     1st-resp-ms-max:           401.819000
     1st-resp-ms-mean:          42.217669
     Fetches/sec mean:          873.584785
     connect-ms-min:            0.000000
     Total fetches:             34953
     bytes/sec mean:            650784.075365
     end2end-ms-min mean:       11.345000
     mean-bytes-per-conn:       744.958106
     connect-ms-mean:           0.037327

Response Codes:
     2xx:                       411
     3xx:                       0
     4xx:                       34442
     5xx:                       0

Mission Assessment: Target crushed bee offensive.
The swarm is awaiting new orders.
</pre>

A bees attack example with --long_output

<pre>
$ ./bees attack --hurl -u $testurl -S20 -M1000 -H "Accept : text/html" --long_output
eu-west-1b
Read 2 bees from the roster: eu-west-1b
Connecting to the hive.
Assembling bees.
ap-southeast-1b
Read 2 bees from the roster: ap-southeast-1b
Connecting to the hive.
Assembling bees.
us-west-2b
Read 2 bees from the roster: us-west-2b
Connecting to the hive.
Assembling bees.
Each of 2 bees will fire 500 rounds, 50 at a time.
Stinging URL so it will be cached for the attack.
Organizing the swarm.
Bee 0 is joining the swarm.
Bee 1 is joining the swarm.
Each of 2 bees will fire 500 rounds, 50 at a time.
Stinging URL so it will be cached for the attack.
Organizing the swarm.
Bee 0 is joining the swarm.
Bee 1 is joining the swarm.
Each of 2 bees will fire 500 rounds, 50 at a time.
Stinging URL so it will be cached for the attack.
Organizing the swarm.
Bee 0 is joining the swarm.
Bee 1 is joining the swarm.
Bee 0 is firing her machine gun. Bang bang!
Bee 1 is firing her machine gun. Bang bang!
Bee 1 is firing her machine gun. Bang bang!
Bee 0 is firing her machine gun. Bang bang!
Bee 0 is firing her machine gun. Bang bang!
Bee 1 is firing her machine gun. Bang bang!
hurl http://can.192bf.transactcdn.com/00192BF/test.html/config.workflow:ContinueWarranty -p 50  -H "Accept : text/html" -H "Content-Type : text/plain" -o /tmp/tmp.aAojMFs3ob -l 20 -A 1000 -j

i-fb457323
ec2-54-186-204-52.us-west-2.compute.amazonaws.com
Running 1 threads 50 parallel connections per thread with 1 reqests per connection
+-----------/-----------+-----------+-----------+--------------+-----------+-------------+-----------+
|    Cmpltd /     Total |    IdlKil |    Errors | kBytes Recvd |   Elapsed |       Req/s |      MB/s |
+-----------/-----------+-----------+-----------+--------------+-----------+-------------+-----------+
|         0 /         0 |         0 |         0 |         0.00 |     0.50s |       0.00s |     0.00s |
|       505 /       505 |         0 |         0 |       313.02 |     1.00s |    1007.98s |     0.61s |
|       970 /       970 |         0 |         0 |       633.81 |     1.50s |     930.00s |     0.63s |
|      1442 /      1442 |         0 |         0 |       961.08 |     2.00s |     944.00s |     0.64s |
|      1900 /      1900 |         0 |         0 |      1276.81 |     2.50s |     916.00s |     0.62s |
|      2376 /      2376 |         0 |         0 |      1606.85 |     3.00s |     952.00s |     0.64s |
|      2835 /      2835 |         0 |         0 |      1922.85 |     3.50s |     918.00s |     0.62s |
|      3310 /      3310 |         0 |         0 |      2252.20 |     4.00s |     950.00s |     0.64s |
|      3769 /      3769 |         0 |         0 |      2568.62 |     4.50s |     918.00s |     0.62s |
|      4243 /      4243 |         0 |         0 |      2897.27 |     5.00s |     946.11s |     0.64s |
|      4706 /      4706 |         0 |         0 |      3215.84 |     5.50s |     926.00s |     0.62s |
|      5178 /      5178 |         0 |         0 |      3543.10 |     6.00s |     944.00s |     0.64s |
|      5641 /      5641 |         0 |         0 |      3862.09 |     6.50s |     926.00s |     0.62s |
|      6114 /      6114 |         0 |         0 |      4190.05 |     7.00s |     946.00s |     0.64s |
|      6581 /      6581 |         0 |         0 |      4511.81 |     7.50s |     934.00s |     0.63s |
|      7053 /      7053 |         0 |         0 |      4839.07 |     8.00s |     944.00s |     0.64s |
|      7514 /      7514 |         0 |         0 |      5156.25 |     8.50s |     922.00s |     0.62s |
|      7975 /      7975 |         0 |         0 |      5475.88 |     9.00s |     920.16s |     0.62s |
|      8450 /      8450 |         0 |         0 |      5803.62 |     9.50s |     950.00s |     0.64s |
|      8910 /      8910 |         0 |         0 |      6122.53 |    10.00s |     920.00s |     0.62s |
|      9382 /      9382 |         0 |         0 |      6447.58 |    10.50s |     944.00s |     0.63s |
|      9844 /      9844 |         0 |         0 |      6766.37 |    11.00s |     924.00s |     0.62s |
|     10316 /     10316 |         0 |         0 |      7093.14 |    11.50s |     944.00s |     0.64s |
|     10778 /     10778 |         0 |         0 |      7411.51 |    12.00s |     924.00s |     0.62s |
|     11250 /     11250 |         0 |         0 |      7738.70 |    12.50s |     944.00s |     0.64s |
|     11710 /     11710 |         0 |         0 |      8056.08 |    13.00s |     920.00s |     0.62s |
|     12184 /     12184 |         0 |         0 |      8384.46 |    13.50s |     946.11s |     0.64s |
|     12644 /     12644 |         0 |         0 |      8701.20 |    14.00s |     920.00s |     0.62s |
|     13119 /     13119 |         0 |         0 |      9030.51 |    14.50s |     950.00s |     0.64s |
|     13582 /     13582 |         0 |         0 |      9349.72 |    15.00s |     926.00s |     0.62s |
|     14053 /     14053 |         0 |         0 |      9676.28 |    15.50s |     942.00s |     0.64s |
|     14516 /     14516 |         0 |         0 |      9994.85 |    16.00s |     926.00s |     0.62s |
|     14987 /     14987 |         0 |         0 |     10321.41 |    16.50s |     942.00s |     0.64s |
|     15450 /     15450 |         0 |         0 |     10640.41 |    17.00s |     926.00s |     0.62s |
|     15922 /     15922 |         0 |         0 |     10967.66 |    17.50s |     944.00s |     0.64s |
|     16386 /     16386 |         0 |         0 |     11287.13 |    18.00s |     926.15s |     0.62s |
|     16386 /     16386 |         0 |         0 |     11287.13 |    18.50s |       0.00s |     0.00s |
|     16855 /     16855 |         0 |         0 |     11612.32 |    19.00s |     938.00s |     0.64s |
|     17320 /     17320 |         0 |         0 |     11932.69 |    19.50s |     930.00s |     0.63s |
|     17794 /     17794 |         0 |         0 |     12261.34 |    20.00s |     948.00s |     0.64s |

Bee: i-fb457323
max-parallel:           50
1st-resp-ms-min:        10.036
response-codes
        200:            184
        403:            17560
seconds:                20.006
connect-ms-max:         8.729
1st-resp-ms-max:        130.893
bytes:                  16541472.0
1st-resp-ms-mean:       40.5336982642
end2end-ms-mean:        40.5487644838
fetches-per-sec:        889.433170049
connect-ms-min:         0.0
fetches:                17794
bytes-per-sec:          826825.552334
end2end-ms-min:         10.053
end2end-ms-max:         130.907
mean-bytes-per-conn:    929.609531303
connect-ms-mean:        0.0224927299369


hurl http://can.192bf.transactcdn.com/00192BF/test.html/config.workflow:ContinueWarranty -p 50  -H "Accept : text/html" -H "Content-Type : text/plain" -o /tmp/tmp.PkGEethemi -l 20 -A 1000 -j

i-fa457322
ec2-54-186-127-166.us-west-2.compute.amazonaws.com
Running 1 threads 50 parallel connections per thread with 1 reqests per connection
+-----------/-----------+-----------+-----------+--------------+-----------+-------------+-----------+
|    Cmpltd /     Total |    IdlKil |    Errors | kBytes Recvd |   Elapsed |       Req/s |      MB/s |
+-----------/-----------+-----------+-----------+--------------+-----------+-------------+-----------+
|         0 /         0 |         0 |         0 |         0.00 |     0.50s |       0.00s |     0.00s |
|       499 /       499 |         0 |         0 |       309.51 |     1.00s |     998.00s |     0.60s |
|       965 /       965 |         0 |         0 |       631.24 |     1.50s |     930.14s |     0.63s |
|      1435 /      1435 |         0 |         0 |       957.58 |     2.00s |     940.00s |     0.64s |
|      1900 /      1900 |         0 |         0 |      1279.25 |     2.50s |     930.00s |     0.63s |
|      2373 /      2373 |         0 |         0 |      1607.67 |     3.00s |     946.00s |     0.64s |
|      2834 /      2834 |         0 |         0 |      1925.72 |     3.50s |     922.00s |     0.62s |
|      3306 /      3306 |         0 |         0 |      2253.45 |     4.00s |     944.00s |     0.64s |
|      3781 /      3781 |         0 |         0 |      2581.00 |     4.50s |     950.00s |     0.64s |
|      4246 /      4246 |         0 |         0 |      2903.87 |     5.00s |     928.14s |     0.63s |
|      4701 /      4701 |         0 |         0 |      3217.97 |     5.50s |     910.00s |     0.61s |
|      5181 /      5181 |         0 |         0 |      3551.25 |     6.00s |     960.00s |     0.65s |
|      5666 /      5666 |         0 |         0 |      3885.54 |     6.50s |     970.00s |     0.65s |
|      6135 /      6135 |         0 |         0 |      4210.28 |     7.00s |     938.00s |     0.63s |
|      6605 /      6605 |         0 |         0 |      4535.90 |     7.50s |     940.00s |     0.64s |
|      7072 /      7072 |         0 |         0 |      4857.96 |     8.00s |     934.00s |     0.63s |
|      7553 /      7553 |         0 |         0 |      5191.88 |     8.50s |     962.00s |     0.65s |
|      8020 /      8020 |         0 |         0 |      5514.13 |     9.00s |     932.14s |     0.63s |
|      8497 /      8497 |         0 |         0 |      5845.30 |     9.50s |     954.00s |     0.65s |
|      8966 /      8966 |         0 |         0 |      6168.91 |    10.00s |     938.00s |     0.63s |
|      9437 /      9437 |         0 |         0 |      6495.93 |    10.50s |     942.00s |     0.64s |
|      9921 /      9921 |         0 |         0 |      6829.96 |    11.00s |     968.00s |     0.65s |
|     10389 /     10389 |         0 |         0 |      7154.90 |    11.50s |     936.00s |     0.63s |
|     10389 /     10389 |         0 |         0 |      7154.90 |    12.00s |       0.00s |     0.00s |
|     10857 /     10857 |         0 |         0 |      7477.18 |    12.50s |     936.00s |     0.63s |
|     11323 /     11323 |         0 |         0 |      7800.74 |    13.00s |     932.00s |     0.63s |
|     11790 /     11790 |         0 |         0 |      8124.22 |    13.50s |     932.14s |     0.63s |
|     12257 /     12257 |         0 |         0 |      8448.48 |    14.00s |     934.00s |     0.63s |
|     12718 /     12718 |         0 |         0 |      8765.89 |    14.50s |     922.00s |     0.62s |
|     13191 /     13191 |         0 |         0 |      9094.32 |    15.00s |     946.00s |     0.64s |
|     13670 /     13670 |         0 |         0 |      9424.86 |    15.50s |     958.00s |     0.65s |
|     14133 /     14133 |         0 |         0 |      9746.34 |    16.00s |     926.00s |     0.63s |
|     14603 /     14603 |         0 |         0 |     10070.01 |    16.50s |     940.00s |     0.63s |
|     15067 /     15067 |         0 |         0 |     10392.18 |    17.00s |     928.00s |     0.63s |
|     15532 /     15532 |         0 |         0 |     10712.58 |    17.50s |     928.14s |     0.62s |
|     16012 /     16012 |         0 |         0 |     11045.87 |    18.00s |     960.00s |     0.65s |
|     16487 /     16487 |         0 |         0 |     11372.79 |    18.50s |     950.00s |     0.64s |
|     16963 /     16963 |         0 |         0 |     11703.30 |    19.00s |     952.00s |     0.65s |
|     17451 /     17451 |         0 |         0 |     12040.73 |    19.50s |     976.00s |     0.66s |
|     17919 /     17919 |         0 |         0 |     12365.67 |    20.00s |     936.00s |     0.63s |

Bee: i-fa457322
max-parallel:           50
1st-resp-ms-min:        7.623
response-codes
        200:            183
        403:            17686
seconds:                20.006
connect-ms-max:         8.547
1st-resp-ms-max:        140.328
bytes:                  16676307.0
1st-resp-ms-mean:       39.7687282444
end2end-ms-mean:        39.7864872125
fetches-per-sec:        895.681295611
connect-ms-min:         0.0
fetches:                17919
bytes-per-sec:          833565.280416
end2end-ms-min:         7.636
end2end-ms-max:         140.342
mean-bytes-per-conn:    930.649422401
connect-ms-mean:        0.0225320387263


Offensive complete.

Summarized Results
     Total bytes:               33217779
     Seconds:                   20
     Connect-ms-max:            8.729000
     1st-resp-ms-max:           140.328000
     1st-resp-ms-mean:          40.151213
     Fetches/sec mean:          892.557233
     connect-ms-min:            0.000000
     Total fetches:             35713
     bytes/sec mean:            830195.416375
     end2end-ms-min mean:       8.844500
     mean-bytes-per-conn:       930.129477
     connect-ms-mean:           0.022512

Response Codes:
     2xx:                       367
     3xx:                       0
     4xx:                       35246
     5xx:                       0

Mission Assessment: Target crushed bee offensive.
The swarm is awaiting new orders.
hurl http://can.192bf.transactcdn.com/00192BF/test.html/config.workflow:ContinueWarranty -p 50  -H "Accept : text/html" -H "Content-Type : text/plain" -o /tmp/tmp.L7eQsLiKs9 -l 20 -A 1000 -j

i-9e6fc612
ec2-54-194-180-232.eu-west-1.compute.amazonaws.com
Running 1 threads 50 parallel connections per thread with 1 reqests per connection
+-----------/-----------+-----------+-----------+--------------+-----------+-------------+-----------+
|    Cmpltd /     Total |    IdlKil |    Errors | kBytes Recvd |   Elapsed |       Req/s |      MB/s |
+-----------/-----------+-----------+-----------+--------------+-----------+-------------+-----------+
|         0 /         0 |         0 |         0 |         0.00 |     0.50s |       0.00s |     0.00s |
|       484 /       484 |         0 |         0 |       220.82 |     1.00s |     968.00s |     0.43s |
|       957 /       957 |         0 |         0 |       463.33 |     1.50s |     944.11s |     0.47s |
|      1409 /      1409 |         0 |         0 |       692.96 |     2.00s |     904.00s |     0.45s |
|      1872 /      1872 |         0 |         0 |       930.33 |     2.50s |     926.00s |     0.46s |
|      2345 /      2345 |         0 |         0 |      1170.94 |     3.00s |     946.00s |     0.47s |
|      2803 /      2803 |         0 |         0 |      1405.75 |     3.50s |     916.00s |     0.46s |
|      3259 /      3259 |         0 |         0 |      1637.65 |     4.00s |     912.00s |     0.45s |
|      3729 /      3729 |         0 |         0 |      1878.61 |     4.50s |     940.00s |     0.47s |
|      4190 /      4190 |         0 |         0 |      2112.86 |     5.00s |     922.00s |     0.46s |
|      4645 /      4645 |         0 |         0 |      2346.13 |     5.50s |     908.18s |     0.45s |
|      5108 /      5108 |         0 |         0 |      2581.82 |     6.00s |     926.00s |     0.46s |
|      5566 /      5566 |         0 |         0 |      2816.64 |     6.50s |     916.00s |     0.46s |
|      6035 /      6035 |         0 |         0 |      3055.19 |     7.00s |     938.00s |     0.47s |
|      6501 /      6501 |         0 |         0 |      3294.11 |     7.50s |     932.00s |     0.47s |
|      6928 /      6928 |         0 |         0 |      3510.92 |     8.00s |     854.00s |     0.42s |
|      7381 /      7381 |         0 |         0 |      3743.17 |     8.50s |     906.00s |     0.45s |
|      7851 /      7851 |         0 |         0 |      3981.82 |     9.00s |     940.00s |     0.47s |
|      8308 /      8308 |         0 |         0 |      4216.12 |     9.50s |     912.18s |     0.46s |
|      8757 /      8757 |         0 |         0 |      4444.00 |    10.00s |     898.00s |     0.45s |
|      9218 /      9218 |         0 |         0 |      4680.35 |    10.50s |     922.00s |     0.46s |
|      9690 /      9690 |         0 |         0 |      4920.66 |    11.00s |     944.00s |     0.47s |
|     10158 /     10158 |         0 |         0 |      5159.12 |    11.50s |     936.00s |     0.47s |
|     10627 /     10627 |         0 |         0 |      5398.73 |    12.00s |     938.00s |     0.47s |
|     11104 /     11104 |         0 |         0 |      5641.39 |    12.50s |     954.00s |     0.47s |
|     11576 /     11576 |         0 |         0 |      5883.38 |    13.00s |     944.00s |     0.47s |
|     12056 /     12056 |         0 |         0 |      6126.94 |    13.50s |     960.00s |     0.48s |
|     12528 /     12528 |         0 |         0 |      6368.94 |    14.00s |     942.12s |     0.47s |
|     12997 /     12997 |         0 |         0 |      6606.86 |    14.50s |     938.00s |     0.46s |
|     13447 /     13447 |         0 |         0 |      6837.57 |    15.00s |     900.00s |     0.45s |
|     13899 /     13899 |         0 |         0 |      7067.20 |    15.50s |     904.00s |     0.45s |
|     14378 /     14378 |         0 |         0 |      7312.78 |    16.00s |     958.00s |     0.48s |
|     14815 /     14815 |         0 |         0 |      7534.72 |    16.50s |     874.00s |     0.43s |
|     14815 /     14815 |         0 |         0 |      7534.72 |    17.00s |       0.00s |     0.00s |
|     15290 /     15290 |         0 |         0 |      7778.25 |    17.50s |     950.00s |     0.48s |
|     15743 /     15743 |         0 |         0 |      8008.39 |    18.00s |     904.19s |     0.45s |
|     16218 /     16218 |         0 |         0 |      8251.92 |    18.50s |     950.00s |     0.48s |
|     16676 /     16676 |         0 |         0 |      8484.63 |    19.00s |     916.00s |     0.45s |
|     17138 /     17138 |         0 |         0 |      8721.49 |    19.50s |     924.00s |     0.46s |
|     17597 /     17597 |         0 |         0 |      8954.50 |    20.00s |     918.00s |     0.46s |

Bee: i-9e6fc612
max-parallel:           50
1st-resp-ms-min:        11.354
response-codes
        200:            198
        403:            17349
seconds:                20.006
connect-ms-max:         15.13
1st-resp-ms-max:        376.028
bytes:                  13111135.0
1st-resp-ms-mean:       41.7301567789
end2end-ms-mean:        41.7460330541
fetches-per-sec:        879.586124163
connect-ms-min:         0.0
fetches:                17597
bytes-per-sec:          655360.141957
end2end-ms-min:         11.37
end2end-ms-max:         376.044
mean-bytes-per-conn:    745.07785418
connect-ms-mean:        0.0346185102867


hurl http://can.192bf.transactcdn.com/00192BF/test.html/config.workflow:ContinueWarranty -p 50  -H "Accept : text/html" -H "Content-Type : text/plain" -o /tmp/tmp.cDsfCaHBDo -l 20 -A 1000 -j

i-9d6fc611
ec2-54-194-207-186.eu-west-1.compute.amazonaws.com
Running 1 threads 50 parallel connections per thread with 1 reqests per connection
+-----------/-----------+-----------+-----------+--------------+-----------+-------------+-----------+
|    Cmpltd /     Total |    IdlKil |    Errors | kBytes Recvd |   Elapsed |       Req/s |      MB/s |
+-----------/-----------+-----------+-----------+--------------+-----------+-------------+-----------+
|         0 /         0 |         0 |         0 |         0.00 |     0.50s |       0.00s |     0.00s |
|       490 /       490 |         0 |         0 |       222.63 |     1.00s |     980.00s |     0.43s |
|       958 /       958 |         0 |         0 |       461.10 |     1.50s |     936.00s |     0.47s |
|      1437 /      1437 |         0 |         0 |       704.57 |     2.00s |     958.00s |     0.48s |
|      1913 /      1913 |         0 |         0 |       948.61 |     2.50s |     952.00s |     0.48s |
|      2394 /      2394 |         0 |         0 |      1192.90 |     3.00s |     962.00s |     0.48s |
|      2868 /      2868 |         0 |         0 |      1435.92 |     3.50s |     948.00s |     0.47s |
|      3327 /      3327 |         0 |         0 |      1669.34 |     4.00s |     918.00s |     0.46s |
|      3802 /      3802 |         0 |         0 |      1912.88 |     4.50s |     948.10s |     0.47s |
|      4265 /      4265 |         0 |         0 |      2147.93 |     5.00s |     926.00s |     0.46s |
|      4737 /      4737 |         0 |         0 |      2389.92 |     5.50s |     944.00s |     0.47s |
|      5192 /      5192 |         0 |         0 |      2620.67 |     6.00s |     910.00s |     0.45s |
|      5663 /      5663 |         0 |         0 |      2862.15 |     6.50s |     942.00s |     0.47s |
|      6100 /      6100 |         0 |         0 |      3084.09 |     7.00s |     874.00s |     0.43s |
|      6568 /      6568 |         0 |         0 |      3324.03 |     7.50s |     936.00s |     0.47s |
|      7030 /      7030 |         0 |         0 |      3558.57 |     8.00s |     924.00s |     0.46s |
|      7502 /      7502 |         0 |         0 |      3800.57 |     8.50s |     942.12s |     0.47s |
|      7960 /      7960 |         0 |         0 |      4033.27 |     9.00s |     916.00s |     0.45s |
|      8410 /      8410 |         0 |         0 |      4263.98 |     9.50s |     900.00s |     0.45s |
|      8886 /      8886 |         0 |         0 |      4505.92 |    10.00s |     952.00s |     0.47s |
|      9359 /      9359 |         0 |         0 |      4748.42 |    10.50s |     946.00s |     0.47s |
|      9809 /      9809 |         0 |         0 |      4977.03 |    11.00s |     900.00s |     0.45s |
|     10269 /     10269 |         0 |         0 |      5212.87 |    11.50s |     920.00s |     0.46s |
|     10737 /     10737 |         0 |         0 |      5450.49 |    12.03s |     894.84s |     0.44s |
|     11184 /     11184 |         0 |         0 |      5679.66 |    12.53s |     894.00s |     0.45s |
|     11643 /     11643 |         0 |         0 |      5913.09 |    13.03s |     918.00s |     0.46s |
|     12109 /     12109 |         0 |         0 |      6152.01 |    13.53s |     932.00s |     0.47s |
|     12575 /     12575 |         0 |         0 |      6388.81 |    14.03s |     932.00s |     0.46s |
|     13041 /     13041 |         0 |         0 |      6627.73 |    14.53s |     932.00s |     0.47s |
|     13497 /     13497 |         0 |         0 |      6859.83 |    15.03s |     912.00s |     0.45s |
|     13946 /     13946 |         0 |         0 |      7090.03 |    15.53s |     898.00s |     0.45s |
|     14412 /     14412 |         0 |         0 |      7326.42 |    16.03s |     930.14s |     0.46s |
|     14861 /     14861 |         0 |         0 |      7556.62 |    16.53s |     898.00s |     0.45s |
|     15319 /     15319 |         0 |         0 |      7789.74 |    17.03s |     916.00s |     0.46s |
|     15779 /     15779 |         0 |         0 |      8025.58 |    17.53s |     920.00s |     0.46s |
|     15779 /     15779 |         0 |         0 |      8025.58 |    18.03s |       0.00s |     0.00s |
|     16239 /     16239 |         0 |         0 |      8259.31 |    18.53s |     920.00s |     0.46s |
|     16704 /     16704 |         0 |         0 |      8497.29 |    19.03s |     928.14s |     0.46s |
|     17175 /     17175 |         0 |         0 |      8737.09 |    19.53s |     942.00s |     0.47s |
|     17628 /     17628 |         0 |         0 |      8968.28 |    20.03s |     906.00s |     0.45s |

Bee: i-9d6fc611
max-parallel:           50
1st-resp-ms-min:        11.29
response-codes
        200:            208
        403:            17370
seconds:                20.027
connect-ms-max:         15.115
1st-resp-ms-max:        390.853
bytes:                  13132194.0
1st-resp-ms-mean:       41.6057616907
end2end-ms-mean:        41.6218236432
fetches-per-sec:        880.211714186
connect-ms-min:         0.0
fetches:                17628
bytes-per-sec:          655724.471963
end2end-ms-min:         11.303
end2end-ms-max:         390.866
mean-bytes-per-conn:    744.962219197
connect-ms-mean:        0.0350904539766


Offensive complete.

Summarized Results
     Total bytes:               26243329
     Seconds:                   20
     Connect-ms-max:            15.130000
     1st-resp-ms-max:           390.853000
     1st-resp-ms-mean:          41.667959
     Fetches/sec mean:          879.898919
     connect-ms-min:            0.000000
     Total fetches:             35225
     bytes/sec mean:            655542.306960
     end2end-ms-min mean:       11.336500
     mean-bytes-per-conn:       745.020037
     connect-ms-mean:           0.034854

Response Codes:
     2xx:                       406
     3xx:                       0
     4xx:                       34719
     5xx:                       0

Mission Assessment: Target crushed bee offensive.
The swarm is awaiting new orders.
hurl http://can.192bf.transactcdn.com/00192BF/test.html/config.workflow:ContinueWarranty -p 50  -H "Accept : text/html" -H "Content-Type : text/plain" -o /tmp/tmp.jfVcPxIqE5 -l 20 -A 1000 -j

i-02fead8c
ec2-52-77-216-107.ap-southeast-1.compute.amazonaws.com
Running 1 threads 50 parallel connections per thread with 1 reqests per connection
+-----------/-----------+-----------+-----------+--------------+-----------+-------------+-----------+
|    Cmpltd /     Total |    IdlKil |    Errors | kBytes Recvd |   Elapsed |       Req/s |      MB/s |
+-----------/-----------+-----------+-----------+--------------+-----------+-------------+-----------+
|         0 /         0 |         0 |         0 |         0.00 |     0.50s |       0.00s |     0.00s |
|       100 /       100 |         0 |         0 |        23.95 |     1.00s |     200.00s |     0.05s |
|       250 /       250 |         0 |         0 |        98.11 |     1.50s |     300.00s |     0.14s |
|       388 /       388 |         0 |         0 |       167.60 |     2.00s |     276.00s |     0.14s |
|       529 /       529 |         0 |         0 |       239.25 |     2.50s |     282.00s |     0.14s |
|       673 /       673 |         0 |         0 |       311.39 |     3.00s |     287.43s |     0.14s |
|       816 /       816 |         0 |         0 |       384.29 |     3.50s |     286.00s |     0.14s |
|       953 /       953 |         0 |         0 |       452.42 |     4.00s |     274.00s |     0.13s |
|      1091 /      1091 |         0 |         0 |       522.96 |     4.50s |     276.00s |     0.14s |
|      1226 /      1226 |         0 |         0 |       591.12 |     5.00s |     270.00s |     0.13s |
|      1372 /      1372 |         0 |         0 |       664.71 |     5.50s |     292.00s |     0.14s |
|      1516 /      1516 |         0 |         0 |       736.85 |     6.00s |     288.00s |     0.14s |
|      1656 /      1656 |         0 |         0 |       808.20 |     6.50s |     280.00s |     0.14s |
|      1795 /      1795 |         0 |         0 |       877.78 |     7.00s |     278.00s |     0.14s |
|      1937 /      1937 |         0 |         0 |       950.16 |     7.50s |     283.43s |     0.14s |
|      2073 /      2073 |         0 |         0 |      1018.41 |     8.00s |     272.00s |     0.13s |
|      2213 /      2213 |         0 |         0 |      1089.34 |     8.50s |     280.00s |     0.14s |
|      2356 /      2356 |         0 |         0 |      1161.60 |     9.00s |     286.00s |     0.14s |
|      2495 /      2495 |         0 |         0 |      1232.02 |     9.50s |     278.00s |     0.14s |
|      2637 /      2637 |         0 |         0 |      1303.14 |    10.00s |     284.00s |     0.14s |
|      2779 /      2779 |         0 |         0 |      1375.31 |    10.50s |     284.00s |     0.14s |
|      2916 /      2916 |         0 |         0 |      1443.86 |    11.00s |     274.00s |     0.13s |
|      3052 /      3052 |         0 |         0 |      1513.17 |    11.50s |     272.00s |     0.14s |
|      3194 /      3194 |         0 |         0 |      1584.70 |    12.00s |     283.43s |     0.14s |
|      3334 /      3334 |         0 |         0 |      1656.06 |    12.50s |     280.00s |     0.14s |
|      3471 /      3471 |         0 |         0 |      1724.40 |    13.00s |     274.00s |     0.13s |
|      3605 /      3605 |         0 |         0 |      1793.10 |    13.50s |     268.00s |     0.13s |
|      3747 /      3747 |         0 |         0 |      1864.22 |    14.00s |     284.00s |     0.14s |
|      3882 /      3882 |         0 |         0 |      1932.80 |    14.50s |     270.00s |     0.13s |
|      4026 /      4026 |         0 |         0 |      2004.73 |    15.00s |     288.00s |     0.14s |
|      4166 /      4166 |         0 |         0 |      2075.87 |    15.50s |     280.00s |     0.14s |
|      4306 /      4306 |         0 |         0 |      2146.38 |    16.00s |     280.00s |     0.14s |
|      4451 /      4451 |         0 |         0 |      2220.09 |    16.50s |     289.42s |     0.14s |
|      4597 /      4597 |         0 |         0 |      2293.05 |    17.00s |     292.00s |     0.14s |
|      4728 /      4728 |         0 |         0 |      2360.21 |    17.50s |     262.00s |     0.13s |
|      4865 /      4865 |         0 |         0 |      2428.76 |    18.00s |     274.00s |     0.13s |
|      5008 /      5008 |         0 |         0 |      2501.44 |    18.50s |     286.00s |     0.14s |
|      5153 /      5153 |         0 |         0 |      2574.10 |    19.00s |     289.42s |     0.14s |
|      5292 /      5292 |         0 |         0 |      2645.15 |    19.50s |     278.00s |     0.14s |
|      5429 /      5429 |         0 |         0 |      2713.91 |    20.00s |     274.00s |     0.13s |

Bee: i-02fead8c
max-parallel:           50
1st-resp-ms-min:        167.119
response-codes
        200:            208
        403:            5171
seconds:                20.005
connect-ms-max:         194.213
1st-resp-ms-max:        402.352
bytes:                  3995143.0
1st-resp-ms-mean:       179.083958914
end2end-ms-mean:        179.106678751
fetches-per-sec:        271.382154461
connect-ms-min:         0.0
fetches:                5429
bytes-per-sec:          199707.223194
end2end-ms-min:         167.165
end2end-ms-max:         402.373
mean-bytes-per-conn:    735.889298213
connect-ms-mean:        1.63028611266


hurl http://can.192bf.transactcdn.com/00192BF/test.html/config.workflow:ContinueWarranty -p 50  -H "Accept : text/html" -H "Content-Type : text/plain" -o /tmp/tmp.Ze2gnkVVd2 -l 20 -A 1000 -j

i-03fead8d
ec2-54-254-220-121.ap-southeast-1.compute.amazonaws.com
Running 1 threads 50 parallel connections per thread with 1 reqests per connection
+-----------/-----------+-----------+-----------+--------------+-----------+-------------+-----------+
|    Cmpltd /     Total |    IdlKil |    Errors | kBytes Recvd |   Elapsed |       Req/s |      MB/s |
+-----------/-----------+-----------+-----------+--------------+-----------+-------------+-----------+
|         0 /         0 |         0 |         0 |         0.00 |     0.50s |       0.00s |     0.00s |
|       100 /       100 |         0 |         0 |        23.10 |     1.00s |     199.60s |     0.05s |
|       250 /       250 |         0 |         0 |        98.11 |     1.50s |     300.00s |     0.15s |
|       388 /       388 |         0 |         0 |       167.38 |     2.00s |     276.00s |     0.14s |
|       526 /       526 |         0 |         0 |       237.71 |     2.50s |     276.00s |     0.14s |
|       669 /       669 |         0 |         0 |       308.92 |     3.00s |     286.00s |     0.14s |
|       810 /       810 |         0 |         0 |       380.79 |     3.50s |     282.00s |     0.14s |
|       948 /       948 |         0 |         0 |       449.85 |     4.00s |     276.00s |     0.13s |
|      1083 /      1083 |         0 |         0 |       518.65 |     4.50s |     270.00s |     0.13s |
|      1224 /      1224 |         0 |         0 |       589.04 |     5.00s |     281.44s |     0.14s |
|      1363 /      1363 |         0 |         0 |       659.88 |     5.50s |     278.00s |     0.14s |
|      1503 /      1503 |         0 |         0 |       729.76 |     6.00s |     280.00s |     0.14s |
|      1642 /      1642 |         0 |         0 |       800.81 |     6.50s |     278.00s |     0.14s |
|      1775 /      1775 |         0 |         0 |       867.31 |     7.00s |     266.00s |     0.13s |
|      1917 /      1917 |         0 |         0 |       939.69 |     7.50s |     284.00s |     0.14s |
|      2060 /      2060 |         0 |         0 |      1011.53 |     8.00s |     286.00s |     0.14s |
|      2197 /      2197 |         0 |         0 |      1081.14 |     8.50s |     274.00s |     0.14s |
|      2331 /      2331 |         0 |         0 |      1147.94 |     9.00s |     268.00s |     0.13s |
|      2474 /      2474 |         0 |         0 |      1221.26 |     9.50s |     285.43s |     0.14s |
|      2618 /      2618 |         0 |         0 |      1292.98 |    10.00s |     288.00s |     0.14s |
|      2756 /      2756 |         0 |         0 |      1363.52 |    10.50s |     276.00s |     0.14s |
|      2893 /      2893 |         0 |         0 |      1432.07 |    11.00s |     274.00s |     0.13s |
|      3035 /      3035 |         0 |         0 |      1504.45 |    11.50s |     284.00s |     0.14s |
|      3170 /      3170 |         0 |         0 |      1572.19 |    12.00s |     270.00s |     0.13s |
|      3301 /      3301 |         0 |         0 |      1639.35 |    12.50s |     262.00s |     0.13s |
|      3439 /      3439 |         0 |         0 |      1707.99 |    13.00s |     276.00s |     0.13s |
|      3574 /      3574 |         0 |         0 |      1777.21 |    13.50s |     269.46s |     0.13s |
|      3712 /      3712 |         0 |         0 |      1845.64 |    14.00s |     276.00s |     0.13s |
|      3851 /      3851 |         0 |         0 |      1916.90 |    14.50s |     278.00s |     0.14s |
|      3987 /      3987 |         0 |         0 |      1984.94 |    15.00s |     272.00s |     0.13s |
|      4124 /      4124 |         0 |         0 |      2054.97 |    15.50s |     274.00s |     0.14s |
|      4266 /      4266 |         0 |         0 |      2125.88 |    16.00s |     284.00s |     0.14s |
|      4408 /      4408 |         0 |         0 |      2198.26 |    16.50s |     284.00s |     0.14s |
|      4539 /      4539 |         0 |         0 |      2263.73 |    17.00s |     262.00s |     0.13s |
|      4679 /      4679 |         0 |         0 |      2334.88 |    17.50s |     280.00s |     0.14s |
|      4822 /      4822 |         0 |         0 |      2406.50 |    18.00s |     285.43s |     0.14s |
|      4962 /      4962 |         0 |         0 |      2478.07 |    18.50s |     280.00s |     0.14s |
|      5101 /      5101 |         0 |         0 |      2548.07 |    19.00s |     278.00s |     0.14s |
|      5240 /      5240 |         0 |         0 |      2618.91 |    19.50s |     278.00s |     0.14s |
|      5382 /      5382 |         0 |         0 |      2689.82 |    20.00s |     284.00s |     0.14s |

Bee: i-03fead8d
max-parallel:           50
1st-resp-ms-min:        167.37
response-codes
        200:            208
        403:            5124
seconds:                20.005
connect-ms-max:         197.678
1st-resp-ms-max:        396.03
bytes:                  3959940.0
1st-resp-ms-mean:       180.888643473
end2end-ms-mean:        180.91185859
fetches-per-sec:        269.032741815
connect-ms-min:         0.0
fetches:                5382
bytes-per-sec:          197947.513122
end2end-ms-min:         167.395
end2end-ms-max:         396.049
mean-bytes-per-conn:    735.774804905
connect-ms-mean:        1.66231845461


Offensive complete.

Summarized Results
     Total bytes:               7955083
     Seconds:                   20
     Connect-ms-max:            197.678000
     1st-resp-ms-max:           402.352000
     1st-resp-ms-mean:          179.986301
     Fetches/sec mean:          270.207448
     connect-ms-min:            0.000000
     Total fetches:             10811
     bytes/sec mean:            198827.368158
     end2end-ms-min mean:       167.280000
     mean-bytes-per-conn:       735.832052
     connect-ms-mean:           1.646302

Response Codes:
     2xx:                       416
     3xx:                       0
     4xx:                       10295
     5xx:                       0

Mission Assessment: Target crushed bee offensive.
The swarm is awaiting new orders.
(trusty)rawm@localhost:~/beeswithmachineguns$
</pre>


An example bees down

<pre>
$ ./bees down
Read 2 bees from the roster: eu-west-1b
Connecting to the hive.
Calling off the swarm for eu-west-1b.
Stood down 2 bees.
Read 2 bees from the roster: ap-southeast-1b
Connecting to the hive.
Calling off the swarm for ap-southeast-1b.
Stood down 2 bees.
Read 2 bees from the roster: us-west-2b
Connecting to the hive.
Calling off the swarm for us-west-2b.
Stood down 2 bees.
</pre>

h2. The caveat! (PLEASE READ)

(The following was cribbed from our "original blog post about the bees":http://blog.apps.chicagotribune.com/2010/07/08/bees-with-machine-guns/.)

If you decide to use the Bees, please keep in mind the following important caveat: they are, more-or-less a distributed denial-of-service attack in a fancy package and, therefore, if you point them at any server you don’t own you will behaving *unethically*, have your Amazon Web Services account *locked-out*, and be *liable* in a court of law for any downtime you cause.

You have been warned.

h2. Troubleshooting

h3. EC2 Instances Out Of Sync

If you find yourself in a situation where 'bees report' seems to be out of sync with EC2 instances you know are (or are not) running:
* You can reset the BWMG state by deleting ~/.bees.<region>.  Note that this will prevent BWMG from identifying EC2 instances that may now be orphaned by the tool
* You can manually edit ~/.bees.<region> to add or remove instance IDs and force synchronization with the reality from your EC2 dashboard

This is helpful in cases where BWMG crashes, EC2 instances are terminated outside of the control of BWMG, or other situations where BWMG is out of sync with reality.


h2. Bugs

Please log your bugs on the "Github issues tracker":http://github.com/newsapps/beeswithmachineguns/issues.

h2. Credits

The bees are a creation of the News Applications team at the Chicago Tribune--visit "our blog":http://apps.chicagotribune.com/ and read "our original post about the project":http://blog.apps.chicagotribune.com/2010/07/%2008/bees-with-machine-guns/.

Initial refactoring code and inspiration from "Jeff Larson":http://github.com/thejefflarson.

Multiple url support from "timsu":https://github.com/timsu/beeswithmachineguns.

Thanks to everyone who reported bugs against the alpha release.

h2. License

MIT.
