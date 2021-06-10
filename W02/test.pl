#!/usr/bin/perl

print "Content-Type: text/html\n\n";
print "<html>";
print "<head>";
print "<link href='test1.css' rel='stylesheet' type='text/css'>";
print "</head>";
print "<body>";

print ("<h1>Perl is working</h1>");

print "<section class='acc'>";
print "<input type='checkbox' name='collapse' id ='handle' checked='checked'>";
print "<h2 class='handle'>";
print "<label for='handel1'>task 1 </label>";
print "<div class='content'>";

my $result = `/bin/bash task1.sh`;
print "<p>$result</p>";
print "</div>";
print "</section>";

print("<h2>task 2 </h1>");

$result = `/bin/bash task2.sh`;
print ("<div>$result</div>");
print "\n\n\n";


print("<h2>task 3 </h1>");

$result = `/bin/bash task3.sh`;
print "$result";
print "\n\n\n";


print("<h2>task 4 </h1>");

$result = `/bin/bash task4.sh`;
print "$result";
print "\n\n\n";


print("<h2>task 6 </h1>");

$result = `/bin/bash bash.sh`;
print "$result";
print "\n\n\n";

print "</body>";
print "</html>";
