Class {
	#name : #JRPCDLineInfo,
	#superclass : #Object,
	#instVars : [
		'start',
		'end',
		'source'
	],
	#category : #JRPCDebugger
}

{ #category : #'instance creation' }
JRPCDLineInfo class >> start: start end: end source: source [
	^ self new
		start: start;
		end: end;
		source: source;
		yourself
]

{ #category : #converting }
JRPCDLineInfo >> asJRPCJSON [
	^ { 
		'start' -> self start.
		'stop' -> self end.
		'source' -> self source
	} asDictionary
]

{ #category : #accessing }
JRPCDLineInfo >> end [
	^ end
]

{ #category : #accessing }
JRPCDLineInfo >> end: anObject [
	end := anObject
]

{ #category : #accessing }
JRPCDLineInfo >> source [
	^ source
]

{ #category : #accessing }
JRPCDLineInfo >> source: anObject [
	source := anObject
]

{ #category : #accessing }
JRPCDLineInfo >> start [
	^ start
]

{ #category : #accessing }
JRPCDLineInfo >> start: anObject [
	start := anObject
]
