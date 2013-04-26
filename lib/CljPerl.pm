package CljPerl;

use 5.008008;
use strict;
use warnings;
use File::Basename;
use File::Spec;

require Exporter;

use CljPerl::Evaler;

our @ISA = qw(Exporter);

# This allows declaration	use CljPerl ':all';
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';


# Preloaded methods go here.

sub print {
  print @_;
}

sub open {
  my $file = shift;
  my $cb = shift;
  my $fh;
  open $fh, $file;
  &{$cb}($fh);
  close $fh;
}

sub puts {
  my $fh = shift;
  my $str = shift;
  print $fh $str;
}

sub readline {
  my $fh = shift;
  return <$fh>;
}

sub use_lib {
  my $path = shift;
  unshift @INC, $path;
}

my $lib_path = File::Spec->rel2abs(dirname(__FILE__));
use_lib($lib_path);

1;
__END__

=head1 NAME

CljPerl - A lisp on perl.

=head1 SYNOPSIS

        (defmacro defn [name args & body]
          `(def ~name
             (fn ~args ~@body)))

        (defn foo [arg]
          (println arg))

        (foo "hello world!") ;comment here

=head1 DESCRIPTION

CljPerl is a lisp implemented by Perl. It borrows the idea from Clojure,
which makes a seamless connection with Java packages.
Like Java, Perl has huge number of CPAN packages.
They are amazing resources. We should make use of them as possible.
However, programming in lisp is more insteresting.
CljPerl is a bridge between lisp and perl. We can program in lisp and
make use of the great resource from CPAN.

=head2 EXPORT

=head3 Lisp <-> Perl

CljPerl is hosted on Perl. Any object of CljPerl can be passed into Perl and vice versa including code.

An example of using Perl's IO functions.

=head4 Perl functions in CljPerl.pm

	package CljPerl;
	
	sub open {
	  my $file = shift;
	  my $cb = shift;
	  my $fh;
	  open $fh, $file;
	  &{$cb}($fh);
	  close $fh;
	}
	
	sub puts {
	  my $fh = shift;
	  my $str = shift;
	  print $fh $str;
	}
	
	sub readline {
	  my $fh = shift;
	  return <$fh>;
	}
	
=head4 CljPerl functions in core.clp

	(defn open [file cb]
	  (. open file cb))
	
	(defn >> [fh str]
	  (. puts fh str))
	
	(defn << [fh]
	  (. readline fh))

=head4 Test

	(open ">t.txt" (fn [f]
	  (>> f "aaa")))
	
	(open "<t.txt" (fn [f]
	  (println (perl->clj (<< f)))))

An advanced example which creates a timer with AnyEvent.

	(. require AnyEvent)

	(def cv (->AnyEvent condvar))
	
	(def count 0)
	
	(def t (->AnyEvent timer
	  {:after 1
	   :interval 1
	   :cb (fn [ & args]
	         (println count)
	         (set! count (+ count 1))
	         (if (>= count 10)
	           (set! t nil)))}))
	
	(.AnyEvent::CondVar::Base recv cv)

=head3 Documents

=head4 Reader

=head5 Reader forms

=head6 Symbols :

	foo, foo#bar

=head6 Literals
 
=head6 Strings :

	"foo", "\"foo\tbar\n\""

=head6 Numbers :

	1, -2, 2.5

=head6 Booleans :

	true, false

=head6 Keywords :

	:foo

=head5 Lists :

	(foo bar)

=head5 Vectors :

	[foo bar]

=head5 Maps :

	{:key1 value1 :key2 value2 "key3" value3}


#### Macro charaters

=head5 Quote (') :

	'(foo bar)

=head5 Comment (;) :

	; comment

=head5 Metadata (^) :

	^{:key value}

=head5 Syntax-quote (`) :

	`(foo bar)

=head5 Unquote (~) :

	`(foo ~bar)

=head5 Unquote-slicing (~@) :

	`(foo ~@bar)

=head4 Builtin Functions

=head5 list :

	(list 'a 'b 'c) ;=> '(a b c)

=head5 car :

	(car '(a b c))  ;=> 'a

=head5 cdr :

	(cdr '(a b c))  ;=> '(b c)

=head5 cons :

	(cons 'a '(b c)) ;=> '(a b c)

=head5 key accessor :

	(:a {:a 'a :b 'a}) ;=> 'a

=head5 keys :

	(keys {:a 'a :b 'b}) ;=> (:a :b)

=head5 index accessor :

	(1 ['a 'b 'c]) ;=> 'b

=head5 length :

	(length '(a b c)) ;=> 3
	(length ['a 'b 'c]) ;=> 3
	(length "abc") ;=> 3

=head5 append :

	(append '(a b) '(c d)) ;=> '(a b c d)
	(append ['a 'b] ['c 'd]) ;=> ['a 'b 'c 'd]
	(append "ab" "cd") ;=> "abcd"

=head5 type :

	(type "abc") ;=> "string"
	(type :abc)  ;=> "keyword"
	(type {})    ;=> "map"

=head5 meta :

	(meta foo ^{:m 'b})
	(meta foo) ;=> {:m 'b}

=head5 fn :

	(fn [arg & args]
	  (println 'a))

=head5 apply :

	(apply list '(a b c)) ;=> '(a b c)

=head5 eval :

	(eval "(+ 1 2)")

=head5 require :

	(require "core")

=head5 def :

	(def foo "bar")
	(def ^{:k v} foo "bar")

=head5 set! :

	(set! foo "bar") 

=head5 defmacro :

	(defmacro foo [arg & args]	
	  `(println ~arg)
	  `(list ~@args))

=head5 if :

	(if (> 1 0)
	  (println true)
	  (println false))
	  
	(if true
	  (println true))

=head5 while :

	(while true
	  (println true))

=head5 begin :

	(begin
	  (println 'foo)
	  (println 'bar))

=head5 perl->clj :

=head5 ! :

	(! true) ;=> false

=head5 + - * / % == != >= <= > < : only for number.

=head5 eq ne : only for string.

=head5 equal : for all objects.

=head5 . : (.[perl namespace] method args ...)

	(.CljPerl print "foo")

=head5 -> : (->[perl namespace] method args ...)
   Like '.', but this will pass perl namespace as first argument to perl method.

=head5 println

	(println {:a 'a})

=head5 trace-vars : Trace the variables in current frame.

	(trace-vars)

=head4 Core Functions

=head5 use-lib : append path into Perl and CljPerl files' searching paths.

	(use-lib "path")

=head5 ns : CljPerl namespace.

	(ns "foo"
	  (println "bar"))

=head5 defn :

	(defn foo [arg & args]
	  (println arg))

=head5 defmulti :

=head5 defmethod :

=head5 reduce :

=head5 map :

=head5 open : open a file with a callback.

	(open ">file"
	  (fn [fh]
	    (>> fn "foo")))

=head5 << : read a line from a file handler.

	(<< fh)

=head5 >> : write a string into a file handler.

	(>> fh "foo")

=head1 SEE ALSO

=head1 AUTHOR

Wei Hu, E<lt>huwei04@hotmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Wei Hu. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=cut
