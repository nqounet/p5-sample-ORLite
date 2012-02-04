#!/usr/bin/env perl
#ｕｔｆ８
use utf8;

package Model;
use strict;
use ORLite {
  file => __FILE__ . qq{.db},
  create => sub {
    my $dbh = shift;
    $dbh->do(
      'CREATE TABLE bbs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        msg TEXT NOT NULL
      )'
    );
    return 1;
  },
};

{
  my $connect = sub {
    DBI->connect(
      $_[0]->dsn,
      undef,
      undef,
      {
        PrintError => 0,
        RaiseError => 1,
        sqlite_unicode => 1,
      },
    );
  };
  no warnings 'redefine';
  *connect = $connect;
}

package main;
use Mojolicious::Lite;
use Mojo::ByteStream qw(b);

app->secret( b(__FILE__)->md5_sum )->log->level('debug')->path(__FILE__ .qq{.log})->debug(app->secret);

get '/' => sub {
  my $self = shift;
  $self->stash(
    entries => [Model::Bbs->select('order by id desc')],
    debug => $self->dumper($self)
  );
} => 'index';

post '/' => sub {
  my $self = shift;
  Model::Bbs->create(msg => $self->param('msg'));
  $self->redirect_to('/');
};

app->start;

__DATA__

@@ index.html.ep
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>ORLite with Mojolicious::Lite</title>
  </head>
  <body>
    <h1>ORLite with Mojolicious::Lite</h1>
    <ul>
    % foreach my $entry (@{$entries}) {
      <li><%= $entry->msg %></li>
    % }
    </ul>
    <p>今何してる？</p>
    <%= form_for '/' => (method => 'post') => begin %>
    <%= input_tag 'msg', 'type' => 'text' %>
    <%= submit_button '投稿する' %>
    <% end %>
    <pre><%= $debug %></pre>
  </body>
</html>

