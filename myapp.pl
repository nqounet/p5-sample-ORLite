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
  # ORLiteのutf8対応
  my $connect = sub {
    DBI->connect(
      $_[0]->dsn,
      undef,
      undef,
      {
        PrintError => 0,
        RaiseError => 1,
        ShowErrorStatement => 1,
        sqlite_unicode => 1,
      },
    );
  };
  no warnings 'redefine';
  *connect = $connect;# オーバーライド
}

package main;
use Mojolicious::Lite;
use Mojo::ByteStream qw(b);

app->secret( b(__FILE__)->md5_sum )
  ->log->level('debug')
  ->debug(app->secret);

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
% layout 'default';
% title 'たいとる';
<div class="container">
  <div class="hero-unit">
    <h1>ORLite with Mojolicious::Lite</h1>
    <p><%= scalar localtime %></p>
  </div>
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
</div>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html lang="ja-JP">
<head>
  <meta charset="<%= app->renderer->encoding %>">
  <title><%= title %></title>
  %= stylesheet '/tb/css/bootstrap.min.css'
  %= stylesheet '/tb/css/bootstrap-responsive.min.css'
  %= stylesheet '/css/app.css'
  %= javascript '/js/jquery.js'
  %= javascript '/tb/js/bootstrap.min.js'
  %= javascript '/js/app.js'
</head>
<body>
  %= content
</body>
</html>
