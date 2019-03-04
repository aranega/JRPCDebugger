Class {
	#name : #JRPCDebugger,
	#superclass : #Object,
	#instVars : [
		'debugContext',
		'debugSession',
		'process',
		'session',
		'jrpcServer'
	],
	#category : #JRPCDebugger
}

{ #category : #adding }
JRPCDebugger >> addEchoHandler [
	"For debugging purpose."
	jrpcServer
		addHandlerNamed: 'echo' block: [ :o | o asString ]
]

{ #category : #actions }
JRPCDebugger >> currentMethodNode [
	^ session context method ast
]

{ #category : #actions }
JRPCDebugger >> currentMethodSource [
	^ self currentMethodNode source
]

{ #category : #actions }
JRPCDebugger >> currentNode [
	| pc |
	pc := session context pc.
	^ self currentMethodNode sourceNodeExecutedForPC: pc.
]

{ #category : #actions }
JRPCDebugger >> debug: processHash [
	| method pc start stop |
	process := self processWithHash: processHash.
	session := process
		newDebugSessionNamed: 'test session'
		startedAt: process suspendedContext.
	method := session context method.
	pc := session context pc.
	start := (method ast sourceNodeExecutedForPC: pc) start.
	stop := (method ast sourceNodeExecutedForPC: pc) stop.
	^ JRPCDLineInfo start: start end: stop source: method sourceCode
]

{ #category : #accessing }
JRPCDebugger >> debugContext [
	^ debugContext
]

{ #category : #accessing }
JRPCDebugger >> debugContext: anObject [
	debugContext := anObject
]

{ #category : #accessing }
JRPCDebugger >> debugSession [
	^ debugSession
]

{ #category : #accessing }
JRPCDebugger >> debugSession: anObject [
	debugSession := anObject
]

{ #category : #actions }
JRPCDebugger >> display [
	| method pc start stop |
	method := session context method.
	pc := session context pc.
	start := (method ast sourceNodeExecutedForPC: pc) start.
	stop := (method ast sourceNodeExecutedForPC: pc) stop.
	^ JRPCDLineInfo start: start end: stop source: method sourceCode
]

{ #category : #actions }
JRPCDebugger >> evaluate: aString [
	^ JRPCDEvalInfo result: (Smalltalk compiler source: aString; context: session context; receiver: session context receiver; evaluate).
]

{ #category : #actions }
JRPCDebugger >> init [
	| context |
	context := [ | x |
	x := 5 + 1.
	'lalala' logCr ] asContext.
	process := Process 
	    forContext: context 
	    priority: Processor userInterruptPriority.
	session := process newDebugSessionNamed: 'test session' startedAt: context.
	
	^ self lineInfo 
]

{ #category : #initialization }
JRPCDebugger >> initialize [
	super initialize.
	jrpcServer := JRPCServer http
						port: 4000;
						addHandlerNamed: 'initialize' block: [ self init ];
						addHandlerNamed: 'display' block: [ self display ];
						addHandlerNamed: 'resume' block: [ self resume ];
						addHandlerNamed: 'evaluate' block: [ :expression | self evaluate: expression ];
						addHandlerNamed: 'nextStatement' block: [ self nextStatement ];
						addHandlerNamed: 'next' block: [ self next ];
						addHandlerNamed: 'step' block: [ self step ];
						addHandlerNamed: 'list' block: [ self listProcesses ];
						addHandlerNamed: 'debug' block: [ :processHash | self debug: processHash ];
						yourself
]

{ #category : #actions }
JRPCDebugger >> lineInfo [
	| range |
	range := session pcRangeForContext: session context.
	^ JRPCDLineInfo
		start: range first
		end: range last
		source: self currentMethodSource
]

{ #category : #actions }
JRPCDebugger >> listProcesses [
	| processList |
	self flag: 'To be moved to the JRPC debuggers manager'.

	^ { 'processes' -> (self processes collect: [ :proc |
		{ 'string' -> proc printString. 'hash' -> proc hash } asDictionary ]) asArray } asDictionary
]

{ #category : #actions }
JRPCDebugger >> next [
	session stepOver.
	^ self lineInfo 
]

{ #category : #actions }
JRPCDebugger >> nextStatement [
	| node |
	node := self currentNode.
	[ node isKindOf: RBSequenceNode ]
		whileFalse: [ session stepOver.
			node := node parent ].
	^ self lineInfo
]

{ #category : #private }
JRPCDebugger >> processWithHash: anInteger [
	^ self processes detect: [ :p | p hash = anInteger ]
]

{ #category : #private }
JRPCDebugger >> processes [
	Smalltalk garbageCollectMost. "lose defunct processes"
	
	^ Process allSubInstances reject: [:each | each isTerminated]
]

{ #category : #actions }
JRPCDebugger >> resume [
	session resume.
	^ 'Execution terminated'
]

{ #category : #actions }
JRPCDebugger >> session [
	^ session
]

{ #category : #accessing }
JRPCDebugger >> start [
	jrpcServer start
]

{ #category : #actions }
JRPCDebugger >> step [
	session stepInto.
	^ self lineInfo 
]

{ #category : #accessing }
JRPCDebugger >> stop [
	jrpcServer stop
]
