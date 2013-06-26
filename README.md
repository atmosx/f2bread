# f2bread

## Description
**f2bread** is a [ruby][] script that extracts data from 'fail2ban.log' files. Fail2ban is a sort of lightweight *Intrusion Detection System*, for more info please visit the [project's homepage](http://www.fail2ban.org/wiki/index.php/Main_Page).

This product includes *GeoLite data* created by MaxMind, available from [www.maxmind.com](http://www.maxmind.com). The GeoLite databases are distributed under the [Creative Commons Attribution-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-sa/3.0/).

## Usage
    $ f2bread -h
    Usage: f2bread -l /path/to/fail2ban.log -s country -n 5
    -l, --log FILE                   Define the location of fail2ban.log. Default is /var/log/fail2ban.log
    -n, --no N                       By default all entries are listed. This option lets you choose the no of entries you want to display from top down
    -i, --info                       Display fail2ban.log summary
    -s, --sort OPT                   Sorts by [date, country, ip (ip frequency)]
    -v, --version                    Display version
    -h, --help                       Display help menu
    

    $ f2bread -l fail2ban.log -i
    f2bread 0.0.1-alpha 2012
    ===============================================================================
    Log file: '/Users/atma/Dropbox/Programming/Projects/Local/f2bread/fail2ban.log'

    First entry: 2011-07-23 02:04:51
    Last  entry: 2012-07-25 15:14:47 
    Time frame:1 year, 3 days and 07:09:56
    Banned IPs:1072
    Countries:70
    Protocol(s):[ssh-ipfw]
    Bans per day:2.91

    Most banned IP(s) by fail2ban: 
    -------------------------
    IP address    -   Attacks
    -------------------------
    121.31.56.62	7

    Most hostile Countries:		
    --------------------------
    Country: Korea(South) - IP(s): 400
    Country: China - IP(s): 195
    Country: United - IP(s): 86
    Country: Russian_Federation - IP(s): 36
    Country: Germany - IP(s): 32


    $ f2bread -s country -n 5 
    f2bread.rb 0.0.1-alpha 2012
    Country: Korea(South) - IP(s): 400
    Country: China - IP(s): 195
    Country: United - IP(s): 86
    Country: Russian_Federation - IP(s): 36
    Country: Germany - IP(s): 32

# License
**The MIT License (MIT)**

Copyright (c) 2013 Panagiotis Atmatizdis

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[ruby]: http://www.ruby-lang.org/en/
[fail2ban]: http://www.fail2ban.org/wiki/index.php/Main_Page
