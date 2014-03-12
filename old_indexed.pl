#!/usr/bin/env perl

use Mojolicious::Lite;

get '/' => sub {
  my $self = shift;
  my $cpan_id = $self->param('a');
  if ($cpan_id) {
    $cpan_id =~ s/^\s+//s;
    $cpan_id =~ s/\s+$//s;
    if ($cpan_id) {
      require Storable;
      my $l = Storable::retrieve('cpan-indexed-old.dat');
      return $self->render('list', l => $l, cpan_id => $cpan_id);
    }
  }
  $self->render('index');
};

app->start;
__DATA__

@@ list.html.ep
% layout 'default';
% title 'cpan-indexed-old results';
<div>
author: <a href="http://search.cpan.org/~<%= $cpan_id %>/"><%= $cpan_id %></a>
</div><br><br>
% if ( !exists $l->{$cpan_id} ) {
<div>
No indexed old versions found for this CPAN id. Sometimes this is incorrect due to invalid
distribution names.
</div>

<div>
<b>Note</b>: is a good idea to delete old unindexed versions too.
</div>
% } else {
<div>
When modules are removed from CPAN distributions, latest version of distribution that contains
this module remains indexed. There are several problems with it:
<ul>
<li>
It takes space not only on CPAN mirrors, but on minicpan mirrors too.
</li><li>
It is tested by cpantesters, so even if problem like hanging module is fixed in newer version,
it still causes problems. Also reports for these versions take space in cpantesters DB.
</li><li>
When doing mass upgrade, older version may replace newer version.
</li>
</ul>
</div>
<div>
If you don't want to delete some old version, you can release new version that includes empty
versions of removed modules.
</div>
<div>
<b>Note</b>: Sometimes this tool incorrectly detects latest version as old version. Please check before deleting.
I can help you in resolving this issue, my e-mail is alexchorny<i>@</i>gmail.com.
</div>
<br><br>

%   foreach my $d ( sort keys %{ $l->{$cpan_id} } ) { #distributions
<table border=1>
 <caption>Distribution: <a href="http://search.cpan.org/dist/<%= $d %>/"><%= $d %></a> latest version: <%= $l->{$cpan_id}{$d}[0]{latest} %></caption>
 <tr><th>Dist version</th><th style="min-width: 300px">dist</th><th>modules indexed</th></tr>

%     foreach my $v ( @{ $l->{$cpan_id}{$d} } ) { #versions
 <tr>
  <td><%= $v->{ver} %></td><td><%= $v->{path} %></td><td>
%       foreach my $m (@{ $v->{mod} }) {
<%== $m %>
%       }
  </td>
 </tr>
%     }

</table><br><br><br>
%   }
% }

@@ index.html.ep
% layout 'default';
% title 'cpan-indexed-old';
<div>
This tool shows old versions of distributions that are still indexed.
</div>
<form method="get">
CPAN id
%= input_tag 'a'
%= submit_button
</form>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body>
<div style="font-size: small">(c) CHORNY (Alexandr Ciornii) 2014. This a tool for CPAN, repository for Perl programming language modules. Fork here <a href="https://github.com/chorny/cpan-indexed-old">https://github.com/chorny/cpan-indexed-old</a>.
</div><br><br>
  <%= content %>
  </body>
</html>
