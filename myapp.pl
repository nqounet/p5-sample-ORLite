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

app->secrets( b(__FILE__)->md5_sum )
  ->log->level('debug')
  ->debug(app->secrets);

app->static->paths(['app']);

get '/' => sub  {
  shift->redirect_to('index.html');
};

get '/entries' => sub {
  my $self = shift;
  $self->stash(
    entries => [Model::Bbs->select('order by id desc')],
    debug => $self->dumper($self)
  );
} => 'index';

post '/entries' => sub {
  my $self = shift;
  Model::Bbs->create(msg => $self->param('msg'));
  $self->redirect_to('/');
};

app->start;
