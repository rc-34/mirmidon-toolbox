#!/usr/bin/perl


use Date::Convert;

$date=new Date::Convert::Julian(8034.666667,01, 01);
convert Date::Convert::Julian $date;
print $date->date_string, "\n";