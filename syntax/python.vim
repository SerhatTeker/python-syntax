" Vim syntax file
" Language:	Python
" Maintainer:	Zvezdan Petkovic <zpetkovic@acm.org>
" Last Change:	2016 Apr 13
" Credits:	Neil Schemenauer <nas@python.ca>
"		Dmitry Vasiliev
"
"		This version is a major rewrite by Zvezdan Petkovic.
"
"		- introduced highlighting of doctests
"		- updated keywords, built-ins, and exceptions
"		- corrected regular expressions for
"
"		  * functions
"		  * decorators
"		  * strings
"		  * escapes
"		  * numbers
"		  * space error
"
"		- corrected synchronization
"		- more highlighting is ON by default, except:
"		- space error highlighting is OFF by default,
"		- self, cls keywords highlighting is OFF by default.
"
" Optional highlighting can be controlled using these variables.
"
"   let python_no_builtin_highlight = 1
"   let python_no_doctest_code_highlight = 1
"   let python_no_doctest_highlight = 1
"   let python_no_exception_highlight = 1
"   let python_no_number_highlight = 1
"   let python_space_error_highlight = 1
"
"   let python_no_parameter_highlight = 1
"   let python_no_operator_highlight = 1
"   let python_self_cls_highlight = 1
"
" All the options above can be switched on together.
"
"   let python_highlight_all = 1
"

" For version 5.x: Clear all syntax items.
" For version 6.x: Quit when a syntax file was already loaded.
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" We need nocompatible mode in order to continue lines with backslashes.
" Original setting will be restored.
let s:cpo_save = &cpo
set cpo&vim

" Keep Python keywords in alphabetical order inside groups for easy
" comparison with the table in the 'Python Language Reference'
" https://docs.python.org/2/reference/lexical_analysis.html#keywords,
" https://docs.python.org/3/reference/lexical_analysis.html#keywords.
" Groups are in the order presented in NAMING CONVENTIONS in syntax.txt.
" Exceptions come last at the end of each group (class and def below).
"
" Keywords 'with' and 'as' are new in Python 2.6
" (use 'from __future__ import with_statement' in Python 2.5).
"
" Some compromises had to be made to support both Python 3 and 2.
" We include Python 3 features, but when a definition is duplicated,
" the last definition takes precedence.
"
" - 'False', 'None', and 'True' are keywords in Python 3 but they are
"   built-ins in 2 and will be highlighted as built-ins below.
" - 'exec' is a built-in in Python 3 and will be highlighted as
"   built-in below.
" - 'nonlocal' is a keyword in Python 3 and will be highlighted.
" - 'print' is a built-in in Python 3 and will be highlighted as
"   built-in below (use 'from __future__ import print_function' in 2)
" - async and await were added in Python 3.5 and are soft keywords.
"
syn keyword pythonClassKeyword	class nextgroup=pythonClass skipwhite
syn keyword pythonDefKeyword	def nextgroup=pythonFunction skipwhite

syn keyword pythonStatement	False, None, True

syn keyword pythonStatement	as assert break continue del exec global
syn keyword pythonStatement	lambda nonlocal pass print return with
syn keyword pythonConditional	elif else if
syn keyword pythonRepeat	for while
syn keyword pythonOperator	and in is not or
syn keyword pythonException	except finally raise try
syn keyword pythonInclude	import
syn keyword pythonAsync		async await

" Generators (yield from: Python 3.3)
syn match pythonInclude   "\<from\>" display
syn match pythonStatement "\<yield\>" display
syn match pythonStatement "\<yield\s\+from\>" display

" pythonExtra(*)Operator
syn match pythonExtraOperator       "\%([~!^&|*/%+-]\|\%(class\s*\)\@<!<<\|<=>\|<=\|\%(<\|\<class\s\+\u\w*\s*\)\@<!<[^<]\@=\|===\|==\|=\~\|>>\|>=\|=\@<!>\|\*\*\|\.\.\.\|\.\.\|::\|=\)"
syn match pythonExtraPseudoOperator "\%(-=\|/=\|\*\*=\|\*=\|&&=\|&=\|&&\|||=\||=\|||\|%=\|+=\|!\~\|!=\)"

" Decorators (new in Python 2.4)
syn match   pythonDecorator	"@" display nextgroup=pythonFunction skipwhite
" The zero-length non-grouping match before the function name is
" extremely important in pythonFunction.  Without it, everything is
" interpreted as a function inside the contained environment of
" doctests.
" A dot must be allowed because of @MyClass.myfunc decorators.

" Comma
syn match pythonDot      "\."   display
syn match pythonComma    "[,]"  display
syn match pythonColon    "[:]"  display


" Bracket symbols
syn match pythonBrackets "[(|)]" contained skipwhite

" Class parameters
syn match  pythonClass "\%(\%(def\s\|class\s\|@\)\s*\)\@<=\h\%(\w\|\.\)*" contained nextgroup=pythonClassVars
syn region pythonClassVars start="(" end=")" contained contains=pythonClassParameters transparent keepend
syn match  pythonClassParameters "[^,]*" contained contains=pythonExtraOperator,pythonBuiltin,pythonConstant,pythonStatement,pythonNumber,pythonString,pythonBrackets skipwhite

" Function parameters
syn match  pythonFunction '\(\.\)\@<=.\{-}\((\)\@='
syn match  pythonFunction '\(\.\)\@<!\w*\((\)\@='
syn match  pythonFunction "\%(\%(def\s\|class\s\|@\)\s*\)\@<=\h\%(\w\|\.\)*" contained contains=pythonDunderMethod nextgroup=pythonFunctionVars

syn region pythonFunctionVars start="(" end=")" contained contains=pythonFunctionParameters transparent keepend
syn match  pythonFunctionParameters "[^,:]*" contained contains=pythonSelf,pythonAnnotation,pythonExtraOperator,pythonBuiltin,pythonConstant,pythonStatement,pythonNumber,pythonString,pythonBrackets skipwhite
syn match  pythonAnnotation ": [^,]*" contained contains=pythonSelf,pythonExtraOperator,pythonBuiltin,pythonConstant,pythonStatement,pythonNumber,pythonString,pythonBrackets skipwhite
syn match  pythonDunderMethod "\<__\(\w\)*__\>"

syn match  pythonFunctionCallKeywordParameter "\<\(\w\)*\>=" contains=pythonAssignmentOperator
syn match  pythonAssignmentOperator "=" contained contains=pythonExtraOperator

syn match  pythonConstant "\<[A-Z_0-9]*\>"

syn match   pythonComment	"#.*$" contains=pythonTodo,@Spell
syn keyword pythonTodo		FIXME NOTE NOTES TODO XXX contained

syn cluster pythonExpression contains=pythonStatement,pythonRepeat,pythonConditional,pythonNumber,pythonNumberError,pythonString,pythonParens,pythonBrackets,pythonOperator,pythonExtraOperator,pythonBuiltin,pythonDot,pythonComma,pythonColon

" Triple-quoted strings can contain doctests.
syn region  pythonBytes matchgroup=pythonQuotes
      \ start=+[bB]\=\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=pythonEscape,@Spell
syn region  pythonBytes matchgroup=pythonTripleQuotes
      \ start=+[bB]\=\z('''\|"""\)+ end="\z1" keepend
      \ contains=pythonEscape,pythonSpaceError,pythonDoctest,@Spell
syn region  pythonString matchgroup=pythonQuotes
      \ start=+[uU]\=\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=pythonEscape,@Spell
syn region  pythonString matchgroup=pythonTripleQuotes
      \ start=+[uU]\=\z('''\|"""\)+ end="\z1" keepend
      \ contains=pythonEscape,pythonSpaceError,pythonDoctest,@Spell
syn region  pythonFormatString matchgroup=pythonQuotes
      \ start=+[uU]\=[fF]\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=pythonEscape,@Spell
syn region  pythonFormatString matchgroup=pythonTripleQuotes
      \ start=+[uU]\=[fF]\z('''\|"""\)+ end="\z1" keepend
      \ contains=pythonEscape,pythonSpaceError,pythonDoctest,@Spell
syn region  pythonRawString matchgroup=pythonQuotes
      \ start=+[uU]\=[rR]\z(['"]\)+ end="\z1" skip="\\\\\|\\\z1"
      \ contains=@Spell
syn region  pythonRawString matchgroup=pythonTripleQuotes
      \ start=+[uU]\=[rR]\z('''\|"""\)+ end="\z1" keepend
      \ contains=pythonSpaceError,pythonDoctest,@Spell

syn match pythonStringFormat "{{\|}}" contained containedin=pythonString,pythonRawString,pythonFormatString
syn match pythonStringFormat "{\%(\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\d\+\)\=\%(\.\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\[\%(\d\+\|[^!:\}]\+\)\]\)*\%(![rsa]\)\=\%(:\%({\%(\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\d\+\)}\|\%([^}{]\=[<>=^]\)\=[ +-]\=#\=0\=\d*[_,]\=\%(\.\d\+\)\=[bcdeEfFgGnosxX%]\=\)\=\)\=}" contained containedin=pythonString,pythonRawString

syn region pythonStringReplacementField matchgroup=PythonFormatBraces start="{\@<!{{\@!" end="\%(![rsa]\)\=\%(:\%({\%(\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\d\+\)}\|\%([^}{]\=[<>=^]\)\=[ +-]\=#\=0\=\d*[_,]\=\%(\.\d\+\)\=[bcdeEfFgGnosxX%]\=\)\=\)\=}"hs=s-1,re=e-1 extend contained containedin=pythonFormatString contains=pythonStringReplacementField,pythonStringconversion,pythonStringFormatSpec,@pythonExpression

syn region pythonStringNestedReplacementField matchgroup=PythonFormatBraces start="{\@<!{{\@!" end="\%(![rsa]\)\=\%(:\%(\%([^}{]\=[<>=^]\)\=[ +-]\=#\=0\=\d*[_,]\=\%(\.\d\+\)\=[bcdeEfFgGnosxX%]\=\)\=\)\=}"hs=s-1,re=e-1 extend contained containedin=pythonFormatString contains=pythonStringReplacementField,pythonStringconversion,pythonStringFormatSpec,@pythonExpression

syn match pythonStringConversion "![rsa]" contained containedin=pythonStringReplacementField

syn match pythonStringFormatSpec ":\%({\%(\%([^[:cntrl:][:space:][:punct:][:digit:]]\|_\)\%([^[:cntrl:][:punct:][:space:]]\|_\)*\|\d\+\)}\|\%([^}{]\=[<>=^]\)\=[ +-]\=#\=0\=\d*[_,]\=\%(\.\d\+\)\=[bcdeEfFgGnosxX%]\=\)\=}\@=" extend contained containedin=pythonStringReplacementField contains=pythonStringNestedReplacementField

syn match   pythonEscape	+\\[abfnrtv'"\\]+ contained
syn match   pythonEscape	"\\\o\{1,3}" contained
syn match   pythonEscape	"\\x\x\{2}" contained
syn match   pythonEscape	"\%(\\u\x\{4}\|\\U\x\{8}\)" contained
" Python allows case-insensitive Unicode IDs: http://www.unicode.org/charts/
syn match   pythonEscape	"\\N{\a\+\%(\s\a\+\)*}" contained
syn match   pythonEscape	"\\$"

if exists("python_highlight_all")
  if exists("python_no_builtin_highlight")
    unlet python_no_builtin_highlight
  endif
  if exists("python_no_doctest_code_highlight")
    unlet python_no_doctest_code_highlight
  endif
  if exists("python_no_doctest_highlight")
    unlet python_no_doctest_highlight
  endif
  if exists("python_no_exception_highlight")
    unlet python_no_exception_highlight
  endif
  if exists("python_no_number_highlight")
    unlet python_no_number_highlight
  endif
  if exists("python_no_parameter_highlight")
    unlet python_no_parameter_highlight
  endif
  if exists("python_no_operator_highlight")
    unlet python_no_operator_highlight
  endif
  let python_self_cls_highlight = 1
  let python_space_error_highlight = 1
endif

" It is very important to understand all details before changing the
" regular expressions below or their order.
" The word boundaries are *not* the floating-point number boundaries
" because of a possible leading or trailing decimal point.
" The expressions below ensure that all valid number literals are
" highlighted, and invalid number literals are not.  For example,
"
" - a decimal point in '4.' at the end of a line is highlighted,
" - a second dot in 1.0.0 is not highlighted,
" - 08 is not highlighted,
" - 08e0 or 08j are highlighted,
"
" and so on, as specified in the 'Python Language Reference'.
" https://docs.python.org/2/reference/lexical_analysis.html#numeric-literals
" https://docs.python.org/3/reference/lexical_analysis.html#numeric-literals
if !exists("python_no_number_highlight")
  " numbers (including longs and complex)
  syn match   pythonNumberError	"\<0[xX]\x*[g-zG-Z]\x*\>" display
  syn match   pythonNumberError	"\<0[oO]\=\o*\D\+\d*\>" display
  syn match   pythonNumberError	"\<0[bB][01]*\D\+\d*\>" display

  syn match   pythonNumber	"\<0[xX][_0-9a-fA-F]*\x\>" display
  syn match   pythonNumber	"\<0[oO][_0-7]*\o\>" display
  syn match   pythonNumber	"\<0[bB][_01]*[01]\>" display

  syn match   pythonNumberError "\<\d[_0-9]*\D\>" display
  syn match   pythonNumberError "\<0[_0-9]\+\>" display
  syn match   pythonNumberError	"\<\d[_0-9]*_\>" display
  syn match   pythonNumber	"\<\d\>" display
  syn match   pythonNumber	"\<[1-9][_0-9]*\d\>" display
  syn match   pythonNumber	"\<\d[jJ]\>" display
  syn match   pythonNumber	"\<[1-9][_0-9]*\d[jJ]\>" display

  syn match   pythonNumberError	"\<0[oO]\=\o*[8-9]\d*\>" display
  syn match   pythonNumberError	"\<0[bB][01]*[2-9]\d*\>" display

  syn match   pythonNumber	"\.\d\%([_0-9]*\d\)\=\%([eE][+-]\=\d\%([_0-9]*\d\)\=\)\=[jJ]\=\>" display
  syn match   pythonNumber	"\<\d\%([_0-9]*\d\)\=[eE][+-]\=\d\%([_0-9]*\d\)\=[jJ]\=\>" display
  syn match   pythonNumber	"\<\d\%([_0-9]*\d\)\=\.\d\%([_0-9]*\d\)\=\%([eE][+-]\=\d\%([_0-9]*\d\)\=\)\=[jJ]\=" display


endif

" Group the built-ins in the order in the 'Python Library Reference' for
" easier comparison.
" https://docs.python.org/2/library/constants.html
" https://docs.python.org/3/library/constants.html
" http://docs.python.org/2/library/functions.html
" http://docs.python.org/3/library/functions.html
" http://docs.python.org/2/library/functions.html#non-essential-built-in-functions
" http://docs.python.org/3/library/functions.html#non-essential-built-in-functions
" Python built-in functions are in alphabetical order.
if !exists("python_no_builtin_highlight")
  " built-in constants
  " 'False', 'True', and 'None' are also reserved words in Python 3
  syn keyword pythonBuiltin	False True None
  syn keyword pythonBuiltin	NotImplemented Ellipsis __debug__

  syn keyword pythonBuiltinConstant	NotImplemented Ellipsis __debug__
  " different sub constant for customization
  syn keyword pythonBuiltinConstantSub	False True None
  " built-in functions
  syn keyword pythonBuiltin	abs all any bin bool bytearray callable chr
  syn keyword pythonBuiltin	classmethod compile complex delattr dict dir
  syn keyword pythonBuiltin	divmod enumerate eval filter float format
  syn keyword pythonBuiltin	frozenset getattr globals hasattr hash
  syn keyword pythonBuiltin	help hex id input int isinstance
  syn keyword pythonBuiltin	issubclass iter len list locals map max
  syn keyword pythonBuiltin	memoryview min next object oct open ord pow
  syn keyword pythonBuiltin	print property range repr reversed round set
  syn keyword pythonBuiltin	setattr slice sorted staticmethod str
  syn keyword pythonBuiltin	sum super tuple type vars zip __import__
  " Python 2 only
  syn keyword pythonBuiltin	basestring cmp execfile file
  syn keyword pythonBuiltin	long raw_input reduce reload unichr
  syn keyword pythonBuiltin	unicode xrange
  " Python 3 only
  syn keyword pythonBuiltin	ascii bytes exec
  " non-essential built-in functions; Python 2 only
  syn keyword pythonBuiltin	apply buffer coerce intern
  " avoid highlighting attributes as builtins
  " syn match   pythonAttribute	/\.\h\w*/hs=s+1 contains=ALLBUT,pythonBuiltin transparent
endif

" From the 'Python Library Reference' class hierarchy at the bottom.
" http://docs.python.org/2/library/exceptions.html
" http://docs.python.org/3/library/exceptions.html
if !exists("python_no_exception_highlight")
  " builtin base exceptions (used mostly as base classes for other exceptions)
  syn keyword pythonExceptions	BaseException Exception
  syn keyword pythonExceptions	ArithmeticError BufferError
  syn keyword pythonExceptions	LookupError
  " builtin base exceptions removed in Python 3
  syn keyword pythonExceptions	EnvironmentError StandardError
  " builtin exceptions (actually raised)
  syn keyword pythonExceptions	AssertionError AttributeError
  syn keyword pythonExceptions	EOFError FloatingPointError GeneratorExit
  syn keyword pythonExceptions	ImportError IndentationError
  syn keyword pythonExceptions	IndexError KeyError KeyboardInterrupt
  syn keyword pythonExceptions	MemoryError NameError NotImplementedError
  syn keyword pythonExceptions	OSError OverflowError ReferenceError
  syn keyword pythonExceptions	RuntimeError StopIteration SyntaxError
  syn keyword pythonExceptions	SystemError SystemExit TabError TypeError
  syn keyword pythonExceptions	UnboundLocalError UnicodeError
  syn keyword pythonExceptions	UnicodeDecodeError UnicodeEncodeError
  syn keyword pythonExceptions	UnicodeTranslateError ValueError
  syn keyword pythonExceptions	ZeroDivisionError
  " builtin OS exceptions in Python 3
  syn keyword pythonExceptions	BlockingIOError BrokenPipeError
  syn keyword pythonExceptions	ChildProcessError ConnectionAbortedError
  syn keyword pythonExceptions	ConnectionError ConnectionRefusedError
  syn keyword pythonExceptions	ConnectionResetError FileExistsError
  syn keyword pythonExceptions	FileNotFoundError InterruptedError
  syn keyword pythonExceptions	IsADirectoryError NotADirectoryError
  syn keyword pythonExceptions	PermissionError ProcessLookupError
  syn keyword pythonExceptions	RecursionError StopAsyncIteration
  syn keyword pythonExceptions	TimeoutError
  " builtin exceptions deprecated/removed in Python 3
  syn keyword pythonExceptions	IOError VMSError WindowsError
  " builtin warnings
  syn keyword pythonExceptions	BytesWarning DeprecationWarning FutureWarning
  syn keyword pythonExceptions	ImportWarning PendingDeprecationWarning
  syn keyword pythonExceptions	RuntimeWarning SyntaxWarning UnicodeWarning
  syn keyword pythonExceptions	UserWarning Warning
  " builtin warnings in Python 3
  syn keyword pythonExceptions	ResourceWarning
endif

if exists("python_space_error_highlight")
  " trailing whitespace
  syn match   pythonSpaceError	display excludenl "\s\+$"
  " mixed tabs and spaces
  syn match   pythonSpaceError	display " \+\t"
  syn match   pythonSpaceError	display "\t\+ "
endif

" Do not spell doctests inside strings.
" Notice that the end of a string, either ''', or """, will end the contained
" doctest too.  Thus, we do *not* need to have it as an end pattern.
if !exists("python_no_doctest_highlight")
  if !exists("python_no_doctest_code_highlight")
    syn region pythonDoctest
	  \ start="^\s*>>>\s" end="^\s*$"
	  \ contained contains=ALLBUT,pythonDoctest,@Spell
    syn region pythonDoctestValue
	  \ start=+^\s*\%(>>>\s\|\.\.\.\s\|"""\|'''\)\@!\S\++ end="$"
	  \ contained
  else
    syn region pythonDoctest
	  \ start="^\s*>>>" end="^\s*$"
	  \ contained contains=@NoSpell
  endif
endif

" Sync at the beginning of class, function, or method definition.
syn sync match pythonSync grouphere NONE "^\s*\%(def\|class\)\s\+\h\w*\s*("

if version >= 508 || !exists("did_python_syn_inits")
  if version <= 508
    let did_python_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " The default highlight links.  Can be overridden later.
  HiLink pythonStatement	      Statement
  HiLink pythonClassKeyword	      Statement
  HiLink pythonDefKeyword	      Statement
  HiLink pythonConditional	      Conditional
  HiLink pythonRepeat		      Repeat
  HiLink pythonOperator		      Operator
  HiLink pythonException	      Exception
  HiLink pythonInclude		      Statement
  HiLink pythonAsync		      Statement
  HiLink pythonDecorator	      Constant
  HiLink pythonComment		      Comment
  HiLink pythonTodo		      Todo
  HiLink pythonString		      String
  HiLink pythonRawString	      String
  HiLink pythonQuotes		      String
  HiLink pythonTripleQuotes	      pythonQuotes
  HiLink pythonEscape		      Special
  HiLink pythonConstant		      Number
  HiLink pythonBuiltinConstant	      Constant
  HiLink pythonBuiltinConstantSub     Number

  " Classes, Functions
  HiLink pythonClass		      Type
  HiLink pythonFunction		      Function

  HiLink pythonBytes		      String
  " String
  HiLink pythonFormatString	      String
  HiLink pythonStringFormat	      Special
  HiLink pythonStringConversion	      Special
  HiLink pythonStringFormatSpec	      Special

  if !exists("python_no_number_highlight")
    HiLink pythonNumber		      Number
    HiLink pythonNumberError	      Error
  endif
  if !exists("python_no_builtin_highlight")
    HiLink pythonBuiltin	      Function
    HiLink pythonDunderMethod	      Constant
  endif
  if !exists("python_no_exception_highlight")
    HiLink pythonExceptions	      Structure
  endif
  if exists("python_space_error_highlight")
    HiLink pythonSpaceError	      Error
  endif
  if !exists("python_no_doctest_highlight")
    HiLink pythonDoctest	      Special
    HiLink pythonDoctestValue	      Define
  endif

  if exists("python_self_cls_highlight")
    syn keyword pythonSelf self cls
    HiLink pythonSelf		      Type
  endif
  if !exists("python_no_operator_highlight")
    HiLink pythonExtraOperator	      Operator
    HiLink pythonExtraPseudoOperator  Operator
  endif
  if !exists("python_no_parameter_highlight")
    HiLink pythonBrackets	      Normal
    HiLink pythonClassParameters      Constant
    HiLink pythonFunctionParameters   Number
  endif

  delcommand HiLink
endif

let b:current_syntax = "python"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim:set sw=2 sts=2 ts=8 noet:
